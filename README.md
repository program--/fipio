
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fipio <a href="https://github.com/program--/fipio"><img src="man/figures/logo.png" align="right" width="25%"/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/fipio)](https://CRAN.R-project.org/package=fipio)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/fipio)](https://CRAN.R-project.org/package=fipio)
[![codecov](https://codecov.io/gh/program--/fipio/graph/badge.svg?token=1ODDHARQM1)](https://app.codecov.io/gh/program--/fipio)
[![R-CMD-check](https://github.com/program--/fipio/workflows/R-CMD-check/badge.svg)](https://github.com/program--/fipio/actions)
[![MIT
License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)
<!-- badges: end -->

`fipio` is a **lightweight** package that makes it easy to get
information about a US FIPS code.

## Installation

You can install the released version of `fipio` from
[CRAN](https://cran.r-project.org/package=fipio) with:

``` r
install.packages("fipio")
```

or the development version with `pak` or `remotes`:

``` r
# Using `pak`
pak::pkg_install("program--/fipio")

# Using `remotes`
remotes::install_github("program--/fipio")
```

## Usage

`fipio` makes it easy to get information about a US FIPS code. Let’s
answer a few questions that might come up if you have a FIPS code:

``` r
fip <- "37129"

# What state is `37129` in?
fipio::fips_state(fip)
#> [1] "North Carolina"

# Alternatively, you can use the state FIPS code by itself
fipio::fips_state("37")
#> [1] "North Carolina"

# What about the state abbreviation?
fipio::fips_abbr(fip)
#> [1] "NC"

# What county is `37129`?
fipio::fips_county(fip)
#> [1] "New Hanover"

# It'd be nice to have this all in a data.frame...
fipio::fips_metadata(fip)
#>   state_region state_division feature_code     state_name state_abbr
#> 1            3              5      1026329 North Carolina         NC
#>          name fip_class tiger_class combined_area_code metropolitan_area_code
#> 1 New Hanover        H1       G4020                 NA                   <NA>
#>   functional_status land_area water_area fip_code
#> 1                 A 497937486  353803887    37129

# And the metadata for the state by itself...
fipio::fips_metadata("37")
#>   state_region state_division feature_code     state_name state_abbr
#> 1            3              5      1027616 North Carolina         NC
#>             name fip_class tiger_class combined_area_code
#> 1 North Carolina      <NA>       G4000                 NA
#>   metropolitan_area_code functional_status    land_area  water_area fip_code
#> 1                   <NA>                 A 125933327733 13456093195       37
```

### With `sf`

`fipio` also includes functions that support geometry for FIPS codes.
This requires `sfheaders` at the very least to get an `sf`-compatible
geometry object back.

``` r
# I'm doing spatial work, what's the geometry of `37129`?
fipio::fips_geometry(fip)
#> Geometry set for 1 feature 
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -78.02992 ymin: 33.7868 xmax: -77.67528 ymax: 34.38929
#> Geodetic CRS:  WGS 84
#> MULTIPOLYGON (((-77.89701 33.7868, -77.8952 33....

# What if I need it with my other metadata?
fipio::fips_metadata(fip, geometry = TRUE)
#>   state_region state_division feature_code     state_name state_abbr
#> 1            3              5      1026329 North Carolina         NC
#>          name fip_class tiger_class combined_area_code metropolitan_area_code
#> 1 New Hanover        H1       G4020                 NA                   <NA>
#>   functional_status land_area water_area                       geometry
#> 1                 A 497937486  353803887 MULTIPOLYGON (((-77.89701 3...
#>   fip_code
#> 1    37129
```

### Vectorized

`fipio` functions are inherently vectorized, so you can use them with
vectors of FIPS codes easily:

``` r
fips <- c("37129", "44001", "48115")

fipio::fips_state(fips)
#> [1] "North Carolina" "Rhode Island"   "Texas"

fipio::fips_abbr(fips)
#> [1] "NC" "RI" "TX"

fipio::fips_county(fips)
#> [1] "New Hanover" "Bristol"     "Dawson"

fipio::fips_metadata(fips)
#>   state_region state_division feature_code     state_name state_abbr
#> 1            3              5      1026329 North Carolina         NC
#> 2            1              1      1219777   Rhode Island         RI
#> 3            3              7      1383843          Texas         TX
#>          name fip_class tiger_class combined_area_code metropolitan_area_code
#> 1 New Hanover        H1       G4020                 NA                   <NA>
#> 2     Bristol        H4       G4020                148                   <NA>
#> 3      Dawson        H1       G4020                 NA                   <NA>
#>   functional_status  land_area water_area fip_code
#> 1                 A  497937486  353803887    37129
#> 2                 N   62500772   53359134    44001
#> 3                 A 2331781561    4720730    48115

fipio::fips_geometry(fips)
#> Geometry set for 3 features 
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -102.2085 ymin: 32.52327 xmax: -71.20837 ymax: 41.7762
#> Geodetic CRS:  WGS 84
#> MULTIPOLYGON (((-77.89701 33.7868, -77.8952 33....
#> MULTIPOLYGON (((-71.33097 41.68696, -71.32372 4...
#> MULTIPOLYGON (((-102.2027 32.52327, -102.1201 3...
```

### Reverse Geolocate Coordinates to FIPS

`fipio` contains the ability to locate the FIPS code(s) for a set of
coordinates (in `WGS84`/`EPSG:4326`):

``` r
# With a single set of coordinates
fipio::coords_to_fips(x = -119.8696, y = 34.4184)
#> [1] "06083"

# Vectorized
fipio::coords_to_fips(
    x = c(-81.4980534549709, -81.1249425046948),
    y = c(36.4314781444978, 36.4911893240597)
)
#> [1] "37009" "37005"

# With a `data.frame` or `matrix`
fipio::coords_to_fips(
    x = data.frame(
        X = c(-81.4980534549709, -81.1249425046948),
        Y = c(36.4314781444978, 36.4911893240597)
    ),
    coords = c("X", "Y")
)
#> [1] "37009" "37005"

# With an `sfg` object
fipio::coords_to_fips(
    x   = sf::st_point(c(-81.4980534549709,
                         36.4314781444978)),
    dim = "XY"
)
#> [1] "37009"

# With an `sf` object
fipio::coords_to_fips(
    x = sf::st_as_sf(
        data.frame(X = c(-81.4980534549709, -81.1249425046948),
                   Y = c(36.4314781444978, 36.4911893240597)),
        coords = c("X", "Y"),
        crs = 4326
    )
)
#> [1] "37009" "37005"
```
