#include <cstdio>

int main(void){
	FILE *output = fdopen(3, "r");
	int x, ret;
	scanf("%d", &x);
	fscanf(output, "%d", &ret);
	if(x*x == ret){
		printf("10");
		return 0;
	} else
		return 1;
}

