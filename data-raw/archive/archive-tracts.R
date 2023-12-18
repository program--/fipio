query <- "
SELECT
    GEOID AS tract_code,
    ALAND AS land_area,
    AWATER AS water_area,
    SHAPE AS geometry
FROM
    cb_2020_us_tract_500k
" %>% stringr::str_replace_all("\n", " ") %>% stringr::str_squish()

tbl_tracts <- sf::st_read("data-raw/cb_2020_us_all_500k.gdb", query = query) %>%
              dplyr::arrange(tract_code) %>%
              sf::st_transform(4326)

.lookup_tracts <- bit64::as.integer64(tbl_tracts$tract_code)
bit64::hashcache(.lookup_tracts)
.metadata_tracts <- sf::st_drop_geometry(tbl_tracts) %>%
                    dplyr::select(-tract_code)

.geometry_tracts <- tbl_tracts %>%
                    dplyr::select(tract_code, geometry) %>%
                    rmapshaper::ms_simplify(
                        keep = 0.05,
                        sys = TRUE,
                        explode = TRUE,
                        keep_shapes = TRUE
                    ) %>%
                    dplyr::group_by(tract_code) %>%
                    dplyr::mutate(geometry = sf::st_combine(geometry)) %>%
                    dplyr::ungroup() %>%
                    dplyr::distinct(tract_code, .keep_all = TRUE) %>%
                    dplyr::arrange(tract_code) %>%
                    dplyr::pull(geometry)