test_that("the installed Korean backend works end to end", {
  reset_dictionary_cache()
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
