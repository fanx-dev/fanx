/*
 * Description: UTF-8 字符串的解码和编码函数
 *              unicode 字符处理函数
 *     History: yang@haipo.me, 2013/05/29, create
 */


# include <stdint.h>
# include <stddef.h>

# include "utf8.h"


/*
 * 标准 C 并没有规定 wchar_t 的位数。但 GNU C Lib 保证 wchar_t 是 32 位的，
 * 所以可以用 wchar.h 中定义的函数来像 wchar_t 一样操纵 ucs4_t.
 * http://www.gnu.org/software/libc/manual/html_node/Extended-Char-Intro.html
 */
typedef int32_t ucs4_t;

/*
 * 从 UTF-8 编码的字符串 *src 中读取一个 unicode 字符，并更新 *src 的值。
 *
 * 如果遇到非法 UTF-8 编码，则跳过非法部分。
 * 如果 illegal 参数不为 NULL, 则 *illegal 表示非法 UTF-8 编码字节数。
 */
ucs4_t getu8c(char **src, int *illegal);

/*
 * 将 src 指向的 UTF-8 编码字符串解码为 unicode，放在长度为 n 的数组 des 中，
 * 并在末尾添加 0. 如果 des 不足以存放所有的字符，则最多保存 n - 1 个 unicode
 * 字符并补 0.
 *
 * 如果遇到非法 UTF-8 编码，则跳过非法部分。
 * 如果 illegal 不为 NULL, 则 *illegal 表示非法 UTF-8 编码的字节数。
 */
size_t u8decode(char const *str, ucs4_t *des, size_t n, int *illegal);

/*
 * 将 unicode 字符 uc 编码为 UTF-8 编码，放到长度为 *left 的字符串 *des 中。
 *
 * 如果 *des 不足以存放 uc 对应的 UTF-8 字符串，返回一个负值。
 * 如果成功，更新 *des 和 *left 的值。
 */
int putu8c(ucs4_t uc, char **des, size_t *left);

/*
 * 将以 0 结尾的 unicode 数组 us 编码为 UTF-8 字符串，放到长度为 n 的字符串 des 中。
 *
 * 负数为非法的 unicode 字符。
 * 如果 illegal 不为 NULL，则 *illegal 表示非法的 unicode 字符数。
 */
size_t u8encode(ucs4_t *us, char *des, size_t n, int *illegal);

/*
 * 判断是否为全角字符
 */
int isufullwidth(ucs4_t uc);

/*
 * 判断是否为全角字母
 */
int isufullwidthalpha(ucs4_t uc);

/*
 * 判断是否为全角数字
 */
int isufullwidthdigit(ucs4_t uc);

/*
 * 全角字符转半角字符。
 * 如果 uc 为全角字符，则返回对应的半角字符，否则返回 uc 本身。
 */
ucs4_t ufull2half(ucs4_t uc);

/*
 * 半角字符转全角字符
 * 如果 uc 为半角字符，则返回对应的全角字符，否则返回 uc 本身。
 */
ucs4_t uhalf2full(ucs4_t uc);

/*
 * 判断是否为汉字字符（中日韩越统一表意文字）
 */
int isuchiness(ucs4_t uc);

/*
 * 判断是否为中文标点
 */
int isuzhpunct(ucs4_t uc);

/*
 * 判断是否为日文平假名字符
 */
int isuhiragana(ucs4_t uc);

/*
 * 判断是否为日文片假名字符
 */
int isukatakana(ucs4_t uc);

/*
 * 判断是否为韩文字符
 */
int isukorean(ucs4_t uc);

ucs4_t getu8c(char **src, int *illegal)
{
  static char umap[256] = { 0 };
  static int  umap_init_flag = 0;
  
  if (umap_init_flag == 0)
  {
    int i;
    
    for (i = 0; i < 0x100; ++i)
    {
      if (i < 0x80)
      {
        umap[i] = 1;
      }
      else if (i >= 0xc0 && i < 0xe0)
      {
        umap[i] = 2;
      }
      else if (i >= 0xe0 && i < 0xf0)
      {
        umap[i] = 3;
      }
      else if (i >= 0xf0 && i < 0xf8)
      {
        umap[i] = 4;
      }
      else if (i >= 0xf8 && i < 0xfc)
      {
        umap[i] = 5;
      }
      else if (i >= 0xfc && i < 0xfe)
      {
        umap[i] = 6;
      }
      else
      {
        umap[i] = 0;
      }
    }
    
    umap_init_flag = 1;
  }
  
  uint8_t *s = (uint8_t *)(*src);
  int r_illegal = 0;
  
  while (umap[*s] == 0)
  {
    ++s;
    ++r_illegal;
  }
  
  uint8_t *t;
  int byte_num;
  uint32_t uc;
  int i;
  
repeat_label:
  t = s;
  byte_num = umap[*s];
  uc = *s++ & (0xff >> byte_num);
  
  for (i = 1; i < byte_num; ++i)
  {
    if (umap[*s])
    {
      r_illegal += s - t;
      goto repeat_label;
    }
    else
    {
      uc = (uc << 6) + (*s & 0x3f);
      s += 1;
    }
  }
  
  *src = (char *)s;
  if (illegal)
  {
    *illegal = r_illegal;
  }
  
  return uc;
}

