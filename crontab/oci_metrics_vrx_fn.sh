#!/bin/bash
#************************************************************************
#
#   oci_metrics_vrx-fn.sh - get OCI Metrics using APIGW & Functions
#   metadata information into JSON files.
#
#   Copyright 2019  Olivier Perard 
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#************************************************************************
# Available at: https://github.com/operard/madhack_vrx/blob/master/crontab/
# Created on: 03/11/2019 by Olivier Perard
# Version 1.00
#************************************************************************
set -e

# Define paths for oci-cli and jq or put them on $PATH. Don't use relative PATHs in the variables below.
v_oci="oci"
v_jq="jq"

apigw=$(curl -k -X GET https://cvp4qdwzed5hxig7cfcb73utde.apigateway.eu-frankfurt-1.oci.customer-oci.com/v1/getocimetrics)

echo "$apigw" >> /tmp/oci_metrics_vrx_fn.log

curl -k "http://130.61.28.47:18088/services/collector" \
    -H "Authorization: Splunk b81fe15a-0be4-4a1e-82d5-5324888d78f0" \
	-d '{"sourcetype": "_json", "event": '$apigw'}'

