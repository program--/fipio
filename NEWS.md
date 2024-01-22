# fipio 1.1.2

- Fixed `coords_to_fips()` throwing `order` error due to `ret_index` being a list ([#15](https://github.com/program--/fipio/issues/15))
- Return documentation back to linking to https://github.com/program-- instead of UFOKN's GitHub org.

# fipio 1.1.1

- Added [Mike Johnson](https://github.com/mikejohnson51) to `DESCRIPTION`.
- Fixed `coords_to_fips()` throwing error in some edge cases ([#11](https://github.com/program--/fipio/issues/11)).
- Fixed `as_fips()` throwing error for unknown states. ([#10](https://github.com/program--/fipio/issues/10)).
- Fixed `as_fips()` edge case throwing error ([#13](https://github.com/program--/fipio/pull/13)).

# fipio 1.1.0

* **`fipio` now depends on R >= 3.5.0 due to using `.rds` and version 3 `.rda` files.**

## Enhancements
* Updated internal FIPS table to TIGER 2021.
* Removed `sfheaders` from suggested imports.

## New features
* Added the function `coords_to_fips()`, which provides coordinates to FIPS code utility. This is implemented without `sf` using a simple ray casting algorithm for intersections. Based on a few benchmarks, `coords_to_fips()` performs approximately the same as using `sf::st_intersects()`  against the geometry table, but is most likely slower in the case of having a *large* amount of points.
* Added the function `as_fips()`, which provides a reverse lookup utility for FIPS codes.
* Added `fastmatch` to `Suggests`. If `fastmatch` is installed, all `fipio` functions utilizing `base::match` will instead use `fastmatch::fmatch`.
    - *Note:* this addition includes the function `fipio::using_fastmatch()` for debugging purposes, and test coverage for `.has_fastmatch()`, `using_fastmatch()`, and `.onLoad()` are *essentially* covered by the unit test containing the function calls to `expect_match_assignment()`.
* Added `data-raw/` directory describing process to get internal tables.


# fipio 1.0.0

* Added a `NEWS.md` file to track changes to the package.
* Initial commit to version control with the following functions:
    - `fips_abbr()` - Gets state abbreviation.
    - `fips_state()` - Gets state name.
    - `fips_county()` - Gets county name.
    - `fips_geometry()` - Gets geometry.
    - `fips_metadata()` - Gets the information above as a `data.frame`.
