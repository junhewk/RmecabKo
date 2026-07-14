mock_keyword_tokens <- function(tokens) {
  local_mocked_bindings(
    .keyword_tokens = function(phrase, div, sys_dic, user_dic, parallel) tokens,
    .package = "RmecabKo",
    .env = parent.frame()
  )
}

test_that("keywords_tfidf scores document-unique terms above shared terms", {
  mock_keyword_tokens(list(
    d1 = enc2utf8(c("한국어", "분석", "분석")),
    d2 = enc2utf8(c("분석", "도구", "도구"))
  ))
  out <- keywords_tfidf(c("x", "y"), div = "nouns")

  expect_identical(names(out), c("doc", "word", "n", "tf", "idf", "tf_idf"))
  # 분석 occurs in both documents, so its idf (and tf_idf) is zero
  shared <- out[out$word == enc2utf8("분석"), ]
  expect_true(all(shared$tf_idf == 0))
  # the top keyword of d1 is the document-unique term
  d1 <- out[out$doc == "d1", ]
  expect_identical(d1$word[[1L]], enc2utf8("한국어"))
})

test_that("keywords_tfidf honors stopwords and top_n", {
  mock_keyword_tokens(list(
    d1 = enc2utf8(c("가", "나", "다", "가"))
  ))
  out <- keywords_tfidf("x", div = "nouns",
                        stopwords = enc2utf8("가"), top_n = 1L)
  expect_false(enc2utf8("가") %in% out$word)
  expect_identical(nrow(out), 1L)
})

test_that(".textrank_scores centers a well-connected term", {
  terms <- enc2utf8(c("분석", "한국어", "분석", "도구", "분석"))
  scores <- RmecabKo:::.textrank_scores(terms, window = 2L,
                                        damping = 0.85, iter = 30L)
  expect_true(scores[[enc2utf8("분석")]] == max(scores))
})

test_that("keywords_textrank returns ranked terms per document", {
  mock_keyword_tokens(list(
    d1 = enc2utf8(c("분석", "한국어", "분석", "도구", "분석"))
  ))
  out <- keywords_textrank("x", div = "nouns", top_n = 2L)
  expect_identical(names(out), c("doc", "word", "score"))
  expect_identical(nrow(out), 2L)
  expect_identical(out$word[[1L]], enc2utf8("분석"))
})

test_that("keyword extractors handle a single unnamed document", {
  mock_keyword_tokens(list(
    enc2utf8(c("분석", "한국어", "분석", "도구", "분석"))
  ))
  tfidf <- keywords_tfidf("x", div = "nouns")
  expect_gt(nrow(tfidf), 0L)
  expect_identical(unique(tfidf$doc), "1")

  mock_keyword_tokens(list(
    enc2utf8(c("분석", "한국어", "분석", "도구", "분석"))
  ))
  rank <- keywords_textrank("x", div = "nouns", top_n = 2L)
  expect_identical(nrow(rank), 2L)
  expect_identical(rank$word[[1L]], enc2utf8("분석"))
})

test_that("keyword extraction works on the real backend", {
  skip_if_not(.korean_backend_ready())
  reset_dictionary_cache()
  out <- keywords_tfidf(
    c("한국어 분석은 즐겁다", "분석 도구가 필요하다"),
    div = "nouns"
  )
  expect_true(all(c("doc", "word", "tf_idf") %in% names(out)))
  expect_gt(nrow(out), 0L)
})
