data "scaleway_k8s_version" "latest" {
  name = "latest"
}

resource "scaleway_vpc_private_network" "kapsule" {
  name = "pn_kapsule"
  tags = ["kapsule"]
}

resource "scaleway_k8s_cluster" "kapsule" {
  name                        = "open-pn-test"
  version                     = data.scaleway_k8s_version.latest.name
  cni                         = "cilium"
  private_network_id          = scaleway_vpc_private_network.kapsule.id
  delete_additional_resources = true
  depends_on                  = [scaleway_vpc_private_network.kapsule]
}

resource "scaleway_instance_security_group" "kapsule" {
  name                    = "kubernetes ${split("/", scaleway_k8s_cluster.kapsule.id)[1]}"
  inbound_default_policy  = "accept"
  outbound_default_policy = "accept"
  stateful                = true
  depends_on              = [scaleway_k8s_cluster.kapsule]
}

resource "scaleway_k8s_pool" "default" {
  cluster_id          = scaleway_k8s_cluster.kapsule.id
  name                = "default"
  node_type           = "PLAY2-NANO"
  size                = 2
  min_size            = 1
  max_size            = 3
  autohealing         = true
  autoscaling         = true
  wait_for_pool_ready = true
  depends_on          = [scaleway_instance_security_group.kapsule]
}
