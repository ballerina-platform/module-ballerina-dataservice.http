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

@test:Config
function testAuthConfig() returns error? {
    http:ListenerAuthConfig[] providers = [{fileUserStoreConfig: {}}];
    test:assertEquals(check authConfig(providers), providers);
    http:ListenerAuthConfig[]|error empty = authConfig([]);
    test:assertTrue(empty is error);
    if empty is error {
        test:assertEquals(empty.message(),
                "The configurable value 'dataserviceAuth' must hold at least one authentication provider.");
    }
}

@test:Config
function testForbiddenStatus() {
    Forbidden response = {body: dataservice:forbidden("Employee", "department")};
    test:assertEquals(response.status.code, 403);
    test:assertEquals(response.body.code, dataservice:FORBIDDEN);
}
