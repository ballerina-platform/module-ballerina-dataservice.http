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

import ballerina/test;

@test:Config
function testSingleKey() {
    test:assertEquals(location("/api/employees", [1]), "/api/employees/1");
}

@test:Config
function testCompositeKeyIsPercentEncoded() {
    test:assertEquals(location("/api/assignments", ["P 1/a", 1]), "/api/assignments/P%201%2Fa/1");
}

@test:Config
function testRootBasePath() {
    test:assertEquals(location("/employees", [1]), "/employees/1");
}

@test:Config
function testKeyText() {
    test:assertEquals(location("/api/rates", [1.5, 2.50d, true, -3]), "/api/rates/1.5/2.50/true/-3");
}

@test:Config
function testReservedAndNonAsciiCharacters() {
    test:assertEquals(location("/api/codes", ["a~b_c.d-e"]), "/api/codes/a~b_c.d-e");
    test:assertEquals(location("/api/codes", ["?#%+&=é"]), "/api/codes/%3F%23%25%2B%26%3D%C3%A9");
}
