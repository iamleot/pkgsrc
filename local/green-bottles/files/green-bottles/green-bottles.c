#include <stdio.h>

void
sing_green_bottles(int n)
{
	const char *numbers[] = { "no more", "one", "two", "three", "four", "five",
	    "six", "seven", "eight", "nine", "ten" };

	if ((1 <= n) && (n <= 10)) {
		printf("%s green bottle%s hanging on the wall\n",
		    numbers[n], n > 1 ? "s" : "");
		printf("%s green bottle%s hanging on the wall\n",
		    numbers[n], n > 1 ? "s" : "");
		printf("and if %s green bottle should accidentally fall,\n",
		    n > 2 ? "one" : "that");
		printf("there'll be %s green bottles hanging on the wall.\n",
		    numbers[n - 1]);
	}

	return;
}


/*
 * Sing the famous `Ten Green Bottles' song.
 */
int
main(void)
{
	int i;

	for (i = 10; i > 0; i--) {
		sing_green_bottles(i);
	}

	return 0;
}
