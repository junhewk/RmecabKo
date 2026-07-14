#' Keyword extraction with TF-IDF
#'
#' Ranks the morphemes of each document by term frequency-inverse document
#' frequency over the supplied corpus. Tokens are produced with one of the
#' Korean presets, so keywords are morphologically normalized rather than raw
#' whitespace tokens.
#'
#' @param phrase A character vector or list of character scalars.
#' @param div Token preset: nouns, content words, or all morphemes.
#' @param top_n Number of keywords to keep per document, ranked by TF-IDF. Use
#'   `Inf` for all terms.
#' @param stopwords Character tokens to drop before scoring. Combine with
#'   [stopwords_ko_words()].
#' @param sys_dic Optional Korean system dictionary directory.
#' @param user_dic Optional compiled user dictionary.
#' @param parallel Use parallel analysis for multiple documents.
#' @return A data frame with columns `doc`, `word`, `n` (count), `tf`, `idf`,
#'   and `tf_idf`, ordered by document and descending TF-IDF.
#' @seealso [keywords_textrank()]
#' @examples
#' \dontrun{
#' docs <- c("\ud55c\uad6d\uc5b4 \ubd84\uc11d\uc740 \uc7ac\ubbf8\uc788\ub2e4",
#'           "\ubd84\uc11d \ub3c4\uad6c\uac00 \ud544\uc694\ud558\ub2e4")
#' keywords_tfidf(docs)
#' }
#' @export
keywords_tfidf <- function(phrase, div = c("nouns", "words", "morph"),
                           top_n = 10L, stopwords = character(),
                           sys_dic = "", user_dic = "", parallel = FALSE) {
  div <- match.arg(div)
  top_n <- .validate_top_n(top_n)
  counts <- .document_term_counts(
    phrase, div, stopwords, sys_dic, user_dic, parallel
  )
  n_docs <- length(counts)

  document_freq <- table(unlist(lapply(counts, function(d) d$word)))

  frames <- lapply(names(counts), function(doc) {
    d <- counts[[doc]]
    if (is.null(d) || !nrow(d)) {
      return(NULL)
    }
    tf <- d$n / sum(d$n)
    idf <- log(n_docs / as.integer(document_freq[d$word]))
    tf_idf <- tf * idf
    frame <- data.frame(
      doc = doc, word = d$word, n = d$n, tf = tf, idf = idf,
      tf_idf = tf_idf, stringsAsFactors = FALSE
    )
    frame <- frame[order(-frame$tf_idf, -frame$n, frame$word), , drop = FALSE]
    utils::head(frame, top_n)
  })

  result <- do.call(rbind, frames)
  if (is.null(result)) {
    result <- data.frame(
      doc = character(), word = character(), n = integer(),
      tf = numeric(), idf = numeric(), tf_idf = numeric(),
      stringsAsFactors = FALSE
    )
  }
  rownames(result) <- NULL
  result
}

