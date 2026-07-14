#' Manage a MeCab user dictionary from R
#'
#' These functions provide a friendly layer over [RcppMeCab::dict_index()] for
#' teaching the analyzer new words - proper nouns, neologisms, domain terms -
#' without hand-writing `mecab-ko-dic` CSV rows. Words are kept in a named
#' registry in the user data directory, compiled to a binary dictionary, and
#' activated for the current session.
#'
#' `dict_add_words()` appends words and (by default) recompiles.
#' `dict_words()` returns the current registry, `dict_remove_words()` drops
#' entries, `dict_compile()` rebuilds the binary dictionary, `dict_use()`
#' activates it for later calls to [pos()] and the tokenizers, and
#' `dict_path()` returns the path of the compiled dictionary for use with the
#' `user_dic` argument.
#'
#' The left/right context IDs and jongseong (final-consonant) flag required by
#' `mecab-ko-dic` are filled in automatically from the active system
#' dictionary's `left-id.def` and `right-id.def`. Supply `left_id`/`right_id`
#' columns to override them, and tune `cost` (lower costs make a word more
#' likely to be selected).
#'
#' @param words Either a character vector of surface forms or a data frame with
#'   a `surface` column and optional `tag`, `reading`, `meaning`, `cost`,
#'   `left_id`, and `right_id` columns. For `dict_remove_words()`, a character
#'   vector of surfaces to drop.
#' @param tag Default `mecab-ko-dic` POS tag for character-vector input,
#'   typically `"NNP"` (proper noun) or `"NNG"` (common noun).
#' @param reading Optional reading; defaults to the surface form.
#' @param meaning Optional semantic class (the `mecab-ko-dic` semantic field,
#'   for example a personal-name or place-name class); defaults to `"*"`.
#' @param cost Integer cost. Lower values make the word more likely to be
#'   chosen during analysis.
#' @param name Dictionary name, or an absolute path to a dictionary directory
#'   for per-project dictionaries.
#' @param sys_dic Optional Korean system dictionary directory. Defaults to the
#'   active dictionary.
#' @param compile Recompile the binary dictionary after the change.
#' @return `dict_add_words()`, `dict_remove_words()`, and `dict_compile()`
#'   return the registry data frame invisibly; `dict_words()` returns it
#'   visibly. `dict_use()` and `dict_path()` return the compiled dictionary
#'   path.
#' @examples
#' \dontrun{
#' dict_add_words(c("\uc740\uc804\ud55c\ub2e2", "\uce74\ube44\ubd07"), tag = "NNP")
#' dict_use()
#' pos("\uce74\ube44\ubd07 \ucd9c\uc2dc")
#' dict_words()
#' dict_remove_words("\uce74\ube44\ubd07")
#' }
#' @rdname dictionary
#' @export
dict_add_words <- function(words, tag = "NNP", reading = NULL, meaning = NULL,
                           cost = 3000L, name = "user", sys_dic = "",
                           compile = TRUE) {
  additions <- .as_word_frame(words, tag, reading, meaning, cost)
  registry <- .read_registry(name)
  registry <- rbind(registry, additions)
  registry <- registry[!duplicated(registry[c("surface", "tag")],
                                    fromLast = TRUE), , drop = FALSE]
  rownames(registry) <- NULL
  .write_registry(name, registry)
  if (.check_flag(compile, "compile")) {
    dict_compile(name, sys_dic)
  }
  invisible(registry)
}

#' @rdname dictionary
#' @export
dict_words <- function(name = "user") {
  .read_registry(name)
}

#' @rdname dictionary
#' @export
dict_remove_words <- function(words, name = "user", compile = TRUE) {
  if (!is.character(words) || anyNA(words)) {
    stop("words must be a character vector of surfaces", call. = FALSE)
  }
  registry <- .read_registry(name)
  registry <- registry[!registry$surface %in% enc2utf8(words), , drop = FALSE]
  rownames(registry) <- NULL
  .write_registry(name, registry)
  if (.check_flag(compile, "compile")) {
    dict_compile(name, sys_dic = "")
  }
  invisible(registry)
}

