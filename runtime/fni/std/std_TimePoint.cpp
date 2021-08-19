#include "fni_ext.h"
#include "pod_std_native.h"

#include "util/miss.h"
#include <mutex>

const int64_t NanoPerSecond = 1000000000L;

#ifndef CF_WIN

  #include <sys/types.h>
  #include <time.h>
  #include <unistd.h>

#ifdef P__MACH__
  #include <mach/mach.h>
  #include <mach/mach_time.h>
  //#include <sys/_types/_timespec.h>
  #include <mach/mach.h>
  #include <mach/clock.h>
  #include <sys/timeb.h>
  #include <sys/time.h>
  #include <sys/sysctl.h>

  int64_t nanoTicks(void) {
    //            clock_serv_t cclock;
    //            mach_timespec_t mts;
    //
    //            host_get_clock_service(mach_host_self(), SYSTEM_CLOCK, &cclock);
    //            clock_get_time(cclock, &mts);
    //            mach_port_deallocate(mach_task_self(), cclock);
    //
    //            return (mts.tv_sec * NanoPerSecond) + mts.tv_nsec;
    //            mach_timebase_info_data_t timebase;
    //            mach_timebase_info(&timebase);
    //            int64_t now = mach_absolute_time();
    //            int64_t elapsedNanoSeconds = now * timebase.numer / timebase.denom;
    //            return elapsedNanoSeconds;
    
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    (void)time(&now);
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
      uptime = now - boottime.tv_sec;
    }
    return uptime * NanoPerSecond;
  }
#else
  #include <sys/timeb.h>
  #include <sys/time.h>

  int64_t nanoTicks(void) {
    //  return clock() / (CLOCKS_PER_SECOND * 1000);
    struct timespec ts;
    static time_t startTime;
#ifdef __MACH__
    int rc = clock_gettime(CLOCK_MONOTONIC, &ts);
#else
    int rc = clock_gettime(CLOCK_BOOTTIME, &ts);
#endif
    //获取CLOCK_BOOTTIME失败的时候使用time函数代替
    if (rc != 0) {
      if (startTime == 0) {
        time(&startTime);
      }
      time_t now;
      time(&now);
      return ((int64_t)(now - startTime))*NanoPerSecond;
    }
    return (ts.tv_sec * NanoPerSecond) + ts.tv_nsec;
  }
#endif

int64_t currentTimeMillis() {
  //        struct timeb val;
  //        ftime(&val);
  //        return val.time * (int64_t)1000+ val.millitm;
  
  struct timeval tv;
  gettimeofday (&tv, NULL);
  return ((int64_t) tv.tv_sec) * 1000 + tv.tv_usec / 1000;
}

#else
/*========================================================================
 * Windows
 */

#include <Windows.h>

int64_t nanoTicks() {
  
   LARGE_INTEGER m_nBeginTime;
   static LARGE_INTEGER m_nFreq = {0};
   if (!m_nFreq.QuadPart) {
       QueryPerformanceFrequency(&m_nFreq);
   }
   QueryPerformanceCounter(&m_nBeginTime);
   return (m_nBeginTime.QuadPart*NanoPerSecond)/m_nFreq.QuadPart;
   
  //int64_t t = (int64_t)timeGetTime();
  //return t * 1000000L;
}

int64_t currentTimeMillis() {
    FILETIME file_time;
    GetSystemTimeAsFileTime(&file_time);
    uint64_t time = ((uint64_t)file_time.dwLowDateTime) + ((uint64_t)file_time.dwHighDateTime << 32);

    // This magic number is the number of 100 nanosecond intervals since January 1, 1601 (UTC)
    // until 00:00:00 January 1, 1970 
    static const uint64_t EPOCH = ((uint64_t)116444736000000000ULL);

    return (uint64_t)((time - EPOCH) / 10000LL);
}
#endif

fr_Int std_TimePoint_nowMillis(fr_Env env) {
    return currentTimeMillis();
}
fr_Int std_TimePoint_nanoTicks(fr_Env env) {
    return nanoTicks();
}
fr_Int std_TimePoint_nowUnique(fr_Env env) {
    static fr_Int nowUniqueLast;
    static std::mutex lock;
    fr_Int now = currentTimeMillis();

    lock.lock();
    if (now <= nowUniqueLast) now = nowUniqueLast + 1;
    nowUniqueLast = now;
    lock.unlock();

    return now;
}
