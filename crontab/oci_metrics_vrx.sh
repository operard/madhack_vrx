#!/bin/bash
#************************************************************************
#
#   oci_metrics_vrx.sh - get OCI Metrics
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
# Available at: https://github.com/
# Created on: 03/11/2019 by Olivier Perard
# Version 1.00
#************************************************************************
set -e

# Define paths for oci-cli and jq or put them on $PATH. Don't use relative PATHs in the variables below.
v_oci="oci"
v_jq="jq"

cpu=$(/home/ubuntu/bin/oci monitoring metric-data summarize-metrics-data --compartment-id ocid1.compartment.oc1..aaaaaaaa4gk5fmtbrfnkfrwwkoef5pmrvxu7dauh52hbisvnhx6rgas5jxja --namespace "oci_computeagent" --query-text "CPUUtilization[1m]{resourceId = "ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva"}.mean()")
		 
mem=$(/home/ubuntu/bin/oci monitoring metric-data summarize-metrics-data --compartment-id ocid1.compartment.oc1..aaaaaaaa4gk5fmtbrfnkfrwwkoef5pmrvxu7dauh52hbisvnhx6rgas5jxja --namespace "oci_computeagent" --query-text "MemoryUtilization[1m]{resourceId = "ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva"}.mean()")

netin=$(/home/ubuntu/bin/oci monitoring metric-data summarize-metrics-data --compartment-id ocid1.compartment.oc1..aaaaaaaa4gk5fmtbrfnkfrwwkoef5pmrvxu7dauh52hbisvnhx6rgas5jxja --namespace "oci_computeagent" --query-text "NetworksBytesIn[1m]{resourceId = "ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva"}.rate()")

netout=$(/home/ubuntu/bin/oci monitoring metric-data summarize-metrics-data --compartment-id ocid1.compartment.oc1..aaaaaaaa4gk5fmtbrfnkfrwwkoef5pmrvxu7dauh52hbisvnhx6rgas5jxja --namespace "oci_computeagent" --query-text "NetworksBytesOut[1m]{resourceId = "ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva"}.rate()")

host=$(echo $cpu | jq ' .data[0]."dimensions"."resourceDisplayName"')
region=$(echo $cpu | jq ' .data[0]."dimensions"."region"')
availabilityDomain=$(echo $cpu | jq ' .data[0]."dimensions"."availabilityDomain"')
faultDomain=$(echo $cpu | jq ' .data[0]."dimensions"."faultDomain"')
shape=$(echo $cpu | jq ' .data[0]."dimensions"."shape"')

cpulast=$(echo $cpu |  jq ' .data[0]."aggregated-datapoints"' | jq ' .[-1]')
memlast=$(echo $mem |  jq ' .data[0]."aggregated-datapoints"' | jq ' .[-1]')
netinlast=$(echo $netin |  jq ' .data[0]."aggregated-datapoints"' | jq ' .[-1]')
netoutlast=$(echo $netout |  jq ' .data[0]."aggregated-datapoints"' | jq ' .[-1]')

timestamp=$(echo $cpulast | jq ' ."timestamp"')
cpuval=$(echo $cpulast | jq ' ."value"')
memval=$(echo $memlast | jq ' ."value"')
netinval=$(echo $netinlast | jq ' ."value"')
netoutval=$(echo $netoutlast | jq ' ."value"')

#echo "host: $host"
#echo "region: $region"
#echo "availabilityDomain: $availabilityDomain"
#echo "faultDomain: $faultDomain"
#echo "shape: $shape"

#echo "timestamp: $timestamp"
#echo "cpuval: $cpuval"
#echo "memval: $memval"
#echo "netinval: $netinval"
#echo "netoutval: $netoutval"

echo "$timestamp|$host|$region|$availabilityDomain|$faultDomain|$shape|$cpuval|$memval|$netinval|$netoutval" >> /tmp/oci_metrics_vrx.log

curl -k "http://130.61.28.47:18088/services/collector" \
    -H "Authorization: Splunk b81fe15a-0be4-4a1e-82d5-5324888d78f0" \
	-d '{"sourcetype": "_json", "event": {"timestamp": '$timestamp', "host": '$host', "region": '$region', "availabilityDomain": '$availabilityDomain', "faultDomain": '$faultDomain', "shape": '$shape', "cpu_mean": '$cpuval', "mem_mean": '$memval', "net_in": '$netinval', "net_out": '$netoutval' }}'

