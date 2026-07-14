#' Recover dictionary forms of Korean predicates
#'
#' Reconstructs the dictionary (citation) form of verbs and adjectives from
#' MeCab morphemes by appending the terminal ending to a predicate stem, and by
#' recombining a noun root with a following derivational suffix into a single
#' predicate. This is useful for frequency counts and for matching against a
#' sentiment lexicon, where inflected surfaces would otherwise scatter.
#'
#' MeCab sometimes fuses a stem and its ending into a single token (tagged, for
#' example, `VV+EP` or `VA+ETM`). Because [RcppMeCab::pos()] does not expose the
#' underlying morpheme decomposition, the original stem cannot be recovered for
#' these fused tokens, and their `lemma` is returned as `NA`.
#'
#' @param tokens A named character vector of morphemes with POS tags as names,
#'   as produced by `pos(x, join = FALSE)[[i]]`.
#' @param combine_root Recombine a noun root immediately before a derivational
#'   suffix (`XSV`/`XSA`) into a single predicate lemma.
#' @return A data frame with columns `surface`, `tag`, and `lemma` (the
#'   dictionary form, or `NA` when it cannot be recovered).
#' @seealso [token_lemma()]
#' @examples
#' \dontrun{
#' lemmatize_morphemes(pos("\uba39\uc5c8\ub2e4", join = FALSE)[[1]])
#' }
#' @export
lemmatize_morphemes <- function(tokens, combine_root = TRUE) {
  combine_root <- .check_flag(combine_root, "combine_root")
  surfaces <- unname(tokens)
  tags <- names(tokens)
  if (is.null(tags)) {
    tags <- rep(NA_character_, length(surfaces))
  }

  n <- length(surfaces)
  lemma <- rep(NA_character_, n)
  for (i in seq_len(n)) {
    tag <- tags[[i]]
    if (is.na(tag)) {
      next
    }
    if (tag %in% .PREDICATE_TAGS) {
      lemma[[i]] <- paste0(surfaces[[i]], "\ub2e4")
    } else if (tag %in% .DERIVATIONAL_TAGS) {
      if (combine_root && i > 1L && !is.na(tags[[i - 1L]]) &&
          tags[[i - 1L]] %in% .NOUN_ROOT_TAGS) {
        lemma[[i]] <- paste0(surfaces[[i - 1L]], surfaces[[i]], "\ub2e4")
      } else {
        lemma[[i]] <- paste0(surfaces[[i]], "\ub2e4")
      }
    }
  }

  data.frame(
    surface = surfaces, tag = tags, lemma = enc2utf8(lemma),
    stringsAsFactors = FALSE
  )
}

#' Tokenize Korean text into predicate dictionary forms
#'
#' Analyzes text and returns the dictionary forms of its predicates (verbs and
#' adjectives), following the [tokenizers][token_morph] contract. Fused tokens
#' whose stem cannot be recovered are dropped; see [lemmatize_morphemes()] for
#' the token-level detail and limitations.
#'
#' @param phrase A character vector or list of character scalars.
#' @param keep POS tags whose lemmas to keep. Compound tags match on their
#'   first component.
#' @param combine_root Recombine a noun root with a following derivational
#'   suffix into one predicate lemma.
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use parallel analysis for multiple documents.
#' @param simplify When `TRUE` and a single document is supplied, return a bare
#'   character vector instead of a length-one list.
#' @return A list of character vectors of predicate lemmas, named when the
#'   input is named.
#' @seealso [lemmatize_morphemes()]
#' @examples
#' \dontrun{
#' token_lemma(c("\uc544\uce68\uc744 \uba39\uc5c8\ub2e4",
#'               "\ub0a0\uc528\uac00 \uc88b\uc558\ub2e4"))
#' }
#' @export
token_lemma <- function(phrase,
                        keep = c("VV", "VA", "VX", "VCP", "VCN", "XSV", "XSA"),
                        combine_root = TRUE, sys_dic = "", user_dic = "",
                        parallel = FALSE, simplify = FALSE) {
  if (!is.character(keep) || anyNA(keep)) {
    stop("keep must be a character vector", call. = FALSE)
  }
  combine_root <- .check_flag(combine_root, "combine_root")
  tagged <- pos(
    phrase, join = FALSE, format = "list",
    sys_dic = .check_path(sys_dic, "sys_dic"),
    user_dic = .check_path(user_dic, "user_dic"),
    parallel = .check_flag(parallel, "parallel")
  )

  lemmas <- lapply(tagged, function(tokens) {
    if (length(tokens) == 1L && is.na(tokens)) {
      return(NA_character_)
    }
    table <- lemmatize_morphemes(tokens, combine_root)
    first <- vapply(
      strsplit(table$tag, "+", fixed = TRUE),
      function(parts) parts[[1L]], character(1)
    )
    keep_row <- first %in% keep & !is.na(table$lemma)
    table$lemma[keep_row]
  })
  names(lemmas) <- names(tagged)
  .simplify_list(lemmas, .check_flag(simplify, "simplify"))
}

.PREDICATE_TAGS <- c("VV", "VA", "VX", "VCP", "VCN")
.DERIVATIONAL_TAGS <- c("XSV", "XSA")
.NOUN_ROOT_TAGS <- c("NNG", "NNP", "NR", "XR")
