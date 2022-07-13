library(tidyverse)
library(janitor)
library(here)
library(fs)
library(rvest)
library(httr)
library(openxlsx)
library(blsAPI)
library(jsonlite)
library(listviewer)
library(tidyquant)
library(lubridate)
library(scales)
library(plotly)
library(wesanderson)
library(PNWColors)

library(conflicted)

conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")
conflict_prefer("last", "dplyr")
# conflict_prefer("set_names", "purrr")


font_size_tiny   <- 9
font_size_small  <- 9
font_size_medium <- 10
font_size_large  <- 11
font_size_larger <- 12
font_size_huge   <- 13
font_size_giant  <- 15

theme_report <-
  theme_minimal(base_size = font_size_small) +
  theme(strip.text.x = element_text(size = font_size_small, hjust = 0, color = "gray30", face = "bold"),
        axis.title.x = element_text(size = font_size_small, hjust = 1, vjust = 1, color = "gray30", margin = margin(t = 0.1, r = 0, b = 0, l = 0, unit = "in")),
        axis.title.y = element_text(size = font_size_small, hjust = 1, color = "gray30"),
        axis.text.x = element_text(size = font_size_small),
        axis.text.y = element_text(size = font_size_small),
        axis.ticks.x = element_line(color = "gray30"),
        # plot.title.position = "plot",
        # plot.caption.position =  "plot",
        plot.title = element_text(size = font_size_medium, hjust = 0, colour = "gray30", face = "bold"),
        plot.subtitle = element_text(size = font_size_small, color = "gray30", hjust = 0),
        plot.caption = element_text(size = font_size_tiny, hjust = 0, color = "gray30"),
        # plot.caption = element_text(size = font_size_tiny, hjust = 0, color = "gray30", margin = margin(t = 0.15, r = 0, b = 0, l = 0, unit = "in")),
        # panel.spacing = unit(0.25, "in"),
        panel.grid = element_line(colour = "gray95"),
        # panel.grid.minor.x = element_blank(),
        # panel.grid.minor.y = element_blank(),
        legend.title = element_text(size = font_size_small, colour = "gray30"),
        legend.text = element_text(size = font_size_small, colour = "gray30"),
        legend.position = "top",
        legend.justification = 0,
        legend.direction = "horizontal")
# legend.margin = margin(0, 0, -10, 0, unit = "pt"),
# legend.spacing.y = unit(0, "pt"))
# legend.margin = margin(t = -0.1, r = 0, b = -0.1, l = 0, unit = "in"))

theme_slides <-
  theme_minimal(base_size = font_size_larger) +
  theme(strip.text.x = element_text(size = font_size_medium, hjust = 0, color = "gray30", face = "bold"),
        axis.title.x = element_text(size = font_size_medium, hjust = 1, vjust = 1, color = "gray30", margin = margin(t = 0.1, r = 0, b = 0, l = 0, unit = "in")),
        axis.title.y = element_text(size = font_size_medium, hjust = 1, color = "gray30"),
        axis.text.x = element_text(size = font_size_medium, vjust = -1),
        axis.text.y = element_text(size = font_size_medium),
        axis.ticks.x = element_line(color = "gray30"),
        # plot.title.position = "plot",
        # plot.caption.position =  "plot",
        plot.title = element_text(size = font_size_larger, hjust = 0, colour = "gray30", face = "bold"),
        plot.subtitle = element_text(size = font_size_large, color = "gray30", hjust = 0),
        plot.caption = element_text(size = font_size_medium, hjust = 0, vjust = -1, color = "gray30"),
        # plot.caption = element_text(size = font_size_medium, hjust = 0, color = "gray30", margin = margin(t = 0.15, r = 0, b = 0, l = 0, unit = "in")),
        # panel.spacing = unit(0.25, "in"),
        panel.grid = element_line(colour = "gray95"),
        # panel.grid.minor.x = element_blank(),
        # panel.grid.minor.y = element_blank(),
        legend.title = element_text(size = font_size_large, colour = "gray30"),
        legend.text = element_text(size = font_size_large, colour = "gray30"),
        legend.position = "top",
        # legend.justification = 0,
        legend.justification = "left",
        legend.direction = "horizontal")
# legend.margin = margin(0, 0, -10, 0, unit = "pt"),
# legend.spacing.y = unit(0, "pt"))
# legend.margin = margin(t = -0.1, r = 0, b = -0.1, l = 0, unit = "in"))


theme_report_right <-
  theme_report +
  theme(legend.position = "right",
        legend.direction = "vertical")

theme_set(theme_slides)
