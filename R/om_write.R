#' Save map layers to a file
#'
#' Write a list a map of layers to a geopackage file.
#' @param x a list of map layers produce with \code{om_get}
#' @param filename a geopackage file
#'
#' @returns The layers are saved to a geopackage file. Nothing is returned.
#' @export
#' @importFrom sf st_write
#'
#' @examples
#' \dontrun{
#' r = om_get(c(2.17, 41.39), 500)
#' (om_write(r, "bcn.gpkg"))
#' }
om_write = function(x, filename){
  if (tools::file_ext(filename) != "gpkg") {
    stop("'filename' must be the path to a geopackage. It must end with '.gpkg'")
  }
  st_write(obj = x$zone,     dsn = filename, layer = "zone",     append = FALSE, quiet = TRUE)
  st_write(obj = x$urban,    dsn = filename, layer = "urban",    append = FALSE, quiet = TRUE)
  st_write(obj = x$building, dsn = filename, layer = "building", append = FALSE, quiet = TRUE)
  st_write(obj = x$green,    dsn = filename, layer = "green",    append = FALSE, quiet = TRUE)
  st_write(obj = x$road,     dsn = filename, layer = "road",     append = FALSE, quiet = TRUE)
  st_write(obj = x$street,   dsn = filename, layer = "street",   append = FALSE, quiet = TRUE)
  st_write(obj = x$railway,  dsn = filename, layer = "railway",  append = FALSE, quiet = TRUE)
  st_write(obj = x$water,    dsn = filename, layer = "water",    append = FALSE, quiet = TRUE)
  return(invisible(filename))
}

