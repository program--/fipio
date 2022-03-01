geolocate_data <- readRDS(system.file(
    "testdata",
    "testdata.rds",
    package = "fipio")
)

local_fipio <- function(fip_code, state_abbr, state_name, county_name) {

    multi_test <- if (length(fip_code) > 1) TRUE else FALSE

    state_code <- substr(fip_code, 1, 2)

    descs <- if (multi_test) {
        c("fipio functions return correct information for multiple fips",
          "fipio geometry returns correct information for multiple fips",
          "fipio as_fips returns correct information for multiple descriptions")
    } else {
        c(paste("fipio functions return correct information for fip", fip_code),
          paste("fipio geometry returns correct information for fip", fip_code),
          "fipio as_fips returns correct information for a given description")
    }

    testthat::test_that(descs[1], {
        expect_abbr(state_code, state_abbr)
        expect_abbr(fip_code, state_abbr)
        expect_state(state_code, state_name)
        expect_state(fip_code, state_name)
        expect_county(
            fip_code,
            ifelse(
                nchar(fip_code) == 2,
                NA,
                county_name
            )
        )
        expect_metadata(state_code, state_name)
        expect_metadata(
            fip_code,
            ifelse(
                nchar(fip_code) == 2,
                state_name,
                county_name
            )
        )
    })

    testthat::test_that(descs[2], {
        expect_geometry_class(fip_code)
    })

    testthat::test_that(descs[3], {
        expect_fips(state_name, county_name, fip_code)
        expect_fips(state_abbr, county_name, fip_code)
        expect_fips(toupper(state_name), county_name, fip_code)
        expect_fips(toupper(state_abbr), county_name, fip_code)
        expect_fips(tolower(state_name), county_name, fip_code)
        expect_fips(tolower(state_abbr), county_name, fip_code)
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

    testthat::expect_equal(meta$name, expected)
    exp_names <- c(
        "state_region", "state_division", "feature_code", "state_name",
        "state_abbr", "name", "fip_class", "tiger_class", "combined_area_code",
        "metropolitan_area_code", "functional_status", "land_area", "water_area",
        "fip_code"
    )

    testthat::expect_named(meta, exp_names)
    testthat::expect_equal(meta$fip_code, fip)
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

expect_fips <- function(state, county, expected) {
    if (missing(county)) county <- NULL
    testthat::expect_equal(
        fipio::as_fips(state = state, county = county),
        expected
    )
}

expect_match_assignment <- function(expected) {
    temp_env <- testthat::test_env("fipio")
    assign("match",
           if (.has_fastmatch()) fastmatch::fmatch else base::match,
           pos = temp_env)
    fname <- getNamespaceName(environment(get("match", pos = temp_env)))[[1]]
    testthat::expect_equal(fname, expected)
    rm(temp_env)
}
