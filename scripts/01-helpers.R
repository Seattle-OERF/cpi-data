
#### BLS API helpers ####

set_bls_api_key <- function() {
  config::get("API_keys") %>%
    pluck("BLS_key")
}

construct_payload <- function(.series_id, .startyear, .endyear, .bls_api_key) {
  list("seriesid" = .series_id,
       "startyear" = .startyear,
       "endyear" = .endyear,
       "registrationkey" = .bls_api_key)
}

bls_api_request <- function(.payload) {
  blsAPI(payload = .payload, api_version = 2, return_data_frame = TRUE) %>%
    as_tibble() %>%
    clean_names() %>%
    select(series_id, year, period, period_name, value)
}
