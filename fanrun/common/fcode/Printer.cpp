//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/7/5.
//

#include "Printer.h"
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

Printer::Printer() : indentation(0), needIndent(false), file(NULL), console(true) {
}

Printer::Printer(const char *path) : indentation(0), needIndent(false), file(NULL), console(false) {
    file = fopen(path, "w");
    if (!file) {
        ::printf("open file error %s\n", path);
    }
    ::printf("printer:%s\n", path);
}

Printer::~Printer() {
    if (file) {
        fclose(file);
        file = NULL;
    }
}

void Printer::print(const char *str) {
    if (console) {
        ::printf("%s", str);
    }
    if (file) {
        fprintf(file, "%s", str);
    }
}

void Printer::printIndent() {
    for (int i=0; i<indentation; ++i) {
        print("    ");
    }
}

bool Printer::println(const char *fmt, ...) {
    va_list args;
    char buf[F_STR_BUF_SIZE];
    int rc;
    size_t size = F_STR_BUF_SIZE-1;
    //CF_ENTRY_FUNC
    va_start(args, fmt);
    
    rc = vsnprintf(buf, size, fmt, args);
    
    bool ok = true;
    //windows return -1, unix return expected size
#ifdef CF_WIN
    while (rc < 0) {
        ok = false;
    }
#else
    if (rc > (int)(size-1)) {
        ok = false;
    }
#endif
    
    if (needIndent) {
        printIndent();
        needIndent = false;
    }
    
    va_end(args);
    if (ok) {
        size_t len = strlen(buf);
        buf[len] = '\n';
        buf[len+1] = 0;
        print(buf);
    }
    
    needIndent = true;
    return ok;
}

void Printer::newLine() {
    print("\n");
    needIndent = true;
}

bool Printer::printf(const char *fmt, ...) {
    va_list args;
    char buf[F_STR_BUF_SIZE];
    int rc;
    size_t size = F_STR_BUF_SIZE;
    //CF_ENTRY_FUNC
    va_start(args, fmt);
    
    rc = vsnprintf(buf, size, fmt, args);
    
    bool ok = true;
    //windows return -1, unix return expected size
#ifdef CF_WIN
    while (rc < 0) {
        ok = false;
    }
#else
    if (rc > (int)(size-1)) {
        ok = false;
    }
#endif
    
    if (needIndent) {
        printIndent();
        needIndent = false;
    }
    
    va_end(args);
    if (ok) {
        print(buf);
    }
    return ok;
}

char *Printer::format(const char *fmt, ...) {
    va_list args;
    int rc;
    size_t size = F_STR_BUF_SIZE;

    //CF_ENTRY_FUNC
    va_start(args, fmt);
    
    rc = vsnprintf(buf, size, fmt, args);
    
    bool ok = true;
    //windows return -1, unix return expected size
#ifdef CF_WIN
    while (rc < 0) {
        ok = false;
    }
#else
    if (rc > (int)(size-1)) {
        ok = false;
    }
#endif
    
    va_end(args);
    if (ok) {
        return buf;
    }
    return NULL;
}
