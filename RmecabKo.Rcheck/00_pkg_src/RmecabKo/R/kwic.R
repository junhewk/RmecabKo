#' Keyword-in-context concordance
#'
#' Finds occurrences of a keyword among the morphemes of each document and
#' returns them with their left and right context, the Korean analogue of a
#' classic KWIC concordance. Matching is done on morpheme tokens, so it is
#' robust to the particles and endings that attach to a word in running text.
#'
#' @param phrase A character vector or list of character scalars.
#' @param pattern A single search term. Matched exactly against a morpheme when
#'   `fixed = TRUE`, or as a regular expression when `fixed = FALSE`.
#' @param window Number of context tokens to show on each side.
#' @param div Token preset used to segment the text.
#' @param fixed Match `pattern` exactly against a token; when `FALSE`, treat it
#'   as a regular expression.
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use parallel analysis for multiple documents.
#' @return A data frame with columns `doc`, `position` (token index of the
#'   match), `left`, `keyword`, and `right`. Left and right context tokens are
#'   joined with single spaces.
#' @examples
#' \dontrun{
#' docs <- c("\ud55c\uad6d\uc5b4 \ubd84\uc11d\uc740 \uc990\uac81\ub2e4",
#'           "\ud55c\uad6d\uc5b4 \uacf5\ubd80\ub294 \uc5b4\ub835\ub2e4")
#' kwic(docs, "\ud55c\uad6d\uc5b4")
#' }
#' @export
kwic <- function(phrase, pattern, window = 5L,
                 div = c("morph", "words", "nouns"), fixed = TRUE,
                 sys_dic = "", user_dic = "", parallel = FALSE) {
  div <- match.arg(div)
  fixed <- .check_flag(fixed, "fixed")
  window <- .validate_integer_values(window, "window", minimum = 0L)[[1L]]
  if (!is.character(pattern) || length(pattern) != 1L || is.na(pattern) ||
      !nzchar(pattern)) {
    stop("pattern must be a non-empty character scalar", call. = FALSE)
  }
  pattern <- enc2utf8(pattern)

  tokens <- .keyword_tokens(phrase, div, sys_dic, user_dic, parallel)
  if (is.null(names(tokens))) {
    names(tokens) <- as.character(seq_along(tokens))
  }

  rows <- lapply(names(tokens), function(doc) {
    terms <- tokens[[doc]]
    if (length(terms) == 1L && is.na(terms)) {
      return(NULL)
    }
    hits <- if (fixed) {
      which(terms == pattern)
    } else {
      grep(pattern, terms)
    }
    if (!length(hits)) {
      return(NULL)
    }
    do.call(rbind, lapply(hits, function(pos) {
      left <- if (pos > 1L) terms[max(1L, pos - window):(pos - 1L)] else character()
      right <- if (pos < length(terms)) {
        terms[(pos + 1L):min(length(terms), pos + window)]
      } else {
        character()
      }
      data.frame(
        doc = doc, position = pos,
        left = paste(left, collapse = " "),
        keyword = terms[[pos]],
        right = paste(right, collapse = " "),
        stringsAsFactors = FALSE
      )
    }))
  })

  result <- do.call(rbind, rows)
  if (is.null(result)) {
    result <- data.frame(
      doc = character(), position = integer(), left = character(),
      keyword = character(), right = character(), stringsAsFactors = FALSE
    )
  }
  rownames(result) <- NULL
  result
}
