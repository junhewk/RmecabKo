# RmecabKo

`RmecabKo`는 [`RcppMeCab`](https://cran.r-project.org/package=RcppMeCab)와
`mecab-ko-dic`을 기반으로 한 R용 한국어 텍스트 분석 도구입니다. `tidytext`와
바로 연결되는 토크나이저, 선별된 한국어 불용어 데이터, KNU 감성 사전 접근,
사용자 사전 관리, 용언 원형 복원, 키워드 추출, 문맥 색인(KWIC), 텍스트 정규화를
제공합니다.

**RmecabKo는 CRAN에 등록되어 활발히 유지 관리되는 유일한 한국어 텍스트 분석
전용 패키지입니다.** 한국어 전용 대안들은 CRAN에서 사라졌습니다. `KoNLP`는
2020년에, `elbird`(Kiwi 바인딩)는 2023년에 아카이브되었습니다. 따라서 네이티브
엔진인 `RcppMeCab`(같은 저자)과 그 위의 분석 계층인 `RmecabKo`가
`install.packages()`로 설치할 수 있는 한국어 자연어 처리 경로입니다.

## 0.3.0의 새로운 기능

- **tidytext 호환 토크나이저.** `token_morph()`, `token_words()`,
  `token_nouns()`, `token_ngrams()`가 `tokenizers` 규약을 따르므로
  `tidytext::unnest_tokens(token = ...)`에 그대로 사용할 수 있습니다. `simplify`,
  `drop_pos` 인자가 추가되었습니다.
- **한국어 데이터.** 품사 태그가 붙은 불용어 표 `stopwords_ko`와 접근 함수
  `stopwords_ko_words()` / `stopwords_ko_tags()`, KNU 감성 사전을 내려받는
  `lexicon_knu()`.
- **사용자 사전.** `dict_add_words()` 등으로 R에서 새 단어를 등록하며,
  `mecab-ko-dic`의 문맥 ID와 종성 유무를 자동으로 채웁니다.
- **분석 도우미.** `token_lemma()`(용언 원형), `keywords_tfidf()` /
  `keywords_textrank()`, `kwic()`, `text_normalize()`.
- 전체 tidy 워크플로를 다루는 `vignette("korean-text-analysis")`를 제공합니다.

## 설치와 기본 사용법

```r
install.packages("RmecabKo")
library(RmecabKo)

text <- c(
  문서1 = "한국어 형태소 분석을 합니다.",
  문서2 = "R에서도 빠르게 처리할 수 있습니다."
)

pos(text)
nouns(text)
words(text)
token_morph(text, strip_punct = TRUE)
token_ngrams(text, n = 1:3, skip = 0:1, div = "words")
```

활성화된 한국어 사전이 없다면 다음과 같이 설치하고 선택할 수 있습니다.

```r
RcppMeCab::download_dic("ko")
RcppMeCab::set_dic("ko")
```

한국어 분석에는 호환되는 `mecab-ko` 엔진이 필요합니다. 표준 일본어 MeCab
엔진에서 한국어 사전만 선택해도 한국어 엔진으로 바뀌지는 않습니다. 기존
`mecab-ko-dic` 설치 경로가 있다면 `sys_dic`으로 전달할 수 있습니다. 일본어
사전이 선택된 경우 잘못된 결과를 반환하지 않고 한국어 사전이 필요하다는 오류를
표시합니다.

토크나이저는 입력 문서마다 하나의 문자열 벡터를 담은 리스트를 반환합니다.
이름이 있는 입력은 이름을 유지하고, 이름이 없는 입력은 이름 없는 리스트를
반환합니다(`tokenizers` 규약).

## tidytext, 데이터, 분석 도우미

```r
library(dplyr)
library(tidytext)

tibble(doc = names(demo_ko), text = demo_ko) |>
  unnest_tokens(word, text, token = token_nouns) |>
  anti_join(data.frame(word = stopwords_ko_words()), by = "word") |>
  count(doc, word, sort = TRUE)

keywords_tfidf(demo_ko, div = "nouns")       # TF-IDF 키워드
token_lemma("아침을 먹었다")                  # 용언 원형
kwic(demo_ko, "분석")                         # 문맥 색인
text_normalize("분석 ㅋㅋㅋㅋ 재밌어요!!!!")  # NFC, 전각/반각, 반복 문자 축약
lexicon_knu()                                 # KNU 감성 사전
```

`lexicon_knu()`가 내려받는 KNU 감성 사전은 CC BY-NC-SA(경북대학교) 라이선스로
배포되므로 패키지에 포함하지 않고 필요할 때 원본에서 내려받습니다. 비영리
조항에 유의하고 사용 전에 약관을 확인하십시오.

## 사용자 사전

`mecab-ko-dic` CSV를 직접 작성하지 않고 R에서 새 단어를 등록할 수 있습니다.
`RmecabKo`가 문맥 ID와 종성 유무를 채우고 `RcppMeCab`으로 컴파일한 뒤 세션에
활성화합니다.

```r
dict_add_words(c("은전한닢", "카비봇"), tag = "NNP")
dict_use()
pos("카비봇 출시 소식")
dict_words()
dict_remove_words("카비봇")
```

`reading`, `meaning`, `cost`를 세밀하게 지정하려면 데이터 프레임을 전달하고,
자동 조회를 재정의하려면 `left_id` / `right_id`를 지정하십시오. 현재 로드된
사전은 `RcppMeCab::dictionary_info()`로 확인할 수 있습니다.

자세한 내용은 `vignette("korean-text-analysis")`를 참고하십시오.
