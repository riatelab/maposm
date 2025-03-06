kv_green = list(
  "landuse" = c(
    "allotments",
    "farmland",
    "cemetery",
    "forest",
    "grass",
    "meadow",
    "orchard",
    "recreation_ground",
    "greenfield",
    "village_green",
    "vineyard"
  ),
  "amenity" = "grave_yard",
  "leisure" = c("garden", "golf_course", "nature_reserve", "park", "pitch"),
  "natural" = c("wood", "scrub", "health", "grassland", "wetland")
)

kv_water = list("natural" = c("water", "bay", "strait"),
                "place" = c("sea", "ocean"),
                "landuse" = "basin")
kv_water2 = list("waterway" = c("river", "canal"))
kv_water3 = list("natural"="coastline")

kv_building = "building"

kv_urban = list(
  "landuse" = c(
    "commercial",
    "residential",
    "industrial",
    "retail",
    "institutional",
    "civic_admin",
    "railway",
    "garage"
  ),
  "man_made" = "pier"
)

kv_road = list(
  "highway" = c(
    "motorway",
    "motorway_link",
    "trunk",
    "trunk_link",
    "primary",
    "primary_link",
    "secondary",
    "secondary_link"
  )
)

kv_street = list(
  "highway" = c(
    "tertiary",
    "tertiary_link",
    "unclassified",
    "residential",
    # "service",
    "living_street",
    "pedestrian"
  )
)

kv_railway = list("railway" = "rail")
