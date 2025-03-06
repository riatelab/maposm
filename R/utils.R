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

#' @importFrom sf st_coordinates st_geometry<- st_linestring
#' st_point st_polygon
empty_sf = function(x, zone, type){
  if (type == "POINT"){
    x = st_sf(geom = st_sfc(st_point()), crs = st_crs(zone))
  }
  if (type == "POLYGON"){
    x = st_sf(geom = st_sfc(st_polygon()), crs = st_crs(zone))
  }
  if (type == "LINE"){
    x = st_sf(geom = st_sfc(st_linestring()), crs = st_crs(zone))
  }
  new_bb = st_bbox(zone)
  attr(st_geometry(x), "bbox") = new_bb
  x
}



zone_input = function(x, r){
  prj = "EPSG:3857"
  if (inherits(x = x, what = c("sfc", "sf"))) {
    lx <- length(st_geometry(x))
    if (lx != 1) {
      stop("x must have 1 row or element.", call. = FALSE)
    }
    type <- sf::st_geometry_type(x, by_geometry = TRUE)
    if (type == "POINT") {
      prj = st_crs(x)
      x = st_transform(x, "EPSG:4326")
      x = c(st_coordinates(x)[1], st_coordinates(x)[2])
    } else if (!type %in% c("POLYGON", "MULTIPOLYGON")){
      stop("x must be a POINT or (MULTI)POLYGON.", call. = FALSE)
    } else {
      return(x)
    }
  }

  if (is.vector(x) && length(x) == 2 && is.numeric(x)) {
    if (x[1] > 180 || x[1] < -180 || x[2] > 90 || x[2] < -90) {
      stop(
        paste0(
          "longitude is bounded by the interval [-180, 180], ",
          "latitude is bounded by the interval [-90, 90]"
        ),
        call. = FALSE
      )
    }
    zone = data.frame(x = x[1], y = x[2]) |>
      st_as_sf(coords = c("x", "y"), crs = "EPSG:4326") |>
      st_transform(prj) |>
      st_buffer(dist = r)
    return(zone)
  } else {
    stop("x should be an sf or sfc object, or a couple of coordinates.")
  }
}
