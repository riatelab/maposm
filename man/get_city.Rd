% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_city.R
\name{get_city}
\alias{get_city}
\title{Get City Map Layers}
\usage{
get_city(x, r = 1000, verbose = TRUE)
}
\arguments{
\item{x}{city center coordinates}

\item{r}{radi of the extraction}

\item{verbose}{output messages}
}
\value{
A list of layers is returned.
}
\description{
Download various OpenStreetMap
features to create city map layers.
}
\examples{
\dontrun{
bb1 <- osmdata::getbb("Gare Matabiau, 31000 TOULOUSE, France")
lon <- mean(bb1[1, ])
lat <- mean(bb1[2, ])
res <- get_city(c(lon, lat), dist = 700)
if (require("mapsf")){
  mf_map(res$zone, col = "#f2efe9", border = NA, add = FALSE)
  mf_map(res$green, col = "#c8facc", border = "#c8facc", lwd = .5, add = TRUE)
  mf_map(res$water, col = "#aad3df", border = "#aad3df", lwd = .5, add = TRUE)
  mf_map(res$railway, col = "grey50", lty = 2, lwd = .2, add = TRUE)
  mf_map(res$road, col = "white", border = "white", lwd = .5, add = TRUE)
  mf_map(res$street, col = "white", border = "white", lwd = .5, add = TRUE)
  mf_map(res$building, col = "#d9d0c9", border = "#c6bab1", lwd = .5, add = TRUE)
  mf_map(res$zone, col = NA, border = "#c6bab1", lwd = 4, add = TRUE)
}
}
}
