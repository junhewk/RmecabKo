test_that("POS list output is stable for scalar, vector, list, and missing input", {
  mock_korean_engine()

  scalar <- pos("문장", join = FALSE)
  expect_type(scalar, "list")
  expect_named(scalar, "문장")
  expect_named(scalar[[1L]], c("NP", "JX", "SL", "SN", "NNBC", "SF", "VCP+EF"))

  documents <- pos(list(first = "하나", second = NA_character_))
  expect_named(documents, c("first", "second"))
  expect_identical(documents[[2L]], NA_character_)
})

test_that("Korean noun and content-word presets use POS categories", {
  mock_korean_engine()

  expect_identical(nouns("문장")[[1L]], c("저", "개"))
  expect_identical(words("문장")[[1L]], c("저", "R", "개", "입니다"))
})

test_that("morpheme filters operate on POS tags", {
  mock_korean_engine()

  expect_identical(
    token_morph("문장", strip_punct = TRUE, strip_numeric = TRUE)[[1L]],
    c("저", "는", "R", "개", "입니다")
  )
  expect_identical(
    token_morph("문장", keep_pos = c("NP", "EF"))[[1L]],
    c("저", "입니다")
  )
})

test_that("input and scalar arguments are validated", {
  mock_korean_engine()

  expect_error(token_morph(factor("문장")), "character vector")
  expect_error(token_morph(list(c("한", "둘"))), "one character")
  expect_error(token_morph("문장", strip_punct = NA), "TRUE or FALSE")
  expect_error(pos("문장", sys_dic = NA_character_), "sys_dic")
})

test_that("UTF-8 input reaches the engine unchanged", {
  reset_dictionary_cache()
  input <- enc2utf8("형태소 분석 테스트 중입니다.")
  received <- NULL
  local_mocked_bindings(
    .engine_dictionary_info = fake_dictionary_info,
    .engine_pos = function(sentence, join = TRUE, format = "list",
                           sys_dic = "", user_dic = "") {
      if (!identical(sentence, enc2utf8("한국어 형태소 분석"))) {
        received <<- sentence
      }
      fake_korean_pos(sentence, join, format, sys_dic, user_dic)
    },
    .package = "RmecabKo"
  )

  pos(input)

  expect_identical(received, input)
  expect_identical(Encoding(received), "UTF-8")
})
