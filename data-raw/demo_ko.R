# Build the small demonstration corpus shipped as `demo_ko`.
#
# The sentences are self-authored and public domain so they can ship on CRAN.
# Run with: Rscript data-raw/demo_ko.R

demo_ko <- c(
  d1 = "한국어 형태소 분석은 텍스트 마이닝의 첫걸음입니다.",
  d2 = "오늘 날씨가 정말 좋아서 공원을 오래 걸었어요.",
  d3 = "이 책은 자연어 처리를 배우는 사람에게 큰 도움이 됩니다.",
  d4 = "친구들과 함께 맛있는 저녁을 먹으니 기분이 좋았다.",
  d5 = "새로운 기술을 배우는 것은 언제나 흥미로운 일이다.",
  d6 = "회의가 길어져서 조금 피곤했지만 결과는 만족스러웠다.",
  d7 = "봄이 오면 벚꽃이 활짝 피어 거리가 아름다워진다.",
  d8 = "데이터를 꼼꼼하게 정리하면 분석이 훨씬 쉬워집니다.",
  d9 = "아이들이 운동장에서 즐겁게 뛰어놀고 있었다.",
  d10 = "좋은 글은 읽는 사람의 마음을 오래도록 움직인다."
)
demo_ko <- enc2utf8(demo_ko)
Encoding(demo_ko) <- "UTF-8"

save(demo_ko,
     file = file.path("data", "demo_ko.rda"),
     version = 2, compress = "xz")
message(sprintf("demo_ko: %d sentences", length(demo_ko)))
