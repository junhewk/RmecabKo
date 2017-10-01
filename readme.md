## RmecabKo [![License](http://img.shields.io/badge/license-GPL%20%28%3E=%202%29-brightgreen.svg?style=flat)](http://www.gnu.org/licenses/gpl-2.0.html)

[은전한닢 프로젝트](http://eunjeon.blogspot.com/) `mecab-ko`의 R wrapper입니다.

### About

은전한닢 프로젝트가 기반으로 하고 있는 `mecab`은 일본어 형태소 분석기로, 띄어쓰기와 관계없이 형태소를 분석합니다. 인터넷에서 수집한 텍스트는 띄어쓰기에 오류가 있는 경우가 많아, 텍스트 분석을 진행할 때 은전한닢 프로젝트의 `mecab-ko`를 통해 진행하는 것이 유용한 경우가 있습니다.

이 패키지는 은전한닢 프로젝트의 R wrapper입니다. Mac OSX, Linux에서는 `mecab-ko`와 `mecab-ko-dic`를 먼저 설치해야 합니다. [Rcpp](http://dirk.eddelbuettel.com/code/rcpp.html)를 통해 제작했습니다. C++에서 직접 동작하므로 다른 형태소 분석기에 비해 상당히 빠릅니다. Windows에서는 VC++로 빌드한 `mecab-ko-msvc`, `mecab-ko-dic-msvc`를 system command로 구동합니다. 따라서 Windows에서는 속도 저하가 발생합니다.

### Installation

#### Mac OSX, Linux

먼저 `mecab-ko`와 `mecab-ko-dic`을 설치합니다.

* [mecab-ko](https://bitbucket.org/eunjeon/mecab-ko)
* [mecab-ko-dic](https://bitbucket.org/eunjeon/mecab-ko-dic)

`mecab-ko-dic`이 `/usr/local/lib/mecab/dic/mecab-ko-dic`에 설치된 경우에만 정상 작동합니다. 추후 사전 설치 디렉토리를 환경 변수로 추가할 수 있도록 하겠습니다.

```r
# install.packages("devtools")
devtools::install_github("junhewk/RmecabKo")
```

#### Windows

`mecab-ko-msvc`, `mecab-ko-dic-msvc`가 패키지에 이미 포함되어 있습니다.

```r
# install.packages("devtools")
devtools::install_github("junhewk/RmecabKo")
```

### Example

`pos`, `nouns` 함수를 제공합니다. 두 함수 모두 **문자열 벡터**를 입력값으로 받습니다. (0.1판의 리스트에서 변경하였습니다. 혼동을 드려 죄송합니다.)

* `pos`는 문장 전체의 형태소 태깅을 제공합니다.
* `nouns`는 명사만 추출하여 제공합니다.

```r
> library(RmecabKo)
> pos("안녕하세요.")
$안녕하세요.
[1] "안녕/NNG"   "하/XSV"     "세요/EP+EF" "./SF"      

> pos(c("안녕하세요.", "은전한닢 프로젝트 R wrapper입니다."))
$안녕하세요.
[1] "안녕/NNG"   "하/XSV"     "세요/EP+EF" "./SF"      

$`은전한닢 프로젝트 R wrapper입니다.`
[1] "은전한닢/NNG+NR+NNG" "프로젝트/NNG"        "R/SL"                "wrapper/SL"         
[5] "입니다/VCP+EF"       "./SF"               

> nouns("안녕하세요.")
$안녕하세요.
[1] "안녕"

> nouns(c("안녕하세요.", "은전한닢 프로젝트 R wrapper입니다."))
$안녕하세요.
[1] "안녕"

$`은전한닢 프로젝트 R wrapper입니다.`
[1] "은전한닢" "프로젝트"
              
```

### Version History

* 0.1: First draft, `pos(list)`
* 0.1.5: Windows support, add `nouns` function, `pos(character)`

### Author

김준혁 (junhewk.kim@gmail.com)

문의사항은 Issues에 올려주시면 감사하겠습니다.

### Thanks to and Contributors

* [은전한닢 프로젝트(이용운, 유영호)](http://eunjeon.blogspot.com/): `mecab` 한국어 fork 
* [윤원섭](www.github.com/Pusnow): `mecab-ko-msvc`, `mecab-ko-dic-msvc` VC++ 빌드

### TODO

1. <del>윈도우에서 구동 (`mecab-ko-msvc`): 제가 윈도우를 설치하지 않아 테스트를 하기가 어렵습니다. 도와주실 분을 찾습니다.</del>
2. 사전 설치 디렉트로 환경 변수로 옮기고 수정할 수 있도록 변경
3. 자료형 추가
4. `mecab-ko-msvc`, `mecab-ko-dic-msvc` 설치 스크립트 제공 (Windows)
5. `mecab-ko`, `mecab-ko-dic` 설치 스크립트 제공 (Mac OSX, Linux)
6. User Dictionary 함수 추가

### License

GPL (>= 2)

