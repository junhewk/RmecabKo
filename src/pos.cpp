
#include <Rcpp.h>
#include <iostream>
#include <string>

#if defined(__unix__) || (defined(__APPLE__) && defined(__MACH__))

#include <mecab.h>

#define CHECK(eval) if (! eval) { \
const char *e = tagger ? tagger->what() : MeCab::getTaggerError();\
std::cerr << "Exception:" << e << std::endl;\
delete tagger;\
return R_NilValue; }

using namespace Rcpp;

// [[Rcpp::export]]
List posRcpp(const CharacterVector & phrase, const CharacterVector & dic){
  
  const char * dicpath = as<const char *>(dic);
  
  MeCab::Tagger *tagger = MeCab::createTagger(dicpath);
  CHECK(tagger);
  
  // Gets Node object.
  Rcpp::List tagged_list;
  
  for (int i = 0; i < phrase.size(); i++) {
    std::string text = Rcpp::as<std::string>(phrase(i));
    const MeCab::Node* node = tagger->parseToNode(text.c_str());
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

#elif defined(_WIN32)

using namespace Rcpp;

// [[Rcpp::export]]
List posRcpp(const CharacterVector & phrase, const CharacterVector& dic) {
  // mecab in Windows needs to be compiled by VC++, but Rcpp doesn't compatible with it.
  Rcpp::List returnValue;
  returnValue.push_back("Rcpp doesn't support VC++.");
  return returnValue;
}

#endif
