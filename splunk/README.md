# Splunk Installation, Configuration & Deployment


See https://docs.splunk.com/Documentation/Splunk/8.0.0/Installation/DeployandrunSplunkEnterpriseinsideDockercontainers

## Installation


```
docker pull splunk/splunk:latest
```

## Configuration 

Default Configuration
```
docker run -it -p 8000:8000 -p 8089:8089 -p 8088:8088 -e 'SPLUNK_START_ARGS=--accept-license' -e 'SPLUNK_PASSWORD=Welcome1' splunk/splunk:latest start

```

With HTTP Event listener

```
docker run -it -p 8000:8000 -p 8089:8089 -p 8088:8088 -e 'SPLUNK_START_ARGS=--accept-license' -e 'SPLUNK_PASSWORD=Welcome1' splunk/splunk:latest start

```

## Splunk Cloud Gateway Configuration 

![Cloud Gateway](https://github.com/operard/madhack_vrx/blob/master/splunk/cloud_gateway_0001.png)

![Cloud Gateway](https://github.com/operard/madhack_vrx/blob/master/splunk/cloud_gateway_0002.png)

![Cloud Gateway](https://github.com/operard/madhack_vrx/blob/master/splunk/cloud_gateway_0003.png)

![Cloud Gateway](https://github.com/operard/madhack_vrx/blob/master/splunk/cloud_gateway_0004.png)

