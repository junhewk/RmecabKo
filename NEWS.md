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
