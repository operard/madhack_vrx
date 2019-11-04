import io
import sys
import json
import oci
import oci.monitoring as monitoring
import oci.monitoring.models as models
from datetime import datetime, timedelta
from fdk import response

class OCIGetMetrics:
    def __init__(self, compartment_id, name_space, query):
        self._compartmentID = compartment_id
        self._name_space = name_space
        self._query = query
        self.monitoring_client = self.init_monitor_client()

    @property
    def compartment_id(self):
        return self._compartmentID

    @property
    def name_space(self):
        return self._name_space

    @property
    def query(self):
        return self._query

    @staticmethod
    def init_monitor_client():
        # Load the default configuration
        # config = oci.config.from_file()

        monitoring_client = monitoring.MonitoringClient(config)
        return monitoring_client

    def get_metrics(self):
        end_time = datetime.utcnow()
        start_time = str((datetime.utcnow() - timedelta(hours=1, minutes=5)).isoformat()[:-3]) + 'Z'

        summarize_metrics_data_details = models.SummarizeMetricsDataDetails(
            namespace=self.name_space,
            query=self.query,
            start_time=start_time,
            end_time=end_time
        )
        response = self.monitoring_client.summarize_metrics_data(
            compartment_id=self.compartment_id,
            summarize_metrics_data_details=summarize_metrics_data_details)
        return response



def handler(ctx, data: io.BytesIO=None):
    compartmentID = "ocid1.compartment.oc1..aaaaaaaa4gk5fmtbrfnkfrwwkoef5pmrvxu7dauh52hbisvnhx6rgas5jxja"
    namespace = "oci_computeagent"
    query = "CPUUtilization[1m]{resourceId = \"ocid1.instance.oc1.eu-frankfurt-1.antheljrqtij3macskkzfsvile75zoka7hmrga3opeuwcycogz5s62hfczva\"}.mean()"
    try:
        body = json.loads(data.getvalue())
        # query = body.get("query")
        name = body.get("name")
        metrics_obj = OCIGetMetrics(compartmentID, namespace, query)
        if sys.getsizeof(name) > 40:
           name = "Toni"
        databeta = metrics_obj.get_metrics().data

    except (Exception, ValueError) as ex:
        print(str(ex))

    return response.Response(
        ctx, response_data=json.dumps(
            {"availabilityDomain": "VrTN:EU-FRANKFURT-1-AD-3", 
             "cpu_mean": 6.094046517476844, 
             "faultDomain": "FAULT-DOMAIN-3", 
             "host": "Ubuntu-madhack-vrx", 
             "mem_mean": 3.931413040783038, 
             "net_in": 18619.02, 
             "net_out": 20041.54, 
             "region": "eu-frankfurt-1", 
             "shape": "VM.Standard2.4", 
             "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S")}),
          #    {"message": "hola {0}".format(name)}),
        headers={"Content-Type": "application/json"}
    )
    # return metrics_obj.get_metrics().data
