#ifndef _MD5_h
#define _MD5_h

typedef struct {
  unsigned int state[4];                                   /* A,B,C,D四个常数 */
  unsigned int count[2];        /* 数据的bit数计数器(对2^64取余) */
  unsigned char buffer[64];                         /* 输入数据缓冲区 */
} MD5_CTX; //存放MD5算法相关信息的结构体定义

void MD5Init (MD5_CTX *context);
void MD5Update (MD5_CTX *context, unsigned char *input, unsigned int inputLen);
void MD5Final (unsigned char digest[16], MD5_CTX *context);


#endif