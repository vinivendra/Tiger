%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos=1;

int commentLevel = 0;

int yywrap(void)
{
 charPos=1;
 return 1;
}


void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

%}

character [a-zA-Z]
digit[0-9]

%x COMMENT
%%

<INITIAL>"/*" { // Comments
	adjust();
	BEGIN(COMMENT);
	commentLevel++;
	return COMMENT_START;
}
<COMMENT>"/*" {
	adjust();
	commentLevel++;
	return COMMENT_START;
}
<COMMENT>"*/" {
	adjust();
	commentLevel--;
	if (commentLevel == 0) {
		BEGIN(INITIAL);
	}
	return COMMENT_END;
}
<COMMENT>. {adjust(); continue;}


" "	 {adjust(); continue;}
\n	 {adjust(); EM_newline(); continue;}
","	 {adjust(); return COMMA;}

for  	 {adjust(); return FOR;}

({character})({character}|{digit}|"_")* { // ID
	adjust();
	yylval.sval = yytext;
	return ID;
}

[0-9]+	 { // INT
	adjust();
	yylval.ival = atoi(yytext);
	return INT;
}




.	 {adjust();} // EM_error(EM_tokPos,"illegal token");
