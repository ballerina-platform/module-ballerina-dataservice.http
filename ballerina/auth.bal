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
const WWW_AUTHENTICATE = "WWW-Authenticate";
const BASIC_CHALLENGE = http:AUTH_SCHEME_BASIC + " realm=\"dataservice\"";
const BEARER_CHALLENGE = http:AUTH_SCHEME_BEARER + " realm=\"dataservice\"";

final string:RegExp SPACE = re ` `;
final string:RegExp WHITESPACE = re `\s`;

# Authenticates each request of a data service with auth and checks the scopes of its operation, before
# `ballerina/http` dispatches the request and binds its parameters.
public isolated class Authenticator {
    private final Provider[] providers = [];
    private final readonly & map<map<string[]>> scopes;
    private final readonly & string[] challenges;
    private final readonly & http:CorsConfig cors;

    # Checks the authentication providers and creates their handlers.
    #
    # + providers - The value of `dataserviceConfig.serviceConfig.auth`
    # + scopes - The scopes of each operation, by collection and then by HTTP method
    # + cors - The service's CORS settings, applied to the `401` and `403` responses
    # + return - An error when there is no provider
    public isolated function init(http:ListenerAuthConfig[] providers, map<map<string[]>> scopes,
            http:CorsConfig cors = {}) returns error? {
        if providers.length() == 0 {
            return error("The configurable value 'dataserviceConfig.serviceConfig.auth' must hold at least one " +
                "authentication provider.");
        }
        string[] challenges = [];
        foreach http:ListenerAuthConfig provider in providers {
            boolean basic = provider is http:FileUserStoreConfigWithScopes|http:LdapUserStoreConfigWithScopes;
            string challenge = basic ? BASIC_CHALLENGE : BEARER_CHALLENGE;
            if challenges.indexOf(challenge) is () {
                challenges.push(challenge);
            }
            AuthHandler handler;
            string scopeKey = "";
            if provider is http:FileUserStoreConfigWithScopes {
                handler = new http:ListenerFileUserStoreBasicAuthHandler(provider.fileUserStoreConfig);
            } else if provider is http:LdapUserStoreConfigWithScopes {
                handler = new http:ListenerLdapUserStoreBasicAuthHandler(provider.ldapUserStoreConfig.cloneReadOnly());
            } else if provider is http:JwtValidatorConfigWithScopes {
                handler = new http:ListenerJwtAuthHandler(provider.jwtValidatorConfig.cloneReadOnly());
            } else {
                handler = new http:ListenerOAuth2Handler(provider.oauth2IntrospectionConfig.cloneReadOnly());
                scopeKey = provider.oauth2IntrospectionConfig.scopeKey;
            }
            string|string[]? configured = provider?.scopes;
            readonly & string[]? providerScopes;
            if configured is string {
                providerScopes = [configured];
            } else {
                providerScopes = configured.cloneReadOnly();
            }
            lock {
                self.providers.push({
                    handler,
                    scheme: basic ? http:AUTH_SCHEME_BASIC : http:AUTH_SCHEME_BEARER,
                    scopeKey,
                    scopes: providerScopes
                });
            }
        }
        self.scopes = scopes.cloneReadOnly();
        self.challenges = challenges.cloneReadOnly();
        self.cors = cors.cloneReadOnly();
    }

    # Authenticates the request, keeps the caller in the request context, and checks that the caller holds a scope
    # of the operation, or, for an operation without scopes, a scope of the provider that authenticated it. An
    # `OPTIONS` request, such as a CORS preflight, is passed on without a credential.
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
            map<string|string[]> headers = self.corsHeaders(request);
            headers[WWW_AUTHENTICATE] = self.challenges;
            return <Unauthorized>{headers, body: dataservice:toUnauthenticatedError()};
        }
        ctx.set(CALLER, caller);
        string[]? scopes = path.length() == 0 ? () : self.scopes[path[0]][request.method];
        if !caller.isAllowed(scopes ?: []) {
            return <Forbidden>{headers: self.corsHeaders(request), body: dataservice:toNoScopeError()};
        }
        return ctx.next();
    }

    // `ballerina/http` adds the CORS headers only to the responses of a resource, so the responses of the request
    // interceptor get them here, as `ballerina/http` sets them for a simple cross-origin request.
    isolated function corsHeaders(http:Request request) returns map<string|string[]> {
        string|http:HeaderNotFoundError origin = request.getHeader("Origin");
        if origin is http:HeaderNotFoundError {
            return {};
        }
        string[] origins = from string value in SPACE.split(origin) where value.includes("://") select value;
        string[] allowed = self.cors.allowOrigins;
        boolean anyOrigin = allowed.length() == 1 && allowed[0] == "*";
        if origins.length() == 0 {
            return {};
        }
        foreach string value in origins {
            if !anyOrigin && allowed.indexOf(value) is () {
                return {};
            }
        }
        map<string|string[]> headers = {"Access-Control-Allow-Origin": string:'join(" ", ...origins)};
        if self.cors.allowCredentials {
            headers["Access-Control-Allow-Credentials"] = "true";
        }
        if self.cors.exposeHeaders.length() > 0 {
            headers["Access-Control-Expose-Headers"] = string:'join(", ", ...self.cors.exposeHeaders);
        }
        return headers;
    }

    // As `ballerina/http` does, a `Basic` credential is tried only with the user stores and a `Bearer` credential
    // only with the JWT and OAuth2 providers, in the order of the providers, and the first that authenticates the
    // credential decides.
    isolated function authenticate(http:Request request) returns Caller? {
        string|http:HeaderNotFoundError header = request.getHeader("Authorization");
        if header is http:HeaderNotFoundError {
            return ();
        }
        string scheme = WHITESPACE.split(header)[0];
        int count;
        lock {
            count = self.providers.length();
        }
        foreach int i in 0 ..< count {
            AuthHandler handler;
            string providerScheme;
            string scopeKey;
            readonly & string[]? providerScopes;
            lock {
                Provider provider = self.providers[i];
                handler = provider.handler;
                providerScheme = provider.scheme;
                scopeKey = provider.scopeKey;
                providerScopes = provider.scopes;
            }
            if providerScheme != scheme {
                continue;
            }
            if handler is http:ListenerFileUserStoreBasicAuthHandler {
                auth:UserDetails|http:Unauthorized user = handler.authenticate(request);
                if user is auth:UserDetails {
                    return new (handler, scopeKey, user.cloneReadOnly(), providerScopes);
                }
            } else if handler is http:ListenerLdapUserStoreBasicAuthHandler {
                auth:UserDetails|http:Unauthorized user = handler->authenticate(request);
                if user is auth:UserDetails {
                    return new (handler, scopeKey, user.cloneReadOnly(), providerScopes);
                }
            } else if handler is http:ListenerJwtAuthHandler {
                jwt:Payload|http:Unauthorized payload = handler.authenticate(request);
                if payload !is http:Unauthorized {
                    // `jwt:Payload` is an open record, so the check above does not narrow `payload`.
                    return new (handler, scopeKey, (<jwt:Payload>payload).cloneReadOnly(), providerScopes);
                }
            } else if handler is http:ListenerOAuth2Handler {
                oauth2:IntrospectionResponse|http:Unauthorized|http:Forbidden response = handler->authorize(request);
                if response is oauth2:IntrospectionResponse {
                    return new (handler, scopeKey, response.cloneReadOnly(), providerScopes);
                }
            }
        }
        return ();
    }
}

