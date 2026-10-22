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

# The response to a request for a record that does not exist.
#
# + body - The error body, with the code `NOT_FOUND`
public type NotFound record {|
    *http:NotFound;
    dataservice:DataserviceError body;
|};

# The response to a request with a value that is not in its format.
#
# + body - The error body, with the code `INVALID_INPUT`
public type InvalidInput record {|
    *http:BadRequest;
    dataservice:DataserviceError body;
|};

# The response to a write that conflicts with an existing record.
#
# + body - The error body, with the code `CONFLICT`
public type Conflict record {|
    *http:Conflict;
    dataservice:DataserviceError body;
|};

# The response to a write that violates a constraint of the entity.
#
# + body - The error body, with the code `CONSTRAINT_VIOLATION`
public type ConstraintViolation record {|
    *http:Conflict;
    dataservice:DataserviceError body;
|};

# The response to a request that failed for any other reason.
#
# + body - The error body, with the code `INTERNAL`
public type InternalError record {|
    *http:InternalServerError;
    dataservice:DataserviceError body;
|};

# Any error response of a data service operation.
public type ErrorResponse NotFound|InvalidInput|Conflict|ConstraintViolation|InternalError;

# Builds the error response for an error that the persist client returned.
#
# + err - The error
# + entity - The name of the entity
# + key - The values of the record's key fields, in key order
# + return - The response for the error's category
public isolated function errorResponse(error err, string entity, dataservice:KeyValue[] key = [])
        returns ErrorResponse {
    dataservice:DataserviceError body = dataservice:toDataserviceError(err, entity, key);
    match body.code {
        dataservice:NOT_FOUND => {
            return <NotFound>{body};
        }
        dataservice:CONFLICT => {
            return <Conflict>{body};
        }
        dataservice:CONSTRAINT_VIOLATION => {
            return <ConstraintViolation>{body};
        }
        dataservice:INVALID_INPUT => {
            return <InvalidInput>{body};
        }
    }
    return <InternalError>{body};
}

# Builds the response for an error that can only be internal, such as one from reading many records.
#
# + err - The error
# + return - The `500` response
public isolated function internalError(error err) returns InternalError {
    // Wrapping the error keeps a persist error of another category from changing the code.
    return {body: dataservice:toDataserviceError(error(err.message(), err))};
}

# Builds the response for a field value that is not in its JSON format.
#
# + err - The error from the `ballerina/dataservice` conversion
# + entity - The name of the entity
# + 'field - The name of the field
# + return - The `400` response
public isolated function invalidInput(dataservice:ConversionError err, string entity, string 'field)
        returns InvalidInput => {
    body: {
        code: dataservice:INVALID_INPUT,
        message: string `The field '${'field}' of the entity '${entity}' is not ${err.detail().format}.`
    }
};
