#include <Rcpp.h>
#include <cstdint>
#include <set>
#include <string>
#include <vector>

using namespace Rcpp;

// [[Rcpp::export]]
List simple_ngrams(const List tokenized_list,
                   const IntegerVector n_values,
                   const IntegerVector skip_values,
                   const CharacterVector stopwords,
                   const String ngram_delim) {
  std::set<std::string> stopword_set;
  for (R_xlen_t i = 0; i < stopwords.size(); ++i) {
    if (!CharacterVector::is_na(stopwords[i])) {
      stopword_set.insert(as<std::string>(stopwords[i]));
    }
  }

  const std::string delimiter = ngram_delim.get_cstring();
  List output(tokenized_list.size());

  for (R_xlen_t document = 0; document < tokenized_list.size(); ++document) {
    if (document % 1000 == 0) {
      checkUserInterrupt();
    }

    CharacterVector tokens = tokenized_list[document];
    if (tokens.size() == 1 && CharacterVector::is_na(tokens[0])) {
      output[document] = CharacterVector::create(NA_STRING);
      continue;
    }

    std::vector<std::vector<std::string> > segments(1);
    for (R_xlen_t i = 0; i < tokens.size(); ++i) {
      if (CharacterVector::is_na(tokens[i])) {
        if (!segments.back().empty()) {
          segments.push_back(std::vector<std::string>());
        }
        continue;
      }
      const std::string token = as<std::string>(tokens[i]);
      if (stopword_set.find(token) != stopword_set.end()) {
        if (!segments.back().empty()) {
          segments.push_back(std::vector<std::string>());
        }
      } else {
        segments.back().push_back(token);
      }
    }

    CharacterVector result;
    for (R_xlen_t n_index = 0; n_index < n_values.size(); ++n_index) {
      const std::uint64_t n = static_cast<std::uint64_t>(n_values[n_index]);
      const R_xlen_t skips_to_use = n == 1 ? 1 : skip_values.size();

      for (R_xlen_t skip_index = 0; skip_index < skips_to_use; ++skip_index) {
        const std::uint64_t step =
          static_cast<std::uint64_t>(skip_values[skip_index]) + 1;
        const std::uint64_t width = (n - 1) * step + 1;

        for (const auto& segment : segments) {
          if (segment.empty() || width > segment.size()) {
            continue;
          }
          const std::uint64_t last_start = segment.size() - width;
          for (std::uint64_t start = 0; start <= last_start; ++start) {
            std::string value;
            for (std::uint64_t item = 0; item < n; ++item) {
              if (item > 0) {
                value += delimiter;
              }
              value += segment[start + item * step];
            }
            result.push_back(value);
          }
        }
      }
    }
    output[document] = result;
  }

  output.attr("names") = tokenized_list.attr("names");
  return output;
}
