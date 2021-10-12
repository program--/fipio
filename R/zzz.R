#nocov start
.onLoad <- function(libname, pkgname) {
    # Use `fastmatch::fmatch` if it's available
    assign("match",
           if (.has_fastmatch()) fastmatch::fmatch else base::match,
           pos = getNamespace("fipio"))
}
#nocov end