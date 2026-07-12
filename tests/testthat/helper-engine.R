reset_dictionary_cache <- function() {
  cache <- get(".rmecabko_state", asNamespace("RmecabKo"))$dictionary_checks
  rm(list = ls(cache, all.names = TRUE), envir = cache)
}

fake_dictionary_info <- function(sys_dic = "", user_dic = "") {
  data.frame(
    filename = if (nzchar(sys_dic)) file.path(sys_dic, "sys.dic") else "ko/sys.dic",
    charset = "UTF-8",
    type = "system",
    size = 1,
    left_size = 1L,
    right_size = 1L,
    version = 102L,
    stringsAsFactors = FALSE
  )
}

fake_korean_pos <- function(sentence, join = TRUE, format = "list",
                            sys_dic = "", user_dic = "") {
  parse_one <- function(text) {
    if (identical(text, enc2utf8("한국어 형태소 분석"))) {
      tokens <- c("한국어", "형태소", "분석")
      tags <- c("NNG", "NNG", "NNG")
    } else if (!nzchar(text)) {
      tokens <- character()
      tags <- character()
    } else {
      tokens <- c("저", "는", "R", "2", "개", ".", "입니다")
      tags <- c("NP", "JX", "SL", "SN", "NNBC", "SF", "VCP+EF")
    }
    if (join) {
      paste0(tokens, "/", tags)
    } else {
      stats::setNames(tokens, tags)
    }
  }

  parsed <- lapply(sentence, parse_one)
  if (length(parsed) == 1L) parsed[[1L]] else parsed
}

mock_korean_engine <- function() {
  reset_dictionary_cache()
  testthat::local_mocked_bindings(
    .engine_dictionary_info = fake_dictionary_info,
    .engine_pos = fake_korean_pos,
    .engine_pos_parallel = function(sentence, ...) {
      result <- fake_korean_pos(sentence, ...)
      if (is.list(result)) result else list(result)
    },
    .package = "RmecabKo",
    .env = parent.frame()
  )
}
