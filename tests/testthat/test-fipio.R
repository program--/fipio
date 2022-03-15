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

    expect_fips("CA",
                c("San Luis Obispo", "Santa Barbara",   "Ventura"),
                c("06079", "06083", "06111"))

    testthat::expect_error(fipio::as_fips())
    testthat::expect_error(fipio::as_fips(""))
    testthat::expect_error(fipio::as_fips(NULL))

    testthat::expect_equal(
        fipio::as_fips(state = "American Samoa", county = "all"),
        c("60010", "60020", "60030", "60040", "60050")
    )

    testthat::expect_equal(
        fipio::fips_state(fipio::as_fips("conus")),
        sort(
            c(state.name[!state.abb %in% c("AK", "HI")], "District of Columbia")
        )
    )

    testthat::expect_equal(
        fipio::as_fips(c("conus", "territories")),
        sort(c(
            fipio::as_fips(state.name[!state.abb %in% c("AK", "HI")]),
            "11", "60", "66", "69", "72", "78"
        ))
    )

    testthat::expect_equal(
        fipio::as_fips("territories"),
        c("60", "66", "69", "72", "78")
    )

    testthat::expect_equal(
        fipio::as_fips("us-territories"),
        c("60", "66", "69", "72", "78")
    )

    testthat::expect_error(fipio::as_fips(c("all", "NC")))

    testthat::expect_equal(
        fipio::as_fips("all"),
        sort(c(fipio::as_fips(state.name), "11"))
    )

    testthat::expect_equal(
        fipio::as_fips(c("CA", "RI"), c("Alameda", "all")),
        c("06001", "44001", "44003", "44005", "44007", "44009")
    )
})

# Test matching function
# Coverage for match(), .has_fastmatch(), .onLoad()
testthat::test_that("`fmatch` is assigned to `match` if it is installed", {
    testthat::skip_if(!requireNamespace("mockery", quietly = TRUE))
    m <- mockery::mock(FALSE, TRUE)
    mockery::stub(expect_match_assignment, ".has_fastmatch", m)

    expect_match_assignment("base")
    expect_match_assignment("fastmatch")
})

# Test geolocation function
testthat::test_that("fipio geolocates on `base` classes", {
    testthat::skip_if(
        as.numeric(R.Version()$major) < 3 &
        as.numeric(R.Version()$minor) < 5
    )

    indices <- sample(seq_len(nrow(geolocate_data)), 30)

    # Single Numeric
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = geolocate_data[[2]][indices[1]],
            y = geolocate_data[[3]][indices[1]]
        ),
        geolocate_data[[1]][indices[1]]
    )

    # Single Character
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = as.character(geolocate_data[[2]][indices[1]]),
            y = as.character(geolocate_data[[3]][indices[1]])
        ),
        geolocate_data$FIPS[indices[1]]
    )

    # Vectorized Numeric
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = geolocate_data[[2]][indices],
            y = geolocate_data[[3]][indices]
        ),
        geolocate_data$FIPS[indices]
    )

    # Vectorized Character
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = as.character(geolocate_data[[2]][indices]),
            y = as.character(geolocate_data[[3]][indices])
        ),
        geolocate_data$FIPS[indices]
    )

    # data.frame
    testthat::expect_identical(
        fipio::coords_to_fips(
            x = data.frame(
                X = geolocate_data[[2]][indices],
                Y = geolocate_data[[3]][indices]
            ),
            coords = c("X", "Y")
        ),
        geolocate_data[[1]][indices]
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
    # testthat::skip_if_not_installed("sf")
    # testthat::skip_if_not_installed("sfheaders")
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

testthat::test_that("fipio returns NA for nonexistant states/counties", {
    testthat::expect_equal(
        fipio::as_fips(state = "FAKE"),
        NA_character_
    )

    testthat::expect_equal(
        fipio::as_fips(state = c("CA", "FAKE", "north carolina")),
        c("06", NA_character_, "37")
    )

    testthat::expect_equal(
        fipio::as_fips(state = "FAKE", county = "FAKE"),
        NA_character_
    )

    testthat::expect_equal(
        fipio::as_fips(state = "CA", county = c("FAKE", "Alameda")),
        c(NA_character_, "06001")
    )

    testthat::expect_equal(
        fipio::as_fips(
            state = c("RI", "CA"),
            county = c("bristol", "FAKE", "Alameda")
        ),
        c("44001", NA_character_, "06001")
    )
})