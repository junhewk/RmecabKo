#' Korean sentiment lexicon (KNU)
#'
#' Downloads and caches the KNU Korean sentiment lexicon (KnuSentiLex) and
#' returns it as a tidy data frame suitable for joining against tokens produced
#' by [token_morph()] or [token_nouns()]. The lexicon is not bundled with the
#' package: on first use it is fetched from its public repository and stored in
#' the user data directory, then read from that cache on later calls.
#'
#' The lexicon assigns each entry a polarity from `-2` (strongly negative) to
#' `2` (strongly positive). Some entries are multi-word expressions; the
#' `n_words` column gives the token count so you can restrict to single
#' morphemes when joining.
#'
#' The KNU sentiment lexicon (KnuSentiLex) is developed by researchers at
#' Kyungpook National University (KNU) and is distributed under the Creative
#' Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA) license. It is
#' therefore not bundled with this package, whose own license permits
#' commercial use: `lexicon_knu()` downloads it from its source repository so
#' that you obtain it directly and accept its terms. The **NonCommercial**
#' clause restricts commercial use, and any redistribution must preserve
#' attribution and the ShareAlike terms. Cite the lexicon when you use it and
#' review the full terms at <https://github.com/park1200656/KnuSentiLex>.
#'
#' @param dir Directory for the cached copy. Defaults to a `lexicons`
#'   subfolder of `tools::R_user_dir("RmecabKo", "data")`.
#' @param force Re-download and overwrite the cached copy.
#' @param quiet Suppress the download and attribution messages.
#' @return A data frame with columns `word` (UTF-8), `polarity` (integer
#'   `-2..2`), and `n_words` (token count of `word`).
#' @examples
#' \dontrun{
#' senti <- lexicon_knu()
#' # keep single-morpheme entries only
#' senti[senti$n_words == 1L, ]
#' }
#' @export
lexicon_knu <- function(dir = NULL, force = FALSE, quiet = FALSE) {
  force <- .check_flag(force, "force")
  quiet <- .check_flag(quiet, "quiet")
  if (is.null(dir)) {
    dir <- .user_data_dir("lexicons")
  }
  cache <- file.path(dir, "sentiments_knu.rds")

  if (file.exists(cache) && !force) {
    return(readRDS(cache))
  }

  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop(
      "Package 'jsonlite' is required to build the KNU lexicon. ",
      "Install it with install.packages(\"jsonlite\").",
      call. = FALSE
    )
  }

  if (!quiet) {
    message(
      "Downloading the KNU Korean sentiment lexicon (KnuSentiLex).\n",
      "Source: https://github.com/park1200656/KnuSentiLex\n",
      "License: CC BY-NC-SA (Kyungpook National University). ",
      "The NonCommercial clause restricts commercial use. ",
      "Cite the lexicon and review its terms before use or redistribution."
    )
  }

  url <- paste0(
    "https://raw.githubusercontent.com/park1200656/KnuSentiLex/",
    "master/SentiWord_info.json"
  )
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp), add = TRUE)
  status <- tryCatch(
    utils::download.file(url, tmp, quiet = quiet, mode = "wb"),
    error = function(e) {
      stop(
        "Could not download the KNU lexicon: ", conditionMessage(e),
        call. = FALSE
      )
    }
  )
  if (!identical(status, 0L) || !file.exists(tmp)) {
    stop("Could not download the KNU lexicon from ", url, call. = FALSE)
  }

  lexicon <- .parse_knu(tmp)
  saveRDS(lexicon, cache)
  lexicon
}

.parse_knu <- function(path) {
  raw <- jsonlite::fromJSON(path)
  word <- enc2utf8(as.character(raw$word))
  Encoding(word) <- "UTF-8"
  polarity <- suppressWarnings(as.integer(as.character(raw$polarity)))
  n_words <- lengths(strsplit(trimws(word), "\\s+"))
  n_words[!nzchar(trimws(word))] <- 0L

  lexicon <- data.frame(
    word = word,
    polarity = polarity,
    n_words = as.integer(n_words),
    stringsAsFactors = FALSE
  )
  lexicon <- lexicon[!is.na(lexicon$polarity) & nzchar(lexicon$word), ]
  rownames(lexicon) <- NULL
  lexicon
}
