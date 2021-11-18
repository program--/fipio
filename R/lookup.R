#' @title Convert a state name, abbreviation, or county name to FIPS codes
#' @param state State names or abbreviations
#' @param county County names
#' @return a `character` vector
#' @examples
#' fipio::as_fips(state = "California")
#' fipio::as_fips(state = "NC")
#' fipio::as_fips(state = "Rhode Island", county = "Washington")
#' fipio::as_fips(c("CA", "North Carolina"), c("Stanislaus", "NEW HANOVER"))
#'
#' @export
as_fips <- function(state, county = NULL) {
    if (missing(state) | any(state == "") | is.null(state)) {
        stop("`state` must be specificed at least.", call. = FALSE)
    }

    state   <- tolower(state)
    indices <- match(state, tolower(tbl_fips$state_abbr))

    tmp <- match(state, tolower(tbl_fips$state_name))
    indices[is.na(indices)] <- tmp[!is.na(tmp)]
    rm(tmp)

    ret <- tbl_fips$state_code[indices]

    if (any(!is.null(county))) {
        state_abbrs  <- tbl_fips$state_abbr[indices]
        county       <- trimws(gsub("county", "", tolower(county)))
        county_tbl   <- tbl_fips[
            tbl_fips$state_abbr %in% state_abbrs,
            c("fip_code", "name")
        ]
        county_codes <- county_tbl$fip_code[
            match(county, tolower(county_tbl$name))
        ]

        if (all(is.na(county_codes))) {
            repl <- TRUE
        } else {
            repl <- !is.na(c(
                county_codes,
                rep(NA, length(ret) - length(county_codes))
            ))
        }

        ret[repl] <- county_codes[repl]
    }

    ret
}

#' @title Get the state abbreviation for a FIPS code
#' @param fip 2-digit or 5-digit FIPS code
#' @return a `character` vector
#' @examples
#' fipio::fips_abbr("37")
#' fipio::fips_abbr("06001")
#'
#' @export
fips_abbr <- function(fip) {
    with(tbl_fips, state_abbr[.index(fip)])
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
    x <- with(tbl_fips, state_name[.index(fip)])
    x[is.na(x)] <- with(tbl_fips, name[.index(fip)])[is.na(x)]
    x
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
    x <- with(tbl_fips, name[.index(fip)])
    x[nchar(fip) == 2] <- NA
    x
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
    with(tbl_geo, geometry[.index(fip, tbl_geo)])
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
    df <- tbl_fips[.index(fip), ]
    df[is.na(df$state_name), ]$state_name <- df[is.na(df$state_name), ]$name
    if (geometry) df$geometry <- fips_geometry(df$fip_code)
    rownames(df) <- NULL
    df
}

#nocov start
#' @title Get the matching function that `fipio` is using
#' @description
#' This function is primarily for debugging purposes,
#' or for ensuring that the correct matching function
#' is used.
#' @return `TRUE` if `fastmatch::fmatch` is used.
#' @export
using_fastmatch <- function() {
    if (getNamespaceName(environment(match))[[1]] == "fastmatch") {
        TRUE
    } else {
        FALSE
    }
}
#nocov end