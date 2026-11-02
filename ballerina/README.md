# Ballerina Data Service HTTP Library

## Overview

The `ballerina/dataservice.http` package is the HTTP runtime of the data services that `bal persist` generates from a persist model. Generated HTTP services call it to build error responses and `Location` headers, so fixes reach them without regeneration.

The design is in the [HTTP data service proposal](https://github.com/ballerina-platform/ballerina-spec/issues/1513).
