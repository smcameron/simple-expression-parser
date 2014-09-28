%{

/*
	(C) Copyright 2014, Stephen M. Cameron.

	This file is part of simple-expression-parser.

	simple-expression-parser is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	simple-expression-parser is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with simple-expression-parser; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <stdio.h>
#include <string.h>

struct parser_value_type {
	double dval;
	int ival;
	int has_dval;
	int has_error;
};

typedef union valtype {
	struct parser_value_type v;
} PARSER_VALUE_TYPE;

#define YYSTYPE PARSER_VALUE_TYPE

int yyerror(__attribute__((unused)) int *result,
		__attribute__((unused)) double *dresult,
		__attribute__((unused)) int *has_error,
		__attribute__((unused)) int *bye, const char *msg);

extern int yylex(void);
extern void yyrestart(FILE *file);

%}

%union valtype {
	struct parser_value_type {
		double dval;
		int ival;
		int has_dval;
		int has_error;
	} v;
};

%token <v> NUMBER
%token <v> BYE
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS
%parse-param { int *result }
%parse-param { double *dresult }
%parse-param { int *has_error }
%parse-param { int *bye }

%type <v> expression
%%

top_level:	expression {
				*result = $1.ival;
				*dresult = $1.dval;
				*has_error = $1.has_error;
			}
		| expression error {
				*result = $1.ival;
				*dresult = $1.dval;
				*has_error = 1;
			}
expression:	expression '+' expression { 
			if (!$1.has_dval && !$3.has_dval)
				$$.ival = $1.ival + $3.ival;
			else
				$$.ival = (int) ($1.dval + $3.dval);
			$$.dval = $1.dval + $3.dval;
			$$.has_error = $1.has_error || $3.has_error;
		}
	|	expression '-' expression {
			if (!$1.has_dval && !$3.has_dval)
				$$.ival = $1.ival - $3.ival; 
			else
				$$.ival = (int) ($1.dval - $3.dval); 
			$$.dval = $1.dval - $3.dval; 
			$$.has_error = $1.has_error || $3.has_error;
		}
	|	expression '*' expression {
			if (!$1.has_dval && !$3.has_dval)
				$$.ival = $1.ival * $3.ival;
			else
				$$.ival = (int) ($1.dval * $3.dval);
			$$.dval = $1.dval * $3.dval;
			$$.has_error = $1.has_error || $3.has_error;
		}
	|	expression '/' expression {
			if ($3.ival == 0)
				yyerror(0, 0, 0, 0, "divide by zero");
			else
				$$.ival = $1.ival / $3.ival;
			if ($3.dval < 1e-20 && $3.dval > -1e-20)
				yyerror(0, 0, 0, 0, "divide by zero");
			else
				$$.dval = $1.dval / $3.dval;
			if ($3.has_dval || $1.has_dval)
				$$.ival = (int) $$.dval;
			$$.has_error = $1.has_error || $3.has_error;
		}
	|	'-' expression %prec UMINUS {
			$$.ival = -$2.ival;
			$$.dval = -$2.dval;
			$$.has_error = $2.has_error;
		}
	|	'(' expression ')' { $$ = $2; }
	|	NUMBER { $$ = $1; }
	|	BYE { $$ = $1; *bye = 1; };
%%
#include <stdio.h>

/* Urgh.  yacc and lex are kind of horrible.  This is not thread safe, obviously. */
static int lexer_read_offset = 0;
static char lexer_input_buffer[1000];

int lexer_input(char* buffer, int *bytes_read, int bytes_requested)
{
	int bytes_left = strlen(lexer_input_buffer) - lexer_read_offset;

	if (bytes_requested > bytes_left )
		bytes_requested = bytes_left;
	memcpy(buffer, &lexer_input_buffer[lexer_read_offset], bytes_requested);
	*bytes_read = bytes_requested;
	lexer_read_offset += bytes_requested;
	return 0;
}

static void setup_to_parse_string(char *string)
{
	unsigned int len;

	len = strlen(string);
	if (len > sizeof(lexer_input_buffer) - 3)
		len = sizeof(lexer_input_buffer) - 3;

	strncpy(lexer_input_buffer, string, len);
	lexer_input_buffer[len] = '\0'; 
	lexer_input_buffer[len + 1] = '\0';  /* lex/yacc want string double null terminated! */
	lexer_read_offset = 0;
}

int evaluate_arithmetic_expression(char *buffer, int *ival, double *dval)
{
	int rc, bye = 0, has_error = 0;

	setup_to_parse_string(buffer);
	rc = yyparse(ival, dval, &has_error, &bye);
	yyrestart(NULL);
	if (rc || bye || has_error) {
		*ival = 0;
		*dval = 0;
		has_error = 1;
	}
	return has_error;
}

int yyerror(__attribute__((unused)) int *result,
		__attribute__((unused)) double *dresult,
		__attribute__((unused)) int *has_error,
		__attribute__((unused)) int *bye, const char *msg)
{
	fprintf(stderr, "xxxx %s\n", msg);
	return 0;
}

