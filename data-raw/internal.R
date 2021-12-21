# Download to disk approach, new `tiger.vrt` uses VSIs
#> tiger_url <- "https://www2.census.gov/geo/tiger/TIGER2021/"
#> state_zip <- "./data-raw/tl_2021_us_state.zip"
#> withr::defer(unlink(state_zip))
#> httr::GET(
#>     paste0(tiger_url, "STATE/tl_2021_us_state.zip"),
#>     httr::write_disk(state_zip, overwrite = TRUE),
#>     httr::progress()
#> )
#> state_dir <- fs::dir_create("./data-raw/state_shp")
#> unzip(state_zip, exdir = state_dir)
#> withr::defer(fs::dir_delete(state_dir))
#> state_shp <- list.files(state_dir, pattern = "\\.shp$", full.names = TRUE)
#> Download TIGER shapefiles for counties ======================================
#> county_zip <- "./data-raw/tl_2021_us_county.zip"
#> withr::defer(unlink(county_zip))
#> httr::GET(
#>     paste0(tiger_url, "COUNTY/tl_2021_us_county.zip"),
#>     httr::write_disk(county_zip, overwrite = TRUE),
#>     httr::progress()
#> )
#> county_dir <- fs::dir_create("./data-raw/county_shp")
#> unzip(county_zip, exdir = county_dir)
#> withr::defer(fs::dir_delete(county_dir))
#> county_shp <- list.files(county_dir, pattern = "\\.shp$", full.names = TRUE)
#> Download TIGER shapefiles for ZCTA codes ====================================
#> zcta_zip <- "./data-raw/tl_2021_us_zcta520.zip"
#> withr::defer(unlink(zcta_zip))
#> httr::GET(
#>     paste0(tiger_url, "ZCTA520/tl_2021_us_zcta520.zip"),
#>     httr::write_disk(zcta_zip, overwrite = TRUE),
#>     httr::progress()
#> )
#> zcta_dir <- fs::dir_create("./data-raw/zcta_shp")
#> unzip(zcta_zip, exdir = zcta_dir)
#> withr::defer(fs::dir_delete(zcta_dir))
#> zcta_shp <- list.files(zcta_dir, pattern = "\\.shp$", full.names = TRUE)
#==============================================================================

library(dplyr)

predicate_zip <- function(x, y) {
    indices <- list()
    gint   <- sf::st_intersects(x, y)
    gtouch <- sf::st_touches(x, y)

    iter <- length(gint)

    lapply(
        seq_len(iter),
        function(i) {
            indices[[i]] <<-
                gint[[i]][!gint[[i]] %in% gtouch[[i]]]
        }
    )

    attr(indices, "predicate") <- "intersects & !touches"
    attr(indices, "region.id") <- attr(gint, "region.id")
    attr(indices, "ncol")      <- attr(gint, "ncol")
    class(indices)             <- c("sgbp", "list")

    indices
}

# Load shapefiles and transform
tiger_vrt  <- "data-raw/tiger-local.vrt"

fips_query <- "
SELECT
    states.REGION AS state_region,
    states.DIVISION AS state_division,
    counties.STATEFP as state_code,
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

tbl_fips <- sf::st_read(tiger_vrt, query = fips_query, quiet = TRUE) %>%
            sf::st_transform(4326) %>%
            dplyr::arrange(fip_code) %>%
            dplyr::select(-state_code) %>%
            dplyr::mutate(
                state_region       = as.integer(state_region),
                state_division     = as.integer(state_division),
                feature_code       = as.integer(feature_code),
                tiger_class        = as.factor(tiger_class),
                functional_status  = as.factor(functional_status),
                fip_class          = as.factor(fip_class),
                combined_area_code = as.integer(combined_area_code)
            )

.lookup_fips   <- as.integer(tbl_fips$fip_code)
.metadata_fips <- sf::st_drop_geometry(tbl_fips) %>%
                  dplyr::select(-fip_code)

.geometry_fips <- tbl_fips %>%
                  rmapshaper::ms_simplify(
                      keep = 0.05,
                      sys = TRUE,
                      explode = TRUE,
                      keep_shapes = TRUE
                  ) %>%
                  dplyr::group_by(fip_code) %>%
                  dplyr::mutate(geometry = sf::st_combine(geometry)) %>%
                  dplyr::ungroup() %>%
                  dplyr::distinct(fip_code, .keep_all = TRUE) %>%
                  dplyr::arrange(fip_code)

if (!all(as.integer(.geometry_fips$fip_code) == .lookup_fips)) {
    stop("Geometry isn't indexed correctly")
} else {
    .geometry_fips <- sf::st_geometry(.geometry_fips)
}

# Save transformed data to internal tables ====================================

# Export to data
save(
    .lookup_fips,
    .metadata_fips,
    .geometry_fips,
    file              = "R/sysdata.rda",
    compress          = "xz",
    compression_level = -9,
    version           = 3
)
