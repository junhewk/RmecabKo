# Build the curated Korean stopword table shipped as `stopwords_ko`.
#
# Each row is a function morpheme that is usually dropped before content
# analysis, tagged with its typical mecab-ko-dic part-of-speech tag and grouped
# into a coarse category. The `word` column holds the morpheme surface (for
# surface-level anti_join / stopwords = ), and the `tag` column drives
# tag-level filtering through stopwords_ko_tags() / drop_pos = .
#
# Run with: Rscript data-raw/stopwords_ko.R

make_rows <- function(category, ...) {
  pairs <- list(...)
  words <- vapply(pairs, `[[`, character(1), 1L)
  tags <- vapply(pairs, `[[`, character(1), 2L)
  data.frame(word = words, tag = tags, category = category,
             stringsAsFactors = FALSE)
}
p <- function(word, tag) c(word, tag)

josa <- make_rows(
  "josa",
  p("은", "JX"), p("는", "JX"), p("이", "JKS"), p("가", "JKS"),
  p("께서", "JKS"), p("을", "JKO"), p("를", "JKO"),
  p("의", "JKG"), p("에", "JKB"), p("에서", "JKB"),
  p("에게", "JKB"), p("께", "JKB"), p("한테", "JKB"),
  p("로", "JKB"), p("으로", "JKB"), p("와", "JKB"),
  p("과", "JKB"), p("처럼", "JKB"), p("같이", "JKB"),
  p("보다", "JKB"), p("만큼", "JKB"), p("대로", "JKB"),
  p("도", "JX"), p("만", "JX"), p("까지", "JX"),
  p("부터", "JX"), p("조차", "JX"), p("마저", "JX"),
  p("밖에", "JX"), p("이나", "JX"), p("나", "JX"),
  p("이라도", "JX"), p("라도", "JX"), p("이든", "JX"),
  p("든지", "JX"), p("추", "JX"), p("에게서", "JKB"),
  p("한테서", "JKB"), p("이랑", "JC"), p("랑", "JC"),
  p("이며", "JC"), p("며", "JC"), p("하고", "JKB"),
  p("이라고", "JKQ"), p("라고", "JKQ"), p("고", "JKQ"),
  p("아", "JKV"), p("야", "JKV"), p("이여", "JKV")
)

eomi <- make_rows(
  "eomi",
  p("다", "EF"), p("라", "EF"), p("요", "EF"), p("죠", "EF"),
  p("지", "EF"), p("니다", "EF"), p("습니다", "EF"),
  p("는다", "EF"), p("자", "EF"), p("니", "EF"),
  p("까", "EF"), p("네", "EF"), p("구나", "EF"),
  p("고", "EC"), p("며", "EC"), p("면서", "EC"),
  p("서", "EC"), p("어서", "EC"), p("아서", "EC"),
  p("니까", "EC"), p("으니까", "EC"), p("는데", "EC"),
  p("은데", "EC"), p("지만", "EC"), p("거나", "EC"),
  p("려고", "EC"), p("면", "EC"), p("으면", "EC"),
  p("어야", "EC"), p("아야", "EC"), p("게", "EC"),
  p("도록", "EC"), p("든", "EC"), p("어", "EC"),
  p("아", "EC"), p("면서도", "EC"),
  p("ㄴ", "ETM"), p("은", "ETM"), p("는", "ETM"), p("을", "ETM"),
  p("ㄹ", "ETM"), p("던", "ETM"), p("음", "ETN"), p("기", "ETN"),
  p("았", "EP"), p("었", "EP"), p("였", "EP"), p("겠", "EP"),
  p("시", "EP"), p("더", "EP")
)

suffix <- make_rows(
  "suffix",
  p("들", "XSN"), p("님", "XSN"), p("씨", "XSN"), p("적", "XSN"),
  p("성", "XSN"), p("화", "XSN"), p("째", "XSN"), p("쯤", "XSN"),
  p("여", "XSN"), p("하", "XSV"), p("되", "XSV"),
  p("시키", "XSV"), p("당하", "XSV"), p("스럽", "XSA"),
  p("답", "XSA"), p("롭", "XSA")
)

formal_noun <- make_rows(
  "formal_noun",
  p("것", "NNB"), p("수", "NNB"), p("데", "NNB"), p("등", "NNB"),
  p("뿐", "NNB"), p("채", "NNB"), p("줄", "NNB"), p("바", "NNB"),
  p("리", "NNB"), p("터", "NNB"), p("참", "NNB"), p("지", "NNB"),
  p("나름", "NNB"), p("따름", "NNB"), p("거", "NNB"),
  p("년", "NNBC"), p("개", "NNBC"), p("명", "NNBC"),
  p("원", "NNBC"), p("번", "NNBC"), p("분", "NNBC"),
  p("살", "NNBC"), p("시", "NNBC"), p("장", "NNBC")
)

function_word <- make_rows(
  "function_word",
  p("및", "MAJ"), p("즉", "MAJ"), p("그리고", "MAJ"),
  p("그러나", "MAJ"), p("그런데", "MAJ"),
  p("그래서", "MAJ"), p("하지만", "MAJ"),
  p("또는", "MAJ"), p("또한", "MAJ"), p("따라서", "MAJ"),
  p("그러므로", "MAJ"), p("혹은", "MAJ"),
  p("이", "MM"), p("그", "MM"), p("저", "MM"), p("어떤", "MM"),
  p("무슨", "MM"), p("이런", "MM"), p("그런", "MM"),
  p("저런", "MM"), p("이", "NP"), p("그", "NP"), p("저", "NP"),
  p("저희", "NP"), p("우리", "NP"), p("나", "NP"),
  p("너", "NP"), p("그것", "NP"), p("무엇", "NP"),
  p("여기", "NP"), p("거기", "NP")
)

stopwords_ko <- rbind(josa, eomi, suffix, formal_noun, function_word)
stopwords_ko$word <- enc2utf8(stopwords_ko$word)
Encoding(stopwords_ko$word) <- "UTF-8"
stopwords_ko$category <- factor(
  stopwords_ko$category,
  levels = c("josa", "eomi", "suffix", "formal_noun", "function_word")
)
stopwords_ko <- stopwords_ko[!duplicated(stopwords_ko[c("word", "tag")]), ]
rownames(stopwords_ko) <- NULL

save(stopwords_ko,
     file = file.path("data", "stopwords_ko.rda"),
     version = 2, compress = "xz")
message(sprintf("stopwords_ko: %d rows", nrow(stopwords_ko)))
