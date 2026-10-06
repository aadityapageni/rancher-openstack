# Equivalent to the credentials entered in the Rancher UI
# when selecting OpenStack as the cloud provider.
# The OpenStack cloud credential only stores `password`;
# all other connection details live in rancher2_machine_config_v2.
resource "rancher2_cloud_credential" "openstack" {
  name        = var.cloud_credential_name
  description = "OpenStack credentials for Rancher node provisioning"

  openstack_credential_config {
    password = var.openstack_password
  }
}
