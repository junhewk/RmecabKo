## RMecabKo [![License](http://img.shields.io/badge/license-GPL%20%28%3E=%202%29-brightgreen.svg?style=flat)](http://www.gnu.org/licenses/gpl-2.0.html)

[은전한닢 프로젝트](http://eunjeon.blogspot.com/) `mecab-ko`의 R wrapper입니다.

### About

은전한닢 프로젝트가 기반으로 하고 있는 `mecab`은 일본어 형태소 분석기로, 띄어쓰기와 관계없이 형태소를 분석합니다. 인터넷에서 수집한 텍스트는 띄어쓰기에 오류가 있는 경우가 많아, 텍스트 분석을 진행할 때 은전한닢 프로젝트의 `mecab-ko`를 통해 진행하는 것이 유용한 경우가 있습니다.

이 패키지는 `mecab-ko` 및 `mecab-ko-dic`이 설치된 **Mac OS**와 **Linux** 기반 시스템에서 작동하는 은전한닢 프로젝트의 R wrapper입니다. [Rcpp](http://dirk.eddelbuettel.com/code/rcpp.html)를 통해 제작했습니다. C++에서 직접 동작하므로 다른 형태소 분석기에 비해 상당히 빠릅니다.

### Installation

아직 손 볼 부분이 많이 있습니다. 먼저 `mecab-ko`와 `mecab-ko-dic`을 설치합니다.

* [mecab-ko](https://bitbucket.org/eunjeon/mecab-ko)
* [mecab-ko-dic](https://bitbucket.org/eunjeon/mecab-ko-dic)

`mecab-ko-dic`이 `/usr/local/lib/mecab/dic/mecab-ko-dic`에 설치된 경우에만 정상 작동합니다. 추후 사전 설치 디렉토리를 환경 변수로 추가할 수 있도록 하겠습니다.

```r
# install.packages("devtools")
devtools::install_github("junhewk/RmecabKo")
```

### Example

현재는 `pos` 함수 하나만 존재합니다. `pos("문자열")` 또는 `pos(리스트)`로 구동합니다. 리스트로 직접 넣으면 C++ 내부에서 루프 처리를 하므로 더 빠르게 처리할 수 있습니다. 자료형은 추후 추가할 예정입니다.

```r
> library(RmecabKo)
> pos("안녕하세요.")
$안녕하세요.
[1] "안녕/NNG"   "하/XSV"     "세요/EP+EF" "./SF"      

> pos(list("안녕하세요.", "은전한닢 프로젝트 R wrapper입니다."))
$안녕하세요.
[1] "안녕/NNG"   "하/XSV"     "세요/EP+EF" "./SF"      

$`은전한닢 프로젝트 R wrapper입니다.`
[1] "은전한닢/NNG+NR+NNG" "프로젝트/NNG"        "R/SL"                "wrapper/SL"          "입니다/VCP+EF"      
[6] "./SF"               
```

### Author

김준혁 (junhewk.kim@gmail.com)

문의사항은 Issues에 올려주시면 감사하겠습니다.

### TODO

1. 윈도우에서 구동 (`mecab-ko-msvc`): 제가 윈도우를 설치하지 않아 테스트를 하기가 어렵습니다. 도와주실 분을 찾습니다.
2. 사전 설치 디렉트로 환경 변수로 옮기고 수정할 수 있도록 변경
3. 자료형 추가

### License

GPL (>= 2)

