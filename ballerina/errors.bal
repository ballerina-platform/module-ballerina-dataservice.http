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

# Maps an error from reading many records to the `500` response.
#
# + err - The error the persist client returned
# + return - The `500` response
public isolated function toListError(error err) returns InternalError => toInternalError(err);

# Maps an error from reading one record to its response.
#
# + err - The error the persist client returned
# + entity - The name of the entity
# + key - The values of the record's key fields, in key order
# + return - The `404` or `500` response
public isolated function toGetError(error err, string entity, dataservice:KeyValue[] key)
        returns NotFound|InternalError {
    dataservice:DataserviceError body = dataservice:toErrorBody(err, entity, key);
    return body.code == dataservice:NOT_FOUND ? <NotFound>{body} : toInternalError(err, body);
}

# Maps an error from creating records, or from reading a created record back, to its response.
#
# + err - The error the persist client returned
# + entity - The name of the entity
# + key - The values of the key fields of the record read back, in key order
# + return - The `404`, `409` or `500` response
public isolated function toCreateError(error err, string entity, dataservice:KeyValue[] key = [])
        returns NotFound|Conflict|ConstraintViolation|InternalError {
    dataservice:DataserviceError body = dataservice:toErrorBody(err, entity, key);
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
    }
    return toInternalError(err, body);
}

# Maps an error from updating a record to its response.
#
# + err - The error the persist client returned
# + entity - The name of the entity
# + key - The values of the record's key fields, in key order
# + return - The `404`, `409` or `500` response
public isolated function toUpdateError(error err, string entity, dataservice:KeyValue[] key)
        returns NotFound|ConstraintViolation|InternalError => toWriteError(err, entity, key);

# Maps an error from deleting a record to its response.
#
# + err - The error the persist client returned
# + entity - The name of the entity
# + key - The values of the record's key fields, in key order
# + return - The `404`, `409` or `500` response
public isolated function toDeleteError(error err, string entity, dataservice:KeyValue[] key)
        returns NotFound|ConstraintViolation|InternalError => toWriteError(err, entity, key);

# Maps a field value that is not in its JSON format to the `400` response.
#
# + err - The error from the `ballerina/dataservice` conversion
# + entity - The name of the entity
# + 'field - The name of the field
# + return - The `400` response
public isolated function toInvalidInput(dataservice:ConversionError err, string entity, string 'field)
        returns InvalidInput => {
    body: {
        code: dataservice:INVALID_INPUT,
        message: string `The field '${'field}' of the entity '${entity}' is not ${err.detail().format}.`
    }
};

// Conflict and ConstraintViolation have the same shape, so the category is decided from the body's code.
isolated function toWriteError(error err, string entity, dataservice:KeyValue[] key)
        returns NotFound|ConstraintViolation|InternalError {
    dataservice:DataserviceError body = dataservice:toErrorBody(err, entity, key);
    match body.code {
        dataservice:NOT_FOUND => {
            return <NotFound>{body};
        }
        dataservice:CONSTRAINT_VIOLATION => {
            return <ConstraintViolation>{body};
        }
    }
    return toInternalError(err, body);
}

// A body of another category is replaced, and logged as internal, so the code always matches the status.
isolated function toInternalError(error err, dataservice:DataserviceError? body = ())
        returns InternalError {
    if body is dataservice:DataserviceError && body.code == dataservice:INTERNAL {
        return {body};
    }
    return {body: dataservice:toErrorBody(error(err.message(), err))};
}
