#include <assert.h>

#define TRUE 1
#define FALSE 0

void *checked_malloc(int);
char * String(char *);

typedef struct U_boolList_ *U_boolList;
struct U_boolList_ {char head; U_boolList tail;};
U_boolList U_BoolList(char head, U_boolList tail);

