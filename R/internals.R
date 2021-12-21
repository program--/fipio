#nocov start
#' @keywords internal
.has_fastmatch <- function() {
    requireNamespace("fastmatch", quietly = TRUE)
}
#nocov end

#' @keywords internal
.bbox <- function(geometry) {
    geometry <- .to_matrix(geometry)
    c(xmin = min(geometry[, 1]),
      ymin = min(geometry[, 2]),
      xmax = max(geometry[, 1]),
      ymax = max(geometry[, 2]))
}

#' Simple intersection via ray casting
#' @return indices of points in `x` and `y`
#'         that intersect `geometry`
#' @keywords internal
.intersects <- function(x, y, geometry) {
    geometry <- .to_matrix(geometry)
    starts   <- geometry[-nrow(geometry), ]
    ends     <- geometry[-1, ]
    nodes    <- cbind(starts, ends)
    rm(starts, ends)

    sides <- lapply(
        seq_len(nrow(nodes)),
        FUN = function(i) {
            list(list(X = nodes[i, 1],
                      Y = nodes[i, 2]),
                 list(X = nodes[i, 3],
                      Y = nodes[i, 4]))
        }
    )

    # `names(.)` are the indices of points in `x` and `y`
    # the values are how many sides that point intersects with `geometry`
    points_per_side <- table(unlist(lapply(
        sides,
        FUN = function(side) which(.segment_intersect(side, x, y))
    )))

    # indices of the point(s) that intersect with `geometry`
    # i.e. if below = 6, then (x[6], y[6]) intersects `geometry`.
    ret <- as.numeric(names(which(points_per_side %% 2 == 1)))

    if (length(ret) == 0) {
        NA_real_
    } else {
        ret
    }
}

#' Check if a point intersects with a side of a polygon
#' @keywords internal
.segment_intersect <- function(side, x, y) {
    .slope <- function(x1, y1, x2, y2) ((y2 - y1) / (x2 - x1))

    offset <- ifelse(side[[1]]$Y > side[[2]]$Y, 1, 0)
    a      <- side[[1 + offset]]
    b      <- side[[2 - offset]]
    y      <- ifelse((y == a$Y) | (y == b$Y), y + 0.0001, y)
    m1     <- ifelse(a$X != b$X, .slope(a$X, a$Y, b$X, b$Y), Inf)
    m2     <- ifelse(a$X != x, .slope(a$X, a$Y, x, y), Inf)
    c1     <- (y < a$Y | y > b$Y) | (x > max(a$X, b$X))
    c2     <- x < min(a$X, b$X)

    ifelse(c1, FALSE, ifelse(c2, TRUE, m2 >= m1))
}

#nocov start
#' @keywords internal
.to_matrix <- function(geometry) {
    if (isNamespaceLoaded("sf")) {
        as.matrix(geometry)
    } else {
        do.call(
            rbind,
            unlist(geometry,
                   recursive = FALSE)
        )
    }
}

#' @keywords internal
.index <- function(fips, tbl = .lookup_fips) {
    match(as.integer(fips), tbl)
}


#' @keywords internal
.pad0 <- function(x) {
    ifelse(
        is.na(x),
        as.character(x),
        sprintf(
            paste0(
                "%0",
                ifelse(nchar(as.character(x)) < 3, 2, 5),
                ifelse(is.character(x), "s", "d")
            ),
            x
        )
    )
}

#' @keywords internal
.pad <- function(x, len) {
    ifelse(
        is.na(x),
        as.character(x),
        sprintf(
            paste0("%0", len, ifelse(is.character(x), "s", "d")),
            x
        )
    )
}

#' @keywords internal
.subint <- function(x, n) {
    if (n <= 0) {
        stop("n must be > 0")
    }

    tmp    <- as.double(x)
    cutoff <- 10 ^ n

    while (any(abs(tmp) >= cutoff)) {
        index <- abs(tmp) >= cutoff
        tmp[index] <- tmp[index] / 10
    }

    as.integer(trunc(tmp))
}
#nocov end