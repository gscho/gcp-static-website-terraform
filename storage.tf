resource "google_storage_bucket" "static_website" {
  name     = var.website_domain_name
  location = var.website_location
  website {
    main_page_suffix = var.index_html_page
    not_found_page   = var.not_found_page
  }
}

# Objects need to be public so that they can be used as a static website
resource "google_storage_default_object_access_control" "static_website" {
  bucket = google_storage_bucket.static_website.name
  role   = "READER"
  entity = "allUsers"
}