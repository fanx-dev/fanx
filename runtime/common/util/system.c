//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 16/9/11.
//


#include "system.h"
#include <sys/types.h>
#include <time.h>

#ifndef CF_WIN
#include <unistd.h>
#include <sys/timeb.h>
#include <sys/time.h>

void System_sleep(uint32_t millitm) {
    usleep(millitm * 1000);
}

int64_t System_currentTimeMillis() {
  //        struct timeb val;
  //        ftime(&val);
  //        return val.time * (int64_t)1000+ val.millitm;
  
  struct timeval tv;
  gettimeofday (&tv, NULL);
  return ((int64_t) tv.tv_sec) * 1000 + tv.tv_usec / 1000;
}

#else
#include <Windows.h>

void System_sleep(uint32_t millitm) {
    Sleep(millitm);
}

int64_t System_currentTimeMillis() {
    FILETIME file_time;
    GetSystemTimeAsFileTime(&file_time);
    uint64_t time = ((uint64_t)file_time.dwLowDateTime) + ((uint64_t)file_time.dwHighDateTime << 32);

    // This magic number is the number of 100 nanosecond intervals since January 1, 1601 (UTC)
    // until 00:00:00 January 1, 1970
    static const uint64_t EPOCH = ((uint64_t)116444736000000000ULL);

    return (uint64_t)((time - EPOCH) / 10000LL);
}

#endif
