## ----setup, include = FALSE---------------------------------------------------
library(RmecabKo)
backend <- tryCatch({
  probe <- RcppMeCab::pos(enc2utf8("한국어"), join = FALSE)
  if (is.list(probe)) probe <- probe[[1L]]
  any(names(probe) %in% c("NNG", "NNP"))
}, error = function(e) FALSE)
has_tidy <- requireNamespace("tidytext", quietly = TRUE) &&
  requireNamespace("dplyr", quietly = TRUE)
if (has_tidy) {
  suppressPackageStartupMessages({
    library(dplyr)
    library(tidytext)
  })
}
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", eval = backend)

## ----install, eval = FALSE----------------------------------------------------
# install.packages("RcppMeCab")
# RcppMeCab::download_dic("ko")
# RcppMeCab::set_dic("ko")

## ----normalize, eval = TRUE---------------------------------------------------
text_normalize("한국어 분석 ㅋㅋㅋㅋ 정말 재밌어요!!!!")

## ----demo---------------------------------------------------------------------
demo_ko[1:2]

## ----unnest, eval = backend && has_tidy---------------------------------------
corpus <- tibble(doc = names(demo_ko), text = demo_ko)
tokens <- corpus |>
  unnest_tokens(word, text, token = token_nouns)
head(tokens, 8)

## ----fallback, eval = has_tidy------------------------------------------------
tidy_tokens <- if (backend && exists("tokens")) {
  tokens
} else {
  readRDS(system.file("extdata", "demo_ko_tokens.rds", package = "RmecabKo"))
}
count(tidy_tokens, word, sort = TRUE) |> head(6)

## ----stopwords, eval = has_tidy-----------------------------------------------
tidy_tokens |>
  anti_join(data.frame(word = stopwords_ko_words()), by = "word") |>
  count(word, sort = TRUE) |>
  head(6)

## ----droppos------------------------------------------------------------------
# drop every particle and ending directly during tokenization
token_morph(demo_ko[[2]], drop_pos = stopwords_ko_tags(c("josa", "eomi")),
            simplify = TRUE)

## ----tfidf, eval = has_tidy---------------------------------------------------
tidy_tokens |>
  count(doc, word) |>
  bind_tf_idf(word, doc, n) |>
  arrange(desc(tf_idf)) |>
  head(6)

## ----keywords-----------------------------------------------------------------
keywords_tfidf(demo_ko, div = "nouns", top_n = 2) |> head(6)

## ----sentiment, eval = FALSE--------------------------------------------------
# senti <- lexicon_knu()
# tidy_tokens |>
#   inner_join(senti[senti$n_words == 1, ], by = "word") |>
#   group_by(doc) |>
#   summarise(score = sum(polarity))

## ----ngrams-------------------------------------------------------------------
token_ngrams(demo_ko[[1]], n = 2, div = "nouns", simplify = TRUE)

## ----lemma--------------------------------------------------------------------
token_lemma(c("아침을 먹었다", "날씨가 좋았다"))

## ----kwic---------------------------------------------------------------------
kwic(demo_ko, "분석")

## ----userdic, eval = FALSE----------------------------------------------------
# dict_add_words(c("은전한닢", "카비봇"), tag = "NNP")
# dict_use()
# pos("카비봇 출시 소식")
# dict_words()

