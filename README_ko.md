# RmecabKo

`RmecabKo`는 `RcppMeCab`을 기반으로 한국어 텍스트를 분석하는 R
패키지입니다. MeCab 빌드와 사전 컴파일은 `RcppMeCab`이 담당하고,
이 패키지는 한국어 품사 확인, 명사·내용어 추출, 형태소 토큰화와
n-gram/skip-gram 생성을 제공합니다.

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

일본어 사전이 선택된 경우 잘못된 결과를 반환하지 않고 한국어 사전이
필요하다는 오류를 표시합니다.

## 사용자 사전

사용자 사전 컴파일은 `RcppMeCab::dict_index()`를 사용합니다.

```r
RcppMeCab::dict_index(
  dic_csv = "user-words.csv",
  out_dic = "user-words.dic",
  dic_dir = getOption("mecabSysDic")
)

pos("새로 등록한 단어", user_dic = normalizePath("user-words.dic"))
```

고유명사 CSV 항목의 예시는 다음과 같습니다.

```text
새단어,,,,NNP,*,F,새단어,*,*,*,*
```

`sys_dic`과 `user_dic`에는 전체 경로를 사용하십시오.
