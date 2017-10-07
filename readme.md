# RmecabKo [![License](http://img.shields.io/badge/license-GPL%20%28%3E=%202%29-brightgreen.svg?style=flat)](http://www.gnu.org/licenses/gpl-2.0.html)

The goal of RmecabKo is to parse Korean phrases with `mecab-ko` ([Eunjeon project](http://eunjeon.blogspot.com/), and to provide helper functions to analyze Korean documents. RmecabKo provides R wrapper function of `mecab-ko` with `Rcpp` (in Mac OSX and Linux) or wrapper function of binary build of `mecab-ko-msvc` by system commands and file I/O (in Windows).


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
install.package("RmecabKo")
# or, install.packages("devtools")
devtools::install_github("junhewk/RmecabKo")
```

You need to install `mecab-ko-dic`, refer to [Bitbucket page](https://bitbucket.org/eunjeon/mecab-ko-dic). The installation procedure is same as `mecab-ko`.

### Windows

In Windows, `install_mecab` function is provided.

```
install.package("RmecabKo")
# or, install.packages("devtools")
devtools::install_github("junhewk/RmecabKo")
install_mecab()
```


## Example

Basic usage of the provided functions is to put character vector in `phrase` parameter of `pos(phrase)` and `nouns(phrase)`. Loop between phrases are operated in the C++ binary, thus you can analyze many phrases quickly.

```
pos("Hello. This is R wrapper of Korean morpheme analyzer mecab-ko.")
```

Output of the `pos` is list. Each element of the list contains classified morpheme and inferred part-of-speech (POS), separated by "/". The name of the element is the original phrase.

Output of the `nouns` is also list. Each element of the list contains extracted nouns. The name of the element is the original phrase.

More examples will be provided on [Github wiki](https://github.com/junhewk/RmecabKo/wiki).


## Author

Junhewk Kim (junhewk.kim@gmail.com)


## Thanks to and Contributor

* [Eunjeon project](http://eunjeon.blogspot.com/): Fork Japanese morpheme analyzer `mecab` to Korean version
* [Wonsup Yoon](www.github.com/Pusnow): VC++ binary build of `mecab-ko-msvc`, `mecab-ko-dic-msvc`.
