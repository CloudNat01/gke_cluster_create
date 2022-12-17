#!/bin/bash

# Check if all required arguments are provided
if [ $# -ne 5 ]; then
  echo "Usage: create-gke-cluster.sh cluster-name project-id region zone env"
  exit 1
fi

# Assign arguments to variables
CLUSTER_NAME=$1
PROJECT_ID=$2
REGION=$3
ZONE=$4
ENV=$5

cat <<EOF > cluster.tf 
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = $PROJECT_ID
  name                       = $CLUSTER_NAME
  region                     = $REGION
  zones                      = $ZONE
  network                    = "vpc-01"
  subnetwork                 = "us-central1-01"
  ip_range_pods              = "us-central1-01-gke-01-pods"
  ip_range_services          = "us-central1-01-gke-01-services"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  node_pools = [
    {
      name                      = "${ENV}-NODE"
      machine_type              = "e2-medium"
      node_locations            = "us-central1-b,us-central1-c"
      min_count                 = 1
      max_count                 = 100
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      auto_repair               = true
      auto_upgrade              = true
    #   service_account           = "project-service-account@$PROJECT_ID.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 5
    },
  ]

#   node_pools_oauth_scopes = {
#     all = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]
#   }

#   node_pools_labels = {
#     all = {}

#     default-node-pool = {
#       default-node-pool = true
#     }
#   }

#   node_pools_metadata = {
#     all = {}

#     default-node-pool = {
#       node-pool-metadata-custom-value = "my-node-pool"
#     }
#   }

#   node_pools_taints = {
#     all = []

#     default-node-pool = [
#       {
#         key    = "default-node-pool"
#         value  = true
#         effect = "PREFER_NO_SCHEDULE"
#       },
#     ]
#   }

#   node_pools_tags = {
#     all = []

#     default-node-pool = [
#       "default-node-pool",
#     ]
#   }
}
EOF