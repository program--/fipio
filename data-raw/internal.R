library(dplyr)
tiger_url <- "https://www2.census.gov/geo/tiger/TIGER2021/"

state_zip <- "./data-raw/tl_2021_us_state.zip"
withr::defer(unlink(state_zip))
httr::GET(
    paste0(tiger_url, "STATE/tl_2021_us_state.zip"),
    httr::write_disk(state_zip, overwrite = TRUE),
    httr::progress()
)
state_dir <- fs::dir_create("./data-raw/state_shp")
unzip(state_zip, exdir = state_dir)
withr::defer(fs::dir_delete(state_dir))
state_shp <- list.files(state_dir, pattern = "\\.shp$", full.names = TRUE)
system(paste(
    "ogrinfo -sql \"CREATE SPATIAL INDEX ON tl_2021_us_state\"",
    state_shp
))

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
county_shp <- list.files(county_dir, pattern = "\\.shp$", full.names = TRUE)
system(paste(
    "ogrinfo -sql \"CREATE SPATIAL INDEX ON tl_2021_us_county\"",
    county_shp
))

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
zcta_shp <- list.files(zcta_dir, pattern = "\\.shp$", full.names = TRUE)
system(paste(
    "ogrinfo -sql \"CREATE SPATIAL INDEX ON tl_2021_us_zcta520\"",
    zcta_shp
))

load("./data-raw/sysdata-old.rda")

# Load shapefiles and transform
tiger_vrt  <- "data-raw/tiger.vrt"

fips_query <- "
SELECT
    states.REGION AS state_region,
    states.DIVISION AS state_division,
    counties.STATEFP AS state_code,
    counties.COUNTYFP AS county_code,
    counties.COUNTYNS AS feature_code,
    counties.GEOID AS fip_code,
    states.NAME as state_name,
    states.STUSPS AS state_abbr,
    counties.NAME AS name,
    counties.CLASSFP AS fip_class,
    counties.MTFCC AS tiger_class,
    counties.CSAFP AS combined_area_code,
    counties.METDIVFP AS metropolitan_area_code,
    counties.FUNCSTAT AS functional_status,
    counties.ALAND AS land_area,
    counties.AWATER AS water_area
FROM
    tl_2021_us_county counties
    LEFT JOIN
        tl_2021_us_state states
    ON
        counties.STATEFP = states.STATEFP
UNION ALL
SELECT
    REGION AS state_region,
    DIVISION AS state_division,
    STATEFP AS state_code,
    STATENS AS feature_code,
    GEOID AS fip_code,
    STUSPS AS state_abbr,
    NAME AS name,
    MTFCC AS tiger_class,
    null AS combined_area_code,
    null AS metropolitan_area_code,
    FUNCSTAT AS functional_status,
    ALAND AS land_area,
    AWATER AS water_area
FROM
    tl_2021_us_state
"

fips_ <- sf::st_read(tiger_vrt, query = fips_query, quiet = TRUE) %>%
         sf::st_transform(4326)

zcta_query <- "
SELECT
    ZCTA5CE20 AS zip_code
FROM
    tl_2021_us_zcta520 AS zcta
"

zcta_data <-
    sf::st_read(tiger_vrt, query = zcta_query, quiet = TRUE) %>%
    sf::st_transform(4326)

# Save transformed data to internal tables ====================================
zip_  <- dplyr::select(fips_, fip_code) %>%
         dplyr::filter(nchar(fip_code) == 5) %>%
         sf::st_join(zcta_data) %>%
         dplyr::select(fip_code, zip_code) %>%
         sf::st_drop_geometry() %>%
         as.data.frame()

fips_ <- sf::st_drop_geometry(fips_) %>%
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