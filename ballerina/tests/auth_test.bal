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

@test:Config
function testAuthConfig() returns error? {
    http:ListenerAuthConfig[] providers = [{fileUserStoreConfig: {}}];
    test:assertEquals(check authConfig(providers), providers);
    http:ListenerAuthConfig[]|error empty = authConfig([]);
    test:assertTrue(empty is error);
    if empty is error {
        test:assertEquals(empty.message(),
                "The configurable value 'dataserviceConfig.auth' must hold at least one authentication provider.");
    }
}

@test:Config
function testForbiddenStatus() {
    Forbidden response = {body: dataservice:forbidden("Employee", "department", "Department")};
    test:assertEquals(response.status.code, 403);
    test:assertEquals(response.body.code, dataservice:FORBIDDEN);
}

@test:Config {dependsOn: [testAuthConfig]}
function testAuthorizeRelation() returns error? {
    _ = check authConfig([
        {fileUserStoreConfig: {}},
        {jwtValidatorConfig: {issuer: "dataservice", signatureConfig: {secret: JWT_SECRET}}}
    ]);
    test:assertEquals(authorizeRelation(basic("reader", "reader-pass"), "Employee", "department", "Department",
            ["departments:read"]), ());
    test:assertEquals(authorizeRelation(check bearer("departments:read"), "Employee", "department", "Department",
            ["hr:read", "departments:read"]), ());
    assertForbidden(authorizeRelation(basic("guest", "guest-pass"), "Employee", "department", "Department",
            ["departments:read"]));
    assertForbidden(authorizeRelation(check bearer("employees:read"), "Employee", "department", "Department",
            ["departments:read"]));
    assertForbidden(authorizeRelation(basic("reader", "wrong"), "Employee", "department", "Department",
            ["departments:read"]));
    assertForbidden(authorizeRelation(new, "Employee", "department", "Department", ["departments:read"]));
}

function assertForbidden(Forbidden? response) {
    if response is () {
        test:assertFail("expected Forbidden");
    }
    test:assertEquals(response.body, dataservice:forbidden("Employee", "department", "Department"));
}

function basic(string username, string password) returns http:Request {
    http:Request request = new;
    request.setHeader("Authorization", "Basic " + array:toBase64(string `${username}:${password}`.toBytes()));
    return request;
}

function bearer(string scope) returns http:Request|error {
    string token = check jwt:issue({
        issuer: "dataservice",
        username: "caller",
        customClaims: {scope},
        signatureConfig: {algorithm: jwt:HS256, config: JWT_SECRET}
    });
    http:Request request = new;
    request.setHeader("Authorization", "Bearer " + token);
    return request;
}
