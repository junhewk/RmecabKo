#' Extract Korean nouns
#'
#' Keeps all `mecab-ko-dic` POS categories beginning with `N`, including
#' common and proper nouns, dependent nouns, numerals, and pronouns.
#'
#' @param sentence A character vector or list of character scalars.
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use parallel analysis for multiple documents.
#' @return A named list of character vectors.
#' @export
nouns <- function(sentence, sys_dic = "", user_dic = "", parallel = FALSE) {
  token_nouns(
    sentence,
    sys_dic = sys_dic,
    user_dic = user_dic,
    parallel = parallel
  )
}

#' Extract Korean content words
#'
#' Keeps Korean POS categories beginning with `N`, `V`, `M`, or `I`, plus
#' foreign-language tokens tagged `SL`.
#'
#' @inheritParams nouns
#' @return A named list of character vectors.
#' @export
words <- function(sentence, sys_dic = "", user_dic = "", parallel = FALSE) {
  token_words(
    sentence,
    sys_dic = sys_dic,
    user_dic = user_dic,
    parallel = parallel
  )
}
