package main

import rego.v1

# Policy-as-code for the GKE cluster and node pools. Evaluated by conftest
# against the Terraform HCL source (conftest --parser hcl2), BEFORE plan.

# Node pools must use a dedicated (non-default) service account.
deny contains msg if {
	some name
	pool := input.resource.google_container_node_pool[name][_]
	nc := pool.node_config[_]
	not nc.service_account
	msg := sprintf("google_container_node_pool.%s: must set a dedicated service_account", [name])
}

deny contains msg if {
	some name
	pool := input.resource.google_container_node_pool[name][_]
	nc := pool.node_config[_]
	nc.service_account == "default"
	msg := sprintf("google_container_node_pool.%s: must not use the default compute service account", [name])
}

# Node pools must enable Shielded VM secure boot.
deny contains msg if {
	some name
	pool := input.resource.google_container_node_pool[name][_]
	nc := pool.node_config[_]
	not secure_boot_enabled(nc)
	msg := sprintf("google_container_node_pool.%s: must enable shielded secure boot", [name])
}

secure_boot_enabled(nc) if {
	sic := nc.shielded_instance_config[_]
	sic.enable_secure_boot == true
}

# Node pools must run the GKE metadata server (Workload Identity).
deny contains msg if {
	some name
	pool := input.resource.google_container_node_pool[name][_]
	nc := pool.node_config[_]
	not gke_metadata(nc)
	msg := sprintf("google_container_node_pool.%s: must set workload_metadata_config mode = GKE_METADATA", [name])
}

gke_metadata(nc) if {
	wmc := nc.workload_metadata_config[_]
	wmc.mode == "GKE_METADATA"
}

# Cluster must enable Workload Identity.
deny contains msg if {
	some name
	cluster := input.resource.google_container_cluster[name][_]
	not cluster.workload_identity_config
	msg := sprintf("google_container_cluster.%s: must enable Workload Identity", [name])
}

# Cluster must enable Shielded Nodes.
deny contains msg if {
	some name
	cluster := input.resource.google_container_cluster[name][_]
	cluster.enable_shielded_nodes != true
	msg := sprintf("google_container_cluster.%s: must set enable_shielded_nodes = true", [name])
}

# Cluster must use private nodes.
deny contains msg if {
	some name
	cluster := input.resource.google_container_cluster[name][_]
	not private_nodes(cluster)
	msg := sprintf("google_container_cluster.%s: must enable private nodes", [name])
}

private_nodes(cluster) if {
	pcc := cluster.private_cluster_config[_]
	pcc.enable_private_nodes == true
}
