is_windows <- function() {
  identical(.Platform$OS.type, "windows")
}

is_osx <- function() {
  Sys.info()["sysname"] == "Darwin"
}

is_linux <- function() {
  identical(tolower(Sys.info()[["sysname"]]), "linux")
}

mecab_installed <- function() {
  mecabLibs <- getOption("mecab.libpath")
  
  if (is_windows() && mecabLibs != "") {
    file.exists(file.path(mecabLibs, "mecab.exe"))
  } else {
    return(FALSE)
  }
}
