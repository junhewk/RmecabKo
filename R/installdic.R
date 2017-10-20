#' Install Mecab-Ko-Dic in Linux and Mac OSX.
#'
#' \code{install_dic} installs Mecab-Ko-Dic.
#' 
#' This code checks and installs Mecab-Ko-Dic in Linux and Mac OSX. This is essential for using custom-defined user dictionary.
#' 
#' @usage install_dic()
#' 
#' @return None. The function will halt when the current operation system is not Linux or Mac OSX, or Mecab-Ko-Dic is installed already.
#'
#' See examples in \href{https://github.com/junhewk/RmecabKo}{Github}.
#' 
#' @examples 
#' \dontrun{
#' install_dic()
#' }
#' 
#' @importFrom utils download.file untar
#' @export

install_dic <- function() {
  
  mecabDicCurrentVer <- "https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.0.3-20170922.tar.gz"
  mecabDicCurrentDir <- "mecab-ko-dic-2.0.3-20170922"
  
  # verify os
  if (!is_linux() && !is_osx()) {
    stop("Unable to install Mecab-Ko-Dic on this platform. ",
         "Building Mecab-Ko-Dic is possible only in Linux or Mac OSX")
  }
 
  #if (file.exists("/usr/local/lib/mecab/dic/mecab-ko-dic/dicrc")) {
  #  stop("Mecab-Ko-Dic is already installed.")
  #}
  
  mecabPackage <- find.package("RmecabKo")
  mecabDicInst <- file.path(mecabPackage, mecabDicCurrentDir)
  
  if (dir.exists(mecabDicInst)) {
    file.remove(dir(mecabDicInst))
  } else {
    dir.create(mecabDicInst)
  }
  
  mecabKoDicFile <- file.path(mecabPackage, "mecab_ko_dic.tar.gz")
  suppressWarnings(download.file(url = mecabDicCurrentVer, destfile = mecabKoDicFile))
  
  untar(mecabKoDicFile, exdir = mecabPackage)
  
  suppressWarnings(file.remove(mecabKoDicFile))
  
  if (is_linux) {
    script <- paste0("cd ", mecabDicInst, "; ./configure; make; su; make install;")
  } else {
    script <- paste0("cd ", mecabDicInst, "; ./autogen.sh; ./configure; make; sudo make install;")
  }
  
  # The script will preserve the source file for custom dictonary building.
  system(script)
}