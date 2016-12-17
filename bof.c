#include <stdio.h>

int main(void) {
  char buf[32];
  gets(buf);
  printf("Hello, %s\n", buf);
  return 0;
}
