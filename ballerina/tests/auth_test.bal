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

import ballerina/dataservice;
import ballerina/http;
import ballerina/jwt;
import ballerina/lang.array;
import ballerina/test;

const JWT_SECRET = "dataservice-test-secret";

// An OAuth2 introspection endpoint that knows one active token.
service /oauth2 on new http:Listener(9593) {
    resource function post introspect(http:Request request) returns json|error {
        map<string> form = check request.getFormParams();
        return form["token"] == "departments-token" ? {active: true, scope: "hr:read departments:read"} :
            {active: false};
    }
}

final Authenticator scopeAuthenticator = check new ([
    {fileUserStoreConfig: {}},
    {jwtValidatorConfig: {issuer: "dataservice", signatureConfig: {secret: JWT_SECRET}}},
    {oauth2IntrospectionConfig: {url: "http://localhost:9593/oauth2/introspect"}}
], {});

isolated service class ScopeInterceptor {
    *http:RequestInterceptor;

    isolated resource function 'default [string... path](http:RequestContext ctx, http:Request request)
            returns http:NextService|Unauthorized|Forbidden|error? => scopeAuthenticator.authorize(ctx, request, path);
}

service http:InterceptableService /scopes on new http:Listener(9592) {

    public function createInterceptors() returns ScopeInterceptor => new;

    resource function get has(http:RequestContext ctx, string scope) returns boolean => hasScope(ctx, [scope]);

    resource function get relation(http:RequestContext ctx, string scope) returns Forbidden? =>
        checkRelationScopes(ctx, "Employee", "department", "Department", [scope]);
}

@test:Config
function testAuthenticatorNeedsAProvider() {
    Authenticator|error empty = new ([], {});
    if empty !is error {
        test:assertFail("expected an error");
    }
    test:assertEquals(empty.message(), "The configurable value 'dataserviceConfig.serviceConfig.auth' must hold at " +
            "least one authentication provider.");
}

@test:Config {dataProvider: callers}
function testHasScope(string authorization, string scope, boolean expected) returns error? {
    http:Client c = check new ("http://localhost:9592/scopes");
    http:Response response = check c->get(string `/has?scope=${scope}`, {"Authorization": authorization});
    test:assertEquals(check response.getJsonPayload(), expected, authorization);
}

@test:Config {dataProvider: callers}
function testCheckRelationScopes(string authorization, string scope, boolean expected) returns error? {
    http:Client c = check new ("http://localhost:9592/scopes");
    http:Response response = check c->get(string `/relation?scope=${scope}`, {"Authorization": authorization});
    if expected {
        test:assertEquals(response.statusCode, 202, authorization);
        return;
    }
    test:assertEquals(response.statusCode, 403, authorization);
    test:assertEquals(check response.getJsonPayload(), dataservice:forbidden("Employee", "department", "Department"));
}

function callers() returns [string, string, boolean][]|error => [
    [basic("reader", "reader-pass"), "departments:read", true],
    [basic("guest", "guest-pass"), "departments:read", false],
    [check bearer("departments:read"), "departments:read", true],
    [check bearer("employees:read"), "departments:read", false],
    ["Bearer departments-token", "departments:read", true],
    ["Bearer departments-token", "hr:admin", false]
];

@test:Config
function testInvalidCredentialIsUnauthenticated() returns error? {
    http:Client c = check new ("http://localhost:9592/scopes");
    foreach string authorization in [basic("reader", "wrong"), "Bearer inactive-token", "Bearer not-a-jwt"] {
        http:Response response = check c->get("/has?scope=departments:read", {"Authorization": authorization});
        test:assertEquals(response.statusCode, 401, authorization);
        test:assertEquals(check response.getJsonPayload(), dataservice:unauthenticated());
    }
}

function basic(string username, string password) returns string =>
    "Basic " + array:toBase64(string `${username}:${password}`.toBytes());

function bearer(string scope) returns string|error {
    string token = check jwt:issue({
        issuer: "dataservice",
        username: "caller",
        customClaims: {scope},
        signatureConfig: {algorithm: jwt:HS256, config: JWT_SECRET}
    });
    return "Bearer " + token;
}
