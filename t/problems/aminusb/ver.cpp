#include <cstdio>

int main(void){
	FILE *output = fdopen(3, "r");
	int a, b, ret;
	scanf("%d%d", &a, &b);
	fscanf(output, "%d", &ret);
	if(a-b == ret){
		printf("20");
		return 0;
	} else
		return 1;
}

