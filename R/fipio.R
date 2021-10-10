#' @title Get the state abbreviation for a FIPS code
#' @param fip 2-digit or 5-digit FIPS code
#' @return a `character` vector
#' @examples
#' fipio::fips_abbr("37")
#' fipio::fips_abbr("06001")
#'
#' @export
fips_abbr <- function(fip) {
    tmp <- unique(fips_[, c(1, 4)])
    tmp[[2]][match(substr(fip, 1, 2), tmp[[1]])]
}

#' @title Get the state name for a FIPS code
#' @inheritParams fips_abbr
#' @return a `character` vector
#' @examples
#' fipio::fips_state("37")
#' fipio::fips_state("06001")
#'
#' @export
fips_state <- function(fip) {
    tmp <- unique(fips_[, c(1, 5)])
    tmp[[2]][match(substr(fip, 1, 2), tmp[[1]])]
}

#' @title Get the county name for a FIPS code
#' @inheritParams fips_abbr
#' @return a `character` vector
#' @examples
#' fipio::fips_county("37129")
#' fipio::fips_county("06001")
#'
#' # 2-digit FIP codes will not work
#' fipio::fips_county("37")
#'
#' @export
fips_county <- function(fip) {
    tmp <- fips_[, c(3, 6)]
    tmp[[2]][match(fip, tmp[[1]])]
}


#' @title Get the geometry for a FIPS code
#' @inheritParams fips_abbr
#' @return an `sfg`/`sfc` object
#' @examples
#' \dontrun{
#' fipio::fips_geometry("37")
#' fipio::fips_geometry("06001")
#' }
#'
#' @export
fips_geometry <- function(fip) {
    if (.has_sfheaders()) {
        geo_$geometry[match(fip, geo_$fip_code)]
    } else {
        stop("`fipio::geometry()` requires `sfheaders`.", call. = FALSE)
    }
}

#' @title Get the metadata for a FIPS code
#' @inheritParams fips_abbr
#' @param geometry If `TRUE`, returns a geometry column (requires `sfheaders`)
#' @return a `data.frame`
#' @examples
#' fipio::fips_metadata("37")
#' fipio::fips_metadata("06001")
#'
#' @export
fips_metadata <- function(fip, geometry = FALSE) {
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

    if (geometry) df$geometry <- fips_geometry(df$fip_code)

    rownames(df) <- NULL

    df
}

#' @keywords internal
.has_sfheaders <- function() {
    requireNamespace("sfheaders", quietly = TRUE)
}