// 'Does a string have all unique characters?' sf lst.
#include <iostream>

// Check without any additional data structure
bool isUnique(std::string str) {
  for(int i = 0; i < str.size(); i++) {
    for(int j = i + 1; j < str.size(); j++) {
      if(str[j] == str[i])
        return false;
    }
  }
  return true;
}

// Check with additional data structure
bool isUnique2(std::string str) {
  char check[256];
  for(int i = 0; i < str.size(); i++) {
    if(check[str[i]] != ' ')
      return false;
    check[str[i]] = str[i];
  }
  return true;
}

std::string reverse(std::string s) {
  int n = s.size();
  std::string str = s;
  for(int i = 0, j = n - 1; i < j; i++, j--) {
    char tmp = str[i];
    str[i] = str[j];
    str[j] = tmp;
  }
  return str;
}

std::string reverse2(std::string s) {
  int n = s.size();
  if(n < 2) return s;
  std::string h(1, s[0]);
  std::string t = reverse2(s.substr(1));
  return t + h;
}

int main() {
  std::string str;
  std::cin >> str;
  std::cout << str << " is unique " << isUnique2(str) << "\n";
  std::cout << str << " reversed " << reverse2(str) << "\n";
  return 0;
}
