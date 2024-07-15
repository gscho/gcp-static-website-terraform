resource "google_compute_backend_bucket" "static_website" {
  name        = "${local.website_name}-backend"
  description = "Source files for the website ${var.website_domain_name}"
  bucket_name = google_storage_bucket.static_website.name
  enable_cdn  = true
}

resource "google_certificate_manager_dns_authorization" "static_website" {
  name   = "${local.website_name}-dns-authorization"
  domain = var.website_domain_name
}

resource "google_dns_record_set" "static_website_authorization" {
  project      = var.project_id
  name         = google_certificate_manager_dns_authorization.static_website.dns_resource_record[0].name
  type         = "CNAME"
  ttl          = 30
  managed_zone = google_dns_managed_zone.static_website.name
  rrdatas      = [google_certificate_manager_dns_authorization.static_website.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate" "static_website" {
  name = "${local.website_name}-cert"
  managed {
    domains = [
      var.website_domain_name,
      "*.${var.website_domain_name}"
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.static_website.id,
    ]
  }
  depends_on = [
    google_dns_record_set.static_website
  ]
}

resource "google_certificate_manager_certificate_map" "static_website" {
  name        = "emissary-public-lb-cert-map"
  description = "Emissary ingress public LoadBalancer certificate map"
}

resource "google_certificate_manager_certificate_map_entry" "static_website" {
  name         = "emissary-public-lb-gcp-wildcard-cert-map-entry"
  map          = google_certificate_manager_certificate_map.static_website.name
  certificates = [google_certificate_manager_certificate.static_website.id]
  hostname     = "*.${var.website_domain_name}"
}

resource "google_compute_url_map" "static_website" {
  name            = "${local.website_name}-url-map"
  default_service = google_compute_backend_bucket.static_website.self_link
}

resource "google_compute_target_https_proxy" "static_website" {
  name                             = "${local.website_name}-target-proxy"
  url_map                          = google_compute_url_map.static_website.self_link
  certificate_map  = "https://certificatemanager.googleapis.com/v1/${google_certificate_manager_certificate_map.static_website.id}"
}

resource "google_compute_global_forwarding_rule" "static_website" {
  name                  = "${local.website_name}-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.static_website.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.static_website.self_link
}