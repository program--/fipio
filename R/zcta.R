#' @title Get FIPS codes for a given zip code/ZCTA
#' @param zip_code a 5-digit US zip code.
#' @param ... Additional 5-digit US zip codes.
#' @return a `list` with names set to the given
#'         zip codes, and elements of FIPS codes.
#' @examples
#' fipio::zip_to_fips("95380", "28412")
#' @export
zip_to_fips <- function(zip_code, ...) {
    .zipfip(zip_code, ..., col = "zip_code", opp = "fip_code")
}

#' @title Get zip codes for a given FIPS code.
#' @param fip_code a 5-digit US FIPS code.
#' @param ... Additional 5-digit US FIPS codes.
#' @return a `list` with names set to the given
#'         FIPS codes, and elements of zip codes.
#' @examples
#' fipio::fips_to_zip("37129", "06099")
#' @export
fips_to_zip <- function(fip_code, ...) {
    .zipfip(fip_code, ..., col = "fip_code", opp = "zip_code")
}

#' @keywords internal
.zipfip <- function(..., col, opp) {
    codes    <- c(...)
    x        <- zip_[which(zip_[[col]] %in% codes), ]
    x        <- split(x, f = x[[col]])
    x_nms    <- names(x)
    x        <- lapply(x, function(y) y[[opp]])
    names(x) <- x_nms
    x        <- x[codes]
    names(x) <- codes
    x
}