#' Korean morpheme tokenizers
#'
#' Tokenizes text using Korean POS categories. Filtering is applied to MeCab
#' output rather than deleting punctuation or digits from the source text. The
#' functions follow the \pkg{tokenizers} contract, so they drop directly into
#' `tidytext::unnest_tokens(token = token_nouns)` and related pipelines.
#'
#' @param phrase A character vector or list of character scalars.
#' @param strip_punct Remove tokens tagged as Korean punctuation.
#' @param strip_numeric Remove tokens tagged `SN`.
#' @param keep_pos Optional Korean POS tags to retain. Compound tags match when
#'   any component is selected.
#' @param drop_pos Optional Korean POS tags to remove. Compound tags match when
#'   any component is selected. Combine with [stopwords_ko_tags()] to strip
#'   particles, endings, or other function morphemes.
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use parallel analysis for multiple documents.
#' @param simplify When `TRUE` and a single document is supplied, return a bare
#'   character vector instead of a length-one list.
#' @return A list of character vectors, one per document, named when the input
#'   is named. With `simplify = TRUE` a single document returns a character
#'   vector.
#' @rdname token
#' @export
token_morph <- function(phrase, strip_punct = FALSE, strip_numeric = FALSE,
                        keep_pos = NULL, drop_pos = NULL, sys_dic = "",
                        user_dic = "", parallel = FALSE, simplify = FALSE) {
  strip_punct <- .check_flag(strip_punct, "strip_punct")
  strip_numeric <- .check_flag(strip_numeric, "strip_numeric")
  parallel <- .check_flag(parallel, "parallel")
  .check_pos_filter(keep_pos, "keep_pos")
  .check_pos_filter(drop_pos, "drop_pos")
  tokens <- .tokenize_documents(
    phrase, "morph", strip_punct, strip_numeric, keep_pos,
    .check_path(sys_dic, "sys_dic"), .check_path(user_dic, "user_dic"),
    parallel, drop_pos
  )
  .simplify_list(tokens, simplify)
}

#' @rdname token
#' @export
token_words <- function(phrase, strip_punct = FALSE, strip_numeric = FALSE,
                        sys_dic = "", user_dic = "", parallel = FALSE,
                        simplify = FALSE) {
  tokens <- .tokenize_documents(
    phrase, "words",
    .check_flag(strip_punct, "strip_punct"),
    .check_flag(strip_numeric, "strip_numeric"),
    NULL,
    .check_path(sys_dic, "sys_dic"), .check_path(user_dic, "user_dic"),
    .check_flag(parallel, "parallel")
  )
  .simplify_list(tokens, simplify)
}

#' @rdname token
#' @export
token_nouns <- function(phrase, strip_punct = FALSE, strip_numeric = FALSE,
                        sys_dic = "", user_dic = "", parallel = FALSE,
                        simplify = FALSE) {
  tokens <- .tokenize_documents(
    phrase, "nouns",
    .check_flag(strip_punct, "strip_punct"),
    .check_flag(strip_numeric, "strip_numeric"),
    NULL,
    .check_path(sys_dic, "sys_dic"), .check_path(user_dic, "user_dic"),
    .check_flag(parallel, "parallel")
  )
  .simplify_list(tokens, simplify)
}

.check_pos_filter <- function(x, name) {
  if (!is.null(x) && (!is.character(x) || anyNA(x))) {
    stop(name, " must be NULL or a character vector", call. = FALSE)
  }
  invisible(x)
}
