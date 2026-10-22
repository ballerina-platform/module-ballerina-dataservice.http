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
import ballerina/persist;
import ballerina/test;

@test:Config
function testNotFound() {
    ErrorResponse response = errorResponse(error persist:NotFoundError("no row"), "Employee", [99]);
    test:assertTrue(response is NotFound);
    test:assertEquals(response.body, {
        code: dataservice:NOT_FOUND,
        message: "A record with the key '99' does not exist for the entity 'Employee'."
    });
}

@test:Config
function testNotFoundCompositeKey() {
    ErrorResponse response = errorResponse(error persist:NotFoundError("no row"), "Assignment", ["P 1/a", 1]);
    test:assertEquals(response.body.message,
            "A record with the key 'P 1/a/1' does not exist for the entity 'Assignment'.");
}

@test:Config
function testConflict() {
    ErrorResponse response = errorResponse(error persist:AlreadyExistsError("Duplicate entry"), "Employee", [1]);
    test:assertTrue(response is Conflict);
    test:assertEquals(response.body, {
        code: dataservice:CONFLICT,
        message: "A record that conflicts with an existing record of the entity 'Employee' already exists."
    });
}

@test:Config
function testConstraintViolation() {
    ErrorResponse response = errorResponse(error persist:ConstraintViolationError("FK_1 violated"), "Employee", [1]);
    test:assertEquals(response.body, {
        code: dataservice:CONSTRAINT_VIOLATION,
        message: "The operation violates a constraint of the entity 'Employee'."
    });
    test:assertEquals(response.status.code, 409);
}

@test:Config
function testInternal() {
    ErrorResponse response = errorResponse(error persist:Error("connection refused"), "Employee");
    test:assertTrue(response is InternalError);
    test:assertEquals(response.body, {code: dataservice:INTERNAL, message: "An internal error occurred."});
}

@test:Config
function testInternalError() {
    InternalError response = internalError(error persist:Error("connection refused"));
    test:assertEquals(response.body, {code: dataservice:INTERNAL, message: "An internal error occurred."});
    test:assertEquals(response.status.code, 500);
}

@test:Config
function testInternalErrorKeepsCodeForOtherCategories() {
    InternalError response = internalError(error persist:NotFoundError("no row"));
    test:assertEquals(response.body, {code: dataservice:INTERNAL, message: "An internal error occurred."});
}

@test:Config
function testInvalidInput() {
    dataservice:ConversionError|anydata result = dataservice:dateFromString("2024-13-01");
    if result !is dataservice:ConversionError {
        test:assertFail("expected a conversion error");
    }
    InvalidInput response = invalidInput(result, "Employee", "hiredOn");
    test:assertEquals(response.body, {
        code: dataservice:INVALID_INPUT,
        message: "The field 'hiredOn' of the entity 'Employee' is not an ISO 8601 date."
    });
    test:assertEquals(response.status.code, 400);
}

@test:Config
function testInvalidInputFormats() {
    string[] messages = [];
    foreach dataservice:ConversionError|anydata result in [
                dataservice:timeOfDayFromString("x"), dataservice:civilFromString("x"),
                dataservice:utcFromString("x"), dataservice:bytesFromString("x")
            ] {
        if result is dataservice:ConversionError {
            messages.push(invalidInput(result, "Doc", "f").body.message);
        }
    }
    test:assertEquals(messages, [
        "The field 'f' of the entity 'Doc' is not an ISO 8601 time.",
        "The field 'f' of the entity 'Doc' is not an ISO 8601 date-time.",
        "The field 'f' of the entity 'Doc' is not an ISO 8601 date-time.",
        "The field 'f' of the entity 'Doc' is not a base64 string."
    ]);
}
