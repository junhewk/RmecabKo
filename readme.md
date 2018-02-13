# RmecabKo [![License](http://img.shields.io/badge/license-GPL%20%28%3E=%202%29-brightgreen.svg?style=flat)](http://www.gnu.org/licenses/gpl-2.0.html) [![CRAN](http://www.r-pkg.org/badges/version/RmecabKo)](https://cran.r-project.org/package=RmecabKo) [![Downloads](http://cranlogs.r-pkg.org/badges/RmecabKo?color=brightgreen)](http://www.r-pkg.org/pkg/RmecabKo)

The goal of RmecabKo is to parse Korean phrases with `mecab-ko` ([Eunjeon project](http://eunjeon.blogspot.com/), and to provide helper functions to analyze Korean documents. RmecabKo provides R wrapper function of `mecab-ko` with `Rcpp` (in Mac OSX and Linux) or wrapper function of binary build of `mecab-ko-msvc` by system commands and file I/O (in Windows).

For instructions in Korean, refer to [readme.rmd](https://github.com/junhewk/RmecabKo/blob/master/readme.rmd).

## Installation

### Mac OSX, Linux

First, install `mecab-ko` from the [Bitbucket repository](https://bitbucket.org/eunjeon/mecab-ko).

You can download a source of `mecab-ko` from [Download page](https://bitbucket.org/eunjeon/mecab-ko/downloads/).

In Mac OSX terminal:

```
$ tar zxfv mecab-ko-XX.tar.gz
$ cd mecab-ko-XX
$ ./configure 
$ make
$ make check
$ sudo make install
```

In Linux:

```
$ tar zxfv mecab-ko-XX.tar.gz
$ cd mecab-ko-XX
$ ./configure 
$ make
$ make check
$ su
# make install
```

After the installation of `mecab-ko`, You can install RmecabKo from github with:

```
install.packages("RmecabKo")
# or, install.packages("devtools")
devtools::install_github("junhewk/RmecabKo")
```

You need to install `mecab-ko-dic` also.

<del>(In Github version, `install_dic` function is added to support this functionality. You can install `mecab-ko-dic` with `install_dic()`. I'm working with custom dictionary function, for it `mecab-ko-dic` has to be installed by this function.)</del>

Refer to [Bitbucket page](https://bitbucket.org/eunjeon/mecab-ko-dic). The installation procedure is same as `mecab-ko`.

### Windows

In Windows, `install_mecab` function is provided. You need to specify the installation path of the `mecab-ko` and `meccab-ko-dic` in the function parameter, `mecabLocation`.

```
install.packages("RmecabKo")
# install.packages("devtools")
devtools::install_github("junhewk/RmecabKo")
install_mecab("D:/Rlibs/mecab")
```

* 12/12/17. Encoding problem in Windows resolved (special thanks to Young Woo Kim).

## Example

Basic usage of the provided functions is to put character vector in `phrase` parameter of `pos(phrase)` and `nouns(phrase)`. Loop between phrases are operated in the C++ binary, thus you can analyze many phrases quickly.

```
pos("Hello. This is R wrapper of Korean morpheme analyzer mecab-ko.")
```

Output of the `pos` is list. Each element of the list contains classified morpheme and inferred part-of-speech (POS), separated by "/". The name of the element is the original phrase.

Output of the `nouns` is also list. Each element of the list contains extracted nouns. The name of the element is the original phrase.

`tokenizer` functions are added. You can use `tokens_morph`, `tokens_words`, `tokens_nouns`, and `tokens_ngram`. Please refer to the help page of each function.

More examples will be provided on [Github wiki](https://github.com/junhewk/RmecabKo/wiki).


## Author

Junhewk Kim (junhewk.kim@gmail.com)


## Thanks to and Contributor

* [Eunjeon project](http://eunjeon.blogspot.com/): Fork Japanese morpheme analyzer `mecab` to Korean version
* [Wonsup Yoon](https://www.github.com/Pusnow): VC++ binary build of `mecab-ko-msvc`, `mecab-ko-dic-msvc`.
