// 'Score Totalizer Software'
// 2016-11-02
// http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=1147&lang=jp
#include <fstream>
#include <iostream>
#include <string>
#include <cstdlib>

typedef struct {
  int n;
  int* arr;
} set_t;

void min_max(int n, int* arr, int* min, int* max) {
  int min2 = 5000;
  int max2 = -1;
  for(int i = 0; i < n; i++) {
    if(arr[i] < min2) {
      min2 = arr[i];
    }
    if(max2 < arr[i]) {
      max2 = arr[i];
    }
  }
  *min = min2;
  *max = max2;
}

// O(Emi + mi)
void calc1(int len, set_t* sets) {
  int min, max, sum;
  for(int i = 0; i < len; i++) {
    int n = sets[i].n;
    int* arr = sets[i].arr;
    min_max(n, arr, &min, &max);
    sum = 0;
    for(int k = 0; k < n; k++) {
      sum += arr[k];
    }
    int ret = sum / (n - 2);
    std::cout << ret << "\n";
  }
}

// O(nlogn)
void sort(int* arr, int left, int right) {
  if(right <= left) return;
  int p = arr[(left + right) / 2];
  int i = left;
  int j = right;
  while(true) {
    while(arr[i] < p) i++;
    while(p < arr[j]) j--;
    if(j <= i) break;
    int tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
    i++;
    j--;
  }
  sort(arr, left, --i);
  sort(arr, ++j, right);
}

// O(Emilogmi + mi)
void calc2(int len, set_t* sets) {
  for(int i = 0; i < len; i++) {
    int n = sets[i].n;
    int* arr = sets[i].arr;
    sort(arr, 0, n - 1);
    int sum = 0;
    for(int j = 1; j < n - 1; j++) {
      sum += arr[j];
    }
    int ret = sum / (n - 2);
    std::cout << ret << "\n";
  }
}

int main(int argc, char** argv) {
  if(argc != 2) {
    std::cout << "Usage: ./score <filename>\n";
    return -1;
  }
  std::ifstream ifs(argv[1]);
  char str[256];
  if (ifs.fail()) {
    std::cout << "failed\n";
    return -1;
  }
  int i = 0;
  int count = -1;
  set_t* sets = new set_t[20];
  while (ifs.getline(str, 256 - 1)) {
    int k = std::stoi(str);
    if(count == -1 && k == 0) break;

    if(count == -1) {
      i++;
      sets[i - 1].n = k;
      sets[i - 1].arr = new int[k];
      count = k - 1;
    } else {
      sets[i - 1].arr[count] = k;
      count--;
    }
  }
  // calc1(i, sets);
  calc2(i, sets);
  for(int k = 0; k < i; k++) delete[] sets[k].arr;
  delete[] sets;
  return 0;
}
