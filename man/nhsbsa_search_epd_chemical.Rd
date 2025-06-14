% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/epd.R
\name{nhsbsa_search_epd_chemical}
\alias{nhsbsa_search_epd_chemical}
\title{Search EPD by Chemical Name}
\usage{
nhsbsa_search_epd_chemical(
  chemical_pattern,
  year,
  month = NULL,
  exact_match = FALSE,
  limit = NULL
)
}
\arguments{
\item{chemical_pattern}{Character. Pattern to search for in chemical names}

\item{year}{Integer. Year to search in}

\item{month}{Integer. Month to search in (optional, defaults to latest available)}

\item{exact_match}{Logical. Whether to use exact matching (default: FALSE)}

\item{limit}{Integer. Maximum number of records to return (optional)}
}
\value{
A data frame containing matching prescribing data
}
\description{
Search for prescribing data by chemical substance name or pattern.
This function first looks up the BNF chemical codes matching the search term.
}
\examples{
\dontrun{
# Search for paracetamol prescriptions
paracetamol <- nhsbsa_search_epd_chemical(
  chemical_pattern = "paracetamol",
  year = 2024,
  month = 1
)

# Search for antibiotics (partial match)
antibiotics <- nhsbsa_search_epd_chemical(
  chemical_pattern = "penicillin",
  year = 2024
)
}
}
