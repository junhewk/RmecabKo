install_mecab <- function() {
  
  # verify os
  if(!is_windows()) {
    stop("Unable to install mecab-ko-msvc on this platform. ",
         "Binary installation is available for Windows")
  }
  
  if(mecab_installed()) {
    stop("Mecab binary version is found in C:\\mecab.")
  }
  
  mecabLocation <- "C:\\mecab"
  
  suppressWarnings(dir.create(mecabLocation))
  
  # verify 64-bit
  # mecab-ko-msvc: https://github.com/Pusnow/mecab-ko-msvc
  if(.Machine$sizeof.pointer != 8) {
    mecabDist <- "https://github.com/Pusnow/mecab-ko-msvc/releases/download/release-0.9.2-msvc-3/mecab-ko-msvc-x86.zip"
  } else {
    mecabDist <- "https://github.com/Pusnow/mecab-ko-msvc/releases/download/release-0.9.2-msvc-3/mecab-ko-msvc-x64.zip"
  }
  
  mecabDest <- "C:\\mecab\\mecab.zip"
  
  cat("Install mecab-ko-msvc...")
  
  # verify R version
  if(getRversion() >= "3.2") {
    method <- "wininet"
  } else {
    # for R < 3.2, mapping to `method="wininet"` in functions `download.file` and `url` needs this function
    setI2 <- `::`(utils, 'setInternet2')
      
    # check for `method="internal"`
    internal2 <- setI2(NA)
      
    # set internal
    if(!internal2) {
      # store initial settings, and restore on exit
      on.exit(suppressWarnings(setI2(internet2Start)))
        
      # needed for https
      suppressWarnings(setI2(TRUE))
    }
      
    method <- "internal"
  }
    
  suppressWarnings(download.file(url=mecabDist, destfile=mecabDest, method=method))  
  
  # unzip mecab-ko-msvc binary distribution
  unzip(mecabDest, exdir=mecabLocation)
  
  cat("Install mecab-ko-dic-msvc...")
  
  mecabDicDist <- "https://github.com/Pusnow/mecab-ko-dic-msvc/releases/download/mecab-ko-dic-2.0.1-20150920-msvc/mecab-ko-dic-msvc.zip"
  mecabDicDest <- "C:\\mecab\\mecab_dic.zip"
  
  suppressWarnings(download.file(url=mecabDicDist, destfile=mecabDicDest, method=method))
  
  unzip(mecabDicDest, exdir=mecabLocation)
  
  # delete distribution files
  suppressWarnings(file.remove(mecabDest))
  suppressWarnings(file.remove(mecabDicDest))
}