size_t u8decode(char const *str, ucs4_t *des, size_t n, int *illegal)
{
  if (n == 0)
    return 0;
  
  char *s = (char *)str;
  size_t i = 0;
  ucs4_t uc = 0;
  int r_illegal_all = 0, r_illegal;
  
  while ((uc = getu8c(&s, &r_illegal)))
  {
    if (i < (n - 1))
    {
      des[i++] = uc;
      r_illegal_all += r_illegal;
    }
    else
    {
      break;
    }
  }
  
  des[i] = 0;
  if (illegal)
  {
    *illegal = r_illegal_all + r_illegal;
  }
  
  return i;
}

# define IF_CAN_HOLD(left, n) do { \
size_t m = (size_t)(n); \
if ((size_t)(left) < (m + 1)) return -2; \
(left) -= m; \
} while (0)

int putu8c(ucs4_t uc, char **des, size_t *left)
{
  if (uc < 0)
    return -1;
  
  if (uc < (0x1 << 7))
  {
    IF_CAN_HOLD(*left, 1);
    
    **des = (char)uc;
    *des += 1;
    **des = 0;
    
    return 1;
  }
  
  int byte_num;
  
  if (uc < (0x1 << 11))
  {
    byte_num = 2;
  }
  else if (uc < (0x1 << 16))
  {
    byte_num = 3;
  }
  else if (uc < (0x1 << 21))
  {
    byte_num = 4;
  }
  else if (uc < (0x1 << 26))
  {
    byte_num = 5;
  }
  else
  {
    byte_num = 6;
  }
  
  IF_CAN_HOLD(*left, byte_num);
  
  int i;
  for (i = byte_num - 1; i > 0; --i)
  {
    *(uint8_t *)(*des + i) = (uc & 0x3f) | 0x80;
    uc >>= 6;
  }
  
  *(uint8_t *)(*des) = uc | (0xff << (8 - byte_num));
  
  *des += byte_num;
  **des = 0;
  
  return byte_num;
}

size_t u8encode(ucs4_t *us, char *des, size_t n, int *illegal)
{
  if (n == 0)
    return 0;
  
  char *s = des;
  size_t left = n;
  size_t len = 0;
  int r_illegal = 0;
  
  *s = 0;
  while (*us)
  {
    int ret = putu8c(*us, &s, &left);
    if (ret > 0)
    {
      len += ret;
    }
    else if (ret == -1)
    {
      r_illegal += 1;
    }
    else
    {
      break;
    }
    
    ++us;
  }
  
  if (illegal)
  {
    *illegal = r_illegal;
  }
  
  return len;
}

/* 全角字符 */
int isufullwidth(ucs4_t uc)
{
  if (uc == 0x3000)
    return 1;
  
  if (uc >= 0xff01 && uc <= 0xff5e)
    return 1;
  
  return 0;
}

/* 全角字母 */
int isufullwidthalpha(ucs4_t uc)
{
  if (uc >= 0xff21 && uc <= 0xff3a)
    return 1;
  
  if (uc >= 0xff41 && uc <= 0xff5a)
    return 2;
  
  return 0;
}

/* 全角数字  */
int isufullwidthdigit(ucs4_t uc)
{
  if (uc >= 0xff10 && uc <= 0xff19)
    return 1;
  
  return 0;
}

/* 全角转半角 */
ucs4_t ufull2half(ucs4_t uc)
{
  if (uc == 0x3000)
    return ' ';
  
  if (uc >= 0xff01 && uc <= 0xff5e)
    return uc - 0xfee0;
  
  return uc;
}

/* 半角转全角 */
ucs4_t uhalf2full(ucs4_t uc)
{
  if (uc == ' ')
    return 0x3000;
  
  if (uc >= 0x21 && uc <= 0x7e)
    return uc + 0xfee0;
  
  return uc;
}

