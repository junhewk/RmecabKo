#' Korean stopword table
#'
#' A curated set of Korean function morphemes that are usually removed before
#' content analysis: particles, endings, derivational suffixes, dependent
#' nouns, and common function words. Each morpheme is tagged with its typical
#' `mecab-ko-dic` part-of-speech tag so it can be filtered either by surface
#' form or by tag.
#'
#' @format A data frame with one row per morpheme and three columns:
#' \describe{
#'   \item{word}{Morpheme surface (UTF-8).}
#'   \item{tag}{Typical `mecab-ko-dic` part-of-speech tag.}
#'   \item{category}{Factor grouping the morpheme: `josa` (particles), `eomi`
#'     (endings), `suffix` (derivational suffixes), `formal_noun` (dependent
#'     nouns), or `function_word` (demonstratives, pronouns, conjunctive
#'     adverbs).}
#' }
#' @seealso [stopwords_ko_words()], [stopwords_ko_tags()]
"stopwords_ko"

#' Korean demonstration sentences
#'
#' A small public-domain corpus of Korean sentences used in the package
#' examples and vignette. The text is short, self-contained, and free of any
#' third-party licensing so it can ship on CRAN.
#'
#' @format A named character vector of Korean sentences.
#' @seealso `vignette("korean-text-analysis", package = "RmecabKo")`
"demo_ko"
