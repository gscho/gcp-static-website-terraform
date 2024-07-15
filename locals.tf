locals {
  website_name = replace(var.website_domain_name, ".", "-")
}