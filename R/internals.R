#' @keywords internal
.has_sfheaders <- function() {
    requireNamespace("sfheaders", quietly = TRUE)
}

#nocov start
#' @keywords internal
.has_fastmatch <- function() {
    requireNamespace("fastmatch", quietly = TRUE)
}
#nocov end