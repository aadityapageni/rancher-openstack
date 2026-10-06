# Rancher provisions OpenStack VMs through the node driver
# and joins them to this RKE2 cluster. This is the code equivalent
# of "Select OpenStack provider" in the Rancher UI wizard
# (not a custom-cluster registration flow).
#
# Shape mirrors the live "rke2" cluster: a single all-roles pool.
resource "rancher2_cluster_v2" "openstack" {
  name               = var.cluster_name
  kubernetes_version = var.rke2_version

  rke_config {
    machine_global_config = yamlencode({
      cni = "cilium"
    })

    machine_pools {
      name               = "pool1"
      quantity           = var.node_count
      control_plane_role = true
      etcd_role          = true
      worker_role        = true

      cloud_credential_secret_name = rancher2_cloud_credential.openstack.id

      machine_config {
        kind = rancher2_machine_config_v2.openstack.kind
        name = rancher2_machine_config_v2.openstack.name
      }
    }

    upgrade_strategy {
      control_plane_concurrency = "1"
      worker_concurrency        = "1"
    }

    etcd {
      snapshot_schedule_cron = var.etcd_snapshot_schedule_cron
      snapshot_retention     = 5
    }

    # Slow OpenStack storage needs relaxed etcd timing (measured fsync
    # avg ~70ms, max >400ms on both ephemeral and Cinder volumes here).
    # Without this, rke2-server loses leader election and crashloops.
    # cloud-provider-config enables the external OpenStack cloud provider
    # (node addresses, taint init, LBs); the CCM itself is delivered via
    # machine_selector_files below.
    machine_selector_config {
      config = yamlencode({
        protect-kernel-defaults = false
        cloud-provider-name     = "external"
        cloud-provider-config = templatefile("${path.module}/files/cloud-provider-config.tmpl", {
          auth_url     = var.openstack_auth_url
          username     = var.openstack_username
          password     = var.openstack_password
          tenant_id    = var.openstack_tenant_id
          region       = var.openstack_region
          domain_name  = var.openstack_domain_name
          lb_subnet_id = var.openstack_lb_subnet_id
          router_id    = var.openstack_router_id
        })
        etcd-arg = [
          "heartbeat-interval=500",
          "election-timeout=5000",
        ]
      })
    }

    # Zero-touch node fixes, delivered to nodes before RKE2 starts so no
    # SSH is ever needed: OpenStack CCM (external cloud provider) and the
    # systemd-resolved stub workaround, both as RKE2 auto-manifests.
    machine_selector_files {
      machine_label_selector {}

      file_sources {
        secret {
          name                = rancher2_secret_v2.node_boot_files.name
          default_permissions = "600"

          items {
            key         = "openstack-ccm.yaml"
            path        = "/var/lib/rancher/rke2/server/manifests/openstack-ccm.yaml"
            permissions = "600"
            dynamic     = false
          }

          items {
            key         = "node-dns-fix.yaml"
            path        = "/var/lib/rancher/rke2/server/manifests/node-dns-fix.yaml"
            permissions = "600"
            dynamic     = false
          }
        }
      }
    }
  }
}
