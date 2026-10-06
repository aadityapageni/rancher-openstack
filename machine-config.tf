# Corresponds to the options entered after selecting
# OpenStack in the Rancher cluster creation wizard.
# Values mirror the live nc-rke2-pool1-mddm8 machine config.
resource "rancher2_machine_config_v2" "openstack" {
  generate_name = "openstack-rke2-"

  openstack_config {
    auth_url          = var.openstack_auth_url
    username          = var.openstack_username
    password          = var.openstack_password
    region            = var.openstack_region
    availability_zone = var.openstack_availability_zone
    endpoint_type     = var.openstack_endpoint_type

    domain_name        = var.openstack_domain_name
    user_domain_name   = var.openstack_user_domain_name != "" ? var.openstack_user_domain_name : null
    tenant_name        = var.openstack_project_name
    tenant_domain_name = var.openstack_tenant_domain_name != "" ? var.openstack_tenant_domain_name : null

    image_name  = var.openstack_image_name
    flavor_name = var.openstack_flavor_name
    net_name    = var.openstack_network_name

    keypair_name = var.openstack_keypair_name
    sec_groups   = var.openstack_security_groups

    floating_ip_pool = var.openstack_floating_ip_pool != "" ? var.openstack_floating_ip_pool : null

    ssh_user = var.openstack_ssh_user

    boot_from_volume = true
    volume_size      = var.openstack_volume_size
    volume_type      = var.openstack_volume_type != "" ? var.openstack_volume_type : null

    config_drive = true
    insecure     = false

    # Live is empty; a value here REPLACES Rancher bootstrap userdata.
    # cloud-init.yaml in this repo is kept as reference content only.
    user_data_file = var.openstack_user_data_file != "" ? var.openstack_user_data_file : null
  }
}
