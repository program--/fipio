# zcta_query <- "
# SELECT
#     ZCTA5CE20 AS zip_code
# FROM
#     tl_2021_us_zcta520
# "
# 
# tbl_zip <-
#     sf::st_read(tiger_vrt, query = zcta_query, quiet = TRUE) %>%
#     sf::st_transform(4326) %>%
#     dplyr::arrange(zip_code)
# 
# .lookup_zips   <- as.integer(tbl_zip$zip_code)
# .metadata_zips <- sf::st_join(tbl_zip, tbl_fips, join = predicate_zip) %>%
#                   sf::st_drop_geometry() %>%
#                   dplyr::arrange(zip_code) %>%
#                   dplyr::mutate(
#                       zip_code = match(as.integer(zip_code), .lookup_zips),
#                       fip_code = match(as.integer(fip_code), .lookup_fips)
#                   ) %>%
#                   as.data.frame(row.names = seq_len(nrow(.)))
# Original:
# .geometry_zips <- tbl_zip %>%
#                   rmapshaper::ms_simplify(
#                       keep = 0.02,
#                       sys = TRUE,
#                       explode = TRUE,
#                       keep_shapes = TRUE
#                   ) %>%
#                   sf::st_make_valid() %>%
#                   dplyr::group_by(zip_code) %>%
#                   dplyr::mutate(geometry = sf::st_combine(geometry)) %>%
#                   dplyr::ungroup() %>%
#                   dplyr::distinct(zip_code, .keep_all = TRUE) %>%
#                   dplyr::arrange(zip_code)
# if (!all(as.integer(.geometry_zips$zip_code) == .lookup_zips)) {
#     stop("Geometry isn't indexed correctly")
# } else {
#     .geometry_zips <- sf::st_geometry(.geometry_zips)
# }
#> Loaded original dataset into mapshaper and simplified to 0.3%
#> Resulting data was exported then loaded into R
# .geometry_zips <- readRDS("data-raw/zips.rds")