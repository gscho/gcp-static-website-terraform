resource "google_compute_global_address" "static_website" {
  name = "${local.website_name}-static-ip"
}

resource "google_dns_managed_zone" "static_website" {
  name     = "${local.website_name}-zone"
  dns_name = "${var.website_domain_name}."
}

resource "google_dns_record_set" "static_website" {
  count        = length(var.website_subdomain_names)
  name         = "${var.website_subdomain_names[count.index]}.${google_dns_managed_zone.static_website.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.static_website.name
  rrdatas      = [google_compute_global_address.static_website.address]
}