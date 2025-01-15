#' @title Get City Map Layers
#' @description Download vairous osm features to create city map layers.
#' @param x city center coordinates
#' @param r radi of the extraction
#' @param verbose output messages
#'
#' @return A list of layers is returned
#' @export
#'
#' @importFrom sf st_as_sf st_transform st_buffer st_bbox
#' @importFrom osmdata opq
#' @importFrom tictoc tic toc
#' @examples
#' \dontrun{
#' bb1 <- osmdata::getbb("Gare Matabiau, 31000 TOULOUSE, France")
#' lon <- mean(bb1[1, ])
#' lat <- mean(bb1[2, ])
#' res <- get_city(c(lon, lat), dist = 700)
#' }
get_city = function(x, r = 1000, verbose = TRUE){
  verbose <- !verbose

  circle = data.frame(x = x[1], y = x[2]) |>
    st_as_sf(coords = c("x", "y"), crs = "EPSG:4326") |>
    st_transform("EPSG:3857") |>
    st_buffer(dist = r)

  bbox = st_buffer(circle, r / 10) |>
    st_transform("EPSG:4326") |>
    st_bbox()

  my_opq = opq(bbox = bbox)

  if(r > 5000) {
    tic("Getting urban patches")
    warning("'r' is large. You'll get urban patches instead of buildings.",
            call. = FALSE)
    urban = get_data(kv_urban, my_opq) |>
      get_poly(crop = circle, buffer = c(2, -2))
    building = NULL
  } else {
    tic("Getting buildings")
    building = get_data(kv_building, my_opq) |>
      get_poly(crop = circle, buffer = c(2, -2))
    urban = NULL
  }
  toc(quiet = verbose)

  tic("Getting green areas")
  green = get_data(kv_green, my_opq) |>
    get_poly(crop = circle, buffer = c(5, -5))
  toc(quiet = verbose)

  tic("Getting water bodies")
  water1 = get_data(kv_water, my_opq) |>
    get_poly(crop = circle, buffer = c(5, -5))
  water2 = get_data(kv_water2, my_opq) |>
    get_line(crop = circle, buffer = c(6, -2))
  water = unify(water1, water2)
  toc(quiet = verbose)

  tic("Getting roads")
  road_raw = get_data(kv_road, my_opq)
  road1 = get_line(x = road_raw, crop = circle, buffer = c(10, -4))
  road2 = get_poly(x = road_raw, crop = circle, buffer = c(4, -4))
  road = unify(road1, road2)
  toc(quiet = verbose)

  tic("Getting streets")
  street_raw = get_data(kv_street, my_opq)
  street1 = get_line(x = street_raw, crop = circle, buffer = c(6, -3))
  street2 = get_poly(x = street_raw, crop = circle, buffer = c(3, -3))
  street = unify(street1, street2)
  toc(quiet = verbose)

  tic("Getting railways")
  railway = get_data(kv_railway, my_opq) |>
    get_line(crop = circle, return = "line")
  toc(quiet = verbose)

  return(list(
    circle = circle, green = green, water = water, railway = railway,
    road = road, street = street, building = building, urban = urban
  ))
}
