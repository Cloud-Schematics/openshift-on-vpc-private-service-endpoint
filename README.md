# Red Hat OpenShift Cluster on VPC Using Private Service Endpoint

This template creates a Red Hat OpenShift cluster with the Public Service Endpoint disabled on an existing VPC. To create this cluster, a COS instance is created for cluster storage, and a Key Protect instance is created for encryption. This template creates a VSI to create an NLB Proxy for cluster access.

To create a VPC for your cluster, use the [Multizone VPC Gen2 Asset](https://github.com/Cloud-Schematics/multizone-vpc-gen2)

![OpenShift Cluster](./.docs/roks-cluster.png)

*Note: this template assumes that the VSI created will have access to the public internet*

---

## Table of Contents

1. [Resources](##resources)
2. [Cluster](##Cluster)
3. [Worker Pools](##worker-pools-(optional))
4. [Virtual Server and NLB Proxy](##Virtual-Server-and-NLB-Proxy)
4. [Variables](##Variables)

---

## Resources

This module creates an IBM Cloud Object Stroage instance required for the creation of an OpenShift cluster. This module also creates a Key Protect instance and a Key Protect Root Key to encrypt the cluster. To ensure that the COS instance has access to the cluster, an authorization policy is created to allow the Key Protect instance to read from the COS instance.

These resources can be found in the [./resources](./resources) module.

---

## Cluster

This module creates a Red Hat OpenShift cluster across any number of existing subnets on an existing VPC.

The cluster is created in [cluster.tf](./cluster.tf)

---

## Worker Pools (Optional)

This module can optionally create any number of worker pools across the same subnets where the cluster is created. 

The worker pools are created in [./worker_pools](./worker_pools)

---

## Virtual Server and NLB Proxy

This template creates a single VSI to create an NLB Proxy to allow access to the cluster via the Private Service Endpoint. To read more about accessing the cluster through a private service endpoint refer to the [documentation here](https://cloud.ibm.com/docs/containers?topic=containers-access_cluster#access_private_se).

The virtual server by default uses the [install_terraform_vsi](./scripts/install_terraform_vsi.sh) script to install terraform, write the script inside the VSI, and run the script.

In addition, the IBM Cloud CLI, kubectl CLI, and OpenShift CLI are installed inside the VSI to test connectivity.

The VSI is created in [nlb_proxy_via_vsi.tf](./nlb_proxy_via_vsi.tf)

To view the code that will be installed on the VSI, refer to the [./scripts/nlb_terraform](./scripts/nlb_terraform) folder.

---

Variable                        | Type   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Default
------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |--------
ibmcloud_api_key                | string | The IBM Cloud platform API key needed to deploy IAM enabled resources                                                                                                                                                                                                                                                                                                                                                                                                                 | 
ibm_region                      | string | IBM Cloud region where all resources will be deployed                                                                                                                                                                                                                                                                                                                                                                                                                                 | 
resource_group                  | string | Name of resource group where all infrastructure will be provisioned                                                                                                                                                                                                                                                                                                                                                                                                                   | `"asset-development"`
unique_id                       | string | A unique identifier need to provision resources. Must begin with a letter                                                                                                                                                                                                                                                                                                                                                                                                             | `"asset-roks"`
vpc_name                        | string | Name of VPC where cluster is to be created                                                                                                                                                                                                                                                                                                                                                                                                                                            | 
subnet_names                    | list(s | List of subnet names                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `[ "asset-multizone-zone-1-subnet-1", "asset-multizone-zone-1-subnet-2", "asset-multizone-zone-1-subnet-3" ]`
machine_type                    | string | The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region.                                                                                                                                                                                                                                                                                                                                                                        | `"bx2.4x16"`
workers_per_zone                | number | Number of workers to provision in each subnet                                                                                                                                                                                                                                                                                                                                                                                                                                         | `2`
disable_public_service_endpoint | bool   | Disable public service endpoint for cluster                                                                                                                                                                                                                                                                                                                                                                                                                                           | `true`
entitlement                     | string | If you purchased an IBM Cloud Cloud Pak that includes an entitlement to run worker nodes that are installed with OpenShift Container Platform, enter entitlement to create your cluster with that entitlement so that you are not charged twice for the OpenShift license. Note that this option can be set only when you create the cluster. After the cluster is created, the cost for the OpenShift license occurred and you cannot disable this charge.                           | `"cloud_pak"`
kube_version                    | string | Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`.                                                                                                                                                                                                                                                                                                                                                             | `"4.5.37_openshift"`
wait_till                       | string | To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`   | `"IngressReady"`
tags                            | list(s | A list of tags to add to the cluster                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `[]`
worker_pools                    | list(o | List of maps describing worker pools                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `[`<br>`{`<br>`pool_name = "dev"`<br>`machine_type = "cx2.8x16"`<br>`workers_per_zone = 2`<br>`},`<br>`{`<br>`pool_name = "test"`<br>`machine_type = "mx2.4x32"`<br>`workers_per_zone = 2`<br>`}`<br>`]`
service_endpoints               | string | Service endpoints for resource instances. Can be `public`, `private`, or `public-and-private`.                                                                                                                                                                                                                                                                                                                                                                                        | `"private"`
kms_plan                        | string | Plan for Key Protect                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `"tiered-pricing"`
kms_root_key_name               | string | Name of the root key for Key Protect instance                                                                                                                                                                                                                                                                                                                                                                                                                                         | `"root-key"`
kms_private_service_endpoint    | bool   | Use private service endpoint for Key Protect instance                                                                                                                                                                                                                                                                                                                                                                                                                                 | `true`
cos_plan                        | string | Plan for Cloud Object Storage instance                                                                                                                                                                                                                                                                                                                                                                                                                                                | `"standard"`
vsi_image                       | string | Image name used for VSI. Run 'ibmcloud is images' to find available images in a region                                                                                                                                                                                                                                                                                                                                                                                                | `"ibm-centos-7-6-minimal-amd64-2"`
ssh_public_key                  | string | ssh public key to use for vsi                                                                                                                                                                                                                                                                                                                                                                                                                                                         | 
vsi_machine_type                | string | VSI machine type. Run 'ibmcloud is instance-profiles' to get a list of regional profiles                                                                                                                                                                                                                                                                                                                                                                                              | `"bx2-8x32"