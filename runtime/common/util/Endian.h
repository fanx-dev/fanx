#ifndef __Endia_h__
#define __Endia_h__
/**
 * ByteOrder
 */
  enum Endian {
      Endian_Big,
      Endian_Little
  };

  static inline bool isBigEndian() {
      static const int __one = 1;
      return (*(char*)(&__one) == 0);
  }
  
  static inline Endian hostEndian() {
    static const int __one = 1;
    return isBigEndian() ? Endian_Big : Endian_Little;
  }

  static inline void swap16p(void *lpMem) {
    char * p = (char*)lpMem;
    p[0] = p[0] ^ p[1];
    p[1] = p[0] ^ p[1];
    p[0] = p[0] ^ p[1];
  }
  
  static inline void swap32p(void *lpMem) {
    char * p = (char*)lpMem;
    p[0] = p[0] ^ p[3];
    p[3] = p[0] ^ p[3];
    p[0] = p[0] ^ p[3];
    p[1] = p[1] ^ p[2];
    p[2] = p[1] ^ p[2];
    p[1] = p[1] ^ p[2];
  }
  
  static inline void swap64p(void *lpMem) {
    char * p = (char*)lpMem;
    p[0] = p[0] ^ p[7];
    p[7] = p[0] ^ p[7];
    p[0] = p[0] ^ p[7];
    p[1] = p[1] ^ p[6];
    p[6] = p[1] ^ p[6];
    p[1] = p[1] ^ p[6];
    p[2] = p[2] ^ p[5];
    p[5] = p[2] ^ p[5];
    p[2] = p[2] ^ p[5];
    p[3] = p[3] ^ p[4];
    p[4] = p[3] ^ p[4];
    p[3] = p[3] ^ p[4];
  }

#endif