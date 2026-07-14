test_that("repeated characters are squashed to the cap", {
  expect_identical(text_normalize("ㅋㅋㅋㅋ"), "ㅋㅋ")
  expect_identical(text_normalize("좋아요!!!!"), "좋아요!!")
  expect_identical(text_normalize("ㅋㅋ"), "ㅋㅋ")
  expect_identical(text_normalize("ㅋㅋㅋ", squash = 1L), "ㅋ")
  expect_identical(text_normalize("ㅋㅋㅋㅋ", squash = Inf), "ㅋㅋㅋㅋ")
})

test_that("width folding converts full-width to ASCII and back", {
  expect_identical(text_normalize("ＡＢＣ１２３", width = "halfwidth"), "ABC123")
  expect_identical(text_normalize("ABC", width = "fullwidth"), "ＡＢＣ")
  expect_identical(text_normalize("ＡＢＣ", width = "none", squash = Inf), "ＡＢＣ")
})

test_that("NFC composes decomposed Hangul", {
  decomposed <- stringi::stri_trans_nfd("한국어")
  expect_identical(
    text_normalize(decomposed, squash = Inf, width = "none"),
    enc2utf8("한국어")
  )
  # NFC runs before width folding, so composed syllables survive the default
  expect_identical(text_normalize(decomposed, squash = Inf), enc2utf8("한국어"))
})

test_that("NA and vectors are handled elementwise", {
  out <- text_normalize(c("ㅋㅋㅋ", NA, "좋아요!!!"))
  expect_length(out, 3L)
  expect_true(is.na(out[2L]))
  expect_identical(out[1L], "ㅋㅋ")
})

test_that("invalid arguments error", {
  expect_error(text_normalize(1L), "character vector")
  expect_error(text_normalize("a", squash = NA), "single number")
  expect_error(text_normalize("a", nfc = NA), "TRUE or FALSE")
})
