# Generates the package hex logo (man/figures/logo.png).
#
# Hand-drawn "NHSBSA" wordmark in white on an NHS-blue panel, set in a light hex
# with an NHS-blue border. The hand-drawn marker lettering deliberately signals
# that this is an unofficial, community client — not an official NHS product.

library(hexSticker)
library(ggplot2)
library(sysfonts)
library(showtext)

nhs_blue <- "#005EB8"
hex_fill <- "#FFFFFF"

font_add_google("Permanent Marker", "marker")
showtext_auto()

# A blue panel carrying the white wordmark, used as the hex subplot.
panel <- ggplot() +
  annotate("rect", xmin = 0, xmax = 1, ymin = 0, ymax = 1, fill = nhs_blue) +
  annotate(
    "text",
    x = 0.5,
    y = 0.5,
    label = "NHSBSA",
    family = "marker",
    colour = "white",
    size = 24
  ) +
  coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
  theme_void()

sticker(
  subplot = panel,
  s_x = 1,
  s_y = 1,
  s_width = 1.55,
  s_height = 0.62,
  package = "",
  p_size = 0,
  h_fill = hex_fill,
  h_color = nhs_blue,
  h_size = 1.6,
  url = "github.com/rmgpanw/nhsbsa",
  u_color = nhs_blue,
  u_size = 5,
  dpi = 320,
  filename = "man/figures/logo.png"
)
