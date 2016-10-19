// 'Fib'
#include <iostream>

#define MAX 50
typedef unsigned long long ull;
ull memo[MAX];

ull fib(int n) {
  memo[0] = 1;
  memo[1] = 1;
  for(int i = 2; i <=n; i++) {
    memo[i] = memo[i - 2] + memo[i - 1];
  }
  return memo[n];
}

int main() {
  ull n;
  std::cin >> n;

  ull ans = fib (n);
  std::cout << ans << "\n";
  return 0;
}
