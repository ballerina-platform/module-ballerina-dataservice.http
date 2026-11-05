# Specification: Ballerina Data Service HTTP Library

_Owners_: @niveathika  
_Reviewers_:  
_Created_: 2026/10/22  
_Updated_: 2026/11/03  
_Edition_: Swan Lake

## Introduction

This is the specification for the `ballerina/dataservice.http` package of the [Ballerina language](https://ballerina.io/).
The package is the HTTP runtime of the data services that `bal persist` generates when
`options.dataservice.protocol = "http"`. A generated service imports it as `dsHttp` and calls its functions to build
error responses and `Location` headers, so a fix to one of them is released without regenerating the service. The
generated service itself is specified in the
[persist tool specification](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md#76-the-http-service).

The functions that generated code calls are a stable API. New behaviour is added through new functions or optional
parameters.

The conforming implementation of the specification is released and included in the distribution. Any deviation from
the specification is considered a bug.

## Contents

* [1. Error responses](#1-error-responses)
    * [1.1. Response types](#11-response-types)
    * [1.2. Functions](#12-functions)
    * [1.3. The error interceptor](#13-the-error-interceptor)
    * [1.4. Configuration](#14-configuration)
* [2. `Location`](#2-location)
* [3. Auth](#3-auth)

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
| `Unauthorized` | `http:Unauthorized` | `401` | `UNAUTHENTICATED` | `ballerina/http` auth, through `ErrorInterceptor`; declared so the OpenAPI definition lists it |
| `Forbidden` | `http:Forbidden` | `403` | `FORBIDDEN` | `ballerina/http` auth when the caller holds no scope of the action, through `ErrorInterceptor`; or get related or a relation in `fields` when the caller holds no `read` scope of the related entity, returned by `checkRelationScopes` |
| `InternalError` | `http:InternalServerError` | `500` | `INTERNAL` | Any other error |

```ballerina
public type NotFound record {|
    *http:NotFound;
    dataservice:DataserviceError body;
|};
```

The other six types have the same form.

### 1.2. Functions

A generated resource declares only the responses its operation can return, so each operation has its own function.
Each maps an error that the persist client returned with `dataservice:toErrorBody`. `entity` is the entity's name
and `key` holds the record's key values, in key order.

```ballerina
public isolated function toListError(error err) returns InternalError;

public isolated function toGetError(error err, string entity, dataservice:KeyValue[] key)
        returns NotFound|InternalError;

public isolated function toCreateError(error err, string entity)
        returns Conflict|ConstraintViolation|InternalError;

public isolated function toUpdateError(error err, string entity, dataservice:KeyValue[] key)
        returns http:NoContent|NotFound|Conflict|ConstraintViolation|InternalError;

public isolated function toDeleteError(error err, string entity, dataservice:KeyValue[] key)
        returns NotFound|ConstraintViolation|InternalError;

public isolated function toInvalidInput(dataservice:ConversionError err, string entity, string 'field)
        returns InvalidInput;

public isolated function toQueryError(dataservice:DataserviceError|dataservice:ConversionError err, string entity)
        returns InvalidInput;
```

| Function | Used for | Responses |
|---|---|---|
| `toListError` | Reading many records | `500` |
| `toGetError` | Reading one record | `404`, `500` |
| `toCreateError` | Creating records, and reading a created record back by its key | `409` `CONFLICT`, `409` `CONSTRAINT_VIOLATION`, `500` |
| `toUpdateError` | Updating a record | `204`, `404`, `409` `CONFLICT`, `409` `CONSTRAINT_VIOLATION`, `500` |
| `toDeleteError` | Deleting a record | `404`, `409` `CONSTRAINT_VIOLATION`, `500` |
| `toInvalidInput` | A request value that does not parse | `400` |
| `toQueryError` | An invalid query option, from `dataservice:toQuery` or `dataservice:checkFields` | `400` |

An error whose category is not among an operation's responses is answered with `500` and the `INTERNAL` body, and is
logged. A created record that is not found when it is read back is therefore a `500`, because the create succeeded.
An update that is saved but cannot be read back, a `persist:ReadBackError`, is answered with `204` and no body, and the
error is logged. `toInvalidInput` builds the message `The field '<field>' of the entity '<Entity>' is not <format>.`, where
`<format>` is the `format` of the conversion error: `an ISO 8601 date`, `an ISO 8601 time`, `an ISO 8601 date-time`
or `a base64 string`. `toQueryError` returns the error body as it is, and builds the same message for a filter value that
does not parse, with the field the conversion error names.

As `dataservice:toErrorBody` defines, the detail of a constraint violation or an internal error is logged and not
returned to the caller.

### 1.3. The error interceptor

```ballerina
public isolated service class ErrorInterceptor {
    *http:ResponseErrorInterceptor;
}
```

A generated service is an `http:InterceptableService` whose `createInterceptors` returns an `ErrorInterceptor`. It
answers the errors that `ballerina/http` raises before a resource runs with the same status and a
`dataservice:DataserviceError` body:

| Status | `code` | `message` | Raised for |
|---|---|---|---|
| `401` | `UNAUTHENTICATED` | `dataservice:unauthenticated` | A missing or rejected credential |
| `403` | `FORBIDDEN` | `dataservice:noScope` | A caller without a scope of the action |
| `404` | `NOT_FOUND` | `ballerina/http`'s | A path that matches no resource |
| Other `4xx` | `INVALID_INPUT` | `ballerina/http`'s | Payload, path and query binding, constraint validation, a method the path has no resource for (`405`), an unsupported media type |
| `5xx` | `INTERNAL` | `An internal error occurred.` | Any other error, logged by `dataservice:toErrorBody` |

The responses that a resource returns, such as `Forbidden` from `checkRelationScopes`, are not errors, so the
interceptor does not change them.

### 1.4. Configuration

```ballerina
public type ServiceConfig record {|
    http:CorsConfig cors = {};
|};

public type AuthServiceConfig record {|
    *ServiceConfig;
    http:ListenerAuthConfig[] auth;
|};

public type Config record {|
    *dataservice:Config;
    http:ListenerConfiguration listenerConfig = {};
    ServiceConfig serviceConfig = {};
|};

public type AuthConfig record {|
    *dataservice:Config;
    http:ListenerConfiguration listenerConfig = {};
    AuthServiceConfig serviceConfig;
|};
```

A generated service declares `configurable dsHttp:Config dataserviceConfig = {};`, or with auth
`configurable dsHttp:AuthConfig dataserviceConfig = ?;`, and the user sets it in the `[dataserviceConfig]` table of
`Config.toml`. `Config` includes `dataservice:Config`, the port and page sizes, and adds the listener settings and the
service's CORS settings. `AuthConfig` adds the authentication providers, which have no default, so the program does
not start without them. `AuthConfig` does not include `Config`, because the closed `AuthServiceConfig` is not a
subtype of `ServiceConfig` and cannot override that field.

## 2. `Location`

```ballerina
public isolated function toLocation(string path, dataservice:KeyValue[] key) returns string;
```

`toLocation` returns the path of a created record: `path` followed by one segment per key value, in key order. `path`
is the path of the entity's collection, including the service's base path, such as `/api/employees`, or
`/employees` when the base path is `/`.

Each key value is written with `toString`, so `1.5` stays `1.5` and a `decimal` keeps its scale, and is then
percent-encoded as a path segment: every byte of its UTF-8 form other than an RFC 3986 unreserved character
(letters, digits, `-`, `.`, `_` and `~`) is written as `%XX`. For example, the key `["P 1/a", 1]` of
`/api/assignments` gives `/api/assignments/P%201%2Fa/1`.

## 3. Auth

```ballerina
public isolated function initAuthProviders(http:ListenerAuthConfig[] providers)
        returns http:ListenerAuthConfig[]|error;
public isolated function checkRelationScopes(http:Request request, string entity, string relation, string target,
        string[] scopes) returns Forbidden?;
public isolated function hasScope(http:Request request, string[] scopes) returns boolean;
```

A data service with auth checks its authentication providers at startup with a module-level `check` on
`initAuthProviders`, so the program stops when the list is empty, with the message
`The configurable value 'dataserviceConfig.serviceConfig.auth' must hold at least one authentication provider.` The providers are
returned as given otherwise, and `initAuthProviders` creates the listener auth handler of each one:
`http:ListenerFileUserStoreBasicAuthHandler`, `http:ListenerLdapUserStoreBasicAuthHandler`,
`http:ListenerJwtAuthHandler` or `http:ListenerOAuth2Handler`.

`checkRelationScopes` checks a relation whose related entity's `read` scopes the entity's do not cover. A resource that
reads such a relation, by get related or in `fields`, calls it before reading. It tries the handlers in the order of
the providers, as `ballerina/http` does, and the first that authenticates the request's credential decides with its
`authorize` against `scopes`, the related entity's `read` scopes. It returns `Forbidden`, with the body of
`dataservice:forbidden`, when that handler refuses or when no handler authenticates the credential, and `()`
otherwise.

`hasScope` checks the credential in the same way and tells whether it holds one of `scopes`. Patch and delete call
it with the entity's `read` scopes when those do not cover the action's, and return no record when it is `false`.

`ballerina/http` has already checked the credential before the resource runs, so this is a second check: a JWT
signature is verified again unless the provider's cache is configured, an OAuth2 token is introspected again unless
its cache is configured, and an LDAP user is looked up again.

