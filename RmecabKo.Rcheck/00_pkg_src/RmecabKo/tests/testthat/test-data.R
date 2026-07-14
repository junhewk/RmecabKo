test_that("stopwords_ko has the documented schema", {
  expect_s3_class(stopwords_ko, "data.frame")
  expect_identical(names(stopwords_ko), c("word", "tag", "category"))
  expect_true(is.factor(stopwords_ko$category))
  expect_setequal(
    levels(stopwords_ko$category),
    c("josa", "eomi", "suffix", "formal_noun", "function_word")
  )
  expect_false(anyNA(stopwords_ko$word))
  expect_true(all(Encoding(stopwords_ko$word[grepl("[가-힣]", stopwords_ko$word)]) == "UTF-8"))
})

test_that("stopword accessors filter by category", {
  expect_true(all(stopwords_ko_tags("josa") %in% stopwords_ko$tag))
  expect_identical(
    sort(stopwords_ko_words("eomi")),
    sort(unique(stopwords_ko$word[stopwords_ko$category == "eomi"]))
  )
  expect_error(stopwords_ko_words("nonsense"), "Unknown stopword category")
})

test_that("demo_ko is a named Korean character vector", {
  expect_type(demo_ko, "character")
  expect_true(length(demo_ko) >= 5L)
  expect_false(is.null(names(demo_ko)))
})

test_that("lexicon_knu reads a cached copy without network", {
  cache_dir <- withr::local_tempdir()
  fixture <- data.frame(
    word = enc2utf8(c("좋다", "나쁘다", "정말 좋다")),
    polarity = c(2L, -2L, 2L),
    n_words = c(1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  saveRDS(fixture, file.path(cache_dir, "sentiments_knu.rds"))

  lex <- lexicon_knu(dir = cache_dir)
  expect_identical(lex, fixture)
  expect_identical(names(lex), c("word", "polarity", "n_words"))
})
