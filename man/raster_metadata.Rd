% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/raster_metadata.R
\name{raster_metadata}
\alias{raster_metadata}
\title{Get metadata from raster paths}
\usage{
raster_metadata(raster_paths, meta = "all", format = "data.table")
}
\arguments{
\item{raster_paths}{A vector of raster paths.}

\item{meta}{Vector with the desired metadata: one or more values among
'res', 'size', 'bbox', 'proj', 'unit', 'outformat', 'type'.
Alternatively meta = 'all' (default) allows to return all metadata.}

\item{format}{One between \code{data.table} (default), \code{data.frame} and \code{list}.}
}
\value{
A data.table, data.frame or list of the output metadata.
}
\description{
This accessory function extract some useful metadata from
a vector of raster paths.
}
\note{
License: GPL 3.0
}
\examples{
# Define product names
examplenames <- c(
  system.file("tif/L7_ETMs.tif", package="stars"),
  system.file("extdata/out/S2A2A_20190723_022_Barbellino_BOA_10.tif",
    package = "sen2r")
)

\donttest{
# Return metadata as data.table
raster_metadata(examplenames)
}

# Return some metadata as data.table
raster_metadata(examplenames, c("res", "size", "bbox", "outformat"))

# Return some metadata as list
raster_metadata(examplenames, c("res", "size", "bbox", "proj"), format = "list")

# Output with an invalid raster
examplenames <- c(
  examplenames, 
  system.file("extdata/settings/gdal_formats.json", package="sen2r")
)
raster_metadata(examplenames, c("bbox", "proj"))
}
\author{
Luigi Ranghetti, phD (2019) \email{luigi@ranghetti.info}
}
