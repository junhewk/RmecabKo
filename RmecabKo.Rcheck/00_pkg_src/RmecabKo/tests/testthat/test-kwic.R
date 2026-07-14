test_that("kwic returns left and right context around matches", {
  local_mocked_bindings(
    .keyword_tokens = function(phrase, div, sys_dic, user_dic, parallel) {
      list(d1 = enc2utf8(c("한국어", "분석", "은", "즐겁다")))
    },
    .package = "RmecabKo"
  )
  out <- kwic("x", enc2utf8("분석"), window = 1L)
  expect_identical(names(out), c("doc", "position", "left", "keyword", "right"))
  expect_identical(nrow(out), 1L)
  expect_identical(out$position, 2L)
  expect_identical(out$left, enc2utf8("한국어"))
  expect_identical(out$keyword, enc2utf8("분석"))
  expect_identical(out$right, enc2utf8("은"))
})

test_that("kwic clips context at document boundaries and finds all hits", {
  local_mocked_bindings(
    .keyword_tokens = function(phrase, div, sys_dic, user_dic, parallel) {
      list(d1 = enc2utf8(c("가", "나", "가", "다", "가")))
    },
    .package = "RmecabKo"
  )
  out <- kwic("x", enc2utf8("가"), window = 5L)
  expect_identical(nrow(out), 3L)
  expect_identical(out$left[[1L]], "")
  expect_identical(out$right[[3L]], "")
})

test_that("kwic supports regular-expression matching", {
  local_mocked_bindings(
    .keyword_tokens = function(phrase, div, sys_dic, user_dic, parallel) {
      list(d1 = enc2utf8(c("분석", "분석기", "도구")))
    },
    .package = "RmecabKo"
  )
  out <- kwic("x", enc2utf8("분석"), fixed = FALSE)
  expect_identical(nrow(out), 2L)
})

test_that("kwic validates its pattern", {
  expect_error(kwic("x", character(0)), "non-empty character scalar")
  expect_error(kwic("x", NA_character_), "non-empty character scalar")
})

test_that("kwic works on the real backend", {
  skip_if_not(.korean_backend_ready())
  reset_dictionary_cache()
  out <- kwic(c("한국어 분석은 즐겁다", "한국어 공부는 어렵다"),
              enc2utf8("한국어"))
  expect_identical(nrow(out), 2L)
  expect_true(all(out$keyword == enc2utf8("한국어")))
})
