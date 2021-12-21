#' @title Convert a state name, abbreviation, or county name to FIPS codes
#' @param state State names, state abbreviations, or
#'              one of the following: "all", "conus", "territories"
#' @param county County names or "all"
#' @return a `character` vector
#' @examples
#' fipio::as_fips(state = "California")
#' fipio::as_fips(state = "NC")
#' fipio::as_fips(state = "Rhode Island", county = "Washington")
#' fipio::as_fips(c("CA", "North Carolina"), c("Stanislaus", "NEW HANOVER"))
#' fipio::as_fips("CONUS")
#' fipio::as_fips(state = "NC", county = "all")
#'
#' @export
as_fips <- function(state, county = NULL) {
    if (missing(state) | any(state == "") | is.null(state)) {
        stop("`state` must be specified at least.", call. = FALSE)
    }

    contains_all <- "all" %in% state
    contains_ter <- ("us-territories" %in% state) |
                    ("territories" %in% state)

    if (length(state) > 1) {
        if (contains_all & !contains_ter) {
            stop(paste("`state` must only also contain ",
                       "'territories' or 'us-territories'",
                       "when it contains 'all'."))
        }
    }

    state <- tolower(state)
    state <- ifelse(
        state == "virgin islands" | state == "us virgin islands",
        "united states virgin islands",
        ifelse(
            state == "northern mariana islands" | state == "mariana islands",
            "commonwealth of the northern mariana islands",
            state
        )
    )

    ind   <- nchar(as.character(.lookup_fips)) < 3
    ret   <- .lookup_fips[ind]

    if (contains_all) {
        if (!contains_ter) {
            # Only states, no territories
            ret <- ret[ret < 60]
        }
    } else if ("conus" %in% state) {
        # Return all state fip codes, except HI, AK, Guam, etc.
        if (contains_ter) {
            # CONUS and territories
            ret <- ret[!ret %in% c(2, 15)]
        } else {
            # Only CONUS
            ret <- ret[!ret %in% c(2, 15, 60, 66, 69, 72, 78)]
        }
    } else {
        if (contains_ter) {
            repl <- which(state == "us-territories" | state == "territories")

            state <- c(
                state[seq_len(repl - 1)],
                "american samoa",
                "guam",
                "commonwealth of the northern mariana islands",
                "puerto rico",
                "united states virgin islands",
                if (repl != length(state)) state[seq(repl + 1, length(state))]
            )
        }

        # Return state fip codes based on name
        nms <- tolower(with(.metadata_fips, name[ind]))
        abr <- tolower(with(.metadata_fips, state_abbr[ind]))
        x <- match(state, nms)
        y <- match(state, abr)
        rm(nms, abr)

        x[is.na(x)] <- y[!is.na(y)]
        ret <- ret[x]
        rm(x, y)
    }

    if (any(!is.null(county))) {
        county <- tolower(county)
        c_ind  <- !ind & as.integer(substr(.pad0(.lookup_fips), 1, 2)) %in% ret

        if ("all" %in% county) {
            if (length(county) == 1) {
                # Return all fip codes in every state
                ret <- .lookup_fips[c_ind]
            } else {
                ret <- unlist(mapply(as_fips, state, county), use.names = FALSE)
            }
        } else {
            abr <- with(.metadata_fips, state_abbr[match(ret, .lookup_fips)])
            county   <- trimws(gsub("county", "", county))
            counties <- with(.metadata_fips, name[c_ind])
            county_codes <- .lookup_fips[c_ind][
                match(county, tolower(counties))
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
    }

    .pad0(ret)
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
    with(.metadata_fips, state_abbr[.index(fip)])
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
    x <- with(.metadata_fips, state_name[.index(fip)])
    x[is.na(x)] <- with(.metadata_fips, name[.index(fip)])[is.na(x)]
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
    x <- with(.metadata_fips, name[.index(fip)])
    x[nchar(as.character(fip)) == 2] <- NA
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
    .geometry_fips[.index(fip)]
}

#' @title Get the metadata for a FIPS code
#' @inheritParams fips_abbr
#' @param geometry If `TRUE`, returns a geometry column
#' @return a `data.frame`
#' @examples
#' fipio::fips_metadata("37")
#' fipio::fips_metadata("06001")
#'
#' @export
fips_metadata <- function(fip, geometry = FALSE) {
    df <- .metadata_fips[.index(fip), ]
    df[is.na(df$state_name), ]$state_name <- df[is.na(df$state_name), ]$name
    if (geometry) df$geometry <- fips_geometry(fip)

    rownames(df)    <- NULL
    df$fip_code     <- .pad0(fip)
    df$feature_code <- .pad(df$feature_code, 7)
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
