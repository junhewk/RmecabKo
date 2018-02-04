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

check_input <- function(x) {
  check_character <- is.character(x) |
    if (is.list(x)) {
      check_list <- all(vapply(x, is.character, logical(1))) &
        all(vapply(x, length, integer(1)) == 1L)
    } else {
      check_list <- FALSE
    }
  if (!(check_character | check_list))
    stop("Input must be a character vector of any length or a list of character\n",
         "  vectors, each of which has a length of 1.")
}