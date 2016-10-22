// 'Add number indicated by Single-linked-list.'
// 2016-10-22
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define LIMIT 50

typedef struct slist {
  int num;
  struct slist* next;
} slist;

slist* convert_num_to_slist(int num) {
  if (num <= 0) {
    return NULL;
  }
  slist* rest = convert_num_to_slist(num / 10);
  int n = num % 10;
  slist* s = (slist*)malloc(sizeof(slist));
  s->num = n;
  s->next = rest;
  return s;
}

// helper
int convert_slist_to_num_h(slist* s, int digit, int acc) {
  if (s == NULL) {
    return acc;
  }
  int ret = (int)(pow(10, digit));
  acc += (s->num) * ret;
  return convert_slist_to_num_h(s->next, ++digit, acc);
}

int convert_slist_to_num(slist* s) {
  return convert_slist_to_num_h(s, 0, 0);
}

void free_slist(slist* s) {
  if(s != NULL) {
    slist* tmp = s->next;
    free(s);
    free_slist(tmp);
  }
}

void print_slist(slist* s) {
  if(s != NULL) {
    printf("%d -> ", s->num);
    print_slist(s->next);
  } else {
    printf("NULL");
  }
}

slist* add(slist* s1, slist* s2) {
  int s1_num = convert_slist_to_num(s1);
  int s2_num = convert_slist_to_num(s2);
  return convert_num_to_slist(s1_num + s2_num);
}

int main() {
  slist* lst1 = convert_num_to_slist(6017);
  slist* lst2 = convert_num_to_slist(295);
  print_slist(lst1);
  putchar('\n');
  print_slist(lst2);
  putchar('\n');
  slist* lst3 = add (lst1, lst2);
  print_slist(lst3);
  putchar('\n');
  free_slist(lst1);
  free_slist(lst2);
  free_slist(lst3);
  return 0;
}
