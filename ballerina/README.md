# Ballerina Data Service HTTP Library

## Overview

The `ballerina/dataservice.http` package is the HTTP runtime of the data services that `bal persist` generates from a persist model. Generated HTTP services call it to build error responses and `Location` headers, so fixes reach them without regeneration.

## Quick start

The package is used by generated code, not imported by hand. To generate an HTTP data service:

1. Add the persist entry with an HTTP data service to the package:

    ```bash
    bal persist add --datastore h2 --dataservice http
    ```

2. Annotate each entity to expose in `persist/model.bal` with `@dataservice:Expose`.

3. Build and run the package. The service is served on port `9090` under `/api`:

    ```bash
    bal run
    curl localhost:9090/api/employees
    ```

A failed request is answered with a status code and a JSON body that names the error category:

```
GET /api/employees/99  →  404  {"code": "NOT_FOUND", "message": "A record with the key '99' does not exist for the entity 'Employee'."}
```

For the details, see the [specification](https://github.com/ballerina-platform/module-ballerina-dataservice.http/blob/main/docs/spec/spec.md).
