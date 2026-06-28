# nhsbsa 0.1.0

* Initial release: a low-level client for the NHS Business Services Authority
  (NHSBSA) Open Data Portal, a CKAN data catalogue.
* Dataset endpoints: `nhsbsa_package_list()`, `nhsbsa_package_show()` and
  `nhsbsa_package_search()`.
* Resource endpoints and file download: `nhsbsa_resource_show()`,
  `nhsbsa_list_resources()` and `nhsbsa_download_resource()`.
* Datastore row queries: `nhsbsa_datastore_search()` and
  `nhsbsa_datastore_search_sql()`.
* Catalogue listings: `nhsbsa_organization_list()`, `nhsbsa_group_list()` and
  `nhsbsa_tag_list()`.
* `nhsbsa_package_show()`, `nhsbsa_resource_show()` and `nhsbsa_package_search()`
  return classed lists with tidy `print()` methods, and `tibble::as_tibble()`
  methods that turn a dataset into its resources and a search into one row per
  dataset.
