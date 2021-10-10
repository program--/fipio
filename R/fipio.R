#' @title Get the state abbreviation for a FIPS code
#' @param fip 2-digit or 5-digit FIPS code
#' @return a `character` vector
#' @examples
#' fipio::abbr("37")
#' fipio::abbr("06001")
#'
#' @export
abbr <- function(fip) {
    tmp <- unique(fips_[, c(1, 4)])
    tmp[[2]][match(substr(fip, 1, 2), tmp[[1]])]
}

#' @title Get the state name for a FIPS code
#' @inheritParams abbr
#' @return a `character` vector
#' @examples
#' fipio::state("37")
#' fipio::state("06001")
#'
#' @export
state <- function(fip) {
    tmp <- unique(fips_[, c(1, 5)])
    tmp[[2]][match(substr(fip, 1, 2), tmp[[1]])]
}

#' @title Get the county name for a FIPS code
#' @inheritParams abbr
#' @return a `character` vector
#' @examples
#' fipio::county("37129")
#' fipio::county("06001")
#'
#' # 2-digit FIP codes will not work
#' fipio::county("37")
#'
#' @export
county <- function(fip) {
    tmp <- fips_[, c(3, 6)]
    tmp[[2]][match(fip, tmp[[1]])]
}


#' @title Get the geometry for a FIPS code
#' @inheritParams abbr
#' @return an `sfg`/`sfc` object
#' @examples
#' \dontrun{
#' fipio::geometry("37")
#' fipio::geometry("06001")
#' }
#'
#' @export
geometry <- function(fip) {
    if (.has_sfheaders()) {
        geo_$geometry[match(fip, geo_$fip_code)]
    } else {
        stop("`fipio::geometry()` requires `sfheaders`.", call. = FALSE)
    }
}

#' @title Get the metadata for a FIPS code
#' @inheritParams abbr
#' @param geometry If `TRUE`, returns a geometry column (requires `sfheaders`)
#' @return a `data.frame`
#' @examples
#' fipio::metadata("37")
#' fipio::metadata("06001")
#'
#' @export
metadata <- function(fip, geometry = FALSE) {
    df <- do.call(rbind, lapply(
        X = fip,
        FUN = function(f) {
            if (nchar(f) == 2) {
                tmp <- unique(fips_[, c(1, 4, 5)])
                tmp <- tmp[match(f, tmp[[1]]), ]
                tmp$fip_code <- tmp$state_code

                if (any(nchar(fip) == 5)) {
                    tmp$county_code <- NA
                    tmp$county_name <- NA
                }
            } else {
                tmp <- fips_[match(substr(f, 1, 5), fips_[[3]]), ]
            }

            tmp
        }
    ))

    if (geometry) df$geometry <- geometry(df$fip_code)

    rownames(df) <- NULL

    df
}

#' @keywords internal
.has_sfheaders <- function() {
    requireNamespace("sfheaders", quietly = TRUE)
}