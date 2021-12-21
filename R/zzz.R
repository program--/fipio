#nocov start
.onLoad <- function(libname, pkgname) {
    # Use `fastmatch::fmatch` and `fastmatch::%fin%` if it's available
    assign("match",
           if (.has_fastmatch()) fastmatch::fmatch else base::match,
           pos = getNamespace("fipio"))

    assign("%in%",
           if (.has_fastmatch()) fastmatch::`%fin%` else base::`%in%`,
           pos = getNamespace("fipio"))
}
#nocov end