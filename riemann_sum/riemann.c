#include <stdio.h>
#include <omp.h>

int main(int argc, char** argv){
    double start = omp_get_wtime();  // Get start time in seconds
    omp_set_num_threads(4);  // Set the number of threads to 8

    #pragma omp parallel for
    for(int j = 1 ; j<=16384; j++){
        int interval = j;
        long double stepping = 1/(long double)interval;
        long double x = stepping/2;
        long double sum = 0;

        for(int i=0; i<interval; i++){
            sum += 4/(1+x*x);
            x += stepping;
			//printf("Debug: sum: %Lf\t x: %Lf\n", sum, x);
        }

        sum = sum/interval;

        // Ensure output is not cluttered, printing for certain intervals only
        if(interval % 4096 == 0){
            printf("Sum is: %.64Lf on %d intervals (Thread %d)\n", sum, interval, omp_get_thread_num());
        }
    }

    double end = omp_get_wtime();  // Get end time in seconds
    double elapsed = (end - start) * 1000;  // Convert to milliseconds

    printf("Took %.2f ms to complete.\n", elapsed);

    return 0;
}
