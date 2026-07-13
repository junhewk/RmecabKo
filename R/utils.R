.rmecabko_state <- new.env(parent = emptyenv())
.rmecabko_state$dictionary_checks <- new.env(parent = emptyenv())

.engine_dictionary_info <- function(sys_dic = "", user_dic = "") {
  RcppMeCab::dictionary_info(sys_dic = sys_dic, user_dic = user_dic)
}

.engine_pos <- function(...) {
  RcppMeCab::pos(...)
}

.engine_pos_parallel <- function(...) {
  RcppMeCab::posParallel(...)
}

.check_flag <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop(name, " must be TRUE or FALSE", call. = FALSE)
  }
  x
}

.check_path <- function(x, name) {
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop(name, " must be a non-missing character scalar", call. = FALSE)
  }
  x
}

.normalize_documents <- function(x) {
  supplied_names <- names(x)

  if (is.list(x)) {
    valid <- vapply(
      x,
      function(element) is.character(element) && length(element) == 1L,
      logical(1)
    )
    if (!all(valid)) {
      stop(
        "List input must contain one character value per element",
        call. = FALSE
      )
    }
    x <- unlist(x, use.names = FALSE)
  } else if (!is.character(x)) {
    stop(
      "Input must be a character vector or a list of character scalars",
      call. = FALSE
    )
  }

  x <- enc2utf8(x)
  document_names <- supplied_names
  if (is.null(document_names)) {
    document_names <- x
  }

  list(text = x, names = document_names)
}

.dictionary_key <- function(sys_dic, user_dic) {
  effective_sys_dic <- sys_dic
  if (!nzchar(effective_sys_dic)) {
    option <- getOption("mecabSysDic")
    if (!is.null(option)) {
      effective_sys_dic <- as.character(option)[1L]
    }
  }
  stamp <- function(path, directory = FALSE) {
    if (!nzchar(path)) {
      return(NA_character_)
    }
    target <- if (directory) file.path(path, "sys.dic") else path
    info <- file.info(target)
    if (is.na(info$mtime)) NA_character_ else format(info$mtime, tz = "UTC", usetz = TRUE)
  }
  paste(
    effective_sys_dic,
    stamp(effective_sys_dic, directory = TRUE),
    user_dic,
    stamp(user_dic),
    sep = "\r"
  )
}

.check_korean_dictionary <- function(sys_dic = "", user_dic = "") {
  sys_dic <- .check_path(sys_dic, "sys_dic")
  user_dic <- .check_path(user_dic, "user_dic")
  key <- .dictionary_key(sys_dic, user_dic)

  if (exists(key, envir = .rmecabko_state$dictionary_checks, inherits = FALSE)) {
    return(invisible(TRUE))
  }

  info <- tryCatch(
    .engine_dictionary_info(sys_dic = sys_dic, user_dic = user_dic),
    error = function(error) {
      stop(
        "RmecabKo could not load a MeCab dictionary: ", conditionMessage(error),
        ". Install and activate a Korean dictionary with ",
        "RcppMeCab::download_dic(\"ko\") and RcppMeCab::set_dic(\"ko\"), ",
        "or supply its directory through sys_dic. A compatible mecab-ko ",
        "engine is required.",
        call. = FALSE
      )
    }
  )
  probe <- tryCatch(
    .engine_pos(
      enc2utf8("\ud55c\uad6d\uc5b4 \ud615\ud0dc\uc18c \ubd84\uc11d"),
      join = FALSE,
      sys_dic = sys_dic,
      user_dic = user_dic
    ),
    error = function(error) NULL
  )
  if (is.list(probe)) {
    probe <- probe[[1L]]
  }
  tags <- names(probe)

  if (is.null(probe) || !length(probe) ||
      is.null(tags) || !any(tags %in% c("NNG", "NNP"))) {
    filenames <- if (nrow(info)) paste(info$filename, collapse = ", ") else "unknown"
    stop(
      "RmecabKo requires a Korean MeCab dictionary, but the active ",
      "dictionary did not produce Korean POS tags. Loaded dictionary: ",
      filenames, ". Install and activate one with ",
      "RcppMeCab::download_dic(\"ko\") and RcppMeCab::set_dic(\"ko\"), ",
      "or supply its directory through sys_dic. A compatible mecab-ko ",
      "engine is required.",
      call. = FALSE
    )
  }

  assign(key, TRUE, envir = .rmecabko_state$dictionary_checks)
  invisible(TRUE)
}

.as_result_list <- function(result, count) {
  if (count == 1L && !is.list(result)) {
    list(result)
  } else {
    result
  }
}

.call_pos_list <- function(text, join, sys_dic, user_dic, parallel) {
  if (!length(text)) {
    return(list())
  }

  result <- if (parallel && length(text) > 1L) {
    .engine_pos_parallel(
      text, join = join, format = "list",
      sys_dic = sys_dic, user_dic = user_dic
    )
  } else {
    .engine_pos(
      text, join = join, format = "list",
      sys_dic = sys_dic, user_dic = user_dic
    )
  }
  .as_result_list(result, length(text))
}

.pos_list <- function(documents, join, sys_dic, user_dic, parallel) {
  output <- vector("list", length(documents$text))
  valid <- !is.na(documents$text)

  if (any(valid)) {
    parsed <- .call_pos_list(
      documents$text[valid], join, sys_dic, user_dic, parallel
    )
    output[valid] <- parsed
  }
  output[!valid] <- list(NA_character_)
  names(output) <- documents$names
  output
}

.tag_components <- function(tags) {
  strsplit(tags, "+", fixed = TRUE)
}

.matches_keep_pos <- function(tags, keep_pos) {
  if (is.null(keep_pos)) {
    return(rep(TRUE, length(tags)))
  }
  vapply(
    .tag_components(tags),
    function(parts) any(parts %in% keep_pos),
    logical(1)
  )
}

.tokenize_documents <- function(phrase, preset, strip_punct, strip_numeric,
                                keep_pos, sys_dic, user_dic, parallel) {
  documents <- .normalize_documents(phrase)
  .check_korean_dictionary(sys_dic, user_dic)
  tagged <- .pos_list(documents, FALSE, sys_dic, user_dic, parallel)
  punctuation <- c("SF", "SE", "SS", "SSO", "SSC", "SC", "SY", "SW", "SP")

  output <- lapply(tagged, function(tokens) {
    if (length(tokens) == 1L && is.na(tokens)) {
      return(NA_character_)
    }
    tags <- names(tokens)
    keep <- switch(
      preset,
      morph = rep(TRUE, length(tokens)),
      nouns = grepl("^N", tags),
      words = grepl("^[NVMI]", tags) | tags == "SL"
    )
    keep <- keep & .matches_keep_pos(tags, keep_pos)
    if (strip_punct) {
      keep <- keep & !vapply(
        .tag_components(tags),
        function(parts) any(parts %in% punctuation),
        logical(1)
      )
    }
    if (strip_numeric) {
      keep <- keep & !vapply(
        .tag_components(tags),
        function(parts) any(parts == "SN"),
        logical(1)
      )
    }
    unname(tokens[keep])
  })
  names(output) <- documents$names
  output
}

check_input <- function(x) {
  .normalize_documents(x)
  invisible(TRUE)
}
