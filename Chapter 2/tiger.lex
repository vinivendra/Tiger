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

%s COMMENT
%%

" "	 {adjust(); continue;}
\n	 {adjust(); EM_newline(); continue;}
","	 {adjust(); return COMMA;}
for  	 {adjust(); return FOR;}
[0-9]+	 {adjust(); yylval.ival=atoi(yytext); return INT;}

<INITIAL>"/*" {
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



.	 {adjust();} // EM_error(EM_tokPos,"illegal token");
