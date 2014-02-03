#include<cstdio>

int main(void){
	for(int i=0;i<100;i++){
		int x;
		scanf("%d", &x);
		printf("%d\n", x + 1);
		fflush(stdout);
	}

	return 0;
}
