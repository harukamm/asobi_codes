// 'bit asobi'
// 2016-11-11
#include <stdio.h>

int insertBit(int n, int m, int i, int j) {
 int mask = (1 << (j - i + 1)) - 1;
  mask << i;
  return (n & ~mask) | (m << i);
}


int main(void) {
  int n2 = insertBit(0x400, 0x13, 2, 6);
  printf("0x%08x\n", n2);
  return 0;
}