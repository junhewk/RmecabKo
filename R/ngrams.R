#' N-gram tokenizer based on mecab-ko
#'
#' This function tokenizes inputs into n-grams. For the developmental purpose, this function offers
#' basic n-gram (or shingle n-gram) only. Other n-gram functionality will be added later. Punctuations
#' and numerics are stripped for this tokenizer, because in Korean n-grams those are usually useless.
#' N-gram function is based on the selective morpheme tokenizer (\code{token_words}), but you can
#' select other tokenizer as well.
#'
#' @param phrase A character vector or a list of character vectors to be tokenized into morphemes.
#'     If \code{phrase} is a charactor vector, it can be of any length, and each element
#'     will be tokenized separately. If \code{phrase} is a list of charactor vectors, each element
#'     of the list should be a one-item vector.
#' @param n The number of words in the n-gram. This must be an integer greater than or equal to 1.
#' @param div The token generator definition. The options are "morph", "words", and "nouns".
#' @param ngram_delim The separator between words in an n-gram.
#' @param stopwords Stopwords set to exclude tokens.
#' @return A list of character vectors containing the tokens, with one element in the list.
#'
#' See examples in \href{https://github.com/junhewk/RmecabKo}{Github}.
#' 
#' @examples 
#' \dontrun{
#' txt <- # Some Korean sentence
#' 
#' token_ngrams(txt)
#' token_ngrams(txt, n = 2)
#' }
#' 
#'@export
token_ngrams <- function(phrase, n = 3L, div = c("morph", "words", "nouns"), stopwords = character(), ngram_delim = " ") {
  div <- match.arg(div)
    
  if (div %in% c("morph", "words", "nouns")) {
    tf <- get(paste0("token_", div))
    tokenfunc <- function(col) tf(col, strip_punct = TRUE, strip_numeric = TRUE)
  } else {
    stop("Cannot tokenize with custom functions. token_ngrams can accept 'morph', 'words', and 'nouns' for the tokens parameter only.")
  }
  words <- tokenfunc(phrase)
  # ret <- generate_ngrams_batch(words, ngram_min = n_min, ngram_max = n, ngram_delim)
  ret <- simple_ngrams(words, n = n, stopwords = stopwords, ngram_delim = ngram_delim)
  ret
}