#' @rdname dictionary
#' @export
dict_compile <- function(name = "user", sys_dic = "") {
  registry <- .read_registry(name)
  dir <- .dict_dir(name)
  csv_path <- file.path(dir, "words.csv")
  dic_path <- .dict_path(dir)

  if (!nrow(registry)) {
    if (file.exists(dic_path)) {
      unlink(dic_path)
    }
    return(invisible(registry))
  }

  dic_dir <- .effective_sys_dic(.check_path(sys_dic, "sys_dic"))
  if (!nzchar(dic_dir) || !dir.exists(dic_dir)) {
    stop(
      "A Korean system dictionary directory is required to compile a user ",
      "dictionary. Activate one with RcppMeCab::download_dic(\"ko\") and ",
      "RcppMeCab::set_dic(\"ko\"), or pass sys_dic.",
      call. = FALSE
    )
  }

  rows <- .compose_dic_rows(registry, dic_dir)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  writeLines(rows, csv_path, useBytes = TRUE)
  .engine_dict_index(csv_path, dic_path, dic_dir)
  invisible(registry)
}

#' @rdname dictionary
#' @export
dict_use <- function(name = "user") {
  path <- dict_path(name)
  if (!file.exists(path)) {
    stop(
      "No compiled dictionary found for \"", name, "\". ",
      "Add words with dict_add_words() first.",
      call. = FALSE
    )
  }
  options(rmecabko.user_dic = path)
  invisible(path)
}

#' @rdname dictionary
#' @export
dict_path <- function(name = "user") {
  .dict_path(.dict_dir(name))
}

# ---- internals -------------------------------------------------------------

.dict_root <- function() {
  root <- getOption("rmecabko.dict_root")
  if (is.null(root)) {
    root <- .user_data_dir("dictionaries")
  }
  root
}

.is_absolute_path <- function(p) {
  grepl("^(~|/|[A-Za-z]:[\\\\/])", p)
}

.dict_dir <- function(name) {
  if (!is.character(name) || length(name) != 1L || is.na(name) ||
      !nzchar(name)) {
    stop("name must be a non-empty character scalar", call. = FALSE)
  }
  if (.is_absolute_path(name)) name else file.path(.dict_root(), name)
}

.dict_path <- function(dir) {
  file.path(dir, "user.dic")
}

.KNOWN_TAGS <- c(
  "NNG", "NNP", "NNB", "NNBC", "NR", "NP", "VV", "VA", "VX", "VCP", "VCN",
  "MM", "MAG", "MAJ", "IC", "JKS", "JKC", "JKG", "JKO", "JKB", "JKV", "JKQ",
  "JX", "JC", "EP", "EF", "EC", "ETN", "ETM", "XPN", "XSN", "XSV", "XSA",
  "XR", "SF", "SE", "SSO", "SSC", "SC", "SY", "SL", "SH", "SN"
)

.as_word_frame <- function(words, tag, reading, meaning, cost) {
  if (is.data.frame(words)) {
    if (!"surface" %in% names(words)) {
      stop("A data frame input must have a 'surface' column", call. = FALSE)
    }
    frame <- data.frame(surface = as.character(words$surface),
                        stringsAsFactors = FALSE)
    frame$tag <- if ("tag" %in% names(words)) {
      as.character(words$tag)
    } else {
      rep(tag, nrow(frame))
    }
    frame$reading <- if ("reading" %in% names(words)) {
      as.character(words$reading)
    } else {
      NA_character_
    }
    frame$meaning <- if ("meaning" %in% names(words)) {
      as.character(words$meaning)
    } else {
      "*"
    }
    frame$cost <- if ("cost" %in% names(words)) {
      as.integer(words$cost)
    } else {
      as.integer(cost)
    }
    frame$left_id <- if ("left_id" %in% names(words)) {
      as.integer(words$left_id)
    } else {
      NA_integer_
    }
    frame$right_id <- if ("right_id" %in% names(words)) {
      as.integer(words$right_id)
    } else {
      NA_integer_
    }
  } else if (is.character(words)) {
    n <- length(words)
    frame <- data.frame(
      surface = words,
      tag = rep(tag, n),
      reading = if (is.null(reading)) NA_character_ else reading,
      meaning = if (is.null(meaning)) "*" else meaning,
      cost = as.integer(cost),
      left_id = NA_integer_,
      right_id = NA_integer_,
      stringsAsFactors = FALSE
    )
  } else {
    stop("words must be a character vector or a data frame", call. = FALSE)
  }

  frame$surface <- enc2utf8(trimws(frame$surface))
  frame$reading <- enc2utf8(frame$reading)
  frame$meaning <- enc2utf8(ifelse(is.na(frame$meaning), "*", frame$meaning))
  .validate_word_frame(frame)
  frame
}

