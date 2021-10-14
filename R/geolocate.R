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
    coords_to_fips(x = as.numeric(x)[1],
                   y = as.numeric(x)[2])
}
# nocov end

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
    lookup <- geo_[nchar(geo_$fip_code) == 5, ]

    indices <- which(unlist(lapply(
        lookup$geometry,
        FUN = function(g) {
            bb <- .bbox(g)
            any(x >= bb[1] & y >= bb[2] &
                x <= bb[3] & y <= bb[4])
        }
    )))

    lookup <- lookup[indices, ]
    lookup <- cbind(lookup$fip_code,
                    index = lapply(lookup$geometry,
                                   .intersects,
                                   x = x,
                                   y = y))
    lookup <- lookup[
        which(!unlist(lapply(lookup[, 2], identical, numeric(0)))),
    ]

    if (nrow(as.data.frame(lookup)) == 1) {
        lookup[[1]]
    } else {
        lookup <- data.frame(
            fips  = unlist(lookup[, 1]),
            index = unlist(lookup[, 2])
        )

        lookup[order(lookup$index), ]$fips
    }
}