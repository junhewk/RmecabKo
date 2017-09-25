\name{RmecabKo-package}
\alias{RmecabKo-package}
\alias{RmecabKo}
\docType{package}
\title{
  Rcpp Wrapper for Eunjeon Project
}
\description{
  Rcpp Wrapper for Eunjeon Project
  The \code{mecab-ko} and \code{mecab-ko-dic} is based on a \code{C++} library, and POS tagging with them is useful when the spacing of source text is not correct. For integrating \code{mecab-ko} with \code{R}, \code{Rcpp} package is used for providing the basic framework.
}
\details{
  
  It is based on the \code{Eunjeon Project}. You need to install \code{mecab-ko} and \code{mecab-ko-dic} before install this package in R.

  \code{mecab-ko}: \url{https://bitbucket.org/eunjeon/mecab-ko}
  \code{mecab-ko-dic}: \url{https://bitbucket.org/eunjeon/mecab-ko-dic}

  Windows version is still working on. I don't have an windows machine, so if you can test the code, it'll be very helpful for developing it.

}
\author{
Junhewk Kim

Maintainer: Junhewk Kim <junhewk.kim@gmail.com>
}
\references{
  eunjeon project, available at \url{http://eunjeon.blogspot.kr/}
}
\keyword{ Korean, tagging, nlp }
\examples{
  \dontrun{
     mecab("안녕하세요.")
     mecab(list("안녕하세요.", "은전한닢 프로젝트의 R wrapper입니다."))
  }
}
