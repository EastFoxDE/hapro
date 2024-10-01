#include <stdio.h>
#include <omp.h>

int main(int argc, char** argv){
    double start = omp_get_wtime();  // Get start time in seconds
    omp_set_num_threads(8);  // Set the number of threads to 8

    #pragma omp parallel for
    for(int j = 1 ; j<=32768; j++){
        int intervall = j;
        long double stepping = 1/(long double)intervall;
        long double x = stepping/2;
        long double sum = 0;

        for(int i=0; i<intervall; i++){
            sum += 4/(1+x*x);
            x += stepping;
        }

        sum = sum/intervall;

        // Ensure output is not cluttered, printing for certain intervals only
        if(intervall % 4096 == 0){
            printf("Sum is: %.64Lf on %d intervals (Thread %d)\n", sum, intervall, omp_get_thread_num());
        }
    }

    double end = omp_get_wtime();  // Get end time in seconds
    double elapsed = (end - start) * 1000;  // Convert to milliseconds

    printf("Took %.2f ms to complete.\n", elapsed);

    return 0;
}
