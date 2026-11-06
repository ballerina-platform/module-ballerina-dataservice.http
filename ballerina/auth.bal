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

const CALLER = "dataservice.http.caller";

# Authenticates each request of a data service with auth and checks the scopes of its operation, before
# `ballerina/http` dispatches the request and binds its parameters.
public isolated class Authenticator {
    private final AuthHandler[] handlers = [];
    private final readonly & string[] oauth2ScopeKeys;
    private final readonly & map<map<string[]>> scopes;

    # Checks the authentication providers and creates their handlers.
    #
    # + providers - The value of `dataserviceConfig.serviceConfig.auth`
    # + scopes - The scopes of each operation, by collection and then by HTTP method
    # + return - An error when there is no provider
    public isolated function init(http:ListenerAuthConfig[] providers, map<map<string[]>> scopes) returns error? {
        if providers.length() == 0 {
            return error("The configurable value 'dataserviceConfig.serviceConfig.auth' must hold at least one " +
                "authentication provider.");
        }
        string[] oauth2ScopeKeys = [];
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
                self.handlers.push(handler);
            }
            oauth2ScopeKeys.push(provider is http:OAuth2IntrospectionConfigWithScopes ?
                provider.oauth2IntrospectionConfig.scopeKey : "");
        }
        self.oauth2ScopeKeys = oauth2ScopeKeys.cloneReadOnly();
        self.scopes = scopes.cloneReadOnly();
    }

    # Authenticates the request, keeps the caller in the request context, and checks that the caller holds a scope
    # of the operation. An `OPTIONS` request, such as a CORS preflight, is passed on without a credential.
    #
    # + ctx - The request context
    # + request - The request
    # + path - The request's path, relative to the service
    # + return - The next service, `Unauthorized` without a valid credential, or `Forbidden` without a scope
    public isolated function authorize(http:RequestContext ctx, http:Request request, string[] path)
            returns http:NextService|Unauthorized|Forbidden|error? {
        if request.method == http:OPTIONS {
            return ctx.next();
        }
        Caller? caller = self.authenticate(request);
        if caller is () {
            return <Unauthorized>{body: dataservice:unauthenticated()};
        }
        ctx.set(CALLER, caller);
        string[]? scopes = path.length() == 0 ? () : self.scopes[path[0]][request.method];
        if scopes is string[] && scopes.length() > 0 && !caller.hasScope(scopes) {
            return <Forbidden>{body: dataservice:noScope()};
        }
        return ctx.next();
    }

    // The handlers are tried in the order of the providers, as `ballerina/http` does, and the first that
    // authenticates the credential decides.
    isolated function authenticate(http:Request request) returns Caller? {
        int count;
        lock {
            count = self.handlers.length();
        }
        foreach int i in 0 ..< count {
            AuthHandler handler;
            lock {
                handler = self.handlers[i];
            }
            if handler is http:ListenerFileUserStoreBasicAuthHandler {
                auth:UserDetails|http:Unauthorized user = handler.authenticate(request);
                if user is auth:UserDetails {
                    return new (handler, user.cloneReadOnly());
                }
            } else if handler is http:ListenerLdapUserStoreBasicAuthHandler {
                auth:UserDetails|http:Unauthorized user = handler->authenticate(request);
                if user is auth:UserDetails {
                    return new (handler, user.cloneReadOnly());
                }
            } else if handler is http:ListenerJwtAuthHandler {
                jwt:Payload|http:Unauthorized payload = handler.authenticate(request);
                if payload !is http:Unauthorized {
                    // `jwt:Payload` is an open record, so the check above does not narrow `payload`.
                    return new (handler, (<jwt:Payload>payload).cloneReadOnly());
                }
            } else if handler is http:ListenerOAuth2Handler {
                oauth2:IntrospectionResponse|http:Unauthorized|http:Forbidden response = handler->authorize(request);
                if response is oauth2:IntrospectionResponse {
                    return new (self.oauth2ScopeKeys[i], response.cloneReadOnly());
                }
            }
        }
        return ();
    }
}

// The authenticated caller of a request. Its scopes are checked as the handler that authenticated it checks them.
isolated class Caller {
    private final AuthHandler|string authority;
    private final readonly & (auth:UserDetails|jwt:Payload|oauth2:IntrospectionResponse) details;

    isolated function init(AuthHandler|string authority,
            readonly & (auth:UserDetails|jwt:Payload|oauth2:IntrospectionResponse) details) {
        self.authority = authority;
        self.details = details;
    }

    isolated function hasScope(string[] scopes) returns boolean {
        AuthHandler|string authority = self.authority;
        readonly & (auth:UserDetails|jwt:Payload|oauth2:IntrospectionResponse) details = self.details;
        if authority is http:ListenerFileUserStoreBasicAuthHandler {
            return authority.authorize(<auth:UserDetails>details, scopes) is ();
        }
        if authority is http:ListenerLdapUserStoreBasicAuthHandler {
            http:Forbidden? refused = authority->authorize(<auth:UserDetails>details, scopes);
            return refused is ();
        }
        if authority is http:ListenerJwtAuthHandler {
            return authority.authorize(<jwt:Payload>details, scopes) is ();
        }
        // As `http:ListenerOAuth2Handler` does, the scope claim is a space-separated string.
        anydata held = (<oauth2:IntrospectionResponse>details)[<string>authority];
        if held !is string {
            return false;
        }
        string[] heldScopes = re ` `.split(held);
        foreach string scope in scopes {
            if heldScopes.indexOf(scope) !is () {
                return true;
            }
        }
        return false;
    }
}

# Tells whether the caller of the request holds one of the scopes.
#
# + ctx - The request context, in which `Authenticator` keeps the caller
# + scopes - The scopes
# + return - Whether the caller holds one of them; `false` when the request was not authenticated
public isolated function hasScope(http:RequestContext ctx, string[] scopes) returns boolean {
    if !ctx.hasKey(CALLER) {
        return false;
    }
    http:ReqCtxMember caller = ctx.get(CALLER);
    return caller is Caller && caller.hasScope(scopes);
}

# Checks that the caller may read a related entity, for a relation whose `read` scopes the entity's do not cover.
#
# + ctx - The request context, in which `Authenticator` keeps the caller
# + entity - The name of the entity
# + relation - The relation field
# + target - The name of the related entity
# + scopes - The `read` scopes of the related entity
# + return - `Forbidden` when the caller holds none of the scopes, or `()`
public isolated function checkRelationScopes(http:RequestContext ctx, string entity, string relation, string target,
        string[] scopes) returns Forbidden? {
    return hasScope(ctx, scopes) ? () : {body: dataservice:forbidden(entity, relation, target)};
}
