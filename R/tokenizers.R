#' Morpheme tokenizer based on mecab-ko
#'
#' These tokernizer functions perform tokenization into full or selected morphemes,
#' nouns.
#'
#' @param phrase A character vector or a list of character vectors to be tokenized into morphemes.
#'     If \code{phrase} is a charactor vector, it can be of any length, and each element
#'     will be tokenized separately. If \code{phrase} is a list of charactor vectors, each element
#'     of the list should be a one-item vector.
#' @param strip_punct Bool. If you want to remove punctuations in the phrase, set this as TRUE.
#' @param strip_numeric Bool. If you want to remove numbers in the phrase, set this as TRUE.
#' @return A list of character vectors containing the tokens, with one element in the list.
#'
#' See examples in \href{https://github.com/junhewk/RmecabKo}{Github}.
#' 
#' @examples 
#' \dontrun{
#' txt <- # Some Korean sentence
#' 
#' token_morph(txt)
#' token_words(txt, strip_punct = FALSE)
#' token_nouns(txt, strip_numeric = TRUE)
#' }
#' 
#' @importFrom stringr str_replace_all

check_input <- function(x) {
  check_character <- is.character(x) |
    if (is.list(x)) {
      check_list <- all(vapply(x, is.character, logical(1))) &
        all(vapply(x, length, integer(1)) == 1L)
    } else {
      check_list <- FALSE
    }
  if (!(check_character | check_list))
    stop("Input must be a character vector of any length or a list of character\n",
         "  vectors, each of which has a length of 1.")
}

#'@export
token_morph <- function(phrase, strip_punct = TRUE, strip_numeric = FALSE) {
  check_input(phrase)
  if (strip_punct) phrase <- stringr::str_replace_all(phrase, "[[:punct:]]", "")
  if (strip_numeric) phrase <- stringr::str_replace_all(phrase, "[[:digit:]]", "")
  ret <- pos(phrase, join = FALSE)
  names(ret) <- NULL
  ret
}

#'@export
token_words <- function(phrase, strip_punct = TRUE, strip_numeric = FALSE) {
  check_input(phrase)
  if (strip_punct) phrase <- stringr::str_replace_all(phrase, "[[:punct:]]", "")
  if (strip_numeric) phrase <- stringr::str_replace_all(phrase, "[[:digit:]]", "")
  ret <- words(phrase)
  ret
}

#'@export
token_nouns <- function(phrase, strip_punct = TRUE, strip_numeric = FALSE) {
  check_input(phrase)
  if (strip_punct) phrase <- stringr::str_replace_all(phrase, "[[:punct:]]", "")
  if (strip_numeric) phrase <- stringr::str_replace_all(phrase, "[[:digit:]]", "")
  ret <- nouns(phrase)
  names(ret) <- NULL
  ret
}
