#' Korean morpheme n-grams and skip-grams
#'
#' Creates n-grams after Korean morphological analysis. Stopwords split token
#' sequences, so an n-gram never bridges across a removed stopword.
#'
#' @param phrase A character vector or list of character scalars.
#' @param n Positive integer n-gram sizes. Multiple values are supported.
#' @param div Token preset: all morphemes, content words, or nouns.
#' @param stopwords Character tokens that break n-gram sequences.
#' @param ngram_delim Character scalar placed between terms.
#' @param skip Non-negative exact numbers of tokens to skip between adjacent
#'   terms. `skip = 0` creates contiguous n-grams.
#' @param keep_pos Optional Korean POS tags to retain before n-gram generation.
#' @param strip_punct Remove Korean punctuation tokens before generation.
#' @param strip_numeric Remove `SN` numeric tokens before generation.
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use parallel morphological analysis for multiple documents.
#' @return A named list of character vectors. Empty or too-short documents
#'   return `character(0)`; missing documents return `NA_character_`.
#' @examples
#' \dontrun{
#' text <- "\ud55c\uad6d\uc5b4 \ud615\ud0dc\uc18c \ubd84\uc11d\uc744 \ud569\ub2c8\ub2e4"
#' token_ngrams(text, n = 2)
#' token_ngrams(text, n = 2:3, skip = 0:1)
#' }
#' @export
token_ngrams <- function(phrase, n = 3L,
                         div = c("morph", "words", "nouns"),
                         stopwords = character(), ngram_delim = " ",
                         skip = 0L, keep_pos = NULL,
                         strip_punct = TRUE, strip_numeric = TRUE,
                         sys_dic = "", user_dic = "", parallel = FALSE) {
  div <- match.arg(div)
  n <- .validate_integer_values(n, "n", minimum = 1L)
  skip <- .validate_integer_values(skip, "skip", minimum = 0L)
  if (!is.character(stopwords)) {
    stop("stopwords must be a character vector", call. = FALSE)
  }
  stopwords <- unique(enc2utf8(stopwords[!is.na(stopwords)]))
  if (!is.character(ngram_delim) || length(ngram_delim) != 1L ||
      is.na(ngram_delim)) {
    stop("ngram_delim must be a non-missing character scalar", call. = FALSE)
  }
  if (!is.null(keep_pos) && (!is.character(keep_pos) || anyNA(keep_pos))) {
    stop("keep_pos must be NULL or a character vector", call. = FALSE)
  }

  tokens <- .tokenize_documents(
    phrase, div,
    .check_flag(strip_punct, "strip_punct"),
    .check_flag(strip_numeric, "strip_numeric"),
    keep_pos,
    .check_path(sys_dic, "sys_dic"),
    .check_path(user_dic, "user_dic"),
    .check_flag(parallel, "parallel")
  )
  simple_ngrams(tokens, n, skip, stopwords, enc2utf8(ngram_delim))
}

.validate_integer_values <- function(x, name, minimum) {
  if (!is.numeric(x) || !length(x) || anyNA(x) ||
      any(!is.finite(x)) || any(x != floor(x)) || any(x < minimum) ||
      any(x > .Machine$integer.max)) {
    stop(
      name, " must contain finite integer values greater than or equal to ",
      minimum,
      call. = FALSE
    )
  }
  unique(as.integer(x))
}
