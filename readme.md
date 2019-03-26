# RmecabKo [![License](http://img.shields.io/badge/license-GPL-brightgreen.svg?style=flat)](http://www.gnu.org/licenses/gpl-2.0.html) [![CRAN](http://www.r-pkg.org/badges/version/RmecabKo)](https://cran.r-project.org/package=RmecabKo) [![Downloads](http://cranlogs.r-pkg.org/badges/RmecabKo?color=brightgreen)](http://www.r-pkg.org/pkg/RmecabKo)

The goal of RmecabKo is providing Korean text analysis environment in R. Based on `RcppMeCab` package, this package provides POS tagging, morphological analysis, sentiment dictionary, N-gram tokenizer, and more.

For instructions in Korean, refer to [readme.rmd](https://github.com/junhewk/RmecabKo/blob/master/readme.rmd).

## Installation

It is highly recommended to install `RcppMeCab` package first. Please refer to [RcppMeCab](https://github.com/junhewk/RcppMeCab).

```
install.packages("RmecabKo") # 0.1.6.2, uses own POS analyzing function
# developmental version
install.packages("devtools")
devtools::install_github("junhewk/RmecabKo") # 0.1.7.0, imports RcppMeCab package
```

## Functions

## Author

Junhewk Kim (junhewk.kim@gmail.com)
