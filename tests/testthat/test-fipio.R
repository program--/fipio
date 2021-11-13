fip_codes    <- c("46093", "30099", "72015", "29229", "01083")
state_abbrs  <- c("SD", "MT", "PR", "MO", "AL")
state_names  <- c("South Dakota", "Montana", "Puerto Rico", "Missouri", "Alabama")
county_names <- c("Meade", "Teton", "Arroyo", "Wright", "Limestone")

# Vectorized test
local_fipio(
    fip_code    = fip_codes,
    state_abbr  = state_abbrs,
    state_name  = state_names,
    county_name = county_names
)

# Test with both 5-digit and 2-digit fip codes
local_fipio(
    fip_code    = c(fip_codes[1], substr(fip_codes[2], 1, 2)),
    state_abbr  = state_abbrs[1:2],
    state_name  = state_names[1:2],
    county_name = c(county_names[1], state_names[2])
)

# Individual tests
invisible(mapply(
    FUN         = local_fipio,
    fip_code    = fip_codes,
    state_abbr  = state_abbrs,
    state_name  = state_names,
    county_name = county_names
))

testthat::test_that("as_fips edge cases", {
    expect_fips("CA", NULL, "06")
    expect_fips("california", NULL, "06")

    expect_fips(c("CA", "NC"),
                c("Stanislaus"),
                c("06099", "37"))

    expect_fips(c("CA", "NC", "RI"),
                c("Stanislaus", NA, "Bristol"),
                c("06099", "37", "44001"))

    expect_fips(c("CA", "NC", "RI"),
                c(NA, "New Hanover", "Bristol"),
                c("06", "37129", "44001"))

    expect_fips(c("CA", "NC", "RI"),
                c(NA, "New Hanover", NA),
                c("06", "37129", "44"))

    expect_fips("CA", "fakecounty", as.character(NA))

    testthat::expect_error(fipio::as_fips())
    testthat::expect_error(fipio::as_fips(""))
    testthat::expect_error(fipio::as_fips(NULL))
})

# Test error
testthat::test_that("fipio returns an error if `sfheaders` is not installed", {
    testthat::skip_if(!requireNamespace("mockery", quietly = TRUE))
    mockery::stub(fips_geometry, ".has_sfheaders", FALSE)
    testthat::expect_error(fips_geometry(NA))
})

# Test matching function
# Coverage for matchfn(), .has_fastmatch(), .onLoad()
testthat::test_that("`fmatch` is assigned to `match` if it is installed", {
    testthat::skip_if(!requireNamespace("mockery", quietly = TRUE))
    m <- mockery::mock(FALSE, TRUE)
    mockery::stub(expect_match_assignment, ".has_fastmatch", m)

    expect_match_assignment("base")
    expect_match_assignment("fastmatch")
})

# Test geolocation function
testthat::test_that("fipio geolocates on `base` classes", {
    testthat::skip_if(R.Version()$major != "4" & R.Version()$minor != "1.1")
    indices <- sample(seq_len(nrow(geolocate_data)), 30)

    # Single Numeric
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = geolocate_data$X[indices[1]],
            y = geolocate_data$Y[indices[1]]
        ),
        geolocate_data$FIPS[indices[1]]
    )

    # Single Character
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = as.character(geolocate_data$X[indices[1]]),
            y = as.character(geolocate_data$Y[indices[1]])
        ),
        geolocate_data$FIPS[indices[1]]
    )

    # Vectorized Numeric
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = geolocate_data$X[indices],
            y = geolocate_data$Y[indices]
        ),
        geolocate_data$FIPS[indices]
    )

    # Vectorized Character
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = as.character(geolocate_data$X[indices]),
            y = as.character(geolocate_data$Y[indices])
        ),
        geolocate_data$FIPS[indices]
    )

    # data.frame
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = as.data.frame(geolocate_data[indices, 2:3]),
            coords = c("X", "Y")
        ),
        geolocate_data$FIPS[indices]
    )

    # matrix
    testthat::expect_identical(
        fipio::coords_to_fips(
            matrix(
                data = c(
                    geolocate_data$X[indices],
                    geolocate_data$Y[indices]
                ),
                ncol = 2, nrow = 30
            )
        ),
        geolocate_data$FIPS[indices]
    )
})

testthat::test_that("fipio geolocates on `sf` classes", {
    testthat::skip_if_not_installed("sf")
    testthat::skip_if_not_installed("sfheaders")
    testthat::skip_on_cran()

    indices <- sample(seq_len(nrow(geolocate_data)), 10)

    # sf
    testthat::expect_identical(
        fipio::coords_to_fips(geolocate_data[indices, ]),
        geolocate_data$FIPS[indices]
    )

    # sfc
    testthat::expect_identical(
        fipio::coords_to_fips(geolocate_data[indices, ]$geometry),
        geolocate_data$FIPS[indices]
    )

    # sfg
    testthat::expect_identical(
        fipio::coords_to_fips(geolocate_data[indices[1], ]$geometry),
        geolocate_data$FIPS[indices[1]]
    )
})

testthat::test_that("fipio matches zip codes to FIPS", {
    testthat::expect_true(
        "06099" %in% fipio::zip_to_fips("95380")$`95380`
    )

    testthat::expect_true(
        "06099" %in% fipio::zip_to_fips("28401", "95380")$`95380` &
        "37129" %in% fipio::zip_to_fips("28401", "95380")$`28401`
    )
})

testthat::test_that("fipio matches FIPS to zip code", {
    testthat::expect_true(
        "95380" %in% fipio::fips_to_zip("06099")$`06099`
    )

    testthat::expect_true(
        "95380" %in% fipio::fips_to_zip("37129", "06099")$`06099` &
        "28401" %in% fipio::fips_to_zip("37129", "06099")$`37129`
    )
})