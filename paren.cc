// 'Paren'
// 2016-11-05
#include <iostream>
#include <vector>

#define LIMIT 20

int memo[LIMIT][LIMIT];

int calc_h(int ln, int rn) {
  if(memo[ln][rn] != -1) return memo[ln][rn];
  int s = 0;
  if(0 < ln) s += calc_h(ln - 1, rn);
  if(ln < rn) s += calc_h(ln, rn - 1);
  memo[ln][rn] = s;
  return s;
}

int calc(int ln, int rn) {
  for(int i = 0; i < LIMIT; i++)
    for(int j = 0; j < LIMIT; j++)
      memo[i][j] = -1;
  memo[0][0] = 1;
  // nankai tadotta ka.
  return calc_h(ln, rn);
}

int main(void) {
  int n;
  std::cin >> n;
  if(n < LIMIT) {
    std::cout << calc(n, n) << "\n";
  }
  return 0;
}