/* 中日韩越统一表意文字 */
int isuchiness(ucs4_t uc)
{
  /* 最初期统一汉字 */
  if (uc >= 0x4e00 && uc <= 0x9fcc)
    return 1;
  
  /* 扩展 A 区 */
  if (uc >= 0x3400 && uc <= 0x4db5)
    return 2;
  
  /* 扩展 B 区 */
  if (uc >= 0x20000 && uc <= 0x2a6d6)
    return 3;
  
  /* 扩展 C 区 */
  if (uc >= 0x2a700 && uc <= 0x2b734)
    return 4;
  
  /* 扩展 D 区 */
  if (uc >= 0x2b740 && uc <= 0x2b81f)
    return 5;
  
  /* 扩展 E 区 */
  if (uc >= 0x2b820 && uc <= 0x2f7ff)
    return 6;
  
  /* 台湾兼容汉字 */
  if (uc >= 0x2f800 && uc <= 0x2fa1d)
    return 7;
  
  /* 北朝鲜兼容汉字 */
  if (uc >= 0xfa70 && uc <= 0xfad9)
    return 8;
  
  /* 兼容汉字 */
  if (uc >= 0xf900 && uc <= 0xfa2d)
    return 9;
  
  /* 兼容汉字 */
  if (uc >= 0xfa30 && uc <= 0xfa6d)
    return 10;
  
  return 0;
}

/* 中文标点 */
int isuzhpunct(ucs4_t uc)
{
  if (uc >= 0x3001 && uc <= 0x3002)
    return 1;
  
  if (uc >= 0x3008 && uc <= 0x300f)
    return 1;
  
  if (uc >= 0xff01 && uc <= 0xff0f)
    return 1;
  
  if (uc >= 0xff1a && uc <= 0xff20)
    return 1;
  
  if (uc >= 0xff3b && uc <= 0xff40)
    return 1;
  
  if (uc >= 0xff5b && uc <= 0xff5e)
    return 1;
  
  if (uc >= 0x2012 && uc <= 0x201f)
    return 1;
  
  if (uc >= 0xfe41 && uc <= 0xfe44)
    return 1;
  
  if (uc >= 0xfe49 && uc <= 0xfe4f)
    return 1;
  
  if (uc >= 0x3010 && uc <= 0x3017)
    return 1;
  
  return 0;
}

/* 日文平假名 */
int isuhiragana(ucs4_t uc)
{
  if (uc >= 0x3040 && uc <= 0x309f)
    return 1;
  
  return 0;
}

/* 日文片假名 */
int isukatakana(ucs4_t uc)
{
  if (uc >= 0x30a0 && uc <= 0x30ff)
    return 1;
  
  if (uc >= 0x31f0 && uc <= 0x31ff)
    return 2;
  
  return 0;
}

/* 韩文 */
int isukorean(ucs4_t uc)
{
  /* 韩文拼音 */
  if (uc >= 0xac00 && uc <= 0xd7af)
    return 1;
  
  /* 韩文字母 */
  if (uc >= 0x1100 && uc <= 0x11ff)
    return 2;
  
  /* 韩文兼容字母 */
  if (uc >= 0x3130 && uc <= 0x318f)
    return 3;
  
  return 0;
}

/////////////////////////////////////////////////////////////

size_t utf8decode(char const *str, wchar_t *des, size_t n, int *illegal) {
    if (n == 0)
    return 0;
    
    char *s = (char *)str;
    size_t i = 0;
    wchar_t uc = 0;
    int r_illegal_all = 0, r_illegal;
    
    while ((uc = getu8c(&s, &r_illegal)))
    {
        if (i < (n - 1))
        {
            des[i++] = uc;
            r_illegal_all += r_illegal;
        }
        else
        {
            ++i;
            break;
        }
    }
    
    des[i] = 0;
    if (illegal)
    {
        *illegal = r_illegal_all + r_illegal;
    }
    
    return i;
}

size_t utf8encode(wchar_t *us, char *des, size_t n, int *illegal)
{
    if (n == 0)
    return 0;
    
    char *s = des;
    size_t left = n;
    size_t len = 0;
    int r_illegal = 0;
    
    *s = 0;
    while (*us)
    {
        int ret = putu8c(*us, &s, &left);
        if (ret > 0)
        {
            len += ret;
        }
        else if (ret == -1)
        {
            r_illegal += 1;
        }
        else
        {
            break;
        }
        
        ++us;
    }
    
    if (illegal)
    {
        *illegal = r_illegal;
    }
    
    return len;
}
size_t utf8len(char const *str, size_t n) {
    if (n == 0)
    return 0;
    
    char *s = (char *)str;
    size_t i = 0;
    wchar_t uc = 0;
    //int r_illegal_all = 0;
    //int r_illegal = 0;
    
    while ((uc = getu8c(&s, NULL)))
    {
        if (i < (n - 1))
        {
            ++i;
            //des[i++] = uc;
            //r_illegal_all += r_illegal;
        }
        else
        {
            ++i;
            break;
        }
    }
    return i;
}
