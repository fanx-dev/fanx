//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 16/9/11.
//


#include "system.h"
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#ifndef CF_WIN

void System_sleep(uint32_t millitm) {
    usleep(millitm * 1000);
}

void System_barrier() {
    
}

#else
#include <Windows.h>

void System_sleep(uint32_t millitm) {
    Sleep(millitm);
}

void System_barrier() {
    
}

#endif
