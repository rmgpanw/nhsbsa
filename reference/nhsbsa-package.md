# nhsbsa: Client for the NHS Business Services Authority Open Data Portal

A low-level client for the NHS Business Services Authority (NHSBSA) Open
Data Portal <https://opendata.nhsbsa.net>, a 'CKAN' data catalogue.
Provides thin wrappers around the portal's API actions for listing
datasets, retrieving metadata, querying the datastore and downloading
resource files. Results are returned as plain data (tibbles and lists)
for the caller to interpret.

## Further reading

The portal is a standard CKAN catalogue. For background on the API this
package wraps, see:

- The portal's API page: <https://opendata.nhsbsa.net/pages/api>

- The CKAN Action API reference: <https://docs.ckan.org/en/latest/api/>

[`vignette("nhsbsa")`](https://rmgpanw.github.io/nhsbsa/articles/nhsbsa.md)
explains how the package maps onto what you see on the portal website,
and shows the different ways to query data.

## See also

Useful links:

- <https://github.com/rmgpanw/nhsbsa>

- <https://rmgpanw.github.io/nhsbsa/>

- Report bugs at <https://github.com/rmgpanw/nhsbsa/issues>

## Author

**Maintainer**: Alasdair Warwick <alasdair.warwick06@gmail.com>
([ORCID](https://orcid.org/0000-0002-0800-2890))
