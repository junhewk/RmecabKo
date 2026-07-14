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

test_that("unavailable dictionaries fail with setup guidance", {
  reset_dictionary_cache()
  local_mocked_bindings(
    .engine_dictionary_info = function(...) {
      stop("dicrc not found")
    },
    .package = "RmecabKo"
  )

  expect_error(
    RmecabKo:::.check_korean_dictionary(),
    "download_dic.*set_dic.*compatible mecab-ko engine"
  )
})

test_that("compiled user dictionaries are forwarded to the engine", {
  reset_dictionary_cache()
  requested <- character()
  user_dictionary <- normalizePath(
    file.path(tempdir(), "custom-user.dic"),
    mustWork = FALSE
  )
  local_mocked_bindings(
    .engine_dictionary_info = function(sys_dic = "", user_dic = "") {
      requested <<- c(requested, user_dic)
      fake_dictionary_info(sys_dic, user_dic)
    },
    .engine_pos = function(sentence, join = TRUE, format = "list",
                           sys_dic = "", user_dic = "") {
      requested <<- c(requested, user_dic)
      fake_korean_pos(sentence, join, format, sys_dic, user_dic)
    },
    .package = "RmecabKo"
  )

  pos("사용자 사전", user_dic = user_dictionary)

  expect_true(length(requested) >= 3L)
  expect_true(all(requested == user_dictionary))
})
