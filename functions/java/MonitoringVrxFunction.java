package io.fnproject.monitoring;

import com.oracle.bmc.auth.ResourcePrincipalAuthenticationDetailsProvider;

import com.oracle.bmc.monitoring.MonitoringClient;
import com.oracle.bmc.monitoring.model.ListMetricsDetails;
import com.oracle.bmc.monitoring.requests.ListMetricsRequest;
import com.oracle.bmc.monitoring.responses.ListMetricsResponse;

import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.stream.Collectors;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.cloudevents.CloudEvent;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;

public class MonitoringVrxFunction {

    private MonitoringClient monitoringClient = null;

    final ResourcePrincipalAuthenticationDetailsProvider provider
            = ResourcePrincipalAuthenticationDetailsProvider.builder().build();

    public MonitoringVrxFunction() {
        try {

            //print env vars in Functions container
            System.err.println("OCI_RESOURCE_PRINCIPAL_VERSION " + System.getenv("OCI_RESOURCE_PRINCIPAL_VERSION"));
            System.err.println("OCI_RESOURCE_PRINCIPAL_REGION " + System.getenv("OCI_RESOURCE_PRINCIPAL_REGION"));
            System.err.println("OCI_RESOURCE_PRINCIPAL_RPST " + System.getenv("OCI_RESOURCE_PRINCIPAL_RPST"));
            System.err.println("OCI_RESOURCE_PRINCIPAL_PRIVATE_PEM " + System.getenv("OCI_RESOURCE_PRINCIPAL_PRIVATE_PEM"));

            monitoringClient = new MonitoringClient(provider);

        } catch (Throwable ex) {
            System.err.println("Failed to instantiate MonitoringClient client - " + ex.getMessage());
        }
    }

    public String getStatus(String input){
        if (monitoringClient == null) {
            System.err.println("There was a problem creating the Monitoring Client object. Please check logs");
            return "";
        }
        // Generate Date in ISO 8601
        Date date = new Date(System.currentTimeMillis());
	    // Conversion
	    SimpleDateFormat sdf;
	    sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
	    sdf.setTimeZone(TimeZone.getTimeZone("CET"));
	    String ttime = sdf.format(date);

	 // {"timestamp": '$timestamp', "host": '$host', "region": '$region', "availabilityDomain": '$availabilityDomain', 
	 // "faultDomain": '$faultDomain', "shape": '$shape', 
	 // "cpu_mean": '$cpuval', "mem_mean": '$memval', "net_in": '$netinval', "net_out": '$netoutval' }

		String compartment = "ocid1.compartment.oc1..aaaaaaaa4gk5fmtbrfnkfrwwkoef5pmrvxu7dauh52hbisvnhx6rgas5jxja";
		String namespace = "oci_computeagent";
		
		String host = "Ubuntu-madhack-vrx";
		String region ="eu-frankfurt-1";
		String availabilityDomain = "VrTN:EU-FRANKFURT-1-AD-3";
		String faultDomain = "FAULT-DOMAIN-3";
		String shape = "VM.Standard2.4";
		
		
		String metricName;
		ListMetricsResponse resp;
		
		metricName = "CPUUtilization[1m]{resourceId = \"ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva\"}.mean()";
		resp= executeQuery(compartment, namespace, metricName);
		// response.getItems(); 
		// 4.214563820932875|3.850824792171347|2126.26|1966.16
		String cpuval = "4.214563820932875";
		
		metricName = "MemoryUtilization[1m]{resourceId = \"ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva\"}.mean()";
		resp= executeQuery(compartment, namespace, metricName);
		String memval = "3.850824792171347";
		
		metricName = "NetworksBytesIn[1m]{resourceId = \"ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva\"}.rate()";
		resp= executeQuery(compartment, namespace, metricName);
		String netinval = "2126.26";
		
		metricName = "NetworksBytesOut[1m]{resourceId = \"ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva\"}.rate()";
		resp= executeQuery(compartment, namespace, metricName);
		String netoutval = "1966.16";
		
		return "{\"timestamp\": \"" +ttime+ "\", \"host\": \""+host+"\", \"region\": \""+region+"\", " +
				"\"availabilityDomain\": \""+availabilityDomain+"\", "+
			    "\"faultDomain\": \""+faultDomain+"\", \"shape\": \""+shape+"\", "+
			    "\"cpu_mean\": "+cpuval+", \"mem_mean\": "+memval+", \"net_in\": "+
			    netinval+", \"net_out\": "+netoutval+" }";
    }


    
    public ListMetricsResponse executeQuery(String compartment, String namespace, String metricName){
    	ListMetricsResponse response = null;
    	try {
	        final ListMetricsRequest request =
	                ListMetricsRequest.builder()
	                        .compartmentId(compartment)
	                        .listMetricsDetails(
	                                ListMetricsDetails.builder()
	                                        .namespace(namespace)
	                                        .name(metricName)
	                                        .build())
	                        .build();

	        System.out.printf("Request constructed:\n%s\n\n", request.getListMetricsDetails());
	
	        System.out.println("Sending...");
	        response = monitoringClient.listMetrics(request);
	        
    	} catch (Throwable e) {
          System.err.println("Error fetching Metrics Request: " + e.getMessage());
    	}
    	return response;
    }
    

}
