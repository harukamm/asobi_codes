#include <iostream>

#define N 30

int board[N][2];
int queen;

void init() {
  for(int i = 0; i < N; i++) {
    board[i][0] = 0;
    board[i][1] = 0;
  }
  queen = 0;
}

int abs(int n) {
  return n < 0 ? (-n) : n;
}

bool is_candidate(int x, int y) {
  for(int i = 0; i < queen; i++) {
    int q_x = board[i][0];
    int q_y = board[i][1];
    if(x == q_x || y == q_y)
      return false;
    if(abs(q_x - x) == abs(q_y - y))
      return false;
  }
  return true;
}

void put_on(int x, int y) {
  board[queen][0] = x;
  board[queen][1] = y;
  queen++;
}

void print_line() {
  std::cout << "\n";
  for(int i = 0; i < 2 * N + 1; i++)
    std::cout << "-";
  std::cout << "\n";
}

void print_board() {
  bool** pos = new bool*[N];
  for(int i = 0; i < N; i++) {
    pos[i] = new bool[N];
    for(int j = 0; j < N; j++) {
      pos[i][j] = false;
    }
  }
  for(int i = 0; i < queen; i++) {
    const int x = board[i][0];
    const int y = board[i][1];
    pos[y][x] = true;
  }
  print_line();
  for(int h = 0; h < N; h++) {
    std::cout << "|";
    for(int w = 0; w < N; w++) {
      if(pos[h][w])
        std::cout << "q|";
      else
        std::cout << ".|";
    }
    print_line();
  }

  for(int i = 0; i < N; i++)
    free(pos[i]);
  free(pos);
}

bool nqueen(int x) {
  if(queen == N)
    return true;
  int tmp = queen;
  for(int y = 0; y < N && queen < N; y++) {
    if(!is_candidate(x, y))
      continue;
    put_on(x, y);
    if(nqueen(x + 1))
      return true;
    else
      queen = tmp; // Revert putting queens
  }
  return false;
}

int main() {
  init();
  if(nqueen(0)) {
    print_board();
  } else {
    std::cout << "no solution\n";
  }
  return 0;
}
