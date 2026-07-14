pkgname <- "RmecabKo"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "RmecabKo-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('RmecabKo')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("dictionary")
### * dictionary

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: dict_add_words
### Title: Manage a MeCab user dictionary from R
### Aliases: dict_add_words dict_words dict_remove_words dict_compile
###   dict_use dict_path

### ** Examples

## Not run: 
##D dict_add_words(c("\uc740\uc804\ud55c\ub2e2", "\uce74\ube44\ubd07"), tag = "NNP")
##D dict_use()
##D pos("\uce74\ube44\ubd07 \ucd9c\uc2dc")
##D dict_words()
##D dict_remove_words("\uce74\ube44\ubd07")
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("dictionary", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("keywords_textrank")
### * keywords_textrank

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: keywords_textrank
### Title: Keyword extraction with TextRank
### Aliases: keywords_textrank

### ** Examples

## Not run: 
##D text <- paste("\ud55c\uad6d\uc5b4 \ubd84\uc11d \ub3c4\uad6c\ub294",
##D               "\ud55c\uad6d\uc5b4 \ucc98\ub9ac\ub97c \ub3d5\ub294\ub2e4")
##D keywords_textrank(text)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("keywords_textrank", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("keywords_tfidf")
### * keywords_tfidf

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: keywords_tfidf
### Title: Keyword extraction with TF-IDF
### Aliases: keywords_tfidf

### ** Examples

## Not run: 
##D docs <- c("\ud55c\uad6d\uc5b4 \ubd84\uc11d\uc740 \uc7ac\ubbf8\uc788\ub2e4",
##D           "\ubd84\uc11d \ub3c4\uad6c\uac00 \ud544\uc694\ud558\ub2e4")
##D keywords_tfidf(docs)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("keywords_tfidf", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("kwic")
### * kwic

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: kwic
### Title: Keyword-in-context concordance
### Aliases: kwic

### ** Examples

## Not run: 
##D docs <- c("\ud55c\uad6d\uc5b4 \ubd84\uc11d\uc740 \uc990\uac81\ub2e4",
##D           "\ud55c\uad6d\uc5b4 \uacf5\ubd80\ub294 \uc5b4\ub835\ub2e4")
##D kwic(docs, "\ud55c\uad6d\uc5b4")
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("kwic", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("lemmatize_morphemes")
### * lemmatize_morphemes

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: lemmatize_morphemes
### Title: Recover dictionary forms of Korean predicates
### Aliases: lemmatize_morphemes

### ** Examples

## Not run: 
##D lemmatize_morphemes(pos("\uba39\uc5c8\ub2e4", join = FALSE)[[1]])
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("lemmatize_morphemes", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("lexicon_knu")
### * lexicon_knu

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: lexicon_knu
### Title: Korean sentiment lexicon (KNU)
### Aliases: lexicon_knu

### ** Examples

## Not run: 
##D senti <- lexicon_knu()
##D # keep single-morpheme entries only
##D senti[senti$n_words == 1L, ]
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("lexicon_knu", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("stopwords_ko_tags")
### * stopwords_ko_tags

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: stopwords_ko_tags
### Title: Korean stopword POS tags
### Aliases: stopwords_ko_tags

### ** Examples

stopwords_ko_tags("josa")



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("stopwords_ko_tags", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("stopwords_ko_words")
### * stopwords_ko_words

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: stopwords_ko_words
### Title: Korean stopword surfaces
### Aliases: stopwords_ko_words

### ** Examples

head(stopwords_ko_words())
stopwords_ko_words("josa")



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("stopwords_ko_words", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("text_normalize")
### * text_normalize

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: text_normalize
### Title: Normalize Korean text before tokenizing
### Aliases: text_normalize

### ** Examples

text_normalize("\ubd84\uc11d \u314b\u314b\u314b\u314b \uc7ac\ubc0c\uc5b4\uc694!!!!")
text_normalize("\uff21\uff22\uff23\uff11\uff12\uff13", width = "halfwidth")



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("text_normalize", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("token_lemma")
### * token_lemma

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: token_lemma
### Title: Tokenize Korean text into predicate dictionary forms
### Aliases: token_lemma

### ** Examples

## Not run: 
##D token_lemma(c("\uc544\uce68\uc744 \uba39\uc5c8\ub2e4",
##D               "\ub0a0\uc528\uac00 \uc88b\uc558\ub2e4"))
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("token_lemma", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("token_ngrams")
### * token_ngrams

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: token_ngrams
### Title: Korean morpheme n-grams and skip-grams
### Aliases: token_ngrams

### ** Examples

## Not run: 
##D text <- "\ud55c\uad6d\uc5b4 \ud615\ud0dc\uc18c \ubd84\uc11d\uc744 \ud569\ub2c8\ub2e4"
##D token_ngrams(text, n = 2)
##D token_ngrams(text, n = 2:3, skip = 0:1)
## End(Not run)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("token_ngrams", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
