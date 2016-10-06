// 'Diff' Straigh-forward 1st.
// http://shinh.skr.jp/t/diff_test.cc
// 2016-10-05
#include <iostream>
#include <vector>

typedef struct {
  char sign;
  int src;
} line_t;

int min3(int a, int b, int c) {
  int min = a;
  if(b < min) min = b;
  if(c < min) min = c;
  return min;
}

void diff(int* a, int* b, int al, int bl) {
  int **graph;
  int hsize = al + 1;
  int wsize = bl + 1;
  int i, j;

  // Initialize graph
  graph = new int*[hsize];
  for(i = 0; i < hsize; i++) {
    graph[i] = new int[wsize];
    for(j = 0; j < wsize; j++) {
      graph[i][j] = 0;
    }
  }
  for(i = 0; i < hsize; i++) {
    graph[i][0] = i;
  }
  for(j = 0; j < wsize; j++) {
    graph[0][j] = j;
  }

  // Calculate
  for(i = 1; i < hsize; i++) {
    for (j = 1; j < wsize; j++) {
      int c1 = graph[i][j - 1] + 1;
      int c2 = graph[i - 1][j] + 1;
      int c3 = a[i - 1] == b[j - 1] ? graph[i - 1][j - 1] : INT_MAX;
      graph[i][j] = min3(c1, c2, c3);
    }
  }

  for(int i = 0; i < hsize; i++) {
    for(int j = 0; j < wsize; j++)
      std::cout << graph[i][j] << " ";
    std::cout << "\n";
  }

  // Tail
  i = hsize - 1;
  j = wsize - 1;
  std::vector<line_t> result;
  while(0 < i || 0 < j) {
    int c1 = 0 < j ? graph[i][j - 1] : INT_MAX;
    int c2 = 0 < i ? graph[i - 1][j] : INT_MAX;
    int c3 = (0 < i && 0 < j && a[i - 1] == b[j - 1])
		  ? graph[i - 1][j - 1] : INT_MAX;
    int min = min3(c1, c2, c3);

    line_t line;
    if(min == c3) {
      line.sign = ' ';
      line.src = a[i - 1];
      i--;
      j--;
    } else if (min == c1) {
      line.sign = '+';
      line.src = b[j - 1];
      j--;
    } else {
      line.sign = '-';
      line.src = a[i - 1];
      i--;
    }
    result.push_back(line);
  }

  // Output result
  int size = result.size();
  for(int n = size - 1; 0 <= n; n--) {
    line_t line = result[n];
    std::cout << line.sign << " " << line.src << "\n";
  }

  // Free graph
  for(i = 0; i < hsize; i++) {
    delete[] graph[i];
  }
  delete[] graph;
}

void print(int* a, int al) {
  for(int i = 0; i < al; i++) {
    std::cout << a[i];
    if(i != al - 1)
      std::cout << ", ";
  }
  std::cout << "\n";
}

int main() {
  int a[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  int b[] = {3, 5, 1, 4, 5, 1, 7, 9, 6, 10};
  std::cout << "Input a: ";
  print(a, 10);
  std::cout << "Input b: ";
  print(b, 10);
  diff(a, b, 10, 10);

  return 0;
}
