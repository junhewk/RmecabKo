make_id_fixture <- function() {
  dir <- withr::local_tempdir(.local_envir = parent.frame())
  writeLines(c(
    "0 BOS/EOS,*,*,*,*,*,*,BOS/EOS",
    "1780 NNG,*,*,*,*,*,*,*",
    "1786 NNP,*,*,*,*,*,*,*",
    "1788 NNP,인명,*,*,*,*,*,*"
  ), file.path(dir, "left-id.def"))
  writeLines(c(
    "0 BOS/EOS,*,*,*,*,*,*,BOS/EOS",
    "3533 NNG,*,F,*,*,*,*,*",
    "3534 NNG,*,T,*,*,*,*,*",
    "3545 NNP,*,F,*,*,*,*,*",
    "3546 NNP,*,T,*,*,*,*,*"
  ), file.path(dir, "right-id.def"))
  dir
}

test_that(".has_final_consonant detects the jongseong", {
  expect_identical(
    RmecabKo:::.has_final_consonant(enc2utf8(c("봇", "한국", "나비", "스미스"))),
    c("T", "T", "F", "F")
  )
  expect_identical(RmecabKo:::.has_final_consonant("R"), "F")
  expect_identical(RmecabKo:::.has_final_consonant(""), "F")
})

test_that(".lookup_context_id prefers generic entries and matches jongseong", {
  dir <- make_id_fixture()
  defs <- RmecabKo:::.load_id_defs(dir)

  expect_identical(RmecabKo:::.lookup_context_id(defs$left, "NNP", "T"), 1786L)
  expect_identical(RmecabKo:::.lookup_context_id(defs$right, "NNP", "T"), 3546L)
  expect_identical(RmecabKo:::.lookup_context_id(defs$right, "NNP", "F"), 3545L)
  expect_identical(RmecabKo:::.lookup_context_id(defs$right, "NNG", "F"), 3533L)
})

test_that(".resolve_context_ids falls back to the built-in table without defs", {
  empty <- withr::local_tempdir()
  ids <- RmecabKo:::.resolve_context_ids("NNP", "T", empty)
  expect_identical(ids[["left"]], 1786L)
  expect_identical(ids[["right"]], 3546L)

  ids_f <- RmecabKo:::.resolve_context_ids("NNG", "F", empty)
  expect_identical(ids_f[["right"]], 3533L)

  expect_error(
    RmecabKo:::.resolve_context_ids("SL", "F", empty),
    "Could not resolve context IDs"
  )
})

test_that(".compose_dic_rows produces mecab-ko-dic CSV rows", {
  dir <- make_id_fixture()
  registry <- data.frame(
    surface = enc2utf8(c("카비봇", "스미스")),
    tag = c("NNP", "NNP"),
    reading = c(NA_character_, NA_character_),
    meaning = c("*", "*"),
    cost = c(3000L, 3000L),
    left_id = NA_integer_,
    right_id = NA_integer_,
    stringsAsFactors = FALSE
  )
  rows <- RmecabKo:::.compose_dic_rows(registry, dir)
  expect_identical(rows[[1L]], enc2utf8("카비봇,1786,3546,3000,NNP,*,T,카비봇,*,*,*,*"))
  expect_identical(rows[[2L]], enc2utf8("스미스,1786,3545,3000,NNP,*,F,스미스,*,*,*,*"))
})

test_that("add / list / remove round-trip with mocked compilation", {
  fixture <- make_id_fixture()
  withr::local_options(
    rmecabko.dict_root = withr::local_tempdir(),
    mecabSysDic = fixture
  )
  compiled <- NULL
  local_mocked_bindings(
    .engine_dict_index = function(dic_csv, out_dic, dic_dir, ...) {
      compiled <<- list(csv = dic_csv, out = out_dic)
      writeLines("", out_dic)
      invisible(TRUE)
    },
    .package = "RmecabKo"
  )

  dict_add_words(c("카비봇", "스미스"), tag = "NNP", sys_dic = fixture)
  expect_identical(nrow(dict_words()), 2L)
  expect_true(file.exists(compiled$out))
  expect_true(file.exists(dict_path()))

  # adding the same surface+tag does not duplicate
  dict_add_words("카비봇", tag = "NNP", sys_dic = fixture)
  expect_identical(nrow(dict_words()), 2L)

  dict_remove_words("카비봇")
  expect_identical(dict_words()$surface, enc2utf8("스미스"))
})

test_that("data frame input carries reading and cost", {
  withr::local_options(rmecabko.dict_root = withr::local_tempdir())
  fixture <- make_id_fixture()
  local_mocked_bindings(
    .engine_dict_index = function(...) invisible(TRUE),
    .package = "RmecabKo"
  )
  df <- data.frame(
    surface = enc2utf8("한글날"),
    tag = "NNP",
    cost = 500L,
    stringsAsFactors = FALSE
  )
  reg <- dict_add_words(df, sys_dic = fixture, compile = FALSE)
  expect_identical(reg$cost, 500L)
})

test_that("invalid input is rejected", {
  withr::local_options(rmecabko.dict_root = withr::local_tempdir())
  expect_error(dict_add_words("좋은,단어", compile = FALSE), "commas")
  expect_error(dict_add_words("단어", tag = "ZZZ", compile = FALSE), "Unknown")
  expect_error(dict_add_words(data.frame(x = 1), compile = FALSE), "surface")
})

test_that("dict_use plumbs the compiled dictionary into pos", {
  mock_korean_engine()
  withr::local_options(
    rmecabko.dict_root = withr::local_tempdir(),
    rmecabko.user_dic = NULL
  )
  dic_dir <- withr::local_tempdir()
  writeLines("", file.path(dic_dir, "user.dic"))
  # forge a compiled dictionary directly
  target <- dict_path("user")
  dir.create(dirname(target), showWarnings = FALSE, recursive = TRUE)
  writeLines("", target)

  seen <- NULL
  local_mocked_bindings(
    .engine_pos = function(sentence, join = TRUE, format = "list",
                           sys_dic = "", user_dic = "") {
      if (identical(sentence, enc2utf8("한국어 형태소 분석"))) {
        return(fake_korean_pos(sentence, join, format, sys_dic, user_dic))
      }
      seen <<- user_dic
      fake_korean_pos(sentence, join, format, sys_dic, user_dic)
    },
    .package = "RmecabKo"
  )

  dict_use("user")
  pos("문장")
  expect_identical(seen, target)
})

test_that("real user dictionary is recognized by the backend", {
  skip_on_cran()
  skip_if_not(.korean_backend_ready())
  withr::local_options(
    rmecabko.dict_root = withr::local_tempdir(),
    rmecabko.user_dic = NULL
  )
  reset_dictionary_cache()

  dict_add_words("카비봇테스트", tag = "NNP")
  dict_use()
  tokens <- pos("카비봇테스트 출시", join = FALSE)[[1L]]
  expect_true(enc2utf8("카비봇테스트") %in% tokens)
})
