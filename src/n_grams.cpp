#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
ListOf<CharacterVector> simple_ngrams(const ListOf<const CharacterVector> tokenized_list,
                                      const int n,
                                      CharacterVector stopwords = CharacterVector(),
                                      const String ngram_delim = " ") {
  
  size_t docN = tokenized_list.size();
  List ret(docN);
  CharacterVector tokenized;
  std::string s;
  std::deque<std::string> term_buffer;
  const std::string std_string_delim = ngram_delim.get_cstring();
  
  std::set<std::string> stopwords_set;
  for(size_t i = 0; i < stopwords.size(); i++){
    if(stopwords[i] != NA_STRING){
      stopwords_set.insert(as<std::string>(stopwords[i]));
    }
  }
  
  for (size_t i = 0; i < docN; i++) {
    if (i % 10000 == 0) {
      Rcpp::checkUserInterrupt();
    }
    
    CharacterVector result;
    term_buffer.clear();
    std::string term;
    
    for (size_t h = 0; h < tokenized_list[i].size(); h++) {
      term = as<std::string>(tokenized_list[i][h]);
      if(stopwords_set.find(term) == stopwords_set.end())
        term_buffer.push_back(term);
    }
    
    if (term_buffer.size()) {
      for (size_t j = 0; j < (term_buffer.size() - n + 1); j ++) {
        s = "";
        size_t start = j;
        size_t end = j + n;
        for (size_t k = start; k < end; k++) {
          if (k == start) {
            s = term_buffer[k];
          } else {
            s = s + std_string_delim + term_buffer[k];
          }
        }
        result.push_back(s);
      }
    } else {
      result.push_back(NA_STRING);
    }
    
    ret[i] = result;
  }
  
  return ret;
}