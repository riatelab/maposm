#' Map layers
#'
#' Display a map of the downloaded layers.
#' @param x a list of map layers
#' @param title map title
#' @param theme cartographic theme; "light", "dark", "grey" or "pizza"
#'
#' @returns Nothing is returned. A map is displayed.
#' @importFrom mapsf mf_map mf_credits mf_scale mf_title
#' @importFrom graphics par
#' @export
#'
#' @examples
#' \dontrun{
#' r = om_get(c(1.453587,43.611408), 700)
#' om_map(r, "Matabiau neighbourhood", "light")
#'}
om_map = function(x, title = "Data from OpenStreetMap",
                  theme = "light"){

  theme = themes[[theme]]

  mf_map(x$zone,     col = theme$zone[1],     border = NA, add = FALSE)
  mf_map(x$urban,    col = theme$urban,       border = theme$urban,       lwd = .5, add = TRUE)
  mf_map(x$green,    col = theme$green,       border = theme$green,       lwd = .5, add = TRUE)
  mf_map(x$water,    col = theme$water,       border = theme$water,       lwd = .5, add = TRUE)
  mf_map(x$railway,  col = theme$railway,                                 lwd = .2, add = TRUE, lty = 2)
  mf_map(x$road,     col = theme$road,        border = theme$road,        lwd = .5, add = TRUE)
  mf_map(x$street,   col = theme$street,      border = theme$street,      lwd = .5, add = TRUE)
  mf_map(x$building, col = theme$building[1], border = theme$building[2], lwd = .5, add = TRUE)
  mf_map(x$zone,     col = NA,                border = theme$zone[2],     lwd = if (is.null(theme$size)) 4 else theme$size,  add = TRUE)
  mf_credits(txt = "\ua9 OpenStreetMap contributors", cex = .8 )

  if((diff(par("usr")[1:2]) / 10) < 1000){
    u = "m"
  } else {
    u = "km"
  }
  mf_scale(scale_units = u)
  mf_title(title)
}

themes = list(
  dark = list(
    zone     = c("#2b2b2b", "#151b23"),
    urban    = "#3a3a3a",
    green    = "#3f4d3f",
    water    = "#1f2a38",
    railway  = "#606060",
    road     = "#2b2b2b",
    street   = "#2b2b2b",
    building = c("#3e3e3e", "#151b23")
  ),
  light = list(
    zone     = c("#f2efe9", "#c6bab1"),
    urban    = "#e0dfdf",
    green    = "#c8facc",
    water    = "#aad3df",
    railway  = "#7f7f7f",
    road     = "#ffffff",
    street   = "#ffffff",
    building = c("#d9d0c9", "#c6bab1")
  ),
  grey = list(
    zone     = c("#e5e5e5", "#000000"),
    urban    = "#dddddd",
    green    = "#bababa",
    water    = "#151b23",
    railway  = "#888888",
    road     = "#ffffff",
    street   = "#ffffff",
    building = c("#aaaaaa", "#555555")
  ),
  pizza = list(
    zone     = c("#a83c0a33", "#d7b578"),
    urban    = "#a83c0a",
    green    = "#569128",
    water    = "#aad3df",
    railway  = "white",
    road     = "grey80",
    street   = "grey80",
    building = c("#942222", "#761B1B"),
    size     = 15
    )
)
