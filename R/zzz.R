.onAttach = function(libname, pkgname) {
  packageStartupMessage(paste(
    "Data \ua9 OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright.",
    'Maps based on OpenStreetMap data should cite "\ua9 OpenStreetMap contributors" as the data source.',
    sep = "\n"
  ))
}
