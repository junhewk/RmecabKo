
#include <Rcpp.h>
#include <iostream>
#include <string>

#if defined(__linux__) || (defined(__APPLE__) && defined(__MACH__))

#include <mecab.h>

#elif defined(_WIN32)

#define OS_Windows

#endif

using namespace Rcpp;

// [[Rcpp::export]]
List posRcpp(const CharacterVector & phrase, const CharacterVector & dic, const LogicalVector & join){

#ifdef OS_Windows
  
  return R_NilValue;
  
#else
  
  const char * dicpath = as<const char *>(dic);

  MeCab::Tagger *tagger = MeCab::createTagger(dicpath);
  if (!tagger) {
    const char *e = tagger ? tagger->what() : MeCab::getTaggerError();
    stop(e);
  }

  // Gets Node object.
  Rcpp::List tagged_list;

  for (int i = 0; i < phrase.size(); i++) {
    std::string text = Rcpp::as<std::string>(phrase(i));
    const MeCab::Node* node = tagger->parseToNode(text.c_str());
    
    if (!node) {
      const char *e = tagger ? tagger->what() : MeCab::getTaggerError();
      stop(e);
    }

    Rcpp::CharacterVector tagged;
    
    for (; node; node = node->next) {
      if (node->stat == MECAB_BOS_NODE)
        ;
      else if (node->stat == MECAB_EOS_NODE)
        ;
      else {
        std::string f = node->feature;
        if (join[0]) {
          tagged.push_back(std::string (node->surface).substr(0, node->length) + "/" + f.substr(0, f.find(",")));  
        } else {
          tagged.push_back(std::string (node->surface).substr(0, node->length), f.substr(0, f.find(",")));  
        }
        
      }
    }
    
    tagged_list.push_back(tagged);
    
  }

  delete tagger;
  return tagged_list;
  
#endif
}
