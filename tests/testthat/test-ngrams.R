test_that("the native generator creates contiguous and exact skip-grams", {
  tokens <- list(doc = letters[1:5])

  expect_identical(
    RmecabKo:::simple_ngrams(tokens, 2L, 0L, character(), " ")[[1L]],
    c("a b", "b c", "c d", "d e")
  )
  expect_identical(
    RmecabKo:::simple_ngrams(tokens, 2L, 1L, character(), " ")[[1L]],
    c("a c", "b d", "c e")
  )
})

test_that("n-gram sizes and skips have deterministic ordering", {
  tokens <- list(doc = letters[1:4])
  result <- RmecabKo:::simple_ngrams(tokens, c(1L, 2L), c(0L, 1L), character(), "_")

  expect_identical(
    result[[1L]],
    c("a", "b", "c", "d", "a_b", "b_c", "c_d", "a_c", "b_d")
  )
})

test_that("stopwords break sequences instead of creating false adjacency", {
  tokens <- list(doc = letters[1:5])
  result <- RmecabKo:::simple_ngrams(tokens, 2L, 0L, "c", " ")

  expect_identical(result[[1L]], c("a b", "d e"))
})

test_that("short, empty, and missing documents are safe", {
  tokens <- list(short = "a", empty = character(), missing = NA_character_)
  result <- RmecabKo:::simple_ngrams(tokens, 3L, 0L, character(), " ")

  expect_identical(result$short, character())
  expect_identical(result$empty, character())
  expect_identical(result$missing, NA_character_)
})

test_that("public n-gram arguments are validated", {
  mock_korean_engine()

  expect_error(token_ngrams("문장", n = 0), "n must")
  expect_error(token_ngrams("문장", n = 1.5), "n must")
  expect_error(token_ngrams("문장", skip = -1), "skip must")
  expect_error(token_ngrams("문장", ngram_delim = NA_character_), "ngram_delim")
})
