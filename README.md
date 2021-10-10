
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fipio

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/fipio)](https://CRAN.R-project.org/package=fipio)
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
#>   state_code county_code fip_code state_abbr     state_name county_name
#> 1         37         129    37129         NC North Carolina New Hanover

# And the metadata for the state by itself...
fipio::fips_metadata("37")
#>   state_code state_abbr     state_name fip_code
#> 1         37         NC North Carolina       37
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
#> Bounding box:  xmin: -78.02992 ymin: 34.03824 xmax: -77.71351 ymax: 34.38903
#> Geodetic CRS:  WGS 84
#> MULTIPOLYGON (((-78.02992 34.33177, -77.82268 3...

# What if I need it with my other metadata?
fipio::fips_metadata(fip, geometry = TRUE)
#>   state_code county_code fip_code state_abbr     state_name county_name
#> 1         37         129    37129         NC North Carolina New Hanover
#>                         geometry
#> 1 MULTIPOLYGON (((-78.02992 3...
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
#>   state_code county_code fip_code state_abbr     state_name county_name
#> 1         37         129    37129         NC North Carolina New Hanover
#> 2         44         001    44001         RI   Rhode Island     Bristol
#> 3         48         115    48115         TX          Texas      Dawson

fipio::fips_geometry(fips)
#> Geometry set for 3 features 
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -102.2085 ymin: 32.52327 xmax: -71.2086 ymax: 41.77726
#> Geodetic CRS:  WGS 84
#> MULTIPOLYGON (((-78.02992 34.33177, -77.82268 3...
#> MULTIPOLYGON (((-71.36521 41.73565, -71.3174 41...
#> MULTIPOLYGON (((-102.2085 32.95896, -102.0762 3...
```
