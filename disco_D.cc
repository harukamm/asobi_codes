#include <iostream>
#include <assert.h>

#define DEBUG false

int h, w;
int happy_h, happy_w;
bool** m;

int* init_state() {
  int* state = new int[8]();

  bool a, b, c, d;
  int v;
  for(int y = 0; y < h / 2; y++) {
    for(int x = 0; x < w / 2; x++) {
      a = m[y][x];
      b = m[y][w - x - 1];
      c = m[h - y - 1][x];
      d = m[h - y - 1][w - x - 1];
      if(a) {
        v = (((b << 1) | c) << 1) | d;
      } else if(b) {
        v = (d << 1) | c;
      } else if(c) {
        v = d << 2;
      } else if(d) {
        v = 0;
      } else {
        v = -1;
      }
      if(0 <= v) {
        state[v]++;
      }
    }
  }
  return state;
}

int calc_score(int* state) {
  int score = 0;

  int s = state[3] + state[5] + state[6];
  bool symm_h = !s && !state[4];
  bool symm_w = !s && !state[2];
  if(state[0] | state[1]) {
    score += symm_h ? happy_h : 0;
    score += symm_w ? happy_w : 0;
  }

  int score1 = score;
  int s2 = state[2] + s;
  int s7 = state[7];
  symm_w = !s2;
  if(!symm_h) {
    score1 += happy_h;
    score1 += symm_w ? happy_w : 0;
  }
  if(s2 || s7) {
    int v1 = (s2 + s7 * 2) * happy_h + ((s2 ? 1 : 0) + s7) * happy_w;
    int v2 = (s2 + s7) * happy_h + ((s2 ? 1 : 0) + s7 * 2) * happy_w;
    score1 += std::max(v1, v2);
  }

  int score2 = score;
  int s4 = state[4] + s;
  symm_h = !s4;
  if(!symm_w) {
    score2 += happy_w;
    score2 += symm_h ? happy_h : 0;
  }
  if(s4 || s7) {
    int v1 = (s4 + s7 * 2) * happy_w + ((s4 ? 1 : 0) + s7) * happy_h;
    int v2 = (s4 + s7) * happy_w + ((s4 ? 1 : 0) + s7 * 2) * happy_h;
    score2 += std::max(v1, v2);
  }

  return std::max(score1, score2);
}

int calc() {
  int* state = init_state();
  int score1 = calc_score(state);
  free(state);
  return score1;
}

int main() {
  std::cin >> h;
  std::cin >> w;
  std::cin >> happy_h;
  std::cin >> happy_w;
  m = new bool*[h];
  char c;
  for(int y = 0; y < h; y++) {
    m[y] = new bool[w];
    for(int x = 0; x < w; x++) {
      std::cin >> c;
      m[y][x] = c == 'S';
    }
  }

  int r = calc();
  std::cout << r;

  for(int y = 0; y < h; y++)
    free(m[y]);
  free(m);
}
