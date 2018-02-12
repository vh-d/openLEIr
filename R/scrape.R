#' Scrape attributes of entitities from lei-lookup.com given list of LEI codes
#'
#' @param \code{lei_codes} character verctor of LEI codes
#' @param \code{useLEIsAsNames} TRUE/FALSE -- use LEI as names for resulting list?
#'
#' @return list of legal entities with all attributes
#'
#' @examples
#' lei_vec <- c("259400DZXF7UJKK2AY35", "some misspelled LEI", "529900LN3S50JPU47S06", "some other LEI")
#' openLEIs(lei_vec)
#' openLEIs(lei_vec, showMissing = T)
#'
#' LEIs2df(openLEIs(lei_vec))
#' LEIs2df(openLEIs(lei_vec), wide = F)
#' @export
openLEIs <- function(lei_codes,
                     showMissing    = FALSE,
                     useLEIsAsNames = TRUE) {

  # function to scrape metadata for a single LEI code
  openLEI <- function(LEI, flatten = TRUE) {
    req <- curl::curl_fetch_memory(paste0("http://openleis.com/legal_entities/", LEI, ".json"),
                                   handle = h)
    chr <- rawToChar(req$content)
    Encoding(chr) <- "UTF-8"
    entity <- jsonlite::fromJSON(txt = chr)

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

  # setup curl
  h <- curl::new_handle()

  curl::handle_setheaders(h,
                          "Accept" = "application/json",
                          "charset" = "utf-8")

  # apply openLEI to the vector of LEI codes parameter
  lEntities <- sapply(X = lei_codes,
                      simplify = FALSE,
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

