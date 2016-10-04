// 'Puyo Puyo'
// http://golf.shinh.org/p.rb?Puyo%20Puyo
// Straight-forward
// 2016-10-04 - 03 3
#include <iostream>
#include <string>
#include <fstream>
#include <vector>

typedef struct {
  int x;
  int y;
} point_t;

const int WIDTH = 6;
const int HEIGHT = 13;
char arr[WIDTH][HEIGHT];
int chain = 0;
bool checkBuf[WIDTH][HEIGHT];
bool puyosToRemove[WIDTH][HEIGHT];

std::vector<point_t> rensaLine;

void Print() {
  for(int j = 0; j < HEIGHT; j++) {
    for(int i = 0; i < WIDTH; i++) {
      std::cout << arr[i][j];
    }
    std::cout << "\n";
  } 
}

void Initialize(bool buf[WIDTH][HEIGHT]) {
  for(int i = 0; i < WIDTH; i++) {
    for(int j = 0; j < HEIGHT; j++) {
      buf[i][j] = false;
    }
  }
}

void UpdatePuyosToRemove() {
  int size = rensaLine.size();
  for(int i = 0; i < size; i++) {
    point_t pt = rensaLine[i];
    puyosToRemove[pt.x][pt.y] = true;
  }
}

// Return true if renewing screen arr happened more than once.
bool ApplyPuyosToRemove() {
  int count = 0;
  bool renewed = false;

  for(int i = 0; i < WIDTH; i++) {
    count = 0;
    char tmp[HEIGHT];

    for(int j = HEIGHT - 1; 0 <= j; j--) {
      if(!puyosToRemove[i][j]) {
	tmp[count] = arr[i][j];
	count++;
      }
    }

    if(count != HEIGHT) {
      // Copy tmp to screen arr.
      renewed = true;
      for(int j = HEIGHT - 1; 0 <= j; j--) {
	int reverse = HEIGHT - j - 1;
	arr[i][j] = reverse < count ? tmp[reverse] : ' ';
      }
    }
  }
  return renewed;
}

// (x, y) = (0, 0) left of the top
void SearchSides(int x, int y, char target) {
  if(x < 0 || WIDTH <= x || y < 0 || HEIGHT <= y ||
     checkBuf[x][y] || arr[x][y] != target)
    return;
  checkBuf[x][y] = true;
  point_t pt = {x, y};
  rensaLine.push_back(pt);
  SearchSides(x - 1, y, target);
  SearchSides(x, y + 1, target);
  SearchSides(x + 1, y, target);
  SearchSides(x, y - 1, target);
}

bool UpdateScreen() {
  Initialize(checkBuf);
  Initialize(puyosToRemove);

  for(int i = 0; i < WIDTH; i++) {
    for(int j = 0; j < HEIGHT; j++) {
      if(arr[i][j] == ' ') {
	continue;
      }

      rensaLine.clear();
      SearchSides(i, j, arr[i][j]);

      if(4 <= rensaLine.size()) {
	UpdatePuyosToRemove();
      }
    }
  }
  // Fall down all puyos after remove puyos-to-remove.
  return ApplyPuyosToRemove();
}

void Start() {
  chain = 0;
  while(UpdateScreen()) {
    chain++;
  }
}

int main(int argc, char** argv) {
  if (argc != 2) {
    std::cout << "Usage: ./puyo filename\n";
    return 1;
  }
  std::string filename = argv[1];
  std::ifstream ifs(filename);
  std::string line;
  std::string tmp;
  int j = 0;
  while (std::getline(ifs, line) && j < HEIGHT) {
    tmp = line.substr(1, WIDTH);
    for(int i = 0; i < WIDTH; i++) {
      arr[i][j] = tmp[i];
    }
    // sprintf(arr[j], "%s", tmp.c_str());
    j++;
  }
  std::cout << "------ Input : " << filename << " ------\n";
  Print();
  std::cout << "------ Output ------\n";
  Start();
  Print();
  std::cout << chain << " chains!\n";
  return 0;
}
