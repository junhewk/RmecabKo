# RmecabKo 0.3.0

RmecabKo grows from a thin wrapper into a Korean text-analysis layer over
`RcppMeCab`, filling the gap left by the archived `KoNLP` and `elbird` packages.

## Tokenizers and tidytext

* Tokenizers now follow the `tokenizers` package contract, so `token_morph()`,
  `token_words()`, `token_nouns()`, and `token_ngrams()` drop directly into
  `tidytext::unnest_tokens(token = ...)`. Each gains a `simplify` argument.
* Add a `drop_pos` argument to `token_morph()` and `token_ngrams()` to remove
  tokens by POS tag, complementing `keep_pos`.
* **Breaking:** unnamed input now yields an unnamed list. Previously each
  element was named after its (potentially long) source document. Named input
  is unchanged.

## Korean data

* Add `stopwords_ko`, a curated table of Korean function morphemes, with the
  accessors `stopwords_ko_words()` (surfaces) and `stopwords_ko_tags()` (POS
  tags for `drop_pos`).
* Add `lexicon_knu()`, which downloads and caches the KNU Korean sentiment
  lexicon for tidy sentiment joins.
* Add the `demo_ko` demonstration corpus.

## User dictionaries

* Add `dict_add_words()`, `dict_words()`, `dict_remove_words()`,
  `dict_compile()`, `dict_use()`, and `dict_path()` to manage a MeCab user
  dictionary from a data frame of words, filling the `mecab-ko-dic` context IDs
  and final-consonant flag automatically.

## Analysis helpers

* Add `token_lemma()` and `lemmatize_morphemes()` to recover dictionary forms
  of Korean predicates. Fused tokens whose stem `RcppMeCab` does not expose
  return `NA`.
* Add `keywords_tfidf()` and `keywords_textrank()` for morpheme keyword
  extraction, and `kwic()` for keyword-in-context concordances.
* Add `text_normalize()` for NFC composition, width folding, and repeated-
  character squashing.

## Documentation

* Add the "Korean text analysis with RmecabKo" vignette walking through a full
  tidy workflow.

# RmecabKo 0.2.1

* Require the companion `RcppMeCab` 0.0.1.7 release used by the 0.2.0
  migration to centralized MeCab and dictionary management.
* Skip the end-to-end integration test when a check platform has no compatible
  Korean backend while retaining deterministic dictionary-validation tests.
* Use a valid external URL for the Korean README in built source packages.
* Encode Korean documentation examples with R Unicode escapes so the PDF
  reference manual builds with CRAN's LaTeX toolchain.

# RmecabKo 0.2.0

* Use `RcppMeCab` as the sole native MeCab engine and verify that the active
  dictionary produces Korean POS tags.
* Make noun, content-word, and morpheme tokenizers consistent for scalar,
  vector, named, list, empty, and missing inputs.
* Filter punctuation, numbers, and POS categories after morphological analysis.
* Add multiple n-gram sizes, exact skip-grams, POS filters, and stopword
  boundaries. Empty and too-short documents now safely return `character(0)`.
* Deprecate the obsolete standalone MeCab installer.
* Preserve UTF-8 text on Windows and normalize all analyzer input at the R
  boundary (fixes #1).
* Support compiled cross-platform user dictionaries through `user_dic`, with
  compilation delegated to `RcppMeCab::dict_index()` (fixes #2).

# RmecabKo 0.1.7.0

* Replace package-local POS tagging with `RcppMeCab`.
* Fix encoding issues.

# RmecabKo 0.1.6.2

* Fix `install_mecab()` subdirectory handling.
* Fix local encoding checks in POS and noun extraction.
