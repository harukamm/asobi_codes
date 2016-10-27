// 'Stack and Queue'
// 2016-10-25
#include <iostream>

#define LIMIT 99
char* stack_arr = new char[LIMIT];
char* queue_arr = new char[LIMIT];
int qfst, qnxt, qnum, sfst, snum = 0;

typedef struct respo_t {
  int state;
  char ans;
} respo_t;

respo_t enqueue(char v) {
  respo_t respo;
  if(qnum == LIMIT) { // ippai
    respo.state = -1;
  } else {
    respo.state = 1;
    queue_arr[qnxt] = v;
    qnxt = qnxt == LIMIT - 1 ? 0 : qnxt + 1;
    qnum++;
  }
  return respo;
}

respo_t dequeue(void) {
  respo_t respo;
  if(qnum == 0) {
    respo.state = -1;
  } else {
    respo.state = 1;
    respo.state = queue_arr[qfst];
    qfst = qfst == LIMIT - 1 ? 0 : qfst + 1;
    qnum--;
  }
  return respo;
}

respo_t push(char v) {
  respo_t respo;
  int nxt = snum + 1;
  if(LIMIT < nxt) { // ippai
    respo.state = -1;
  } else {
    stack_arr[nxt - 1] = v;
    snum = nxt;
    respo.state = 1;
  }
  return respo;
}

respo_t pop(void) {
  respo_t respo;
  if(snum == 0) {
    respo.state = -1;
  } else {
    respo.state = 1;
    respo.ans = stack_arr[snum - 1];
    snum--;
  }
  return respo;
}

void print_queue(void) {
  if(qnum == 0) return;
  int ret = qnum;
  int ptr = qfst;
  while(0 < ret) {
    std::cout << queue_arr[ptr] << "->";
    ptr = ptr == LIMIT - 1 ? 0 : ptr + 1;
    ret--;
  }
  std::cout << "done\n";
}

void print_stack(void) {
  for(int i = 0; i < snum; i++) {
    std::cout << stack_arr[i] << "->";
    if(i == snum - 1)
      std::cout << "done\n";
  }
}

int main() {
  push('1');
  push('2');
  push('3');
  print_stack();
  pop();
  print_stack();
  push('4');
  print_stack();
  return 0;
}
