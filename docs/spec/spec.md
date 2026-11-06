# Specification: Ballerina Data Service HTTP Library

_Owners_: @niveathika  
_Reviewers_: @daneshk  
_Created_: 2026/10/22  
_Updated_: 2026/11/05  
_Edition_: Swan Lake

## Introduction

This is the specification for the `ballerina/dataservice.http` package of the [Ballerina language](https://ballerina.io/). The package is the HTTP runtime of the data services that `bal persist` generates when `options.dataservice.protocol = "http"`. The generated service is specified in the [persist tool specification](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md#97-http-service), and the protocol-neutral runtime in the [`ballerina/dataservice` specification](https://github.com/ballerina-platform/module-ballerina-dataservice/blob/main/docs/spec/spec.md).

The conforming implementation of the specification is released and included in the distribution. Any deviation from the specification is considered a bug.

### Notation

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals. Sentences that state behaviour in the present tense are also normative. The overview, notes and examples are informative.

## Contents

- [1. Overview](#1-overview)
- [2. Terminology](#2-terminology)
- [3. Error responses](#3-error-responses)
    - [3.1. Description](#31-description)
    - [3.2. Response types](#32-response-types)
    - [3.3. Behaviour](#33-behaviour)
    - [3.4. Errors raised by ballerina/http](#34-errors-raised-by-ballerinahttp)
- [4. Configuration](#4-configuration)
    - [4.1. Description](#41-description)
    - [4.2. Configuration](#42-configuration)
    - [4.3. Behaviour](#43-behaviour)
- [5. Location](#5-location)
    - [5.1. Description](#51-description)
    - [5.2. Behaviour](#52-behaviour)
- [6. Auth](#6-auth)
    - [6.1. Description](#61-description)
    - [6.2. Behaviour](#62-behaviour)
    - [6.3. Errors](#63-errors)
    - [6.4. Interactions](#64-interactions)
- [7. Security considerations](#7-security-considerations)
- [References](#references)

## 1. Overview

A generated HTTP data service imports this package as `dsHttp`. It calls the functions of this package to map errors to responses, to build the `Location` of a created record and to check auth scopes at runtime, so a fix to one of them is released without regenerating the service. The service's runtime settings, its port, page sizes, listener, CORS and authentication providers, are the configuration types of this package.

The functions that generated code calls are a stable API. New behaviour is added through new functions or optional parameters.

## 2. Terminology

This specification uses the terms of the [`ballerina/dataservice` specification](https://github.com/ballerina-platform/module-ballerina-dataservice/blob/main/docs/spec/spec.md#2-terminology), and these:

- **Response type:** a record type that includes an `http` status code record and holds a `dataservice:DataserviceError` body.
- **Provider:** an `http:ListenerAuthConfig`, one entry of the service's authentication providers.

## 3. Error responses

### 3.1. Description

Each error category of `ballerina/dataservice` maps to an HTTP status code, and every error response carries the `dataservice:DataserviceError` body.

### 3.2. Response types

Each response type includes its `http` status code record and has the field `body` of type `dataservice:DataserviceError`.

| Type | Includes | Status | `code` | Raised from |
|---|---|---|---|---|
| `NotFound` | `http:NotFound` | `404` | `NOT_FOUND` | `persist:NotFoundError` |
| `Conflict` | `http:Conflict` | `409` | `CONFLICT` | `persist:AlreadyExistsError` |
| `ConstraintViolation` | `http:Conflict` | `409` | `CONSTRAINT_VIOLATION` | `persist:ConstraintViolationError` |
| `InvalidInput` | `http:BadRequest` | `400` | `INVALID_INPUT` | A date, time or `byte[]` value that does not parse, or an invalid query option |
| `Unauthorized` | `http:Unauthorized` | `401` | `UNAUTHENTICATED` | `Authenticator`, for a request without a valid credential |
| `Forbidden` | `http:Forbidden` | `403` | `FORBIDDEN` | `Authenticator`, when the caller holds no scope of the operation; or `checkRelationScopes`, for get related or a relation in `fields` when the caller holds no `read` scope of the related entity |
| `InternalError` | `http:InternalServerError` | `500` | `INTERNAL` | Any other error |

### 3.3. Behaviour

A generated resource declares only the responses its operation can return, so each operation has its own mapping function. Each maps an error that the persist client returned with `dataservice:toErrorBody`, given the entity's name, the operation's name and, where the operation has one, the record's key.

| Function | Used for | Responses |
|---|---|---|
| `toListError` | Reading many records | `500` |
| `toGetError` | Reading one record | `404`, `500` |
| `toCreateError` | Creating records, and reading a created record back by its key | `409` `CONFLICT`, `409` `CONSTRAINT_VIOLATION`, `500` |
| `toUpdateError` | Updating a record | `204`, `404`, `409` `CONFLICT`, `409` `CONSTRAINT_VIOLATION`, `500` |
| `toDeleteError` | Deleting a record | `404`, `409` `CONSTRAINT_VIOLATION`, `500` |
| `toInvalidInput` | A request value that does not parse | `400` |
| `toQueryError` | An invalid query option, from `dataservice:toQuery` or `dataservice:checkFields` | `400` |

1. An error whose category is not among an operation's responses is answered with `500` and the `INTERNAL` body, and is logged. A created record that is not found when it is read back is therefore a `500`, because the create succeeded.
2. An update that is saved but cannot be read back, a `persist:ReadBackError`, is answered with `204` and no body, and the error is logged.
3. `toInvalidInput` builds the message `The field '<field>' of the entity '<Entity>' is not <format>.`, where `<format>` is the `format` of the conversion error: `an ISO 8601 date`, `an ISO 8601 time`, `an ISO 8601 date-time` or `a base64 string`.
4. `toQueryError` returns an error body as it is, and builds the message of rule 3 for a filter value that does not parse, with the field the conversion error names.
5. As `dataservice:toErrorBody` defines, the detail of a constraint violation or an internal error is logged and not returned to the caller.
6. The error is logged once, with the entity's name and the operation's name. The operation is `get many` for `toListError`, `get one` for `toGetError`, `create`, `patch one` and `delete one`. A get related passes `get related` to `toListError` and `toGetError`.

### 3.4. Errors raised by ballerina/http

A generated service is an `http:InterceptableService`. Its `createInterceptors` returns a response error interceptor that the generated code defines in the service's own package, because the OpenAPI definition leaves out an interceptor from another package (ballerina-library#9633), and that calls `setErrorBody`. `setErrorBody` sets the `dataservice:DataserviceError` body, as `application/json`, on the response that `ballerina/http` built for an error raised before a resource runs, keeping its status:

| Status | `code` | `message` | Raised for |
|---|---|---|---|
| `404` | `NOT_FOUND` | `ballerina/http`'s | A path that matches no resource |
| Other `4xx` | `INVALID_INPUT` | `ballerina/http`'s | Payload, path and query binding, constraint validation, a method the path has no resource for (`405`) |
| `5xx` | `INTERNAL` | `An internal error occurred.` | Any other error, logged by `dataservice:toErrorBody` |

The interceptor changes the response in place and returns the next service, so the OpenAPI definition gains no response from it. The responses that a resource or a request interceptor returns, such as `Unauthorized` and `Forbidden`, are not errors, so the interceptor does not change them.

## 4. Configuration

### 4.1. Description

A generated service declares its runtime settings as one configurable record, `dataserviceConfig`, of a configuration type of this package. The user sets it in the `[dataserviceConfig]` table of `Config.toml`.

### 4.2. Configuration

`Config` includes `dataservice:Config`, which holds `port`, `pageSize` and `maxPageSize`, and adds these fields:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `listenerConfig` | `http:ListenerConfiguration` | `{}` | The settings of the service's listener. |
| `serviceConfig` | `ServiceConfig` | `{}` | The settings of the service. |

`ServiceConfig` has one field:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `cors` | `http:CorsConfig` | `{}` | The service's CORS settings. The default allows no cross-origin request. |

`AuthConfig`, for a service with auth, has the fields of `Config`, except that `serviceConfig` is an `AuthServiceConfig` and is required. `AuthServiceConfig` includes `ServiceConfig` and adds:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `auth` | `http:ListenerAuthConfig[]` | Required | The service's authentication providers. It must hold at least one provider. |

### 4.3. Behaviour

1. A generated service without auth declares `configurable dsHttp:Config dataserviceConfig = {};`, so every field has its default.
2. A generated service with auth declares `configurable dsHttp:AuthConfig dataserviceConfig = ?;`, so the program does not start without the providers.
3. `AuthConfig` does not include `Config`, because the closed `AuthServiceConfig` is not a subtype of `ServiceConfig` and cannot override that field.

## 5. Location

### 5.1. Description

`toLocation` builds the value of the `Location` header of a created record.

### 5.2. Behaviour

1. `toLocation` returns the path of the entity's collection followed by one segment per key value, in key order. The path of the collection includes the service's base path, such as `/api/employees`, or is `/employees` when the base path is `/`.
2. Each key value is written with `toString`, so `1.5` stays `1.5` and a `decimal` keeps its scale.
3. The text is percent-encoded as a path segment: every byte of the UTF-8 form of a character other than an RFC 3986 unreserved character (letters, digits, `-`, `.`, `_` and `~`) is written as `%XX`, with upper-case hexadecimal digits.

For example, the key `["P 1/a", 1]` of `/api/assignments` gives `/api/assignments/P%201%2Fa/1`, and the key `["é"]` of `/api/codes` gives `/api/codes/%C3%A9`.

## 6. Auth

### 6.1. Description

A data service with auth checks credentials and scopes with `Authenticator`, from a request interceptor that the generated code defines in the service's own package. A request interceptor runs before `ballerina/http` dispatches the request and binds its parameters, so a request without a valid credential is answered with `401` whatever its path, method or body. `ballerina/http` declarative auth is not used, because it runs inside the resource, after dispatching and binding (ballerina-library#9632).

### 6.2. Behaviour

1. A data service with auth creates its `Authenticator` at startup with a module-level `check`, from the configured providers and the scopes of each operation, keyed by the collection and then by the HTTP method. It creates the listener auth handler of each provider: `http:ListenerFileUserStoreBasicAuthHandler`, `http:ListenerLdapUserStoreBasicAuthHandler`, `http:ListenerJwtAuthHandler` or `http:ListenerOAuth2Handler`.
2. The request interceptor's resource, `'default [string... path]`, returns `authorize` with the request context, the request and the path. For each request, `authorize`:
    1. Passes an `OPTIONS` request, such as a CORS preflight, to the next service without a credential.
    2. Tries the handlers in the order of the providers, as `ballerina/http` does, and the first that authenticates the credential decides. When none does, it returns `Unauthorized` with the body of `dataservice:unauthenticated`.
    3. Keeps the authenticated caller in the request context.
    4. Looks up the scopes of the first path segment's collection and the request's method. When there are scopes and the caller holds none of them, as the deciding handler's `authorize` checks them, it returns `Forbidden` with the body of `dataservice:noScope`. A path or method without scopes, such as the OpenAPI definition, needs only the credential.
    5. Returns the next service otherwise.
3. `checkRelationScopes` checks a relation whose related entity's `read` scopes the entity's do not cover. A resource that reads such a relation, by get related or in `fields`, calls it before reading, with the request context, the entity's name, the relation, the related entity's name and the related entity's `read` scopes. It returns `Forbidden`, with the body of `dataservice:forbidden`, when the caller holds none of the scopes, and `()` otherwise.
4. `hasScope` returns whether the caller in the request context holds one of the given scopes, and `false` when the request was not authenticated. Patch and delete call it with the entity's `read` scopes when those do not cover the action's, and return no record when it is `false`.
5. For an OAuth2 provider, a scope is held when it is one of the space-separated values of the introspection response's `scopeKey` claim, as `http:ListenerOAuth2Handler` checks it.

### 6.3. Errors

| Case | Result |
|---|---|
| The providers list is empty | Creating `Authenticator` returns an error with the message `The configurable value 'dataserviceConfig.serviceConfig.auth' must hold at least one authentication provider.`, so the program stops. |
| No handler authenticates the credential | `authorize` returns `Unauthorized`. |
| The caller holds no scope of the operation | `authorize` returns `Forbidden`. |
| The caller holds no scope that `checkRelationScopes` or `hasScope` is given | `checkRelationScopes` returns `Forbidden`; `hasScope` returns `false`. |

### 6.4. Interactions

The credential is checked once per request. `checkRelationScopes` and `hasScope` read the caller that `authorize` kept, so they do not verify a JWT, introspect an OAuth2 token or look up an LDAP user again.

## 7. Security considerations

- Every error response carries only the `dataservice:DataserviceError` body. The persist client's error message, which can hold driver text such as table and constraint names, is never returned; it is logged.
- The default `cors` allows no cross-origin request.
- A service with auth does not start without at least one authentication provider.
- A request without a valid credential is answered with `401` before it is dispatched or bound, so binding errors do not reveal the request types to an unauthenticated caller. An `OPTIONS` request needs no credential, and its answer lists only the allowed methods.
- A relation that needs a scope of the related entity, and the record that patch and delete return, are checked against the credential at runtime, so a caller's `update` or `delete` scope alone does not reveal a record.
- A key value in `Location` is percent-encoded, so a key cannot add a path segment or a query to the header.

## References

- [BEP 1513: Persist data service over HTTP](https://github.com/ballerina-platform/ballerina-spec/issues/1513)
- [`ballerina/dataservice` specification](https://github.com/ballerina-platform/module-ballerina-dataservice/blob/main/docs/spec/spec.md)
- [Persist tool specification, the HTTP service](https://github.com/ballerina-platform/persist-tools/blob/main/docs/spec/spec.md#97-http-service)
- [RFC 2119: Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119)
- [RFC 8174: Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174)
- [RFC 3986: Uniform Resource Identifier (URI): Generic Syntax](https://www.rfc-editor.org/rfc/rfc3986)
