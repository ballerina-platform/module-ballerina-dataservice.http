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

final dataservice:DataserviceError internal = {code: dataservice:INTERNAL, message: "An internal error occurred."};

@test:Config
function testListError() {
    InternalError response = toListError(error persist:Error("connection refused"));
    test:assertEquals(response.body, internal);
    test:assertEquals(response.status.code, 500);
}

@test:Config
function testListErrorKeepsCodeForOtherCategories() {
    test:assertEquals(toListError(error persist:NotFoundError("no row")).body, internal);
}

@test:Config
function testGetErrorNotFound() {
    NotFound|InternalError response = toGetError(error persist:NotFoundError("no row"), "Employee", [99]);
    test:assertTrue(response is NotFound);
    test:assertEquals(response.body, {
        code: dataservice:NOT_FOUND,
        message: "A record with the key '99' does not exist for the entity 'Employee'."
    });
    test:assertEquals(response.status.code, 404);
}

@test:Config
function testGetErrorCompositeKey() {
    NotFound|InternalError response = toGetError(error persist:NotFoundError("no row"), "Assignment", ["P 1/a", 1]);
    test:assertEquals(response.body.message,
            "A record with the key 'P 1/a/1' does not exist for the entity 'Assignment'.");
}

@test:Config
function testGetErrorOtherCategoryIsInternal() {
    NotFound|InternalError response = toGetError(error persist:AlreadyExistsError("exists"), "Employee", [1]);
    test:assertTrue(response is InternalError);
    test:assertEquals(response.body, internal);
}

@test:Config
function testCreateErrorConflict() {
    NotFound|Conflict|ConstraintViolation|InternalError response =
        toCreateError(error persist:AlreadyExistsError("Duplicate entry"), "Employee");
    test:assertTrue(response is Conflict);
    test:assertEquals(response.body, {
        code: dataservice:CONFLICT,
        message: "A record that conflicts with an existing record of the entity 'Employee' already exists."
    });
    test:assertEquals(response.status.code, 409);
}

@test:Config
function testCreateErrorConstraintViolation() {
    NotFound|Conflict|ConstraintViolation|InternalError response =
        toCreateError(error persist:ConstraintViolationError("FK_1 violated"), "Employee");
    test:assertTrue(response is ConstraintViolation);
    test:assertEquals(response.status.code, 409);
}

@test:Config
function testCreateErrorReadBackNotFound() {
    NotFound|Conflict|ConstraintViolation|InternalError response =
        toCreateError(error persist:NotFoundError("no row"), "Employee", [7]);
    test:assertTrue(response is NotFound);
}

@test:Config
function testCreateErrorInternal() {
    test:assertEquals(toCreateError(error persist:Error("connection refused"), "Employee").body, internal);
}

@test:Config
function testUpdateErrorConstraintViolation() {
    NotFound|ConstraintViolation|InternalError response =
        toUpdateError(error persist:ConstraintViolationError("FK_1 violated"), "Employee", [1]);
    test:assertTrue(response is ConstraintViolation);
    test:assertEquals(response.body, {
        code: dataservice:CONSTRAINT_VIOLATION,
        message: "The operation violates a constraint of the entity 'Employee'."
    });
}

@test:Config
function testUpdateErrorNotFound() {
    test:assertTrue(toUpdateError(error persist:NotFoundError("no row"), "Employee", [1]) is NotFound);
}

@test:Config
function testUpdateErrorConflictIsInternal() {
    test:assertEquals(toUpdateError(error persist:AlreadyExistsError("exists"), "Employee", [1]).body, internal);
}

@test:Config
function testDeleteErrors() {
    test:assertTrue(toDeleteError(error persist:NotFoundError("no row"), "Employee", [1]) is NotFound);
    test:assertTrue(toDeleteError(error persist:ConstraintViolationError("FK"), "Employee", [1]) is ConstraintViolation);
    test:assertEquals(toDeleteError(error persist:Error("boom"), "Employee", [1]).body, internal);
}

@test:Config
function testInvalidInput() {
    dataservice:ConversionError|anydata result = dataservice:dateFromString("2024-13-01");
    if result !is dataservice:ConversionError {
        test:assertFail("expected a conversion error");
    }
    InvalidInput response = toInvalidInput(result, "Employee", "hiredOn");
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
            messages.push(toInvalidInput(result, "Doc", "f").body.message);
        }
    }
    test:assertEquals(messages, [
        "The field 'f' of the entity 'Doc' is not an ISO 8601 time.",
        "The field 'f' of the entity 'Doc' is not an ISO 8601 date-time.",
        "The field 'f' of the entity 'Doc' is not an ISO 8601 date-time.",
        "The field 'f' of the entity 'Doc' is not a base64 string."
    ]);
}
