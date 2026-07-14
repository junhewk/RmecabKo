nv <- function(...) {
  pairs <- list(...)
  stats::setNames(
    enc2utf8(vapply(pairs, `[[`, character(1), 1L)),
    vapply(pairs, `[[`, character(1), 2L)
  )
}

test_that("bare predicate stems gain the terminal 다", {
  tokens <- nv(c("먹", "VV"), c("었", "EP"), c("다", "EC"))
  lemma <- lemmatize_morphemes(tokens)
  expect_identical(lemma$lemma[[1L]], enc2utf8("먹다"))
  expect_true(is.na(lemma$lemma[[2L]]))
  expect_true(is.na(lemma$lemma[[3L]]))
})

test_that("a noun root and derivational suffix combine into one lemma", {
  tokens <- nv(c("공부", "NNG"), c("하", "XSV"), c("다", "EF"))
  lemma <- lemmatize_morphemes(tokens)
  expect_identical(lemma$lemma[[2L]], enc2utf8("공부하다"))

  # without combining, only the suffix carries the lemma
  lemma2 <- lemmatize_morphemes(tokens, combine_root = FALSE)
  expect_identical(lemma2$lemma[[2L]], enc2utf8("하다"))
})

test_that("adjective derivational suffix combines with its root", {
  tokens <- nv(c("사랑", "NNG"), c("스럽", "XSA"), c("다", "EC"))
  expect_identical(
    lemmatize_morphemes(tokens)$lemma[[2L]], enc2utf8("사랑스럽다")
  )
})

test_that("fused predicate tokens cannot be lemmatized", {
  tokens <- nv(c("갔", "VV+EP"), c("다", "EC"))
  expect_true(is.na(lemmatize_morphemes(tokens)$lemma[[1L]]))
})

test_that("token_lemma keeps recoverable predicate lemmas end to end", {
  skip_if_not(.korean_backend_ready())
  reset_dictionary_cache()

  expect_identical(
    token_lemma("아침을 먹었다")[[1L]], enc2utf8("먹다")
  )
  expect_identical(
    token_lemma("사랑스럽다", simplify = TRUE), enc2utf8("사랑스럽다")
  )
  # missing documents propagate as NA
  out <- token_lemma(list("먹었다", NA_character_))
  expect_true(is.na(out[[2L]]))
})
