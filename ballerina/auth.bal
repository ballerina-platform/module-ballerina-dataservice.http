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

import ballerina/http;

# Checks the authentication providers that a data service with auth is configured with.
#
# + providers - The value of `dataserviceAuth`
# + return - The providers, or an error when there is none
public isolated function authConfig(http:ListenerAuthConfig[] providers) returns http:ListenerAuthConfig[]|error {
    if providers.length() == 0 {
        return error("The configurable value 'dataserviceAuth' must hold at least one authentication provider.");
    }
    return providers;
}
