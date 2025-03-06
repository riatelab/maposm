#' @title Get City Map Layers
#' @description Download various OpenStreetMap
#' features to create city map layers.
#' @param x city center coordinates
#' @param r radi of the extraction
#' @param verbose output messages
#'
#' @return A list of layers is returned.
#' @export
#'
#' @importFrom sf st_as_sf st_bbox st_buffer st_geometry st_transform st_area
#' st_intersects
#' @importFrom lwgeom st_split
#' @importFrom osmdata opq
#' @importFrom tictoc tic toc
#' @examples
#' \dontrun{
#' bb1 <- osmdata::getbb("Gare Matabiau, 31000 TOULOUSE, France")
#' lon <- mean(bb1[1, ])
#' lat <- mean(bb1[2, ])
#' res <- get_city(c(lon, lat), dist = 700)
#' if (require("mapsf")){
#'   mf_map(res$zone, col = "#f2efe9", border = NA, add = FALSE)
#'   mf_map(res$green, col = "#c8facc", border = "#c8facc", lwd = .5, add = TRUE)
#'   mf_map(res$water, col = "#aad3df", border = "#aad3df", lwd = .5, add = TRUE)
#'   mf_map(res$railway, col = "grey50", lty = 2, lwd = .2, add = TRUE)
#'   mf_map(res$road, col = "white", border = "white", lwd = .5, add = TRUE)
#'   mf_map(res$street, col = "white", border = "white", lwd = .5, add = TRUE)
#'   mf_map(res$building, col = "#d9d0c9", border = "#c6bab1", lwd = .5, add = TRUE)
#'   mf_map(res$zone, col = NA, border = "#c6bab1", lwd = 4, add = TRUE)
#' }
#' }
get_city = function(x, r = 1000, verbose = TRUE){
  verbose = !verbose
  zone = zone_input(x, r)
  bbox = st_buffer(zone, r / 10) |>
    st_transform("EPSG:4326") |>
    st_bbox()
  my_opq = opq(bbox = bbox)

  tic("Getting urban patches")
  urban = get_data(kv_urban, my_opq) |>
    get_poly(crop = zone, buffer = c(2, -2))

  if (as.numeric(st_area(zone)) < 15000000 ) {
    tic("Getting buildings")
    building = get_data(kv_building, my_opq) |>
      get_poly(crop = zone, buffer = c(2, -2))
  } else {
    building = NULL
    warning("'r' is large. You'll not get buildings.",
            call. = FALSE)
  }
  toc(quiet = verbose)

  tic("Getting green areas")
  green = get_data(kv_green, my_opq) |>
    get_poly(crop = zone, buffer = c(5, -5))
  toc(quiet = verbose)

  tic("Getting roads")
  road_raw = get_data(kv_road, my_opq)
  road1 = get_line(x = road_raw, crop = zone, buffer = c(10, -4))
  road2 = get_poly(x = road_raw, crop = zone, buffer = c(4, -4))
  road = unify(road1, road2)
  toc(quiet = verbose)

  tic("Getting streets")
  street_raw = get_data(kv_street, my_opq)
  street1 = get_line(x = street_raw, crop = zone, buffer = c(6, -3))
  street2 = get_poly(x = street_raw, crop = zone, buffer = c(3, -3))
  street = unify(street1, street2)
  toc(quiet = verbose)

  tic("Getting railways")
  railway = get_data(kv_railway, my_opq) |>
    get_line(crop = zone, return = "line")
  toc(quiet = verbose)


  tic("Getting water bodies")
  water1 = get_data(kv_water, my_opq) |>
    get_poly(crop = zone, buffer = c(5, -5))
  water2 = get_data(kv_water2, my_opq) |>
    get_line(crop = zone, buffer = c(6, -2))
  water3 = add_osm_features(opq = my_opq, features = kv_water3) |>
    osmdata_sf() |>
    get_line(crop = st_buffer(zone, 10), return = "line")
  if (!is.null(water3)) {
    xx = st_split(zone, st_geometry(water3)) |>
      st_collection_extract("POLYGON")
    r = get_line(x = street_raw, crop = zone, return = "line")
    water3 = st_union(xx[!(st_intersects(xx, r, sparse = FALSE)), ])
  }
  water = unify(water1, water2)
  water = unify(water, water3)
  toc(quiet = verbose)

  if (is.null(green)) {
    green = empty_sf(green, zone, "POLYGON")
  }
  if (is.null(water)) {
    water = empty_sf(water, zone, "POLYGON")
  }
  if (is.null(railway)) {
    railway = empty_sf(railway, zone, "LINE")
  }
  if (is.null(road)) {
    road = empty_sf(road, zone, "POLYGON")
  }
  if (is.null(street)) {
    street = empty_sf(street, zone, "POLYGON")
  }
  if (is.null(building)) {
    building = empty_sf(building, zone, "POLYGON")
  }
  if (is.null(urban)) {
    urban = empty_sf(urban, zone, "POLYGON")
  }


  return(list(
    zone = zone, green = green, water = water, railway = railway,
    road = road, street = street, building = building, urban = urban
  ))
}
