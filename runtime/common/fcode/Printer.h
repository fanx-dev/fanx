//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/7/5.
//

#ifndef __zip__Printer__
#define __zip__Printer__

#include <stdio.h>

#define F_STR_BUF_SIZE 1024

class Printer {
    char buf[F_STR_BUF_SIZE];
    int indentation;
    bool needIndent;
    
    FILE *file;
    bool console;
public:
    Printer();
    Printer(const char *path);
    ~Printer();
    
    bool println(const char *format, ...);
    void newLine();
    bool printf(const char *format, ...);
    char *format(const char *fmt, ...);
    
    void indent() { ++indentation; }
    void unindent() { --indentation; }
    void _print(const char *str) { print(str); }
protected:
    virtual void print(const char *str);

private:
    void printIndent();
};

#endif /* defined(__zip__Printer__) */
