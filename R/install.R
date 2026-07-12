#' Deprecated MeCab installer
#'
#' `RcppMeCab` now installs the native MeCab engine and Korean dictionary.
#' Install it with `install.packages("RcppMeCab")` instead.
#'
#' @param mecabLocation Ignored legacy installation path.
#' @return Invisibly returns `NULL`.
#' @export
install_mecab <- function(mecabLocation) {
  .Deprecated(msg = paste(
    "install_mecab() is no longer needed.",
    "Install RcppMeCab, which supplies MeCab and mecab-ko-dic."
  ))
  invisible(NULL)
}
