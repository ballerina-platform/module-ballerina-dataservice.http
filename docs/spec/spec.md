# Specification: Ballerina Data Service HTTP Library

_Owners_: @niveathika  
_Reviewers_:  
_Created_: 2026/10/22  
_Updated_: 2026/10/22  
_Edition_: Swan Lake

## Introduction

This is the specification for the `ballerina/dataservice.http` package of the [Ballerina language](https://ballerina.io/).
The package is the HTTP runtime of the data services that `bal persist` generates when
`options.dataservice.protocol = "http"`, as defined in the
[HTTP data service proposal](https://github.com/ballerina-platform/ballerina-spec/issues/1513). A generated service
imports it as `dsHttp` and calls its functions to build error responses and `Location` headers, so a fix to one of them
is released without regenerating the service.

The functions that generated code calls are a stable API. New behaviour is added through new functions or optional
parameters.

The conforming implementation of the specification is released and included in the distribution. Any deviation from
the specification is considered a bug.

## Contents

* [1. Error responses](#1-error-responses)
    * [1.1. Response types](#11-response-types)
    * [1.2. Functions](#12-functions)

## 1. Error responses

### 1.1. Response types

Each error category of `ballerina/dataservice` maps to a status code. The body is the `dataservice:DataserviceError`
record.

| Type | Includes | Status | `code` | Raised from |
|---|---|---|---|---|
| `NotFound` | `http:NotFound` | `404` | `NOT_FOUND` | `persist:NotFoundError` |
| `Conflict` | `http:Conflict` | `409` | `CONFLICT` | `persist:AlreadyExistsError` |
| `ConstraintViolation` | `http:Conflict` | `409` | `CONSTRAINT_VIOLATION` | `persist:ConstraintViolationError` |
| `InvalidInput` | `http:BadRequest` | `400` | `INVALID_INPUT` | A date, time or `byte[]` value that does not parse |
| `InternalError` | `http:InternalServerError` | `500` | `INTERNAL` | Any other error |

```ballerina
public type NotFound record {|
    *http:NotFound;
    dataservice:DataserviceError body;
|};

public type ErrorResponse NotFound|InvalidInput|Conflict|ConstraintViolation|InternalError;
```

The other four types have the same form. Other invalid input, such as a missing field or a path segment that does
not convert to the key's type, is answered by `ballerina/http` with `400` before the resource runs, so its body is
the `ballerina/http` default error body.

### 1.2. Functions

```ballerina
public isolated function errorResponse(error err, string entity, dataservice:KeyValue[] key = [])
        returns ErrorResponse;

public isolated function internalError(error err) returns InternalError;

public isolated function invalidInput(dataservice:ConversionError err, string entity, string 'field)
        returns InvalidInput;
```

- **`errorResponse`** maps an error that the persist client returned with `dataservice:toDataserviceError`, and
  returns the response type of its category. `entity` is the entity's name and `key` holds the record's key values,
  in key order.
- **`internalError`** returns `InternalError` for any error. A generated service uses it where only an internal error
  can occur, such as reading many records.
- **`invalidInput`** returns `InvalidInput` for a request value that did not parse, with the message
  `The field '<field>' of the entity '<Entity>' is not <format>.`, where `<format>` is the `format` of the
  conversion error: `an ISO 8601 date`, `an ISO 8601 time`, `an ISO 8601 date-time` or `a base64 string`.

As `dataservice:toDataserviceError` defines, the detail of a constraint violation or an internal error is logged and
not returned to the caller.
