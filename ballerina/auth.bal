// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/auth;
import ballerina/dataservice;
import ballerina/http;
import ballerina/jwt;
import ballerina/oauth2;

type AuthHandler http:ListenerFileUserStoreBasicAuthHandler|http:ListenerLdapUserStoreBasicAuthHandler
    |http:ListenerJwtAuthHandler|http:ListenerOAuth2Handler;

isolated AuthHandler[] authHandlers = [];

# Checks the authentication providers that a data service with auth is configured with, and creates the handlers
# that `authorizeRelation` and `holdsScope` check a credential with.
#
# + providers - The value of `dataserviceConfig.serviceConfig.auth`
# + return - The providers, or an error when there is none
public isolated function authProviders(http:ListenerAuthConfig[] providers)
        returns http:ListenerAuthConfig[]|error {
    if providers.length() == 0 {
        return error("The configurable value 'dataserviceConfig.serviceConfig.auth' must hold at least one " +
            "authentication provider.");
    }
    lock {
        authHandlers.removeAll();
    }
    foreach http:ListenerAuthConfig provider in providers {
        AuthHandler handler;
        if provider is http:FileUserStoreConfigWithScopes {
            handler = new http:ListenerFileUserStoreBasicAuthHandler(provider.fileUserStoreConfig);
        } else if provider is http:LdapUserStoreConfigWithScopes {
            handler = new http:ListenerLdapUserStoreBasicAuthHandler(provider.ldapUserStoreConfig.cloneReadOnly());
        } else if provider is http:JwtValidatorConfigWithScopes {
            handler = new http:ListenerJwtAuthHandler(provider.jwtValidatorConfig.cloneReadOnly());
        } else {
            handler = new http:ListenerOAuth2Handler(provider.oauth2IntrospectionConfig.cloneReadOnly());
        }
        lock {
            authHandlers.push(handler);
        }
    }
    return providers;
}

# Checks that the caller may read a related entity, for a relation whose `read` scopes the entity's do not cover.
#
# + request - The request
# + entity - The name of the entity
# + relation - The relation field
# + target - The name of the related entity
# + scopes - The `read` scopes of the related entity
# + return - `Forbidden` when the request's credential holds none of the scopes, or `()`
public isolated function authorizeRelation(http:Request request, string entity, string relation, string target,
        string[] scopes) returns Forbidden? {
    return holdsScope(request, scopes) ? () : {body: dataservice:forbidden(entity, relation, target)};
}

# Tells whether the request's credential holds one of the scopes, as the service's authentication providers check it.
#
# + request - The request
# + scopes - The scopes
# + return - Whether the credential holds one of them; `false` when no provider authenticates it
public isolated function holdsScope(http:Request request, string[] scopes) returns boolean {
    int count;
    lock {
        count = authHandlers.length();
    }
    // The handlers are tried in the order of the providers, as `ballerina/http` does, and the first that
    // authenticates the credential decides.
    foreach int i in 0 ..< count {
        AuthHandler handler;
        lock {
            handler = authHandlers[i];
        }
        if handler is http:ListenerFileUserStoreBasicAuthHandler {
            auth:UserDetails|http:Unauthorized user = handler.authenticate(request);
            if user is http:Unauthorized {
                continue;
            }
            return handler.authorize(user, scopes) is ();
        } else if handler is http:ListenerLdapUserStoreBasicAuthHandler {
            auth:UserDetails|http:Unauthorized user = handler->authenticate(request);
            if user is http:Unauthorized {
                continue;
            }
            http:Forbidden? refused = handler->authorize(user, scopes);
            return refused is ();
        } else if handler is http:ListenerJwtAuthHandler {
            jwt:Payload|http:Unauthorized payload = handler.authenticate(request);
            if payload is http:Unauthorized {
                continue;
            }
            // `jwt:Payload` is an open record, so the check above does not narrow `payload`.
            return handler.authorize(<jwt:Payload>payload, scopes) is ();
        } else if handler is http:ListenerOAuth2Handler {
            oauth2:IntrospectionResponse|http:Unauthorized|http:Forbidden result = handler->authorize(request, scopes);
            if result is http:Unauthorized {
                continue;
            }
            return result !is http:Forbidden;
        }
    }
    return false;
}
