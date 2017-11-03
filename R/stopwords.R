#' Stopwords for Korean Morpheme
#'
#' Stopwords dataset developed based on results of scraped articles.
#' It is structured as data frame and tibble (dplyr), so if you want use this stopwords set in the tokenizer, call it directly.
#'
#' @docType data
#'
#' @usage data(stopwords_ko)
#'
#' @keywords datasets
#'
#' @examples
#' \dontrun{
#' # Basic usage: using it combined with tidyverse and tidytext package
#' library(tidyverse)
#' library(tidytext)
#' df %>% unnest_tokens(word, txt, token = token_words) %>% 
#'     anti_join(stopwords_ko)
#' 
#' # Use stopwords in token_ngram
#' token_ngram(txt, n = 2L, stopwords = stopwords_ko$word)
#' }
#' 
"stopwords_ko"