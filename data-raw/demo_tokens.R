# Precompute a tidy tokenization of demo_ko so the vignette can render even on
# a build machine without a working Korean MeCab backend.
#
# Run with: Rscript data-raw/demo_tokens.R  (requires an active mecab-ko-dic)

pkgload::load_all(quiet = TRUE)

nouns <- token_nouns(demo_ko)
tidy <- do.call(rbind, lapply(names(nouns), function(doc) {
  data.frame(doc = doc, word = nouns[[doc]], stringsAsFactors = FALSE)
}))
tidy$word <- enc2utf8(tidy$word)
Encoding(tidy$word) <- "UTF-8"

dir.create("inst/extdata", showWarnings = FALSE, recursive = TRUE)
saveRDS(tidy, "inst/extdata/demo_ko_tokens.rds", version = 2)
message(sprintf("demo_ko_tokens: %d rows", nrow(tidy)))
