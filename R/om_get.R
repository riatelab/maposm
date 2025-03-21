#' @title Get map layers
#' @description Download various OpenStreetMap
#' features to create map layers.
#' @param x an sf or sfc object, or a couple of coordinates
#' @param r radi of the extraction if x is an sf POINT or a couple of
#' coordinates
#' @param quiet suppress info
#'
#' @return
#' A list of map layers is returned :
#' - *zone*, the extraction zone;
#' - *urban*, urban areas;
#' - *building*, buildings (if the extraction zone area is below 15 km^2);
#' - *green*, green spaces;
#' - *road*, main roads;
#' - *street*, secondary roads;
#' - *railway*, railroads (line);
#' - *water*, water bodies
#'
#' @md
#' @export
#'
#' @importFrom sf st_as_sf st_bbox st_buffer st_geometry st_transform st_area
#' st_intersects
#' @importFrom lwgeom st_split
#' @importFrom osmdata opq
#' @importFrom tictoc tic toc
#' @examples
#' \dontrun{
#' bb1 = osmdata::getbb("Gare Matabiau, 31000 TOULOUSE, France")
#' lon = mean(bb1[1, ])
#' lat = mean(bb1[2, ])
#' res = om_get(c(lon, lat), r = 700)
#' om_map(res)
#' }
om_get = function(x, r = 1000, quiet = FALSE){
  zone = zone_input(x, r)
  bbox = st_buffer(zone, r / 10) |>
    st_transform("EPSG:4326") |>
    st_bbox()
  my_opq = opq(bbox = bbox)

  tic("Getting urban areas")
  urban = get_data(kv_urban, my_opq) |>
    get_poly(crop = zone, buffer = c(2, -2))
  toc(quiet = quiet)

  if (as.numeric(st_area(zone)) < 15000000 ) {
    tic("Getting buildings")
    building = get_data(kv_building, my_opq) |>
      get_poly(crop = zone, buffer = c(2, -2))
  } else {
    building = NULL
    if(quiet == TRUE){
      message("The requested area is too large for downloading buildings.")
    }
  }
  toc(quiet = quiet)

  tic("Getting green areas")
  green = get_data(kv_green, my_opq) |>
    get_poly(crop = zone, buffer = c(5, -5))
  toc(quiet = quiet)

  tic("Getting roads")
  road_raw = get_data(kv_road, my_opq)
  road1 = get_line(x = road_raw, crop = zone, buffer = c(10, -4))
  road2 = get_poly(x = road_raw, crop = zone, buffer = c(4, -4))
  road = unify(road1, road2)
  toc(quiet = quiet)

  tic("Getting streets")
  street_raw = get_data(kv_street, my_opq)
  street1 = get_line(x = street_raw, crop = zone, buffer = c(6, -3))
  street2 = get_poly(x = street_raw, crop = zone, buffer = c(3, -3))
  street = unify(street1, street2)
  toc(quiet = quiet)

  tic("Getting railways")
  railway = get_data(kv_railway, my_opq) |>
    get_line(crop = zone, return = "line")
  toc(quiet = quiet)

  tic("Getting water bodies")
  water1 = get_data(kv_water, my_opq) |>
    get_poly(crop = zone, buffer = c(5, -5))
  water2 = get_data(kv_water2, my_opq) |>
    get_line(crop = zone, buffer = c(6, -2))
  water3 = add_osm_features(opq = my_opq, features = kv_water3) |>
    osmdata_sf() |>
    get_line(crop = st_buffer(zone, 10), return = "line")
  if (!is.null(water3)) {
    xx = suppressPackageStartupMessages(st_split(zone, st_geometry(water3))) |>
      st_collection_extract("POLYGON")
    r = get_line(x = street_raw, crop = zone, return = "line")
    water3 = st_union(xx[!(st_intersects(xx, r, sparse = FALSE)), ])
  }
  water = unify(water1, water2)
  water = unify(water, water3)
  toc(quiet = quiet)

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


  return(
    list(
      zone = zone,
      urban = urban,
      building = building,
      green = green,
      road = road,
      street = street,
      railway = railway,
      water = water
    ))
}
