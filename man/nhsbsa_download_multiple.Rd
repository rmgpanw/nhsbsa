% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download.R
\name{nhsbsa_download_multiple}
\alias{nhsbsa_download_multiple}
\title{Download Multiple Resources}
\usage{
nhsbsa_download_multiple(
  resource_names,
  where_conditions = NULL,
  select_fields = "*",
  limit = NULL,
  combine = TRUE
)
}
\arguments{
\item{resource_names}{Character vector. Names or IDs of resources to query}

\item{where_conditions}{Named list. Field-value pairs for WHERE conditions}

\item{select_fields}{Character vector. Fields to select (default: all fields)}

\item{limit}{Integer. Maximum number of records per resource (default: no limit)}

\item{combine}{Logical. Whether to combine results into single data frame (default: TRUE)}
}
\value{
A data frame (if combine=TRUE) or list of data frames (if combine=FALSE)
}
\description{
Downloads and combines data from multiple resources. Useful for getting
data across multiple time periods.
}
\examples{
\dontrun{
# Download EPD data for multiple months
epd_resources <- c("EPD_202401", "EPD_202402", "EPD_202403")

multi_month_data <- nhsbsa_download_multiple(
  resource_names = epd_resources,
  where_conditions = list(
    pco_code = "13T00",
    bnf_chemical_substance = "0407010H0"
  )
)

# Download as separate data frames
separate_data <- nhsbsa_download_multiple(
  resource_names = epd_resources,
  where_conditions = list(pco_code = "13T00"),
  combine = FALSE
)
}
}
