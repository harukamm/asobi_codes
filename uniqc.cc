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

int main() {
  std::string str;
  std::cin >> str;
  std::cout << str << " is unique " << isUnique2(str) << "\n";
  return 0;
}
