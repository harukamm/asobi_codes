// 'Score Totalizer Software'
// 2016-11-02
// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1147&lang=jp
#include <iostream>
#include <vector>
#include <algorithm>

int main() {
  while(1) {
    int n;
    std::cin >> n;
    if(n == 0)
      break;
    std::vector<int> v(n);
    for(int i = 0; i < n; i++) {
      std::cin >> v[i];
    }
    std::sort(v.begin(), v.end());
    int s = 0;
    for(int i = 1; i < n - 1; i++) {
      s += v[i];
    }
    std::cout << (s / (n - 2)) << "\n";
  }
  return 0;
}
