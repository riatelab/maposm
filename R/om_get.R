#' @title Get map layers
#' @description Download various OpenStreetMap
#' features to create map layers.
#' @param x an sf or sfc object, or a couple of coordinates
#' (lon/lat, EPSG:4326)
#' @param r radius of the extraction if x is an sf POINT or a couple of
#' coordinates
#' @param quiet if FALSE, the function prints informative messages
#' @param download_directory directory to store the file containing
#' OpenStreetMap data
#' @param force_download if TRUE, the OpenSteetMap file is updated even if it
#' has already been downloaded.
#' @param force_building force the extraction of buildings in zones larger than
#' 20 km²
#'
#' @return
#' A list of map layers is returned :
#' - *zone*, the extraction zone;
#' - *urban*, urban areas;
#' - *building*, buildings (if the extraction zone area is below 20 km² or
#' `force_building = TRUE`);
#' - *green*, green spaces;
#' - *road*, main roads;
#' - *street*, secondary roads;
#' - *railway*, railways (line);
#' - *water*, water bodies
#'
#' If `x` uses an unprojected CRS (lon/lat, EPSG:4326), ouput uses
#' Web Mercator CRS (EPSG:3857), it uses `x` CRS otherwise.
#' @md
#' @export
#'
#' @examples
#' res = om_get(c(-61.070, 14.605), r = 600)
#' om_map(res, title = "Fort-de-France town centre")
om_get = function(x,
                  r,
                  download_directory = tempdir(),
                  force_download = FALSE,
                  force_building = FALSE,
                  quiet = FALSE) {
  verbose = !quiet
  zone = zone_input(x = x, r = r)

  if (!skip_dl(x, r)){
    res = suppressWarnings(
      mo_download(
        place = zone,
        download_directory = download_directory,
        force_download = force_download,
        quiet = quiet
      )
    )
  } else {
    if (verbose) {
      message(
        paste0(
          "# Download the OpenStreetMap file\n",
          "The input place and the radius matched the sample dataset.\n",
          "Skip download and data extraction.")
      )
    }
    res = list(
      lines = st_read(dsn = system.file("gpkg/f2f.gpkg", package = "maposm"),
                      layer = "lines", quiet = TRUE),
      polygons = st_read(dsn = system.file("gpkg/f2f.gpkg", package = "maposm"),
                         layer = "multipolygons", quiet = TRUE)
    )
  }

  if (verbose) {
    message("\n# Create map layers")
  }
  if (verbose) {
    message("- green spaces")
  }

  res_pol = res$polygons
  res_lin = res$lines

  green = res_pol[
    res_pol$landuse %in%
      c(
        "allotments",
        "farmland",
        "cemetery",
        "forest",
        "grass",
        "meadows",
        "meadow",
        "orchard",
        "recreation_ground",
        "greenfield",
        "village_green",
        "vineyard"
      ) |
      res_pol$tourism %in% "camp_site" |
      res_pol$amenity %in% "grave_yard" |
      res_pol$natural %in%
      c("wood", "scrub", "health", "grassland", "wetland", "park") |
      res_pol$leisure %in%
      c(
        "garden",
        "golf_course",
        "nature_reserve",
        "park",
        "pitch",
        "miniature_golf",
        "track"
      ),
  ] |>
    st_geometry() |>
    st_transform(st_crs(zone)) |>
    st_make_valid() |>
    st_intersection(zone) |>
    st_union() |>
    st_buffer(5, nQuadSegs = 2) |>
    st_buffer(-5, nQuadSegs = 2) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, "POLYGON")

  if (as.numeric(st_area(zone)) < 20000000 || isTRUE(force_building)) {
    if (verbose) {
      message("- buildings")
    }
    building = res_pol[!is.na(res_pol$building), ] |>
      st_geometry() |>
      st_transform(st_crs(zone)) |>
      st_make_valid() |>
      st_intersection(zone) |>
      st_union() |>
      st_buffer(2, nQuadSegs = 1) |>
      st_buffer(-2, nQuadSegs = 1) |>
      st_sf(geometry = _) |>
      empty_sf(zone = zone, type = "POLYGON")
  } else {
    if (verbose) {
      message("x buildings are skipped")
    }
    building = empty_sf(zone = zone, type = "POLYGON")
  }

  if (verbose) {
    message("- urban areas")
  }
  urban = res_pol[
    res_pol$landuse %in%
      c(
        "commercial",
        "residential",
        "industrial",
        "retail",
        "institutional",
        "civic_admin",
        "railway",
        "garage"
      ) |
      res_pol$man_made %in% "pier",
  ] |>
    st_geometry() |>
    st_transform(st_crs(zone)) |>
    st_make_valid() |>
    st_intersection(zone) |>
    st_union() |>
    st_buffer(5, nQuadSegs = 2) |>
    st_buffer(-5, nQuadSegs = 2) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "POLYGON")

  if (verbose) {
    message("- roads")
  }
  road1 = res_lin[
    res_lin$highway %in%
      c(
        "motorway",
        "motorway_link",
        "trunk",
        "trunk_link",
        "primary",
        "primary_link",
        "secondary",
        "secondary_link"
      ),
  ] |>
    st_geometry() |>
    st_make_valid() |>
    st_cast("LINESTRING") |>
    st_transform(st_crs(zone)) |>
    st_intersection(zone) |>
    st_union() |>
    st_buffer(10, nQuadSegs = 2) |>
    st_buffer(-4, nQuadSegs = 2) |>
    st_intersection(zone) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "POLYGON")

  road2 = res_pol[
    res_pol$highway %in%
      c(
        "motorway",
        "motorway_link",
        "trunk",
        "trunk_link",
        "primary",
        "primary_link",
        "secondary",
        "secondary_link"
      ),
  ] |>
    st_geometry() |>
    st_transform(st_crs(zone)) |>
    st_make_valid() |>
    st_intersection(zone) |>
    st_union() |>
    st_buffer(4, nQuadSegs = 2) |>
    st_buffer(-4, nQuadSegs = 2) |>
    st_intersection(zone) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "POLYGON")

  road = unify(road1, road2)

  if (verbose) {
    message("- streets")
  }
  street_raw = res_lin[
    res_lin$highway %in%
      c(
        "tertiary",
        "tertiary_link",
        "unclassified",
        "residential",
        "living_street",
        "pedestrian",
        "service"
      ) |
      res_lin$aeroway %in% c("runway", "taxiway"),
  ] |>
    st_geometry() |>
    st_make_valid() |>
    st_cast("LINESTRING") |>
    st_transform(st_crs(zone)) |>
    st_intersection(zone) |>
    st_union()

  street1 = street_raw |>
    st_buffer(6, nQuadSegs = 2) |>
    st_buffer(-3, nQuadSegs = 2) |>
    st_intersection(zone) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "POLYGON")

  street2 = res_pol[
    res_pol$highway %in%
      c(
        "tertiary",
        "tertiary_link",
        "unclassified",
        "residential",
        "living_street",
        "pedestrian",
        "service"
      ) |
      res_pol$aeroway %in% c("runway", "taxiway") |
      res_pol$man_made %in% "pier",
  ] |>
    st_geometry() |>
    st_transform(st_crs(zone)) |>
    st_make_valid() |>
    st_intersection(zone) |>
    st_union() |>
    st_buffer(3, nQuadSegs = 2) |>
    st_buffer(-3, nQuadSegs = 2) |>
    st_intersection(zone) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "POLYGON")

  street = unify(street1, street2)

  if (verbose) {
    message("- railways")
  }
  railway = res_lin[res_lin$railway %in% "rail", ] |>
    st_geometry() |>
    st_make_valid() |>
    st_cast("LINESTRING") |>
    st_transform(st_crs(zone)) |>
    st_intersection(zone) |>
    st_union() |>
    st_sf(geometry = _) |>
    empty_sf(zone, "LINE")

  if (verbose) {
    message("- water bodies")
  }
  water1 = res_pol[
    res_pol$natural %in%
      c("water", "bay", "strait") |
      res_pol$place %in% c("sea", "ocean") |
      res_pol$landuse %in% "basin",
  ] |>
    st_geometry() |>
    st_transform(st_crs(zone)) |>
    st_make_valid() |>
    st_intersection(zone) |>
    st_union() |>
    st_buffer(5, nQuadSegs = 2) |>
    st_buffer(-5, nQuadSegs = 2) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "POLYGON")
  water2 = res_lin[
    res_lin$waterway %in% c("river", "canal") &
      (is.na(res_lin$location) | res_lin$location != "underground"),
  ] |>
    st_geometry() |>
    st_make_valid() |>
    st_cast("LINESTRING") |>
    st_transform(st_crs(zone)) |>
    st_intersection(zone) |>
    st_union() |>
    st_buffer(6, nQuadSegs = 2) |>
    st_buffer(-2, nQuadSegs = 2) |>
    st_intersection(zone) |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "POLYGON")

  water3 = res_lin[res_lin$natural %in% 'coastline', ] |>
    st_geometry() |>
    st_make_valid() |>
    st_cast("LINESTRING") |>
    st_transform(st_crs(zone)) |>
    st_intersection(st_buffer(zone, 10)) |>
    st_union() |>
    st_sf(geometry = _) |>
    empty_sf(zone = zone, type = "LINE")
  if (isFALSE(st_is_empty(water3))) {
    xx = suppressPackageStartupMessages(lwgeom::st_split(
      st_as_sf(zone),
      st_geometry(water3)
    )) |>
      st_collection_extract("POLYGON")
    xx$ID = 1:nrow(xx)
    st_agr(xx) = "constant"
    s_w = st_intersection(st_sf(street_raw), xx)
    s_w = s_w[
      st_geometry_type(s_w, by_geometry = TRUE) %in%
        c("LINESTRING", "MULTILINESTRING"),
    ]
    s_w$l <- st_length(s_w)
    water3 = xx[!xx$ID %in% s_w$ID[as.numeric(s_w$l) > 200], ] |>
      st_geometry() |>
      st_union() |>
      st_intersection(zone) |>
      st_sf(geometry = _) |>
      empty_sf(zone = zone, type = "POLYGON")
  }
  water = unify(water1, water2)
  water = unify(water, water3)
  if (verbose) {
    message("\nDone!")
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
    )
  )
}
