# Zero-touch node bootstrapping for OpenStack RKE2 nodes.
#
# Two problems are fixed without any SSH access to the nodes:
#  1. The OpenStack cloud-controller-manager is required (cluster uses an
#     external cloud provider) but nothing installs it before the
#     cattle-cluster-agent can connect. It is delivered as an RKE2
#     auto-manifest so rke2-server applies it on first boot.
#  2. Ubuntu's systemd-resolved stub /etc/resolv.conf (127.0.0.53) is
#     unreachable from pod network namespaces, which breaks CoreDNS
#     upstream resolution. A tiny hostNetwork DaemonSet (also an RKE2
#     auto-manifest, running before CNI is needed) replaces the symlink
#     with a static file on every boot.
locals {
  cloud_conf = templatefile("${path.module}/files/cloud.conf.tmpl", {
    auth_url     = var.openstack_auth_url
    username     = var.openstack_username
    password     = var.openstack_password
    region       = var.openstack_region
    tenant_name  = var.openstack_project_name
    domain_name  = var.openstack_domain_name
    lb_subnet_id = var.openstack_lb_subnet_id
  })

  cloud_config_secret_yaml = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "cloud-config"
      namespace = "kube-system"
    }
    type = "Opaque"
    data = {
      "cloud.conf" = base64encode(local.cloud_conf)
    }
  })

  openstack_ccm_yaml = "${local.cloud_config_secret_yaml}\n---\n${file("${path.module}/files/openstack-ccm-static.yaml")}"

  node_dns_fix_yaml = templatefile("${path.module}/files/node-dns-fix.yaml.tmpl", {
    nameservers_printf = "'${join("\\n", [for s in var.node_dns_servers : "nameserver ${s}"])}\\n'"
  })
}

resource "rancher2_secret_v2" "node_boot_files" {
  cluster_id = "local"
  name       = "node-boot-files"
  namespace  = "fleet-default"

  annotations = {
    "rke.cattle.io/object-authorized-for-clusters" = var.cluster_name
  }

  data = {
    "openstack-ccm.yaml" = local.openstack_ccm_yaml
    "node-dns-fix.yaml"  = local.node_dns_fix_yaml
  }
}
