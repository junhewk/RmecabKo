
#include <Rcpp.h>
#include <iostream>
#include <mecab.h>
#include <string>

#define CHECK(eval) if (! eval) { \
const char *e = tagger ? tagger->what() : MeCab::getTaggerError();\
std::cerr << "Exception:" << e << std::endl;\
delete tagger;\
return R_NilValue; }

using namespace Rcpp;

// [[Rcpp::export]]
List posRcpp(const List & phrase_list, const StringVector & dic){
  
  const char * dicpath = as<const char *>(dic);
  
  MeCab::Tagger *tagger = MeCab::createTagger(dicpath);
  CHECK(tagger);
  
  // Gets Node object.
  Rcpp::List tagged_list;
  int n = phrase_list.size();
  
  for (int i = 0; i < n; i++) {
    std::string phrase = Rcpp::as<std::string>(Rcpp::CharacterVector (phrase_list(i)));
    const MeCab::Node* node = tagger->parseToNode(phrase.c_str());
    CHECK(node);

    Rcpp::CharacterVector tagged;
    
    for (; node; node = node->next) {
      if (node->stat == MECAB_BOS_NODE)
        ;
      else if (node->stat == MECAB_EOS_NODE)
        ;
      else {
        std::string f = node->feature;
        tagged.push_back(std::string (node->surface).substr(0, node->length) + "/" + f.substr(0, f.find(",")));
      }
    }
    tagged_list.push_back(tagged);
  }

  delete tagger;
  return tagged_list;
}