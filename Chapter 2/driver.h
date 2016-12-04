#ifndef driver_h
#define driver_h

#include "util.h"
#include "errormsg.h"
#include "tokens.h"

int yylex(void); /* prototype for the lexing function */

//char * toknames[] = {
//	"ID", "STRING", "INT", "COMMA", "COLON", "SEMICOLON", "LPAREN",
//	"RPAREN", "LBRACK", "RBRACK", "LBRACE", "RBRACE", "DOT", "PLUS",
//	"MINUS", "TIMES", "DIVIDE", "EQ", "NEQ", "LT", "LE", "GT", "GE",
//	"AND", "OR", "ASSIGN", "ARRAY", "IF", "THEN", "ELSE", "WHILE", "FOR",
//	"TO", "DO", "LET", "IN", "END", "OF", "BREAK", "NIL", "FUNCTION",
//	"VAR", "TYPE"
//};
//
//
//char * tokname(tok) {
//	return tok<257 || tok>299 ? "BAD_TOKEN" : toknames[tok-257];
//}

#endif /* driver_h */
