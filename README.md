
# maposm <img src="man/figures/logo.png" align="right" width="140"/>

The [OpenStreetMap](https://www.openstreetmap.org/) database provides
numerous and very detailed geographic layers on a global scale. To
obtain synthetic information that can be used for cartographic purposes,
layers must be selected, simplified, merged, or modified.  
The `maposm` package provides a set of composite layers that are built
from extractions performed with the
[`osmdata`](https://docs.ropensci.org/osmdata/) package (which itself
uses the [Overpass
API](https://wiki.openstreetmap.org/wiki/Overpass_API)).

The resulting layers are:

- Urban areas
- Buildings
- Green spaces
- Main roads
- Secondary roads
- Railroads
- Water bodies

## Installation

You can install `maposm` from the r-universe.

``` r
install.packages("maposm", repos = "https://riatelab.r-universe.dev")
```

## Demo

`om_get()` is used to download, merge and simplify the geographic
layers.  
`om_map()` can be used to map the layers.

``` r
library(maposm)
#> Data © OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright.
#> Maps based on OpenStreetMap data should cite "© OpenStreetMap contributors" as the data source.
castries = om_get(x = c(-60.9903, 14.0096), r = 2000)
#> Getting urban areas: 0.741 sec elapsed
#> Getting buildings: 8.504 sec elapsed
#> Getting green areas: 0.549 sec elapsed
#> Getting roads: 0.344 sec elapsed
#> Getting streets: 1.228 sec elapsed
#> Getting railways: 0.348 sec elapsed
#> Getting water bodies: 1.204 sec elapsed
om_map(x = castries, title = "Castries, Saint Lucia", theme = "light")
```

![](man/figures/README-example-1.png)<!-- -->

Several themes are available to map the layers (“light”, “dark” and
“grey”).

``` r
om_map(x = castries, title = "Castries, Saint Lucia", theme = "grey")
```

![](man/figures/README-example2-1.png)<!-- -->

You can also use an sf object to extract the layers and your prefered
library to map the layers.

``` r
library(mapsf)
roseau = st_as_sf(data.frame(lat = 15.300, lon = -61.388), 
                   coords = c("lon", "lat"), 
                   crs = "EPSG:4326") |>
  st_transform("EPSG:3857") |>
  st_buffer(dist = 500, nQuadSegs = 2) |> 
  om_get(quiet = TRUE)

mf_map(roseau$zone, col = "#f2efe9", border = NA, add = FALSE)
mf_map(roseau$urban, col = "#e0dfdf", border = "#e0dfdf", lwd = .5, add = TRUE)
mf_map(roseau$green, col = "#c8facc", border = "#c8facc", lwd = .5, add = TRUE)
mf_map(roseau$water, col = "#aad3df", border = "#aad3df", lwd = .5, add = TRUE)
mf_map(roseau$railway, col = "grey50", lty = 2, lwd = .2, add = TRUE)
mf_map(roseau$road, col = "white", border = "white", lwd = .5, add = TRUE)
mf_map(roseau$street, col = "white", border = "white", lwd = .5, add = TRUE)
mf_map(roseau$building, col = "#d9d0c9", border = "#c6bab1", lwd = .5, add = TRUE)
mf_map(roseau$zone, col = NA, border = "#c6bab1", lwd = 4, add = TRUE)
mf_credits(txt = "\ua9 OpenStreetMap contributors")
mf_scale(size = 100, scale_units = "m")
mf_title("Roseau, Dominique")
```

![](man/figures/README-example3-1.png)<!-- -->

`om_write()` can be used to write the layers to a geopackage file.  
`om_read()` can be used to read the geopackages.

``` r
# save
om_write(x = roseau, filename = "roseau.gpkg")
# import
om_read(x = "roseau.gpkg")
```
