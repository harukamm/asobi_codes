// 'bit asobi'
// 2016-11-11
#include <stdio.h>
#include <stdlib.h>

int power(int n, int l) {
  return l < 1 ? 1 : n * power(n, l - 1);
}

int bketa(int n) {
  int d = 1;
  int a = 2;
  while(n >= a) {
    d++;
    a *= 2;
  }
  return d;
}

int btoi(char* b, int len) {
  int i, n = 0;
  int a = 1;
  for(i = len - 1; 0 <= i; i--) {
    n += (b[i] - '0') * a;
    a *= 2;
  }
  return n;
}

char* itob(int n) {
  int i, len = bketa(n);
  char* b = (char*)malloc(len);
  for(i = len - 1; 0 <= i; i--) {
    b[i] = n % 2 + '0';
    n = n / 2;
  }
  return b;
}

int insertBit(int n, int m, int i, int j) {
 int mask = (1 << (j - i + 1)) - 1;
  mask = mask << i;
  return (n & ~mask) | (m << i);
}

int isOne1Bit(int n) {
  return (n & (n - 1)) == 0;
}

int getLargest(int n) {
  int mask1 = 1;
  if(n == 0) return 0;
  while((mask1 & n) == 0) mask1 = mask1 << 1;
  int mask0 = mask1 << 1;
  while((mask0 & n) != 0) mask0 = mask0 << 1;
  return (n & ~mask1) | mask0;
}

int main(void) {
  int n = btoi("11111111111", 11);
  int m = btoi("10000", 5);
  int n2 = insertBit(n, m, 2, 6);
  printf("insert %s into %s (%d ~ %d) => %s\n", itob(m), itob(n), 6, 2, itob(n2));
  int t = btoi("10101110", 8);
  printf("largest : %s => %s\n", itob(t), itob(getLargest(t)));
  return 0;
}
