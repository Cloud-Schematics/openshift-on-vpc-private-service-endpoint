##############################################################################
# Cluster Outputs
##############################################################################

output cluster_name {
    description = "Name of the cluster that is created"
    value       = ibm_container_vpc_cluster.cluster.name
}

output cluster_id {
    description = "ID of cluster created"
    value       = ibm_container_vpc_cluster.cluster.id
}

output cluster_private_service_endpoint_port {
    description = "Port of the private service endpoint to use for creation of an NLB"
    value       = split(":", ibm_container_vpc_cluster.cluster.private_service_endpoint_url)[2]
}

##############################################################################