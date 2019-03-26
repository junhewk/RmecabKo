#' Rcpp Wrapper for Eunjeon Project
#' 
#' The \code{mecab-ko} and \code{mecab-ko-dic} is based on a \code{C++} library,
#' and POS tagging with them is useful when the spacing of source text is not correct.
#' For integrating \code{mecab-ko} with \code{R}, \code{Rcpp} package is used for providing the basic framework.
#' 
#' @docType package
#' @author Junhewk Kim
#' @import Rcpp
#' @importFrom utils download.file
#' @importFrom utils unzip
#' @importFrom Rcpp evalCpp
#' @useDynLib RmecabKo
#' @name RmecabKo
#' 
#' @details
#' It is based on the \code{Eunjeon Project}.
#' For Mac OSX and Linux, You need to install \code{mecab-ko} and \code{mecab-ko-dic} before install this package in R.
#' \code{mecab-ko}: \url{https://bitbucket.org/eunjeon/mecab-ko}
#' \code{mecab-ko-dic}: \url{https://bitbucket.org/eunjeon/mecab-ko-dic}
#' In Windows, \code{install_mecab(mecabLocation)} function will install \code{mecab-ko-msvc} and \code{mecab-ko-dic-msvc} in user specified directory.
#' It is operated by system command and file I/O, the speed of the analysis is slow compared to the Linux-based operating system.
#' 
#' @references
#' \itemize{
#' \item{\href{http://eunjeon.blogspot.com}{Eunjeon project}}
#' \item{\href{https://github.com/Pusnow}{Wonsup Yoon}, mecab-ko VC++ builds at \url{https://github.com/Pusnow/mecab-ko-msvc}, \url{https://github.com/Pusnow/mecab-ko-dic-msvc}}
#' }
#' 
#' @examples
#' \dontrun{
#' # install.packages("devtools")
#' devtools::install_github("junhewk/RmecabKo")
#' # On Windows platform only
#' install_mecab("D:/Rlibs/mecab")
#' 
#' phrase <- # Some Korean character vectors
#' 
#' # For full POS tagging
#' pos(phrase)
#' # For noun extraction only
#' nouns(phrase)
#' # For tokenizing of selective morphemes
#' tokens_words(phrase)
#' # For n-grams tokenizing
#' tokens_ngram(phrase)
#' }
#' 
#' @keywords Korean tagger nlp
NULL

mecab_libs <- function() {
  mecabLibsData <- system.file("mecabLibs", package = "RmecabKo")
  
  if (mecabLibsData != "") {
    con <- file(mecabLibsData, "r")
    
    tryCatch({
      mecabLibsLoc <- readLines(con)
    },
    finally = {
      close(con)
    })
  } else {
    mecabLibsLoc <- ""
  }
  
  return(list(mecab.libpath = mecabLibsLoc))
}

.onLoad <- function(libname, pkgname) {
  if (is_windows()) {
    op <- options()
    mecabOptions <- mecab_libs()
    if(!(names(mecabOptions) %in% names(op))) options(mecabOptions)
  }
  
  invisible()
}
