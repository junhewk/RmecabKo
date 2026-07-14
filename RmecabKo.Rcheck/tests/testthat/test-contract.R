test_that("tokenizers return one list element per document", {
  mock_korean_engine()

  out <- token_morph(c("문장", "문장"))
  expect_type(out, "list")
  expect_length(out, 2L)
  expect_true(all(vapply(out, is.character, logical(1))))
})

test_that("unnamed input yields an unnamed list, named input is preserved", {
  mock_korean_engine()

  expect_null(names(token_nouns(c("문장", "문장"))))
  expect_named(token_nouns(c(a = "문장", b = "문장")), c("a", "b"))
})

test_that("simplify unwraps a single document to a character vector", {
  mock_korean_engine()

  expect_type(token_morph("문장", simplify = TRUE), "character")
  expect_identical(
    token_nouns("문장", simplify = TRUE),
    c("저", "개")
  )
  # simplify only applies to single documents
  expect_type(token_morph(c("문장", "문장"), simplify = TRUE), "list")
})

test_that("missing documents become NA_character_ elements", {
  mock_korean_engine()

  out <- token_morph(list("문장", NA_character_))
  expect_identical(out[[2L]], NA_character_)
})

test_that("drop_pos removes tokens whose components match", {
  mock_korean_engine()

  # sentence tokens: 저/NP 는/JX R/SL 2/SN 개/NNBC ./SF 입니다/VCP+EF
  expect_identical(
    token_morph("문장", drop_pos = c("JX", "SF"))[[1L]],
    c("저", "R", "2", "개", "입니다")
  )
  # compound tags match when any component is dropped
  expect_false("입니다" %in% token_morph("문장", drop_pos = "EF")[[1L]])
})

test_that("keep_pos and drop_pos compose", {
  mock_korean_engine()

  expect_identical(
    token_morph("문장", keep_pos = c("NP", "EF"), drop_pos = "EF")[[1L]],
    "저"
  )
})

test_that("tokenizers drop into tidytext::unnest_tokens", {
  skip_if_not_installed("tidytext")
  skip_if_not_installed("tibble")
  mock_korean_engine()

  df <- tibble::tibble(doc = "d1", text = "문장")
  tidy <- tidytext::unnest_tokens(df, word, text, token = token_nouns)
  expect_identical(tidy$word, c("저", "개"))
  expect_identical(tidy$doc, c("d1", "d1"))
})