.validate_word_frame <- function(frame) {
  if (!nrow(frame)) {
    stop("No words supplied", call. = FALSE)
  }
  if (anyNA(frame$surface) || any(!nzchar(frame$surface))) {
    stop("Surfaces must be non-empty", call. = FALSE)
  }
  if (any(grepl("[,\"\n\r]", frame$surface)) ||
      any(grepl("[,\"\n\r]", frame$reading[!is.na(frame$reading)])) ||
      any(grepl("[,\"\n\r]", frame$meaning))) {
    stop(
      "Surfaces, readings, and meanings must not contain commas, quotes, ",
      "or line breaks",
      call. = FALSE
    )
  }
  unknown <- setdiff(frame$tag, .KNOWN_TAGS)
  if (length(unknown)) {
    stop(
      "Unknown mecab-ko-dic tag(s): ", paste(unique(unknown), collapse = ", "),
      call. = FALSE
    )
  }
  if (anyNA(frame$cost)) {
    stop("cost must be an integer", call. = FALSE)
  }
  invisible(TRUE)
}

.registry_path <- function(name) {
  file.path(.dict_dir(name), "registry.rds")
}

.read_registry <- function(name) {
  path <- .registry_path(name)
  if (file.exists(path)) {
    return(readRDS(path))
  }
  data.frame(
    surface = character(), tag = character(), reading = character(),
    meaning = character(), cost = integer(), left_id = integer(),
    right_id = integer(), stringsAsFactors = FALSE
  )
}

.write_registry <- function(name, registry) {
  dir <- .dict_dir(name)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  saveRDS(registry, .registry_path(name))
  invisible(registry)
}

.has_final_consonant <- function(surface) {
  chars <- strsplit(surface, "", fixed = TRUE)
  vapply(chars, function(cs) {
    if (!length(cs)) {
      return("F")
    }
    last <- utf8ToInt(cs[[length(cs)]])
    if (last >= 0xAC00L && last <= 0xD7A3L &&
        (last - 0xAC00L) %% 28L != 0L) {
      "T"
    } else {
      "F"
    }
  }, character(1))
}

.compose_dic_rows <- function(registry, dic_dir) {
  jongseong <- .has_final_consonant(registry$surface)
  reading <- ifelse(is.na(registry$reading) | !nzchar(registry$reading),
                    registry$surface, registry$reading)
  meaning <- ifelse(is.na(registry$meaning) | !nzchar(registry$meaning),
                    "*", registry$meaning)

  left <- registry$left_id
  right <- registry$right_id
  for (i in seq_len(nrow(registry))) {
    if (is.na(left[i]) || is.na(right[i])) {
      ids <- .resolve_context_ids(registry$tag[i], jongseong[i], dic_dir)
      if (is.na(left[i])) left[i] <- ids[["left"]]
      if (is.na(right[i])) right[i] <- ids[["right"]]
    }
  }

  paste(
    registry$surface, left, right, registry$cost, registry$tag, meaning,
    jongseong, reading, "*", "*", "*", "*",
    sep = ","
  )
}

