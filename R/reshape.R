#' Transform given list of legal entities from \code{openLEIs} funtion to a data.frame
#'
#' @param \code{lEntities} list of legal entities as returned by \code{openLEI}.
#' @param \code{wide} logical; set \code{TRUE} if you want the data.frame to be reshaped from long to wide.
#'
#' @return data.table/data.frame
#' @export
LEIs2dt <- function(lEntities,
                    wide = TRUE) {

  if (!requireNamespace("data.table", quietly = TRUE)) {
    stop("Package 'data.table' needed for this function to work. Please install it.",
         call. = FALSE)
  }

  if (!is.list(lEntities)) {
    stop(substitute(lEntities), " is not a list!")
  }

  # print warnings when some of the LEIs were not found and thus could not be transformed
  foundLEIs <- !sapply(lEntities, is.null)
  numOfMissLEIs <- sum(!foundLEIs)
  if (numOfMissLEIs > 0) {
    warning(simpleWarning(message = paste0("There are ", numOfMissLEIs, " LEIs that could not be found in the lei-lookup.com database! Skipping...")))
  }

  # transform the list of legal entities to a long-shape data.frame
  dtLEI <- data.table::rbindlist(lEntities[foundLEIs])
  # colnames(dfLEI) <- c("value", "field", "lei")

  # transform from wide shape to long shape if requested
  if (!wide) {
    dtLEI <-
      suppressWarnings(
        data.table::melt(data    = dtLEI,
                         id.vars = "lei",
                         variable.name = "field",
                         variable.factor = FALSE,
                         verbose = FALSE)
      )
  }

  return(dtLEI)
}


#' @export
LEIs2df <- function(...) {
  .Deprecated("sum")
  LEIs2dt(...)
}
