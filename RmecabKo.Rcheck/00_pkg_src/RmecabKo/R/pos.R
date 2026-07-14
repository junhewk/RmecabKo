#' Korean part-of-speech tagging
#'
#' Tags Korean text with the active `mecab-ko-dic` dictionary through
#' [RcppMeCab::pos()].
#'
#' @param sentence A character vector or list of character scalars.
#' @param join Whether to return `morpheme/POS` strings. When `FALSE`, POS tags
#'   are stored as names on each morpheme vector.
#' @param format Either `"list"` or `"data.frame"`.
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use [RcppMeCab::posParallel()] for multiple documents.
#' @return A list for `format = "list"`, or the data frame returned by
#'   `RcppMeCab`.
#' @export
pos <- function(sentence, join = TRUE, format = c("list", "data.frame"),
                sys_dic = "", user_dic = "", parallel = FALSE) {
  documents <- .normalize_documents(sentence)
  join <- .check_flag(join, "join")
  parallel <- .check_flag(parallel, "parallel")
  sys_dic <- .check_path(sys_dic, "sys_dic")
  user_dic <- .effective_user_dic(.check_path(user_dic, "user_dic"))
  format <- match.arg(format)
  .check_korean_dictionary(sys_dic, user_dic)

  if (format == "list") {
    return(.pos_list(documents, join, sys_dic, user_dic, parallel))
  }
  if (anyNA(documents$text)) {
    stop("Missing documents are supported only with format = \"list\"", call. = FALSE)
  }
  if (!length(documents$text)) {
    return(data.frame())
  }

  if (parallel && length(documents$text) > 1L) {
    .engine_pos_parallel(
      documents$text, join = join, format = "data.frame",
      sys_dic = sys_dic, user_dic = user_dic
    )
  } else {
    .engine_pos(
      documents$text, join = join, format = "data.frame",
      sys_dic = sys_dic, user_dic = user_dic
    )
  }
}
