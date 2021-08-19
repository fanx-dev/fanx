//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
// Created by yangjiandong on 2017/8/20.
//

#include "escape.h"


typedef const char *cstr;
cstr keyword[] = {
    "auto",
    //"break",
    //"case",
    "char",
    //"const",
    //"continue",
    //"default",
    //"do",
    "double",
    //"else",
    "enum",
    "extern",
    "float",
    //"for",
    "goto",
    //"if",
    "inline",
    "int",
    "long",
    "register",
    "restrict",
    //"return",
    "short",
    "signed",
    "sizeof",
    //"static",
    "struct",
    "switch",
    "typedef",
    "union",
    "unsigned",
    "void",
    "volatile",
    //"while",
    "typeof",
    "delete",
    
    "not",
    "and",
    "or",
    "xor",
};

const int keywordCount = 28;

void escapeKeyword(std::string &astr) {
    for (int i=0; i<keywordCount; ++i) {
        if (astr == keyword[i]) {
            astr += "_";
            return;
        }
    }
}

void escapeName(std::string &str) {
    long pos = 0;
    
    while (pos < str.length()) {
        if (str[pos] == '$') {
            str.replace(pos, 1, "__");
            ++pos;
        }
        ++pos;
    }
}

void escape(std::string &str) {
    escapeName(str);
    escapeKeyword(str);
}
