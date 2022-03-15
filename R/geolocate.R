#' @title Associate a set of coordinates to FIPS codes
#' @param x `data.frame`, `matrix`, `sf`/`sfc`/`sfg` object,
#'           or longitude in *EPSG:4326*
#' @param ... Named arguments passed on to methods
#' @param y Latitude in *EPSG:4326*
#' @param coords Coordinates columns if `x` is a `data.frame` or `matrix`.
#' @examples
#' # Some coordinates at UC Santa Barbara
#' coords_to_fips(x = -119.8696, y = 34.4184)
#' @return a `character` vector of FIPS codes
#' @export
coords_to_fips <- function(x, ...) {
    UseMethod("coords_to_fips")
}

# nocov start
#' @rdname coords_to_fips
#' @export
coords_to_fips.sf <- function(x, ...) {
    coords_to_fips(
        x = do.call(
            rbind,
            lapply(x[[attr(x, "sf_column")]], as.numeric)
        )
    )
}

#' @rdname coords_to_fips
#' @export
coords_to_fips.sfc <- function(x, ...) {
    coords_to_fips(x = do.call(rbind, lapply(x, as.numeric)))
}

#' @rdname coords_to_fips
#' @export
coords_to_fips.sfg <- function(x, ...) {
    coords_to_fips(x = as.numeric(x)[[1]],
                   y = as.numeric(x)[[2]])
}
# nocov end

#' @rdname coords_to_fips
#' @export
coords_to_fips.list <- function(x, ...) {
    coords_to_fips(x = do.call(rbind, x))
}

#' @rdname coords_to_fips
#' @export
coords_to_fips.data.frame <- function(x, coords = c(1, 2), ...) {
    coords_to_fips(x = x[[coords[1]]],
                   y = x[[coords[2]]])
}

#' @rdname coords_to_fips
#' @export
coords_to_fips.matrix <- function(x, coords = c(1, 2), ...) {
    coords_to_fips(x = x[, coords[1]],
                   y = x[, coords[2]])
}

#' @rdname coords_to_fips
#' @export
coords_to_fips.character <- function(x, y, ...) {
    coords_to_fips(x = as.numeric(x),
                   y = as.numeric(y))
}

#' @rdname coords_to_fips
#' @export
coords_to_fips.numeric <- function(x, y, ...) {
    county_fips     <- nchar(as.character(.lookup_fips)) > 3
    lookup_fips     <- .lookup_fips[county_fips]
    lookup_geometry <- .geometry_fips[county_fips]
    rm(county_fips)

    intersected <- which(sapply(
        lookup_geometry,
        FUN = function(g) {
            bb <- .bbox(g)
            any(x >= bb[1] & y >= bb[2] &
                x <= bb[3] & y <= bb[4])
        },
        USE.NAMES = FALSE
    ))

    lookup_fips     <- lookup_fips[intersected]
    lookup_geometry <- lookup_geometry[intersected]

    ret_index <- sapply(
        lookup_geometry,
        FUN = .intersects,
        x = x,
        y = y,
        USE.NAMES = FALSE
    )

    ret_value <- .pad0(lookup_fips)[!is.na(ret_index)]
    ret_index <- ret_index[!is.na(ret_index)]

    rm(lookup_fips, lookup_geometry)

    ret_value[order(ret_index)]
}