.resolve_context_ids <- function(tag, jongseong, dic_dir) {
  defs <- .load_id_defs(dic_dir)
  left_id <- .lookup_context_id(defs$left, tag, jongseong)
  right_id <- .lookup_context_id(defs$right, tag, jongseong)

  if (is.na(left_id) || is.na(right_id)) {
    fallback <- .CONTEXT_ID_FALLBACK[[tag]]
    if (!is.null(fallback)) {
      if (is.na(left_id)) left_id <- fallback[["left"]]
      if (is.na(right_id)) {
        right_id <- if (jongseong == "T") fallback[["right_t"]] else
          fallback[["right_f"]]
      }
    }
  }

  if (is.na(left_id) || is.na(right_id)) {
    stop(
      "Could not resolve context IDs for tag '", tag, "'. Supply left_id and ",
      "right_id columns explicitly.",
      call. = FALSE
    )
  }
  c(left = as.integer(left_id), right = as.integer(right_id))
}

.load_id_defs <- function(dic_dir) {
  cache <- .rmecabko_state$id_defs
  if (exists(dic_dir, envir = cache, inherits = FALSE)) {
    return(get(dic_dir, envir = cache, inherits = FALSE))
  }
  defs <- list(
    left = .read_id_def(file.path(dic_dir, "left-id.def")),
    right = .read_id_def(file.path(dic_dir, "right-id.def"))
  )
  assign(dic_dir, defs, envir = cache)
  defs
}

.read_id_def <- function(path) {
  if (!file.exists(path)) {
    return(NULL)
  }
  lines <- readLines(path, encoding = "UTF-8", warn = FALSE)
  lines <- lines[grepl("^[0-9]+ ", lines)]
  if (!length(lines)) {
    return(NULL)
  }
  id <- as.integer(sub("^([0-9]+) .*$", "\\1", lines))
  pattern <- sub("^[0-9]+ ", "", lines)
  fields <- strsplit(pattern, ",", fixed = TRUE)
  tag <- vapply(fields, function(f) f[[1L]], character(1))
  jongseong <- vapply(
    fields, function(f) if (length(f) >= 3L) f[[3L]] else "*", character(1)
  )
  # A generic entry wildcards every field except tag and jongseong.
  generic <- vapply(fields, function(f) {
    others <- f[-c(1L, 3L)]
    !length(others) || all(others == "*")
  }, logical(1))
  data.frame(id = id, tag = tag, jongseong = jongseong, generic = generic,
             stringsAsFactors = FALSE)
}

.lookup_context_id <- function(def, tag, jongseong) {
  if (is.null(def)) {
    return(NA_integer_)
  }
  cand <- def[def$tag == tag & def$generic, , drop = FALSE]
  if (!nrow(cand)) {
    return(NA_integer_)
  }
  exact <- cand$id[cand$jongseong == jongseong]
  if (length(exact)) {
    return(exact[[1L]])
  }
  star <- cand$id[cand$jongseong == "*"]
  if (length(star)) {
    return(star[[1L]])
  }
  NA_integer_
}

# Harvested from mecab-ko-dic 2.1.1 left-id.def / right-id.def; used only when
# the active dictionary does not ship the .def source files.
.CONTEXT_ID_FALLBACK <- list(
  NNG = list(left = 1780L, right_f = 3533L, right_t = 3534L),
  NNP = list(left = 1786L, right_f = 3545L, right_t = 3546L),
  NNB = list(left = 761L, right_f = 2686L, right_t = 2751L),
  NNBC = list(left = 1040L, right_f = 2855L, right_t = 3216L),
  NP = list(left = 1790L, right_f = 3554L, right_t = 3555L),
  NR = list(left = 1791L, right_f = 3556L, right_t = 3557L),
  VV = list(left = 2420L, right_f = 3577L, right_t = 3578L),
  VA = list(left = 1804L, right_f = 3571L, right_t = 3572L),
  VX = list(left = 2421L, right_f = 3579L, right_t = 3580L),
  MAG = list(left = 726L, right_f = 2633L, right_t = 2634L),
  MAJ = list(left = 739L, right_f = 2655L, right_t = 2656L),
  MM = list(left = 740L, right_f = 2657L, right_t = 2658L),
  IC = list(left = 196L, right_f = 14L, right_t = 15L),
  XR = list(left = 2423L, right_f = 3583L, right_t = 3584L)
)
