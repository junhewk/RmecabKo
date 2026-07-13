test_that("the installed Korean backend works end to end", {
  reset_dictionary_cache()

  backend_available <- tryCatch({
    info <- RcppMeCab::dictionary_info()
    probe <- RcppMeCab::pos(
      enc2utf8("한국어 형태소 분석"),
      join = FALSE
    )
    if (is.list(probe)) {
      probe <- probe[[1L]]
    }
    any(info$type == "system") &&
      length(probe) > 0L &&
      any(names(probe) %in% c("NNG", "NNP"))
  }, error = function(error) FALSE)

  skip_if_not(
    isTRUE(backend_available),
    "A compatible Korean MeCab engine and dictionary are not available"
  )

  info <- RcppMeCab::dictionary_info()
  expect_true(any(info$type == "system"))

  tagged <- pos(enc2utf8("한국어 형태소 분석"), join = FALSE)
  expect_identical(unname(tagged[[1L]]), enc2utf8(c("한국어", "형태소", "분석")))
  expect_true(all(names(tagged[[1L]]) == "NNG"))

  grams <- token_ngrams(enc2utf8("한국어 형태소 분석"), n = 2)
  expect_identical(
    unname(grams[[1L]]),
    enc2utf8(c("한국어 형태소", "형태소 분석"))
  )
})
