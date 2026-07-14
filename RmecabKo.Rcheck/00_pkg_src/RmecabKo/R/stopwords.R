#' Korean stopword surfaces
#'
#' Returns the morpheme surfaces in [stopwords_ko], optionally restricted to one
#' or more categories. Use the result for surface-level filtering, for example
#' `dplyr::anti_join()` in a tidy pipeline or the `stopwords` argument of
#' [token_ngrams()].
#'
#' @param category Optional character vector of categories to keep: any of
#'   `"josa"`, `"eomi"`, `"suffix"`, `"formal_noun"`, `"function_word"`. `NULL`
#'   returns every surface.
#' @return A character vector of unique morpheme surfaces.
#' @seealso [stopwords_ko_tags()], [stopwords_ko]
#' @examples
#' head(stopwords_ko_words())
#' stopwords_ko_words("josa")
#' @export
stopwords_ko_words <- function(category = NULL) {
  rows <- .filter_stopwords(category)
  unique(rows$word)
}

#' Korean stopword POS tags
#'
#' Returns the mecab-ko-dic part-of-speech tags in [stopwords_ko], optionally
#' restricted to one or more categories. Pass the result to the `drop_pos`
#' argument of [token_morph()] or [token_ngrams()] to strip whole classes of
#' function morphemes at the tag level.
#'
#' @inheritParams stopwords_ko_words
#' @return A character vector of unique POS tags.
#' @seealso [stopwords_ko_words()], [stopwords_ko]
#' @examples
#' stopwords_ko_tags("josa")
#' @export
stopwords_ko_tags <- function(category = NULL) {
  rows <- .filter_stopwords(category)
  unique(rows$tag)
}

.filter_stopwords <- function(category) {
  data <- get0("stopwords_ko", envir = asNamespace("RmecabKo"))
  if (is.null(category)) {
    return(data)
  }
  if (!is.character(category)) {
    stop("category must be NULL or a character vector", call. = FALSE)
  }
  levels <- levels(data$category)
  unknown <- setdiff(category, levels)
  if (length(unknown)) {
    stop(
      "Unknown stopword category: ", paste(unknown, collapse = ", "),
      ". Choose from ", paste(levels, collapse = ", "), ".",
      call. = FALSE
    )
  }
  data[data$category %in% category, , drop = FALSE]
}
