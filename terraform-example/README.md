### CloudStack VPC with 1 Tier and 1 Centos 7 VM ###
1) fill in the following variables in the terraform.tfvars file:

* api_url = "https://" 
* api_key = ""
* secret_key = ""
* zone = ""
* server1_hostname = ""
* instance_ssh_keypairname  = ""
* offering_compute_medium = ""

2) Install Terraform

https://terraform.io/downloads.html

3) Run Terraform plan 
- navigate to plan directory
- execute: terraform plan

4) Run Terraform apply
- execute: terraform apply

5) Login
- ssh -i cloudstack.pem bootstrap@""public_ip_address""
