
#### United States and Seattle MSA data from BLS ####

# uses BLS API to obtain data directly from BLS
# complication: API allows only 20 years of data per request, thus need to send several requests

# CUURS49DSA0   Seattle MSA CPI-U, NSA: All items in Seattle-Tacoma-Bellevue, WA, all urban consumers, not seasonally adjusted
# CWURS49DSA0   Seattle MSA CPI-W, NSA: All items in Seattle-Tacoma-Bellevue, WA, urban wage earners and clerical workers, not seasonally adjusted

# CUUR0000SA0   U.S.  CPI-U, NSA: All items in U.S. city average, all urban consumers, not seasonally adjusted
# CUSR0000SA0   U.S.  CPI-U, SA:  All items in U.S. city average, all urban consumers, seasonally adjusted

# CWUR0000SA0   U.S.  CPI-W, NSA: All items in U.S. city average, urban wage earners and clerical workers, not seasonally adjusted
# CWSR0000SA0   U.S.  CPI-W, SA:  All items in U.S. city average, urban wage earners and clerical workers, seasonally adjusted


#### request data for one series with start and end dates specified ####

bls_api_key <- set_bls_api_key()

cpi_data_tmp <-
  crossing(series_id = c("CUURS49DSA0", "CWURS49DSA0",
                         "CUUR0000SA0", "CWUR0000SA0",
                         "CUSR0000SA0", "CWSR0000SA0"),
           nesting(start_year = c("1990", "2010"),
                   end_year = c("2009", "2029"))) %>%
  mutate(payload = pmap(list(series_id, start_year, end_year), ~construct_payload(..1, ..2, ..3, bls_api_key)))

cpi_data_raw <-
  cpi_data_tmp %>%
  mutate(data_cln = map(payload, bls_api_request))

cpi_m_cln <-
  cpi_data_raw %>%
  select(data_cln) %>%
  unnest(data_cln) %>%
  filter(period %in% str_c("M", str_pad(1:12, 2, "left", "0"))) %>%
  transmute(series_id,
            var_code = recode(series_id,
                              "CUURS49DSA0" = "KSP_CPIU_NSA",
                              "CWURS49DSA0" = "KSP_CPIW_NSA",
                              "CUUR0000SA0" = "US_CPIU_NSA",
                              "CWUR0000SA0" = "US_CPIW_NSA",
                              "CUSR0000SA0" = "US_CPIU_SA",
                              "CWSR0000SA0" = "US_CPIW_SA"),
            yearm  = str_c(period_name, year) %>% as.yearmon(),
            yr = year(yearm),
            mth = month(yearm),
            lvl = as.numeric(value)) %>%
  separate(var_code, into = c("area_code", "var_stub", "seas"), remove = FALSE) %>%
  arrange(var_code, yearm)  %>%
  group_by(series_id, var_code, mth) %>%
  mutate(gyy = lvl / lag(lvl) - 1) %>%
  ungroup()

bls_cpi_vintage <- cpi_m_cln %>% pluck("yearm") %>% max() %>% as_date() %>% label_date(format = "%Y%m")()

cpi_m_cln %>%
  write_csv(here("data", "wrangled", str_c("cpi_m_cln_", bls_cpi_vintage, ".csv")))

# cpi_m_cln <-
#   dir_ls(here("data", "wrangled"), regex = "cpi_m_cln_\\d{6}\\.csv") %>%
#   last() %>%
#   read_csv() %>%
#   mutate(yearm = as.yearmon(yearm))

# save wide format data to csv
cpi_m_cln_wide <-
  cpi_m_cln %>%
  filter(yearm >= "Jan 2000") %>%
  select(yearm, var_code, lvl) %>%
  pivot_wider(names_from = var_code, values_from = lvl) %>%
  arrange(yearm)

cpi_m_cln_wide %>%
  write_csv(here("data", "wrangled", str_c("cpi_m_cln_", bls_cpi_vintage, "_wide_allmonths.csv"))) %>%
  filter(!is.na( KSP_CPIU_NSA)) %>%
  write_csv(here("data", "wrangled", str_c("cpi_m_cln_", bls_cpi_vintage, "_wide_bimonthly.csv")))

# for quarterly data drop months in incomplete quarters
cpi_m_tmp <-
  cpi_m_cln %>%
  mutate(yearq = as.yearqtr(yearm),
         yr = year(yearm),
         n_in_qtr = if_else(area_code == "US", 3, -(quarter(yearq) %% 2) + 2)) %>%
  group_by(series_id, var_code, yearq) %>%
  filter(n() == n_in_qtr) %>%
  ungroup()

# check dropped months in incomplete quarters
anti_join(cpi_m_cln, cpi_m_tmp, by = c("series_id", "var_code", "area_code", "var_stub", "seas", "yearm")) %>%
  arrange(series_id, yearm)

# construct quarterly averages
cpi_q_cln <-
  cpi_m_tmp %>%
  group_by(var_code, yearq) %>%
  summarise(lvl = mean(lvl, na.rm = TRUE)) %>%
  arrange(var_code, yearq) %>%
  group_by(var_code) %>%
  mutate(gyy = lvl / lag(lvl, 4) - 1) %>%
  ungroup() %>%
  separate(var_code, into = c("area_code", "var_stub", "seas"), remove = FALSE) %>%
  arrange(area_code, var_code, var_stub, yearq)

cpi_q_cln %>%
  write_csv(here("data", "wrangled", str_c("cpi_q_cln_", bls_cpi_vintage, ".csv")))
