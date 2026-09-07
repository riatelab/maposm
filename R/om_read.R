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
#' res = om_get(c(-61.070, 14.605), r = 600)
#' om_map(res, title = "Fort-de-France town centre")
#' om_write(res, file.path(tempdir(), "f2f.gpkg"))
#' r = om_read(file.path(tempdir(), "f2f.gpkg"))
#' om_map(r, theme = "grey")
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

