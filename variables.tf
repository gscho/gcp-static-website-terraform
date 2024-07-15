variable "project_id" {
  description = "The GCP project ID to deploy into"
}

variable "region" {
  description = "The GCP region to deploy to"
}

variable "website_location" {
  description = "The location of the website bucket"
  default     = "US"
}

variable "index_html_page" {
  description = "The main page for the website"
  default     = "index.html"
}

variable "not_found_page" {
  description = "The 404 not found page for the website"
  default     = "404.html"
}

variable "website_domain_name" {
  description = "The domain name for the website eg: example.com"
}

variable "website_subdomain_names" {
  description = "The subdomain names for the website eg: ['www', 'blog']"
  type        = list(string)
}