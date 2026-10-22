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

import ballerina/http;
import ballerina/persist;
import ballerina/test;

service /api on new http:Listener(9590) {
    resource function get errors/[string category]() returns ErrorResponse {
        match category {
            "notFound" => {
                return errorResponse(error persist:NotFoundError("no row"), "Employee", [99]);
            }
            "conflict" => {
                return errorResponse(error persist:AlreadyExistsError("exists"), "Employee", [1]);
            }
            "constraint" => {
                return errorResponse(error persist:ConstraintViolationError("FK"), "Employee", [1]);
            }
        }
        return internalError(error("boom"));
    }
}

final http:Client testClient = check new ("http://localhost:9590/api");

@test:Config {dataProvider: categories}
function testResponseOverHttp(string category, int status, string code) returns error? {
    http:Response response = check testClient->get("/errors/" + category);
    test:assertEquals(response.statusCode, status);
    json body = check response.getJsonPayload();
    test:assertEquals(check body.code, code);
}

function categories() returns [string, int, string][] => [
    ["notFound", 404, "NOT_FOUND"],
    ["conflict", 409, "CONFLICT"],
    ["constraint", 409, "CONSTRAINT_VIOLATION"],
    ["other", 500, "INTERNAL"]
];
