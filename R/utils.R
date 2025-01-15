#' @importFrom osmdata add_osm_features add_osm_feature osmdata_sf
#' unique_osmdata
get_data = function(x, opq){
  if (is.list(x)) {
    add_osm_features(opq = opq, features = x) |>
      osmdata_sf() |>
      unique_osmdata()
  } else {
    add_osm_feature(opq = opq, key = x) |>
      osmdata_sf() |>
      unique_osmdata()
  }
}

#' @importFrom sf st_geometry st_sfc st_collection_extract st_transform st_crs
#' st_make_valid st_intersection st_union st_buffer st_sf
get_poly = function(x, crop, buffer) {
  if (!is.null(x$osm_polygons) && nrow(x$osm_polygons) > 0) {
    a = st_geometry(x$osm_polygons)
  } else {
    a = NULL
  }
  if (!is.null(x$osm_multipolygons) && nrow(x$osm_multipolygons) > 0) {
    b = st_geometry(x$osm_multipolygons)
  } else {
    b = NULL
  }

  z = st_sfc(c(a, b), crs = "EPSG:4326")

  suppressWarnings({z = st_collection_extract(z, 'POLYGON',warn = FALSE)})
  if (!is.null(z)) {
    z = st_transform(z, st_crs(crop)) |>
      st_make_valid() |>
      # st_cast("POLYGON") |>
      st_intersection(crop) |>
      st_union() |>
      st_buffer(buffer[1]) |>
      st_buffer(buffer[2])
    z = st_sf(geometry = z)
  }
  if (nrow(z) == 0) {
    z = NULL
  }
  return(z)
}

#' @importFrom sf st_cast
get_line = function(x, crop, buffer, return = "polygon") {
  if (!is.null(x$osm_lines) && nrow(x$osm_lines) > 0) {
    a = st_geometry(x$osm_lines)
  } else {
    a = NULL
  }
  if (!is.null(x$osm_multilines) && nrow(x$osm_multilines) > 0) {
    b = st_geometry(x$osm_multilines)
  } else {
    b = NULL
  }
  z = st_sfc(c(a, b), crs = "EPSG:4326")
  suppressWarnings({z = st_collection_extract(z, 'LINESTRING',warn = FALSE)})
  if (!is.null(z)) {
    z = st_make_valid(z) |>
      st_cast("LINESTRING") |>
      st_transform(st_crs(crop)) |>
      st_intersection(crop) |>
      st_union()
    if (return == "polygon") {
      z = st_buffer(z, buffer[1]) |> st_buffer(buffer[2])
    }
    z = st_sf(geometry = z)
  }

  if (nrow(z) == 0) {
    z = NULL
  }
  return(z)
}


unify = function(x, y){
  if(!is.null(x) && !is.null(y)){
    return(st_union(x,y))
  }
  if(is.null(x) && is.null(y)){
    return(NULL)
  }
  if(is.null(x)){
    return(y)
  } else {
    return(x)
  }
}
