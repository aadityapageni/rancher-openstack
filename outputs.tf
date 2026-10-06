output "cluster_id" {
  value = rancher2_cluster_v2.openstack.cluster_v1_id
}

output "kubeconfig" {
  value     = rancher2_cluster_v2.openstack.kube_config
  sensitive = true
}
