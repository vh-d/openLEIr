# __ LEI CODES DATABASES ---------------------------------------------------------------

#' Scrape attributes of entitities from lei-lookup.com given list of LEI codes
#'
#' @param \code{lei_codes} character verctor of LEI codes
#' @param \code{proxy} proxy settings
#' @param \code{useLEIsAsNames} TRUE/FALSE -- use LEI as names for resulting list?
#'
#' @return list of legal entities with all attributes
#'
#' @examples
#' lei_vec <- c("259400DZXF7UJKK2AY35", "some misspelled LEI", "529900LN3S50JPU47S06", "some other LEI")
#' openLEIs(lei_vec)
#' openLEIs(lei_vec, showMissing = T)
#'
#' convertEntityList2df(openLEI(lei_vec))
#' convertEntityList2df(openLEI(lei_vec), wide = F)
#' @export
openLEIs <- function(lei_codes,
                     proxy = paste(getIEProxy(), collapse = ":"),
                     showMissing = F,
                     useLEIsAsNames = T) {

  # function to scrape metadata for a single LEI code
  openLEI <- function(LEI, flatten = TRUE) {
    req <- curl_fetch_memory(paste0("http://openleis.com/legal_entities/", LEI, ".json"),
                             handle = h)
    chr <- rawToChar(req$content)
    Encoding(chr) <- "UTF-8"
    entity <- fromJSON(txt = chr)

    if (flatten) {
      entity <- append(entity, entity$other_names)
      # entity <- append(entity, entity$other_attributes)

      entity$other_names <- NULL
      entity$other_attributes <- NULL

      attr(entity, which = "flat") <- TRUE
    } else {
      attr(entity, which = "flat") <- FALSE
    }

    entity <- lapply(entity, function(x) if (is.null(x)) NA else x)

    return(entity)
  }

  # attach/detach curl
  if (!("package:curl" %in% search())) {
    tryCatch(library(curl), error = function(x) {stop(x); cat("Cannot load curl package required for accessing API \n")})
    on.exit(
      {detach("package:curl", unload=TRUE)}
    )
  }

  # attach/detach jsonlite
  if (!("package:jsonlite" %in% search())) {
    tryCatch(library(jsonlite), error = function(x) {stop(x); cat("Cannot load jsonlite package required for parsing JSON \n")})
    on.exit(
      {detach("package:jsonlite", unload=TRUE)}
    )
  }

  # set proxy
  orig_proxy <- Sys.getenv("http_proxy")
  Sys.setenv(http_proxy = proxy)
  on.exit(Sys.setenv(http_proxy = orig_proxy))

  # setup curl options
  h <- new_handle()
  handle_setheaders(h,
                    "Accept" = "application/json",
                    "charset" = "utf-8")

  # apply openLEI to the vector of LEI codes parameter
  lEntities <- sapply(X = lei_codes,
                      simplify = F,
                      USE.NAMES = useLEIsAsNames,
                      FUN = openLEI)

  notFoundLEIs <- sapply(lEntities, is.null)
  numOfMissLEIs <- sum(notFoundLEIs)

  if ((numOfMissLEIs > 0)) {
    warning(simpleWarning(message = paste0("There are ", numOfMissLEIs, " LEIs that could not be found in the lei-lookup.com database!")))
    if (!showMissing) {
      warning(simpleWarning(message = "You can try which(sapply(list_of_your_entities, is.null)) to detect them. Or set showMissing parameter to TRUE."))
    } else {
      cat("Missing LEIs: \n")
      cat(paste(which(notFoundLEIs), lei_codes[which(notFoundLEIs)], collapse = "\t"), "\n")
    }
  }

  # return a list of entities
  return(lEntities)
}

#' Transform given list of legal entities from \code{openLEIs} funtion to a data.frame
#'
#' @param \code{lEntities} list of legal entities as returned by \code{openLEI}.
#' @param \code{wide} logical; set \code{TRUE} if you want the data.frame to be reshaped from long to wide.
#'
#' @return data.frame
#' @export
LEIs2df <- function(lEntities,
                    wide = T) {

  if (!is.list(lEntities)) {
    stop(substitute(lEntities), " is not a list!")
  }

  # attach/detach reshape2
  if (!("package:reshape2" %in% search())) {
    tryCatch(library(reshape2),
             error = function(x) {
               stop(x); cat("Cannot load reshape2 package required for converting list to data.frame \n")
             }
    )

    on.exit({detach("package:reshape2", unload = TRUE)})
  }

  # print wearnings when some of the LEIs were not found and thus could not be transformed
  foundLEIs <- !sapply(lEntities, is.null)
  numOfMissLEIs <- sum(!foundLEIs)
  if (numOfMissLEIs > 0) {
    warning(simpleWarning(message = paste0("There are ", numOfMissLEIs, " LEIs that could not be found in the lei-lookup.com database! Skipping...")))
  }

  # transform the list of legal entities to a long-shape data.frame
  dfLEI <- reshape2::melt(lEntities[foundLEIs])
  colnames(dfLEI) <- c("value", "field", ".i")

  # transform from long-shaped to wide-shaped data.frame if requested
  if (wide) {
    dfLEI <- reshape2::dcast(data = dfLEI,
                             formula = .i ~ field)
  }

  return(dfLEI)
}

