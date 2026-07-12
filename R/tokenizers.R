#' Korean morpheme tokenizers
#'
#' Tokenizes text using Korean POS categories. Filtering is applied to MeCab
#' output rather than deleting punctuation or digits from the source text.
#'
#' @param phrase A character vector or list of character scalars.
#' @param strip_punct Remove tokens tagged as Korean punctuation.
#' @param strip_numeric Remove tokens tagged `SN`.
#' @param keep_pos Optional Korean POS tags to retain. Compound tags match when
#'   any component is selected.
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use parallel analysis for multiple documents.
#' @return A named list of unnamed character vectors.
#' @rdname token
#' @export
token_morph <- function(phrase, strip_punct = FALSE, strip_numeric = FALSE,
                        keep_pos = NULL, sys_dic = "", user_dic = "",
                        parallel = FALSE) {
  strip_punct <- .check_flag(strip_punct, "strip_punct")
  strip_numeric <- .check_flag(strip_numeric, "strip_numeric")
  parallel <- .check_flag(parallel, "parallel")
  if (!is.null(keep_pos) && (anyNA(keep_pos) || !is.character(keep_pos))) {
    stop("keep_pos must be NULL or a character vector", call. = FALSE)
  }
  .tokenize_documents(
    phrase, "morph", strip_punct, strip_numeric, keep_pos,
    .check_path(sys_dic, "sys_dic"), .check_path(user_dic, "user_dic"),
    parallel
  )
}

#' @rdname token
#' @export
token_words <- function(phrase, strip_punct = FALSE, strip_numeric = FALSE,
                        sys_dic = "", user_dic = "", parallel = FALSE) {
  .tokenize_documents(
    phrase, "words",
    .check_flag(strip_punct, "strip_punct"),
    .check_flag(strip_numeric, "strip_numeric"),
    NULL,
    .check_path(sys_dic, "sys_dic"), .check_path(user_dic, "user_dic"),
    .check_flag(parallel, "parallel")
  )
}

#' @rdname token
#' @export
token_nouns <- function(phrase, strip_punct = FALSE, strip_numeric = FALSE,
                        sys_dic = "", user_dic = "", parallel = FALSE) {
  .tokenize_documents(
    phrase, "nouns",
    .check_flag(strip_punct, "strip_punct"),
    .check_flag(strip_numeric, "strip_numeric"),
    NULL,
    .check_path(sys_dic, "sys_dic"), .check_path(user_dic, "user_dic"),
    .check_flag(parallel, "parallel")
  )
}
