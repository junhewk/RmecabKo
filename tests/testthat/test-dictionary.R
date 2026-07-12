test_that("Korean dictionaries are accepted and cached", {
  calls <- 0L
  reset_dictionary_cache()
  local_mocked_bindings(
    .engine_dictionary_info = fake_dictionary_info,
    .engine_pos = function(...) {
      calls <<- calls + 1L
      stats::setNames("한국어", "NNG")
    },
    .package = "RmecabKo"
  )

  RmecabKo:::.check_korean_dictionary()
  RmecabKo:::.check_korean_dictionary()
  expect_equal(calls, 1L)
})

test_that("non-Korean dictionaries fail with useful metadata", {
  reset_dictionary_cache()
  local_mocked_bindings(
    .engine_dictionary_info = function(...) {
      transform(fake_dictionary_info(), filename = "ipadic/sys.dic")
    },
    .engine_pos = function(...) stats::setNames("韓国語", "名詞"),
    .package = "RmecabKo"
  )

  expect_error(
    RmecabKo:::.check_korean_dictionary(),
    "requires a Korean MeCab dictionary.*ipadic/sys.dic"
  )
})
