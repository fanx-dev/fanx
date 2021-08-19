#ifndef __runtime__utf8__
#define __runtime__utf8__

# include <stdint.h>
# include <stddef.h>

size_t utf8decode(char const *str, wchar_t *des, size_t n, int *illegal);
size_t utf8encode(wchar_t *us, char *des, size_t n, int *illegal);
size_t utf8len(char const *str, size_t n);

#endif /* defined(__runtime__utf8__) */
