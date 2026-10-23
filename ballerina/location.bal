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

# Builds the `Location` of a created record.
#
# + path - The path of the entity's collection, such as `/api/employees`
# + key - The values of the record's key fields, in key order
# + return - The path of the record, such as `/api/employees/1`
public isolated function buildLocation(string path, dataservice:KeyValue[] key) returns string {
    string location = path;
    foreach dataservice:KeyValue value in key {
        location += "/" + encodeSegment(value.toString());
    }
    return location;
}

isolated function encodeSegment(string segment) returns string {
    string encoded = "";
    foreach byte b in segment.toBytes() {
        // An unreserved byte is an ASCII code point, so the conversion cannot fail.
        encoded += isUnreserved(b) ? checkpanic string:fromCodePointInt(b) : "%" + b.toHexString().toUpperAscii().padZero(2);
    }
    return encoded;
}

// RFC 3986 unreserved characters: ALPHA / DIGIT / "-" / "." / "_" / "~"
isolated function isUnreserved(byte b) returns boolean =>
    (b >= 0x41 && b <= 0x5A) || (b >= 0x61 && b <= 0x7A) || (b >= 0x30 && b <= 0x39)
        || b == 0x2D || b == 0x2E || b == 0x5F || b == 0x7E;
