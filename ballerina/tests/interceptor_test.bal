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
import ballerina/test;

type Item record {|
    int id;
    string name;
|};

final Authenticator itemAuthenticator = check new ([{fileUserStoreConfig: {}}], {"items": {"GET": ["departments:read"]}});

// The interceptors a generated service defines in its own package.
isolated service class ItemAuthInterceptor {
    *http:RequestInterceptor;

    isolated resource function 'default [string... path](http:RequestContext ctx, http:Request request)
            returns http:NextService|Unauthorized|Forbidden|error? => itemAuthenticator.authorize(ctx, request, path);
}

isolated service class ItemErrorInterceptor {
    *http:ResponseErrorInterceptor;

    isolated remote function interceptResponseError(error err, http:RequestContext ctx, http:Response response)
            returns http:NextService? {
        setErrorBody(response, err);
        http:NextService|error? next = ctx.next();
        return next is http:NextService ? next : ();
    }
}

@http:ServiceConfig {cors: {allowOrigins: ["https://app.example.com"]}}
service http:InterceptableService /api on new http:Listener(9591) {

    public function createInterceptors() returns [ItemAuthInterceptor, ItemErrorInterceptor] => [new, new];

    resource function get items/[int id](int? size = ()) returns Item => {id, name: "a"};

    resource function post items(Item payload) returns Item => payload;
}

final http:Client readerClient = check new ("http://localhost:9591/api",
    auth = {username: "reader", password: "reader-pass"});
final http:Client guestClient = check new ("http://localhost:9591/api",
    auth = {username: "guest", password: "guest-pass"});
final http:Client anonymousClient = check new ("http://localhost:9591/api");

@test:Config {dataProvider: interceptedErrors}
function testInterceptedError(string caller, string method, string path, json? body, int status, string code,
        string message) returns error? {
    http:Client c = caller == "reader" ? readerClient : caller == "guest" ? guestClient : anonymousClient;
    http:Response response = check c->execute(method, path, body is () ? new http:Request() : body);
    test:assertEquals(response.statusCode, status, path);
    test:assertEquals(response.getContentType(), "application/json", path);
    json payload = check response.getJsonPayload();
    test:assertEquals(check payload.code, code, path);
    if message != "" {
        test:assertEquals(check payload.message, message, path);
    }
}

function interceptedErrors() returns [string, string, string, json?, int, string, string][] => [
    ["anonymous", "GET", "/items/1", (), 401, dataservice:UNAUTHENTICATED, "The request needs a valid credential."],
    ["anonymous", "GET", "/items/abc", (), 401, dataservice:UNAUTHENTICATED, ""],
    ["anonymous", "POST", "/items", {id: 1}, 401, dataservice:UNAUTHENTICATED, ""],
    ["anonymous", "GET", "/missing", (), 401, dataservice:UNAUTHENTICATED, ""],
    ["anonymous", "PUT", "/items/1", {id: 1, name: "a"}, 401, dataservice:UNAUTHENTICATED, ""],
    ["guest", "GET", "/items/1", (), 403, dataservice:FORBIDDEN, "The caller holds no scope that the operation needs."],
    ["guest", "GET", "/items/abc", (), 403, dataservice:FORBIDDEN, ""],
    ["reader", "GET", "/items/abc", (), 400, dataservice:INVALID_INPUT, "error in casting path parameter : 'id'"],
    ["reader", "GET", "/items/1?size=x", (), 400, dataservice:INVALID_INPUT, ""],
    ["guest", "POST", "/items", {id: 1}, 400, dataservice:INVALID_INPUT, ""],
    ["reader", "GET", "/missing", (), 404, dataservice:NOT_FOUND, ""],
    ["reader", "PUT", "/items/1", {id: 1, name: "a"}, 405, dataservice:INVALID_INPUT, ""]
];

@test:Config
function testOptionsNeedsNoCredential() returns error? {
    http:Response preflight = check anonymousClient->options("/items/1",
        {"Origin": "https://app.example.com", "Access-Control-Request-Method": "GET"});
    test:assertEquals(preflight.statusCode, 204);
    test:assertEquals(check preflight.getHeader("Access-Control-Allow-Origin"), "https://app.example.com");
}

@test:Config
function testAllowedRequestReachesTheResource() returns error? {
    Item item = check readerClient->get("/items/1");
    test:assertEquals(item, {id: 1, name: "a"});
    Item created = check guestClient->post("/items", {id: 2, name: "b"});
    test:assertEquals(created, {id: 2, name: "b"});
}
