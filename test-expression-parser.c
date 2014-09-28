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

#include "y.tab.h"
 
int main(int argc, char *argv[])
{
	int rc, has_error,  bye = 0;
	long long result;
	double dresult;
	char buffer[100];

	do {
		if (fgets(buffer, 90, stdin) == NULL)
			break;
		rc = strlen(buffer);
		if (rc > 0 && buffer[rc - 1] == '\n')
			buffer[rc - 1] = '\0';
		rc = evaluate_arithmetic_expression(buffer, &result, &dresult);
		if (!rc) {
			printf("%lld (%lf)\n", result, dresult);
		} else {
			result = 0;
			dresult = 0;
		}
	} while (!bye);
	return 0;
}

