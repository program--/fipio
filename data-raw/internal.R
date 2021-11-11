library(dplyr)
tiger_url <- "https://www2.census.gov/geo/tiger/TIGER2021/"

# Download TIGER shapefiles for counties ======================================
county_zip <- "./data-raw/tl_2021_us_county.zip"
withr::defer(unlink(county_zip))
httr::GET(
    paste0(tiger_url, "COUNTY/tl_2021_us_county.zip"),
    httr::write_disk(county_zip, overwrite = TRUE),
    httr::progress()
)
county_dir <- fs::dir_create("./data-raw/county_shp")
unzip(county_zip, exdir = county_dir)
withr::defer(fs::dir_delete(county_dir))

# Download TIGER shapefiles for ZCTA codes ====================================
zcta_zip <- "./data-raw/tl_2021_us_zcta520.zip"
withr::defer(unlink(zcta_zip))
httr::GET(
    paste0(tiger_url, "ZCTA520/tl_2021_us_zcta520.zip"),
    httr::write_disk(zcta_zip, overwrite = TRUE),
    httr::progress()
)
zcta_dir <- fs::dir_create("./data-raw/zcta_shp")
unzip(zcta_zip, exdir = zcta_dir)
withr::defer(fs::dir_delete(zcta_dir))

# Load shapefiles and transform
zcta_shp   <- list.files(zcta_dir, pattern = "\\.shp$", full.names = TRUE)
county_shp <- list.files(county_dir, pattern = "\\.shp$", full.names = TRUE)

zcta_data <- sf::st_read(zcta_shp, quiet = TRUE) %>%
             dplyr::select(zip_code = ZCTA5CE20) %>%
             sf::st_transform(4326)

county_data <-
    sf::st_read(county_shp, quiet = TRUE) %>%
    dplyr::select(
        state_code = STATEFP,
        county_code = COUNTYFP,
        feature_code = COUNTYNS,
        fip_code = GEOID,
        county_name = NAME,
        fips_class = CLASSFP,
        tiger_class = MTFCC,
        combined_area_code = CSAFP,
        metropolitan_area_code = METDIVFP,
        functional_status = FUNCSTAT,
        land_area = ALAND,
        water_area = AWATER
    ) %>%
    dplyr::mutate(
        state_abbr = fipio::fips_abbr(state_code),
        state_name = fipio::fips_state(state_code)
    ) %>%
    dplyr::relocate(
        state_code,
        county_code,
        fip_code,
        state_abbr,
        state_name,
        county_name
    ) %>%
    sf::st_transform(4326) %>%
    dplyr::group_by(fip_code) %>%
    dplyr::arrange(fip_code) %>%
    dplyr::ungroup()

# Save transformed data to internal tables ====================================
load("./data-raw/sysdata-old.rda")

zip_  <- county_data %>%
         sf::st_join(zcta_data) %>%
         dplyr::select(fip_code, zip_code) %>%
         sf::st_drop_geometry() %>%
         as.data.frame()

fips_ <- sf::st_drop_geometry(county_data) %>%
         as.data.frame()

# Export to sysdata.rda
usethis::use_data(
    fips_,
    geo_,
    zip_,
    overwrite = TRUE,
    internal  = TRUE,
    compress  = "xz",
    version   = 3
)