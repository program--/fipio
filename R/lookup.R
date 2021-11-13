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
    indices <- match(state, tolower(fips_$state_abbr))

    tmp <- match(state, tolower(fips_$state_name))
    indices[is.na(indices)] <- tmp[!is.na(tmp)]
    rm(tmp)

    ret <- fips_$state_code[indices]

    if (any(!is.null(county))) {
        state_abbrs  <- fips_$state_abbr[indices]
        county       <- trimws(gsub("county", "", tolower(county)))
        county_tbl   <- fips_[
            fips_$state_abbr %in% state_abbrs,
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
    fips_$state_abbr[.index(fip)]
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
    ifelse(
        nchar(fip) == 2,
        fips_$name[.index(fip)],
        fips_$state_name[.index(fip)]
    )
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
    ifelse(
        nchar(fip) == 2,
        as.character(NA),
        fips_$name[.index(fip)]
    )
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
    df <- fips_[.index(fip), ]
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