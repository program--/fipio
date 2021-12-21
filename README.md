
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fipio <a href="https://github.com/program--/fipio"><img src="man/figures/logo.png" align="right" height="200"/></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/fipio)](https://CRAN.R-project.org/package=fipio)
[![Devel
Version](https://img.shields.io/badge/devel%20version-1.0.0.9000-blue.svg)](https://github.com/program--/fipio)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/fipio)](https://CRAN.R-project.org/package=fipio)
[![codecov](https://codecov.io/gh/program--/fipio/branch/master/graph/badge.svg?token=1ODDHARQM1)](https://codecov.io/gh/program--/fipio)
[![R-CMD-check](https://github.com/program--/fipio/workflows/R-CMD-check/badge.svg)](https://github.com/program--/fipio/actions)
[![MIT
License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

`fipio` is a **lightweight** package that makes it easy to get
information about a US FIPS code.

## Installation

You can install the released version of `fipio` from
[CRAN](https://CRAN.R-project.org) with:

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
#>   state_region state_division state_code county_code feature_code fip_code
#> 1            3              5         37         129     01026329    37129
#>       state_name state_abbr        name fip_class tiger_class
#> 1 North Carolina         NC New Hanover        H1       G4020
#>   combined_area_code metropolitan_area_code functional_status land_area
#> 1               <NA>                   <NA>                 A 497937486
#>   water_area
#> 1  353803887

# And the metadata for the state by itself...
fipio::fips_metadata("37")
#>   state_region state_division state_code county_code feature_code fip_code
#> 1            3              5         37        <NA>     01027616       37
#>       state_name state_abbr           name fip_class tiger_class
#> 1 North Carolina         NC North Carolina      <NA>       G4000
#>   combined_area_code metropolitan_area_code functional_status    land_area
#> 1               <NA>                   <NA>                 A 125933327733
#>    water_area
#> 1 13456093195
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
#> MULTIPOLYGON (((-77.89701 33.7868, -77.89369 33...

# What if I need it with my other metadata?
fipio::fips_metadata(fip, geometry = TRUE)
#>   state_region state_division state_code county_code feature_code fip_code
#> 1            3              5         37         129     01026329    37129
#>       state_name state_abbr        name fip_class tiger_class
#> 1 North Carolina         NC New Hanover        H1       G4020
#>   combined_area_code metropolitan_area_code functional_status land_area
#> 1               <NA>                   <NA>                 A 497937486
#>   water_area                       geometry
#> 1  353803887 MULTIPOLYGON (((-77.89701 3...
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
#>   state_region state_division state_code county_code feature_code fip_code
#> 1            3              5         37         129     01026329    37129
#> 2            1              1         44         001     01219777    44001
#> 3            3              7         48         115     01383843    48115
#>       state_name state_abbr        name fip_class tiger_class
#> 1 North Carolina         NC New Hanover        H1       G4020
#> 2   Rhode Island         RI     Bristol        H4       G4020
#> 3          Texas         TX      Dawson        H1       G4020
#>   combined_area_code metropolitan_area_code functional_status  land_area
#> 1               <NA>                   <NA>                 A  497937486
#> 2                148                   <NA>                 N   62500772
#> 3               <NA>                   <NA>                 A 2331781561
#>   water_area
#> 1  353803887
#> 2   53359134
#> 3    4720730

fipio::fips_geometry(fips)
#> Geometry set for 3 features 
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -102.2085 ymin: 32.52327 xmax: -71.20837 ymax: 41.7762
#> Geodetic CRS:  WGS 84
#> MULTIPOLYGON (((-77.89701 33.7868, -77.89369 33...
#> MULTIPOLYGON (((-71.33097 41.68696, -71.32372 4...
#> MULTIPOLYGON (((-102.2027 32.52327, -102.0004 3...
```

### Reverse Geolocate Coordinates to FIPS (`fipio` \>= 1.0.0.9000)

`fipio` contains the ability to locate the FIPS code(s) for a set of
coordinates (in `WGS84`/`EPSG: 4326`):

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