type Provider record {|
    AuthHandler handler;
    string scheme;
    // The scope claim of an OAuth2 introspection response.
    string scopeKey;
    readonly & string[]? scopes;
|};

// The authenticated caller of a request. Its scopes are checked as the handler that authenticated it checks them.
isolated class Caller {
    private final AuthHandler handler;
    private final string scopeKey;
    private final readonly & (auth:UserDetails|jwt:Payload|oauth2:IntrospectionResponse) details;
    private final readonly & string[]? providerScopes;

    isolated function init(AuthHandler handler, string scopeKey,
            readonly & (auth:UserDetails|jwt:Payload|oauth2:IntrospectionResponse) details,
            readonly & string[]? providerScopes) {
        self.handler = handler;
        self.scopeKey = scopeKey;
        self.details = details;
        self.providerScopes = providerScopes;
    }

    // An empty list takes the provider's scopes, as `ballerina/http` applies a service's scopes to a resource
    // without scopes of its own; without those, the credential alone is enough.
    isolated function isAllowed(string[] scopes) returns boolean {
        string[]? required = scopes.length() > 0 ? scopes : self.providerScopes;
        return required is () || required.length() == 0 || self.hasScope(required);
    }

    isolated function hasScope(string[] scopes) returns boolean {
        AuthHandler handler = self.handler;
        readonly & (auth:UserDetails|jwt:Payload|oauth2:IntrospectionResponse) details = self.details;
        if handler is http:ListenerFileUserStoreBasicAuthHandler {
            return handler.authorize(<auth:UserDetails>details, scopes) is ();
        }
        if handler is http:ListenerLdapUserStoreBasicAuthHandler {
            http:Forbidden? refused = handler->authorize(<auth:UserDetails>details, scopes);
            return refused is ();
        }
        if handler is http:ListenerJwtAuthHandler {
            return handler.authorize(<jwt:Payload>details, scopes) is ();
        }
        // As `http:ListenerOAuth2Handler` does, the scope claim is a space-separated string.
        anydata held = (<oauth2:IntrospectionResponse>details)[self.scopeKey];
        if held !is string {
            return false;
        }
        string[] heldScopes = SPACE.split(held);
        foreach string scope in scopes {
            if heldScopes.indexOf(scope) !is () {
                return true;
            }
        }
        return false;
    }
}

# Tells whether the caller of the request holds one of the scopes. An empty list takes the scopes of the provider
# that authenticated the caller, and holds when the provider sets none.
#
# + ctx - The request context, in which `Authenticator` keeps the caller
# + scopes - The scopes
# + return - Whether the caller holds one of them; `false` when the request was not authenticated
public isolated function hasScope(http:RequestContext ctx, string[] scopes) returns boolean {
    if !ctx.hasKey(CALLER) {
        return false;
    }
    http:ReqCtxMember caller = ctx.get(CALLER);
    return caller is Caller && caller.isAllowed(scopes);
}

# Checks that the caller may read a related entity.
#
# + ctx - The request context, in which `Authenticator` keeps the caller
# + entity - The name of the entity
# + relation - The relation field
# + target - The name of the related entity
# + scopes - The `read` scopes of the related entity
# + return - `Forbidden` when the caller holds none of the scopes, or `()`
public isolated function checkRelationScopes(http:RequestContext ctx, string entity, string relation, string target,
        string[] scopes) returns Forbidden? {
    return hasScope(ctx, scopes) ? () : {body: dataservice:toForbiddenError(entity, relation, target)};
}
