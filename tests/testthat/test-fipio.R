fip_codes    <- c("46093", "30099", "72015", "29229", "01083")
state_abbrs  <- c("SD", "MT", "PR", "MO", "AL")
state_names  <- c("South Dakota", "Montana", "Puerto Rico", "Missouri", "Alabama")
county_names <- c("Meade", "Teton", "Arroyo Municipio", "Wright", "Limestone")

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
    county_name = c(county_names[1], NA)
)

# Individual tests
invisible(mapply(
    FUN         = local_fipio,
    fip_code    = fip_codes,
    state_abbr  = state_abbrs,
    state_name  = state_names,
    county_name = county_names
))

# Test error
testthat::test_that("fipio returns an error if `sfheaders` is not installed", {
    mockery::stub(fips_geometry, ".has_sfheaders", FALSE)
    testthat::expect_error(fips_geometry(NA))
})