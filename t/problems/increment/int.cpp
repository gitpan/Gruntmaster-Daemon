#include<cstdio>
#include<cstdlib>
#include<ctime>
#include<unistd.h>

int main(void){
	srand(time(NULL));
	for(int i=0;i<100;i++){
		int nr = rand() % 100;
		printf("%d\n", nr);
		fflush(stdout);
		int ret;
		scanf("%d", &ret);
		if(ret != nr + 1){
			fprintf(stderr, "bad ret: %d instead of %d", ret, nr + 1);
			return 1;
		}
	}

	if(write(4, "20", 2) == -1)
		perror("write");
	return 0;
}
