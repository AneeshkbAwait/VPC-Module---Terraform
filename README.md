# VPC-Module---Terraform

A Terraform module is a set of Terraform configuration files in a single directory. Even a simple configuration consisting of a single directory with one or more .tf files is a module. 

We can remove the overhead of rewriting the code for VPC creation each time when building infrastructure using Terraform. This VPC module can be used in situations where we want to create a VPC while infra building.

### Calling the Module

You can import the module in any of your project like below;
```sh
module "vpc" {
  source = "/var/terraform/modules/vpc/"
  vpc_cidr = var.project_vpc_cidr
  project  = var.project_name
  env      = var.project_environment
}
```sh

- source - Location of the Module
- vpc_cidr - Passing the VPC CIDR to the Module as a Variable
- project - Passing the Project Name to the Module as a Variable
- env - Passing the Project Environment to the Module as Variable
