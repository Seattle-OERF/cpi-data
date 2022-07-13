
#### plots ####

add_labels <- function(.data) {
  .data %>%
    mutate(var_stub_label = recode(var_stub,
                                   "CPIU" = "CPI-U",
                                   "CPIW" = "CPI-W"),
           area_label = recode(area_code,
                               "US" = "United States",
                               "KSP" = "Seattle MSA"),
           reference = case_when(measure == "gyy" ~ 0,
                                 TRUE             ~ NA_real_),
           hover_label = str_c(area_label, " ",
                               var_stub_label, "<br>",
                               time_period, "<br>",
                               label_percent(accuracy = 0.1)(value)))
}

cpi_m_plt <-
  cpi_m_cln %>%
  pivot_longer(c(lvl, gyy), names_to = "measure") %>%
  arrange(var_code, measure, yearm) %>%
  mutate(freq = "M",
         time_period = yearm) %>%
  add_labels()

cpi_q_plt <-
  cpi_q_cln %>%
  pivot_longer(c(lvl, gyy), names_to = "measure") %>%
  arrange(var_code, measure, yearq) %>%
  mutate(freq = "Q",
         time_period = yearq) %>%
  add_labels()

pal_us_vs_seattle <- pnw_palette("Bay", 4)[c(4, 1)]
pal_cpiu_vs_cpiw <- wes_palette("Darjeeling1")

# templates
g_cpi <-
  ggplot() +
    geom_hline(aes(yintercept = reference), col = "gray50") +
    geom_line(size = 1) +
    scale_y_continuous(limits = c(-0.025, 0.1), breaks = seq(-0.025, 0.1, 0.025), labels = label_percent())

g_cpi_by_index <-
  g_cpi +
    aes(x = time_period, y = value, col = area_label, text = hover_label, group = area_label) +
    scale_color_manual(values = pal_us_vs_seattle) +
    labs(x = NULL, y = NULL, color = NULL,
         title = "CPI-U and CPI-W Inflation, Not Seasonally Adjusted") +
    facet_grid(~ var_stub_label)

g_cpi_by_area <-
  g_cpi +
    aes(x = time_period, y = value, col = var_stub_label, text = hover_label, group = var_stub_label) +
    scale_color_manual(values = pal_cpiu_vs_cpiw) +
    labs(x = NULL, y = NULL, color = NULL,
         title = "CPI-U and CPI-W Inflation, Not Seasonally Adjusted") +
    facet_grid(~ area_label)

# plot monthly data
g_cpi_by_index %+%
  {cpi_m_plt %>%
      filter(measure == "gyy",
             yearm >= "Jan 2000")} +
  scale_x_yearmon()
ggplotly(tooltip = "text")

g_cpi_by_area %+%
  {cpi_m_plt %>%
      filter(measure == "gyy",
             yearm >= "Jan 2000")} +
  scale_x_yearmon()
ggplotly(tooltip = "text")

# plot quarterly data
g_cpi_by_index %+%
  {cpi_q_plt %>%
      filter(measure == "gyy",
             yearq >= "2000 Q1")} +
  scale_x_yearqtr(format = "%Y Q%q")
ggplotly(tooltip = "text")
