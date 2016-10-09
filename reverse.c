// 'Reverse single-linked-list'
// 2016-10-09
#include <stdio.h>
#include <stdlib.h>

typedef struct slist {
  int num;
  struct slist* next;
} slist;

slist* create_slist(int i) {
  if(i < 0) {
    return NULL;
  }
  slist* rest = create_slist(i - 1);
  slist* s = (slist*)malloc(sizeof(slist));
  s->num = i;
  s->next = rest;
  return s; 
}

slist* reverse(slist* s, slist* prev) {
  if(s->next == NULL) { // the end of list.
    s->next = prev;
    return s;
  } else {
    slist* tmp = s->next;
    s->next = prev;
    return reverse(tmp, s); 
  }
}

void print_slist(slist* s) {
  if(s != NULL) {
    printf("%d, ", s->num);
    print_slist(s->next);
  }
}

void free_slist(slist* s) {
  if(s != NULL) {
    slist* tmp = s->next;
    free(s);
    free_slist(tmp);
  }
}

int main() {
  slist* s = create_slist(4); 
  print_slist(s);
  putchar('\n');
  slist* rev = reverse(s, NULL);
  print_slist(rev);
  putchar('\n');
  free_slist(s);
  return 0;
}
