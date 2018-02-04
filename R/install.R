#' Install mecab-ko-msvc and mecab-ko-dic-msvc
#'
#' \code{install_mecab} installs Mecab-Ko-MSVC and Mecab-Ko-Dic-MSVC.
#' 
#' This code checks and installs Mecab-Ko-MSVC and Mecab-Ko-Dic-MSVC in user specified directory. Windows only.
#' 
#' @usage install_mecab(mecabLocation)
#' 
#' @param mecabLocation a directory to install Mecab-Ko-MSVC and Mecab-Ko-Dic-MSVC. 
#'
#' @return None. The function will halt when the current operation system is not Windows, or /mecabLocation/mecab.exe exists.
#'
#' See examples in \href{https://github.com/junhewk/RmecabKo}{Github}.
#' 
#' @examples 
#' \dontrun{
#' install_mecab("D:/Rlibs/mecab")
#' }
#' 
#' @importFrom utils download.file unzip
#' @export

install_mecab <- function(mecabLocation) {
  
  # verify os
  if (!is_windows()) {
    stop("Unable to install mecab-ko-msvc on this platform. ",
         "Binary installation is available for Windows")
  }
  
  if (mecab_installed()) {
    stop("Mecab binary version is found.")
  }
  
  if (missing(mecabLocation)) {
    stop("Please speficy the path to install Mecab-Ko library.")
  }
  
  dir.create(mecabLocation, recursive = TRUE, showWarnings = FALSE)
  
  if (file.exists(file.path(mecabLocation, "mecab.exe"))) {
    
    mecabLibsLoc <- file.path(system.file(package = "RmecabKo"), "mecabLibs")
    
    if(!file.exists(mecabLibsLoc)) {
      con <- file(mecabLibsLoc, "a")
      
      tryCatch({
        cat(mecabLocation, file=con, sep="\n")
      },
      finally = {
        close(con)
      })
    }
    
    options(list(mecab.libpath = mecabLocation))
    
    stop("Mecab is already existed. The package will use the binary in this location.")
  }
    
  #if (!mecabLocCreated) {
  #  stop(paste("Unable to create a new directory to", mecabLocation, sep = " "))
  #}
  
  # verify 64-bit
  # mecab-ko-msvc: https://github.com/Pusnow/mecab-ko-msvc
  if(.Machine$sizeof.pointer != 8) {
    mecabDist <- "https://github.com/Pusnow/mecab-ko-msvc/releases/download/release-0.9.2-msvc-3/mecab-ko-msvc-x86.zip"
  } else {
    mecabDist <- "https://github.com/Pusnow/mecab-ko-msvc/releases/download/release-0.9.2-msvc-3/mecab-ko-msvc-x64.zip"
  }
  
  mecabDest <- file.path(mecabLocation, "mecab.zip")
  
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
      on.exit(suppressWarnings(setI2(internal2)))
        
      # needed for https
      suppressWarnings(setI2(TRUE))
    }
      
    method <- "internal"
  }
    
  suppressWarnings(download.file(url=mecabDist, destfile=mecabDest, method=method))  
  
  # unzip mecab-ko-msvc binary distribution
  unzip(mecabDest, exdir=mecabLocation)
  
  cat("Install mecab-ko-dic-msvc...")
  
  mecabDicDist <- "https://github.com/Pusnow/mecab-ko-dic-msvc/releases/download/mecab-ko-dic-2.0.3-20170922-msvc/mecab-ko-dic-msvc.zip"
  mecabDicDest <- file.path(mecabLocation, "mecab_dic.zip")
  
  suppressWarnings(download.file(url=mecabDicDist, destfile=mecabDicDest, method=method))
  
  unzip(mecabDicDest, exdir=mecabLocation)
  
  # delete distribution files
  suppressWarnings(file.remove(mecabDest))
  suppressWarnings(file.remove(mecabDicDest))
  
  # save mecabLocation in the package location
  mecabLibsLoc <- file.path(system.file(package = "RmecabKo"), "mecabLibs")
  
  con <- file(mecabLibsLoc, "a")
    
  tryCatch({
    cat(mecabLocation, file=con, sep="\n")
  },
  finally = {
    close(con)
  })
  
  options(list(mecab.libpath = mecabLocation))
}

