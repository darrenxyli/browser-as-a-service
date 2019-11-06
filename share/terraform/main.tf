terraform {
  required_version = ">= 0.12"

  backend "s3" {
  }
}

provider "aws" {
  version = "2.14.0"

  region = var.aws_region
}

provider "template" {
  version = "2.1.2"
}

data "template_file" "container_definitions" {
  template = file("${path.module}/container-definitions.json")

  vars {
    name      = var.name
    image     = "${var.docker_repo}/${var.name}:${var.docker_image_tag}"
    log_level = var.log_level
  }
}

module "browser-as-a-service" {
  source = "github.com/antifragile-systems/antifragile-service"

  name                  = var.name
  domain_name           = var.domain_name
  container_definitions = data.template_file.container_definitions.rendered

  api_enabled      = 1
  api_keys         = var.api_keys
  api_quota_limit  = 1000
  api_quota_offset = 0
  api_quota_period = "DAY"
  aws_region       = var.aws_region
}
