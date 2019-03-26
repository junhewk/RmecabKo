# RmecabKo 0.1.7.0

* Remove the core POS tagging functions and import `RcppMeCab` package to analyze the text
* Fix encoding issues

# RmecabKo 0.1.6.2

* Fix `install_mecab` to support creating subdirectory
* Fix `pos` and other token functions to check local encoding.

# RmecabKo 0.1.6.1

* Add `install_dic` function to install `mecab-ko-dic`. It is needed to use custom dictionary functionality.
* Add tokenizers.

# RmecabKo 0.1.6

* Remove `mecab-ko-msvc` binary build from the package
* Add `install_mecab` function to install `mecab-ko-msvc` and `mecab-ko-dic-msvc` in user setting directory.
* Fix cpp function to assert errors correctly
* Rearrange documents with `Roxygen2`

# RmecabKo 0.1.5

* Support Windows with binary build `mecab-ko-msvc` and `mecab-ko-dic-msvc`
* Now analysing functions (`pos` and `nouns`) receives character vector, not list.
* Add `nouns` function to extract nouns of Korean phrases

# RmecabKo 0.1

* First release
* Support Mac OSX and Linux
* Need installation of `mecab-ko` for building this package (and `mecab-ko-dic`)