#' Keyword extraction with TextRank
#'
#' Ranks morphemes within each document using the TextRank graph algorithm:
#' tokens that co-occur within a sliding window vote for one another, and the
#' stationary scores of the resulting graph surface the most central terms.
#' Unlike [keywords_tfidf()], TextRank scores each document on its own and needs
#' no reference corpus.
#'
#' @inheritParams keywords_tfidf
#' @param window Co-occurrence window width in tokens.
#' @param damping Damping factor for the random-walk model.
#' @param iter Maximum number of power-iteration steps.
#' @return A data frame with columns `doc`, `word`, and `score`, ordered by
#'   document and descending score.
#' @seealso [keywords_tfidf()]
#' @examples
#' \dontrun{
#' text <- paste("\ud55c\uad6d\uc5b4 \ubd84\uc11d \ub3c4\uad6c\ub294",
#'               "\ud55c\uad6d\uc5b4 \ucc98\ub9ac\ub97c \ub3d5\ub294\ub2e4")
#' keywords_textrank(text)
#' }
#' @export
keywords_textrank <- function(phrase, div = c("nouns", "words", "morph"),
                              top_n = 10L, window = 2L, stopwords = character(),
                              damping = 0.85, iter = 30L, sys_dic = "",
                              user_dic = "", parallel = FALSE) {
  div <- match.arg(div)
  top_n <- .validate_top_n(top_n)
  window <- .validate_integer_values(window, "window", minimum = 1L)[[1L]]
  iter <- .validate_integer_values(iter, "iter", minimum = 1L)[[1L]]
  if (!is.numeric(damping) || length(damping) != 1L || is.na(damping) ||
      damping <= 0 || damping >= 1) {
    stop("damping must be a single number in (0, 1)", call. = FALSE)
  }

  tokens <- .keyword_tokens(phrase, div, sys_dic, user_dic, parallel)
  if (is.null(names(tokens))) {
    names(tokens) <- as.character(seq_along(tokens))
  }
  stopwords <- unique(enc2utf8(stopwords))

  frames <- lapply(names(tokens), function(doc) {
    terms <- tokens[[doc]]
    if (length(terms) == 1L && is.na(terms)) {
      return(NULL)
    }
    terms <- terms[!terms %in% stopwords]
    scores <- .textrank_scores(terms, window, damping, iter)
    if (is.null(scores)) {
      return(NULL)
    }
    frame <- data.frame(
      doc = doc, word = names(scores), score = as.numeric(scores),
      stringsAsFactors = FALSE
    )
    frame <- frame[order(-frame$score, frame$word), , drop = FALSE]
    utils::head(frame, top_n)
  })

  result <- do.call(rbind, frames)
  if (is.null(result)) {
    result <- data.frame(
      doc = character(), word = character(), score = numeric(),
      stringsAsFactors = FALSE
    )
  }
  rownames(result) <- NULL
  result
}

.validate_top_n <- function(top_n) {
  if (identical(top_n, Inf)) {
    return(.Machine$integer.max)
  }
  .validate_integer_values(top_n, "top_n", minimum = 1L)[[1L]]
}

.keyword_tokens <- function(phrase, div, sys_dic, user_dic, parallel) {
  switch(
    div,
    nouns = token_nouns(phrase, sys_dic = sys_dic, user_dic = user_dic,
                        parallel = parallel),
    words = token_words(phrase, sys_dic = sys_dic, user_dic = user_dic,
                        parallel = parallel),
    morph = token_morph(phrase, sys_dic = sys_dic, user_dic = user_dic,
                        parallel = parallel)
  )
}

.document_term_counts <- function(phrase, div, stopwords, sys_dic, user_dic,
                                  parallel) {
  tokens <- .keyword_tokens(phrase, div, sys_dic, user_dic, parallel)
  stopwords <- unique(enc2utf8(stopwords))
  if (is.null(names(tokens))) {
    names(tokens) <- as.character(seq_along(tokens))
  }
  lapply(tokens, function(terms) {
    if (length(terms) == 1L && is.na(terms)) {
      return(NULL)
    }
    terms <- terms[!terms %in% stopwords]
    if (!length(terms)) {
      return(NULL)
    }
    tab <- table(terms)
    data.frame(
      word = names(tab), n = as.integer(tab), stringsAsFactors = FALSE
    )
  })
}

.textrank_scores <- function(terms, window, damping, iter) {
  vocab <- unique(terms)
  v <- length(vocab)
  if (v == 0L) {
    return(NULL)
  }
  if (v == 1L) {
    return(stats::setNames(1, vocab))
  }

  index <- match(terms, vocab)
  weight <- matrix(0, nrow = v, ncol = v)
  n <- length(index)
  for (i in seq_len(n)) {
    hi <- min(n, i + window)
    j <- i + 1L
    while (j <= hi) {
      a <- index[[i]]
      b <- index[[j]]
      if (a != b) {
        weight[a, b] <- weight[a, b] + 1
        weight[b, a] <- weight[b, a] + 1
      }
      j <- j + 1L
    }
  }

  degree <- colSums(weight)
  degree[degree == 0] <- 1
  transition <- sweep(weight, 2L, degree, "/")

  score <- rep(1, v)
  for (step in seq_len(iter)) {
    updated <- (1 - damping) + damping * as.numeric(transition %*% score)
    if (max(abs(updated - score)) < 1e-6) {
      score <- updated
      break
    }
    score <- updated
  }
  stats::setNames(score, vocab)
}
