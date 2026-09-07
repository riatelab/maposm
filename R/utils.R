#' @importFrom sf st_as_sf st_bbox st_buffer st_geometry st_transform st_area
#'  st_intersects st_agr<- st_length st_sf st_sfc st_crs st_geometry<-
#'  st_sf st_union st_intersection st_make_valid st_coordinates st_geometry
#'  st_linestring st_point st_polygon st_cast st_collection_extract
#'  st_geometry_type st_is_empty st_is_longlat
#' @importFrom lwgeom st_split
#' @importFrom osmextract oe_match oe_download oe_vectortranslate


zone_input = function(x, r) {
  out_prj = "EPSG:3857"
  if (inherits(x = x, what = c("sfc", "sf"))) {
    lx = length(st_geometry(x))
    if (lx != 1) {
      stop("x must have 1 row or element.", call. = FALSE)
    }
    type = sf::st_geometry_type(x, by_geometry = TRUE)
    if (type == "POINT") {
      if (!st_is_longlat(x)) {
        out_prj = st_crs(x)
      }
      x = st_transform(x, "EPSG:4326")
      x = c(st_coordinates(x)[1], st_coordinates(x)[2])
    } else if (!type %in% c("POLYGON", "MULTIPOLYGON")) {
      stop("x must be a POINT or (MULTI)POLYGON.", call. = FALSE)
    } else {
      if (st_is_longlat(x)) {
        x = st_transform(x, "EPSG:3857")
      }
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
      st_as_sf(coords = c("x", "y"), crs = "EPSG:4326", remove = FALSE) |>
      st_transform(out_prj) |>
      st_buffer(dist = r)
    return(zone)
  } else {
    stop("x should be an sf or sfc object, or a couple of coordinates.")
  }
}

skip_dl <- function(x, r){
  if (is.vector(x) && length(x) == 2 && is.numeric(x))
    if(x[1] == -61.07 && x[2] == 14.605 & r == 600){
      return(TRUE)
    }
  return(FALSE)
}

unify = function(x, y) {
  if (!st_is_empty(x) && !st_is_empty(y)) {
    return(st_union(x, y))
  }
  if (st_is_empty(x) && st_is_empty(y)) {
    return(x)
  }
  if (st_is_empty(x)) {
    return(y)
  } else {
    return(x)
  }
}

mo_download = function(place, download_directory, force_download, quiet) {
  verbose = !quiet

  if (verbose) {
    message("# Download the OpenStreetMap file")
  }
  place_file = oe_match(place = place, quiet = quiet)
  place_download = oe_download(
    file_url = place_file$url,
    file_size = place_file$file_size,
    download_directory = download_directory,
    force_download = force_download,
    quiet = quiet
  )

  if (verbose) {
    message("\n# Polygons extraction")
  }
  oe_vectortranslate(
    place_download,
    layer = "multipolygons",
    extra_tags = c(
      "landuse",
      "amenity",
      "leisure",
      "natural",
      "place",
      "aeroway",
      "highway",
      "tourism",
      "man_made"
    ),
    boundary = st_bbox(place),
    quiet = quiet
  )

  if (verbose) {
    message("\n# Lines extraction")
  }
  gpkg_path = oe_vectortranslate(
    place_download,
    layer = "lines",
    extra_tags = c("natural", "waterway", "location", "aeroway"),
    boundary = st_bbox(place),
    quiet = quiet
  )

  lines = st_read(dsn = gpkg_path, layer = "lines", quiet = TRUE)
  polygons = st_read(dsn = gpkg_path, layer = "multipolygons", quiet = TRUE)

  return(list(lines = lines, polygons = polygons))
}

empty_sf = function(x, zone, type) {
  if (missing(x)) {
    x = data.frame(NULL)
  }
  if (nrow(x) == 0) {
    if (type == "POINT") {
      x = st_sf(geometry = st_sfc(st_point()), crs = st_crs(zone))
    }
    if (type == "POLYGON") {
      x = st_sf(geometry = st_sfc(st_polygon()), crs = st_crs(zone))
    }
    if (type == "LINE") {
      x = st_sf(geometry = st_sfc(st_linestring()), crs = st_crs(zone))
    }
    new_bb = st_bbox(zone)
    attr(st_geometry(x), "bbox") = new_bb
  }
  return(x)
}
