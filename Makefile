
CFLAGS=-Wall -Wextra

all:	test-expression-parser

lex.yy.o:	lex.yy.c y.tab.h

lex.yy.o y.tab.o:	y.tab.h

y.tab.c y.tab.h:	expression-parser.y
	$(YACC) -d expression-parser.y

lex.yy.c:	expression-parser.l
	$(LEX) expression-parser.l

test-expression-parser:	y.tab.o lex.yy.o test-expression-parser.c
	gcc -o test-expression-parser test-expression-parser.c y.tab.o lex.yy.o -ly -ll

clean:
	rm -f lex.yy.c y.tab.c y.tab.h *.o test-expression-parser
