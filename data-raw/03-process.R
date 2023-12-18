#!/usr/bin/env Rscript

.script_dir <-
    commandArgs() |>
    strsplit(split = "=", fixed = TRUE) |>
    Filter(f = \(x) "--file" %in% x) |>
    unlist() |>
    Filter(f = \(x) x != "--file") |>
    dirname()

tiger_gpkg <- file.path(.script_dir, "tiger.gpkg")

compress_geometry <- function(.tbl, fips_col, geom_col, type = "xz") {
    .tbl <- .tbl |>
        dplyr::select(fips = {{ fips_col }}, geometry = {{ geom_col }}) |>
        rmapshaper::ms_simplify(
            keep = 0.05,
            sys = FALSE,
            explode = TRUE,
            keep_shapes = TRUE
        ) |>
        dplyr::group_by(fips) |>
        dplyr::mutate(geometry = sf::st_combine(geometry)) |>
        dplyr::ungroup() |>
        dplyr::distinct(fips, .keep_all = TRUE) |>
        dplyr::arrange(fips) |>
        dplyr::mutate(
            geometry = lapply(sf::st_as_binary(
                geometry,
                endian = "little",
                precision = 10
            ), FUN = identity),
            compressed = lapply(geometry, memCompress, type = "xz"),
            geometry_size = lengths(geometry),
            compressed_size = lengths(compressed)
        ) |>
        dplyr::as_tibble() |>
        dplyr::mutate(geometry = lapply(geometry, FUN = \(x) {
            class(x) <- c("geometry", "raw")
            x
        }))

    geometry_size <- sum(.tbl$geometry_size)
    comp_size <- sum(.tbl$compressed_size)
    cli::cli_alert(c(
        "Compressed: ",
        "{.field {R.utils::hsize(geometry_size)}}",
        " -> ",
        "{.field {R.utils::hsize(comp_size)}}"
    ))

    .tbl <- dplyr::select(
        .tbl,
        {{ fips_col }} := fips,
        {{ geom_col }} := geometry
    )

    attr(.tbl, "sizes") <-
        list(geometry = geometry_size, compressed = comp_size)

    .tbl
}

as_kvlist <- function(.tbl, id_col) {
    .tbl <- dplyr::as_tibble(.tbl)
    kv <- unlist(lapply(
        X = names(.tbl)[names(.tbl) != id_col],
        FUN = \(x) {
            .tbl[c(id_col, x)] |>
                setNames(c("id", "value")) |>
                dplyr::mutate(key = !!x, type = class(value[[1]])[1]) |>
                dplyr::relocate(id, key, type, value) |>
                dplyr::rowwise() |>
                dplyr::group_split()
        }
    ), recursive = FALSE)

    lapply(
        X = unique(.tbl[[id_col]]),
        FUN = \(id) {
            Filter(\(x) x$id == id, kv) |>
                lapply(\(x) {
                    x$value <- as.list(x$value)
                    x
                }) |>
                dplyr::bind_rows()
        }
    ) |>
        dplyr::bind_rows()
}

states <-
    sf::read_sf(tiger_gpkg, "states") |>
    dplyr::select(-INTPTLAT, -INTPTLON, -STATEFP) |>
    dplyr::arrange(GEOID)

states_geom <- compress_geometry(states, GEOID, geom)

states <-
    sf::st_drop_geometry(states) |>
    dplyr::left_join(states_geom, by = "GEOID") |>
    dplyr::rename(geometry = geom)

states_directory <-
    states |>
    dplyr::rowwise() |>
    dplyr::mutate(
        size = purrr::reduce(dplyr::across(
            .cols = c(dplyr::everything(), -dplyr::all_of(states_id_col)),
            .fns = ~ !any(is.na(.))
        ), `+`)
    ) |>
    sf::st_drop_geometry() |>
    dplyr::select(id = dplyr::all_of(states_id_col), size)

states_properties <-
    as_kvlist(states, "GEOID")

#> counties <- sf::read_sf(tiger_gpkg, "counties")
#> counties_geom <- compress_geometry(counties, GEOID, geom)
