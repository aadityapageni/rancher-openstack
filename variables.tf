# All values live in terraform.tfvars (see terraform.tfvars.example).
# No defaults here on purpose: every setting is explicit per environment.
variable "rancher_url" {
  description = "Rancher API URL, e.g. https://rancher.example.com"
  type        = string
}

variable "rancher_token" {
  description = "Rancher token_key, format token-xxxxx:yyyyyyyy. Prefer env var TF_VAR_rancher_token."
  type        = string
  sensitive   = true
}

variable "openstack_auth_url" {
  description = "Keystone auth URL, e.g. https://openstack.example.com:5000/v3"
  type        = string
}

variable "openstack_username" {
  description = "OpenStack username (ignored when application credentials are used)"
  type        = string
}

variable "openstack_password" {
  description = "OpenStack password or application credential secret"
  type        = string
  sensitive   = true
}

variable "openstack_region" {
  type = string
}

variable "openstack_availability_zone" {
  description = "Nova availability zone. Empty means no AZ constraint (matches live cluster)."
  type        = string
}

# Keystone v3 domain / project scoping, mirroring the live cluster
# (domain_name + tenant_name only; user/tenant domain names empty).
variable "openstack_domain_name" {
  description = "User domain name (Keystone v3). Conflicts with domain_id."
  type        = string
}

variable "openstack_user_domain_name" {
  description = "User domain name. Empty matches the live cluster."
  type        = string
}

variable "openstack_project_name" {
  description = "Tenant/project name (Keystone v3). Conflicts with tenant_id."
  type        = string
}

variable "openstack_tenant_domain_name" {
  description = "Tenant domain name. Empty matches the live cluster."
  type        = string
}

variable "openstack_tenant_id" {
  description = "Keystone project UUID, used in the RKE2 cloud-provider config. Conflicts with tenant_name there; the machine config uses the name."
  type        = string
}

variable "openstack_router_id" {
  description = "Neutron router ID for the RKE2 cloud-provider [Route] section."
  type        = string
}

variable "openstack_image_name" {
  description = "Glance image name. Conflicts with image_id."
  type        = string
}

variable "openstack_flavor_name" {
  description = "Nova flavor name. Conflicts with flavor_id."
  type        = string
}

variable "openstack_network_name" {
  description = "Neutron network name. Conflicts with net_id."
  type        = string
}

variable "openstack_endpoint_type" {
  description = "Keystone endpoint interface."
  type        = string
}

variable "openstack_keypair_name" {
  description = "Existing Nova keypair name for SSH access. Empty lets the driver generate an ephemeral one (matches live)."
  type        = string
}

variable "openstack_user_data_file" {
  description = "Path (on the provisioner side) to extra user data. Empty matches live; setting it REPLACES Rancher bootstrap userdata, use with care."
  type        = string
}

variable "openstack_security_groups" {
  description = "Comma-separated security groups, e.g. \"default,rancher-nodes\""
  type        = string
}

variable "openstack_ssh_user" {
  type = string
}

variable "openstack_volume_size" {
  description = "Root volume size in GiB (required when boot_from_volume = true)"
  type        = string
}

variable "openstack_volume_type" {
  description = "Cinder volume type, e.g. ceph-ssd. Omit (\"\") if cloud has a default."
  type        = string
}

variable "openstack_floating_ip_pool" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "rke2_version" {
  description = "Exact RKE2 version, e.g. v1.36.4+rke2r1"
  type        = string
}

variable "node_count" {
  description = "Nodes in the single all-roles pool (matches live single-node cluster)"
  type        = number
}

variable "cloud_credential_name" {
  type = string
}

variable "node_dns_servers" {
  description = "Upstream DNS servers written to nodes (systemd stub 127.0.0.53 is unreachable from pods)"
  type        = list(string)
}

variable "openstack_lb_subnet_id" {
  description = "Neutron subnet ID for OpenStack LoadBalancer VIPs. Matches live; empty disables the LB section."
  type        = string
}

variable "etcd_snapshot_schedule_cron" {
  description = "etcd snapshot schedule (hourly is safer on slow storage)"
  type        = string
}
