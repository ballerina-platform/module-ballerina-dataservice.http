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

# Sets the data service error body on a response that `ballerina/http` built for an error raised before a resource
# runs, such as a binding or dispatching error, keeping its status code.
#
# + response - The response
# + err - The error
public isolated function setErrorBody(http:Response response, error err) {
    response.setJsonPayload(errorBody(response.statusCode, err), "application/json");
}

isolated function errorBody(int status, error err) returns dataservice:DataserviceError {
    if status == http:STATUS_NOT_FOUND {
        return {code: dataservice:NOT_FOUND, message: err.message()};
    }
    if status >= 400 && status < 500 {
        return {code: dataservice:INVALID_INPUT, message: err.message()};
    }
    return dataservice:toErrorBody(err);
}
