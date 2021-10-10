local_fipio <- function(fip_code, state_abbr, state_name, county_name) {

    multi_test <- if (length(fip_code) > 1) TRUE else FALSE

    state_code <- substr(fip_code, 1, 2)

    descs <- if (multi_test) {
        c("fipio functions return correct information for multiple fips",
          "fipio geometry returns correct information for multiple fips")
    } else {
        c(paste("fipio functions return correct information for fip", fip_code),
          paste("fipio geometry returns correct information for fip", fip_code))
    }

    testthat::test_that(descs[1], {
        expect_abbr(state_code, state_abbr)
        expect_abbr(fip_code, state_abbr)
        expect_state(state_code, state_name)
        expect_state(fip_code, state_name)
        expect_county(fip_code, county_name)
        expect_metadata(state_code, state_name)
        expect_metadata(fip_code, county_name)
    })

    testthat::test_that(descs[2], {
        testthat::skip_if_not(
            requireNamespace("sfheaders", quietly = TRUE),
            message = "`sfheaders` is not available."
        )

        expect_geometry_class(fip_code)
    })
}

expect_abbr <- function(fip, expected) {
    testthat::expect_equal(fipio::fips_abbr(fip), expected)
}

expect_state <- function(fip, expected) {
    testthat::expect_equal(fipio::fips_state(fip), expected)
}

expect_county <- function(fip, expected) {
    testthat::expect_equal(fipio::fips_county(fip), expected)
}

expect_metadata <- function(fip, expected) {
    meta <- fipio::fips_metadata(fip)

    testthat::expect_s3_class(meta, "data.frame")

    if (all(nchar(fip) == 2)) {
        exp_names <- c("state_code", "state_abbr", "state_name", "fip_code")

        testthat::expect_equal(meta$state_name, expected)
    } else {
        exp_names <- c("state_code", "county_code", "fip_code",
                    "state_abbr", "state_name", "county_name")

        testthat::expect_equal(meta$county_name, expected)
    }

    testthat::expect_named(meta, exp_names)
    testthat::expect_equal(
        ifelse(is.na(meta$fip_code), meta$state_code, meta$fip_code),
        fip
    )
}

expect_geometry_class <- function(fip) {
    expect_success({
        geom      <- fipio::fips_geometry(fip)
        geom_meta <- fipio::fips_metadata(fip, geometry = TRUE)

        sf_class <- c("sfg", "sfc", "sf")
        tests <- unlist(
            lapply(
                c(geom, geom_meta$geometry),
                FUN = function(x) {
                    any(sf_class %in% class(x))
                }
            )
        )

        if (all(tests)) {
            testthat::succeed(message = "Geometry returned!")
        } else {
            testthat::fail(
                message = paste(
                    "These fips did not return geometry:",
                    paste(fip, collapse = ", ")
                )
            )
        }
    })
}