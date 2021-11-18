#' @title Get FIPS codes for a given zip code/ZCTA
#' @param zip_code a 5-digit US zip code.
#' @param ... Additional 5-digit US zip codes.
#' @return a `list` with names set to the given
#'         zip codes, and elements of FIPS codes.
#' @examples
#' fipio::zip_to_fips("95380", "28412")
#' @export
zip_to_fips <- function(zip_code, ...) {
    codes <- c(zip_code, ...)
    x <- strsplit(with(tbl_zip, fip_code[match(codes, zip_code)]), ":")
    names(x) <- codes

    x
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
    codes <- c(fip_code, ...)
    x <- lapply(codes, function(fip) {
        with(tbl_zip, zip_code[which(grepl(fip, fip_code))])
    })
    names(x) <- codes

    x
}

#' @title Get zip code geometry
#' @param zip_code a 5-digit US zip code
#' @param ... Additional zip codes
#' @return an `sfc` object of zip_code geometries
#' @export
zip_geometry <- function(zip_code, ...) {
    codes <- c(zip_code, ...)
    with(tbl_zip, geometry[match(codes, zip_code)])
}