#' Import a list of map layers
#'
#' Read and import a list of layers.
#' @param filename a geopackage file
#'
#' @returns A list of map layers is returned.
#' @importFrom sf st_read
#' @export
#'
#' @examples
#' \dontrun{
#' r = om_get(c(2.17, 41.39), 500)
#' om_write(r, "bcn.gpkg")
#' r = om_read("bcn.gpkg")
#' om_map(r)
#' }
om_read = function(filename){
  if (tools::file_ext(filename) != "gpkg") {
    stop("'filename' must be the path to a geopackage. It must end with '.gpkg'")
  }
  r = list()
  r$zone     = st_read(dsn = filename, layer = "zone",     quiet = TRUE)
  r$urban    = st_read(dsn = filename, layer = "urban",    quiet = TRUE)
  r$building = st_read(dsn = filename, layer = "building", quiet = TRUE)
  r$green    = st_read(dsn = filename, layer = "green",    quiet = TRUE)
  r$road     = st_read(dsn = filename, layer = "road",     quiet = TRUE)
  r$street   = st_read(dsn = filename, layer = "street",   quiet = TRUE)
  r$railway  = st_read(dsn = filename, layer = "railway",  quiet = TRUE)
  r$water    = st_read(dsn = filename, layer = "water",    quiet = TRUE)
  return(r)
}

