// 'Coin Charge'
// 2016-10-06
#include <iostream>
#include <vector>

int coins[] = {1, 5, 10, 100, 500};
int size = 5;
int** memo;

int calc(int m, int i) {
  if(m == 0)
    return 1;
  if(i < 0 || size <= i)
    return 0;
  if(memo[m][i] != -1)
    return memo[m][i];

  int x = 0;
  int coin = coins[i];
  for(int j = 0;; j++) {
    int rest = m - (coin * j);
    if(rest < 0) break;
    x += calc(rest, i + 1);
  }
  return (memo[m][i] = x);
}

int main() {
  int n;
  std::cin >> n;

  memo = new int*[n + 1];
  for(int i = 0; i < n + 1; i++) {
    memo[i] = new int[size];
    for(int j = 0; j < size; j++)
      memo[i][j] = -1;
  }
  std::cout << calc(n, 0) << "\n";
}
