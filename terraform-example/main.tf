## Configure the CloudStack Provider
provider "cloudstack" {
    api_url = "${var.api_url}"
    api_key = "${var.api_key}"
    secret_key = "${var.secret_key}"
}

## VPC definitions
resource "cloudstack_vpc" "vpc_1" {
    name = "${var.vpc_1_name}"
    cidr = "${var.vpc_1_cidr}"
    vpc_offering = "${var.offering_vpc}"
    zone = "${var.zone}"
    display_text = "${var.vpc_1_name}"
}

## Network ACLS
resource "cloudstack_network_acl" "acl-1" {
    name = "ACL-1"
    vpc = "${cloudstack_vpc.vpc_1.name}"
}

resource "cloudstack_network_acl_rule" "acl-rule-1" {
  aclid = "${cloudstack_network_acl.acl-1.id}"
  rule {
    action = "allow"
    source_cidr  = "${var.network_source_ip_remote}"
    protocol = "tcp"
    ports = ["22", "80"]
    traffic_type = "ingress"
  }
  rule {
    action = "allow"
    source_cidr  = "0.0.0.0/0"
    protocol = "all"
    traffic_type = "egress"
  }
}


## Subnets

resource "cloudstack_network" "subnet-1" {
    name = "DMZ"
    cidr = "10.10.1.0/24"
    network_offering = "${var.offering_network_lb}"
    zone = "${var.zone}"
    vpc = "${cloudstack_vpc.vpc_1.name}"
    aclid = "${cloudstack_network_acl.acl-1.id}"
}

## Public Ip addresses
resource "cloudstack_ipaddress" "pubip-1" {
    vpc = "${cloudstack_vpc.vpc_1.name}"
}

resource "cloudstack_port_forward" "forward-1" {
    ipaddress = "${cloudstack_ipaddress.pubip-1.ipaddress}"
    forward {
        protocol = "tcp"
        private_port = 22
        public_port = 22
        virtual_machine = "${cloudstack_instance.server1.name}"
    }
    forward {
        protocol = "tcp"
        private_port = 80
        public_port = 80
        virtual_machine = "${cloudstack_instance.server1.name}"
    }
}

## Instances
resource "cloudstack_instance" "server1" {
    name = "${var.server1_hostname}"
    service_offering = "${var.offering_compute_medium}"
    network = "${cloudstack_network.subnet-1.name}"
    template = "${var.compute_template_centos}"
    zone = "${var.zone}"
    expunge = "true"
    keypair = "${var.instance_ssh_keypairname}"
}

## output public allocated ip addressess
output "public-ip-1" {
    value = "${cloudstack_ipaddress.pubip-1.ipaddress}"
}
