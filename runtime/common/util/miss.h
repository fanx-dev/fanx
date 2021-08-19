//
// Copyright (c) 2017, chunquedong
// Licensed under the Apache Licene 2.0
//
//  Created by yangjiandong on 15/9/4.
//

#ifndef runtime_miss_h
#define runtime_miss_h

/*========================================================================
 * WIN
 */
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__WINDOWS__) \
|| defined(WIN64) || defined(_WIN64) || defined(__WIN64__)
#define CF_WIN
#endif

/*========================================================================
 * Fixed int type
 */

#if 1
#include <stdint.h>
#else
typedef signed char       int8_t;
typedef signed short      int16_t;
typedef signed long       int32_t;
typedef unsigned char     uint8_t;
typedef unsigned short    uint16_t;
typedef unsigned long     uint32_t;

#if defined(_MSC_VER) || defined(__BORLANDC__)
typedef signed __int64      int64_t;
typedef unsigned __int64    uint64_t;
#else
typedef signed long long    int64_t;
typedef unsigned long long  uint64_t;
#endif

#ifndef _MSC_VER
#define _Bool char
#endif
#endif

#if defined(_MSC_VER)
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#endif

/*========================================================================
 * Boolean
 */

#ifndef __cplusplus
#define bool    _Bool
#define true    1
#define false   0
#endif

/*========================================================================
 * misc
 */
#ifdef  _MSC_VER
//#define inline      __inline
#define __func__    __FUNCTION__
//#define snprintf    _snprintf
//#define vsnprintf   _vsnprintf
#define strcasecmp  _stricmp
#define strtoll     _strtoi64
#define tzset       _tzset
//#define isnan(x)   _isnan(x)
#define strdup		_strdup
#endif

//#if (NULL != 0)
//  #error NULL is not 0
//#endif


#ifndef offsetof
#define offsetof(s, m)   (size_t)&(((s *)0)->m)
#endif

/*========================================================================
 * extern "C"
 */

#ifdef  __cplusplus
#define CF_BEGIN extern  "C" {
#else
#define CF_BEGIN
#endif

#ifdef  __cplusplus
#define CF_END }
#else
#define CF_END
#endif

/*========================================================================
 * align
 */
#define CF_ALIGNN(size, align) (((size)+((align)-1))&~((align)-1))
#define CF_ALIGN_SIZE sizeof(void*)


#endif //runtime_miss_h
