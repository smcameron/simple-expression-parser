#include <stdio.h>
#include <string.h>

#include "y.tab.h"
 
int main(int argc, char *argv[])
{
	int rc, has_error, result, bye = 0;
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
			printf("%d (%lf)\n", result, dresult);
		} else {
			result = 0;
			dresult = 0;
		}
	} while (!bye);
	return 0;
}

