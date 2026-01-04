import os

from diagrams.onprem.client import User
from diagrams.onprem.network import HAProxy
from diagrams.onprem.security import Vault

from diagrams import Cluster, Diagram, Edge

cur_file_dir = os.path.dirname(__file__)
filename = f"{cur_file_dir}/../assets/vault_transit_secrets_engine_architecture"
with Diagram(
    name="Vault transit secrets engine architecture", filename=filename, show=False, graph_attr=dict(fontsize="18")
):
    user = User()
    lb = HAProxy("Vault load balancer")
    vault_transit_secrets_engine = Vault("Transit secrets engine")
    with Cluster(label="Vault cluster", graph_attr=dict(fontsize="16")):
        vault_1 = Vault("leader node 1")
        vault_2 = Vault("standy node 2")
        vault_3 = Vault("standy node 3")
        vault_1 - vault_2
        vault_1 - vault_3
        vault_cluster = [vault_1, vault_2, vault_3]

    user >> lb >> vault_cluster >> Edge(label="unseal", fontsize="13", style="dashed") << vault_transit_secrets_engine
