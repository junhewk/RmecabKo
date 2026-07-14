#' Normalize Korean text before tokenizing
#'
#' Applies light, rule-based cleanup that improves morphological analysis and
#' downstream matching: Unicode NFC composition, half-/full-width folding, and
#' squashing of long runs of a repeated character (such as a drawn-out laugh or
#' a row of exclamation marks). It is meant to be called on raw text before
#' [token_morph()] and friends; the tokenizers never apply it implicitly so
#' that their behavior stays predictable.
#'
#' @param x A character vector. `NA` elements are returned unchanged.
#' @param squash Maximum run length to keep for a repeated character. Runs
#'   longer than `squash` identical characters are collapsed to `squash`
#'   copies (a run of four identical characters becomes two at the default).
#'   Use a non-finite value such as `Inf` to disable squashing.
#' @param nfc Apply Unicode NFC normalization so decomposed Hangul jamo are
#'   composed into single syllable characters.
#' @param width Fold character width: `"halfwidth"` converts full-width Latin
#'   and digits to ASCII, `"fullwidth"` does the reverse, `"none"` leaves width
#'   untouched.
#' @return A character vector the same length as `x`.
#' @examples
#' text_normalize("\ubd84\uc11d \u314b\u314b\u314b\u314b \uc7ac\ubc0c\uc5b4\uc694!!!!")
#' text_normalize("\uff21\uff22\uff23\uff11\uff12\uff13", width = "halfwidth")
#' @export
text_normalize <- function(x, squash = 2L, nfc = TRUE,
                           width = c("halfwidth", "fullwidth", "none")) {
  if (!is.character(x)) {
    stop("x must be a character vector", call. = FALSE)
  }
  nfc <- .check_flag(nfc, "nfc")
  width <- match.arg(width)
  if (!is.numeric(squash) || length(squash) != 1L || is.na(squash)) {
    stop("squash must be a single number", call. = FALSE)
  }

  x <- enc2utf8(x)

  if (nfc) {
    x <- stringi::stri_trans_nfc(x)
  }

  if (width == "halfwidth") {
    x <- stringi::stri_trans_general(x, "Fullwidth-Halfwidth")
  } else if (width == "fullwidth") {
    x <- stringi::stri_trans_general(x, "Halfwidth-Fullwidth")
  }

  if (is.finite(squash) && squash >= 1L) {
    keep <- as.integer(squash)
    replacement <- paste(rep("\\1", keep), collapse = "")
    pattern <- paste0("(.)\\1{", keep, ",}")
    x <- gsub(pattern, replacement, x, perl = TRUE)
  }

  x
}
