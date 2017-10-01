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
  
  It is based on the \code{Eunjeon Project}. For Mac OSX and Linux, You need to install \code{mecab-ko} and \code{mecab-ko-dic} before install this package in R.

  \code{mecab-ko}: \url{https://bitbucket.org/eunjeon/mecab-ko}
  \code{mecab-ko-dic}: \url{https://bitbucket.org/eunjeon/mecab-ko-dic}

  In Windows, \code{mecab-ko-msvc} and \code{mecab-ko-dic-msvc} is included in the package. It is operated by system command and file I/O, the speed of the analysis is slow compared to the Linux-based operating system.

}
\author{
Junhewk Kim

Maintainer: Junhewk Kim <junhewk.kim@gmail.com>
}
\references{
  \itemize{
    \item \href{http://eunjeon.blogspot.com}{Eunjeon project}
    \item \href{https://github.com/Pusnow}{Wonsup Yoon}, mecab-ko VC++ builds at \url{https://github.com/Pusnow/mecab-ko-msvc}, \url{https://github.com/Pusnow/mecab-ko-dic-msvc}
  }
}
\keyword{ Korean, tagging, nlp }
\examples{
  \dontrun{
    # install.packages("devtools")
    devtools::install_github("junhewk/RmecabKo")

    pos("안녕하세요.")
    pos(c("안녕하세요.", "은전한닢 프로젝트의 R wrapper입니다."))

    nouns("안녕하세요.")
    nouns(c("안녕하세요.", "은전한닢 프로젝트의 R wrapper입니다."))
  }
}
