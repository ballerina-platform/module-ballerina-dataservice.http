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

# Answers the errors that `ballerina/http` raises before a resource runs, such as binding, auth and dispatching
# errors, with the `DataserviceError` body, keeping their status code.
public isolated service class ErrorInterceptor {
    *http:ResponseErrorInterceptor;

    isolated remote function interceptResponseError(error err, http:Response response) returns http:Response {
        response.setJsonPayload(errorBody(response.statusCode, err), "application/json");
        return response;
    }
}

isolated function errorBody(int status, error err) returns dataservice:DataserviceError {
    if status == http:STATUS_UNAUTHORIZED {
        return dataservice:unauthenticated();
    }
    if status == http:STATUS_FORBIDDEN {
        return dataservice:noScope();
    }
    if status == http:STATUS_NOT_FOUND {
        return {code: dataservice:NOT_FOUND, message: err.message()};
    }
    if status >= 400 && status < 500 {
        return {code: dataservice:INVALID_INPUT, message: err.message()};
    }
    return dataservice:toErrorBody(err);
}
