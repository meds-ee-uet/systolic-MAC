#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 4
#define REPEAT 10  // number of repetitions

int main() {
    int A[N][N], B[N][N], C[N][N];
    struct timespec start, end;

    // Seed random number generator
    srand(time(NULL));

    // Fill A and B with random values 0–9
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            A[i][j] = rand() % 1000;
            B[i][j] = rand() % 1000;
        }
    }

    // Start timing
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (int r = 0; r < REPEAT; r++) {
        // Reset C
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                C[i][j] = 0;
            }
        }

        // Multiply A and B
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                for (int k = 0; k < N; k++) {
                    C[i][j] += A[i][k] * B[k][j];
                }
            }
        }
    }

    // End timing
    clock_gettime(CLOCK_MONOTONIC, &end);

    long ns = (end.tv_sec - start.tv_sec) * 1000000000L +
              (end.tv_nsec - start.tv_nsec);

    double avg_time = (double) ns / REPEAT;

    // Print matrices
    printf("Matrix A:\n");
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%4d ", A[i][j]);
        }
        printf("\n");
    }

    printf("\nMatrix B:\n");
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%4d ", B[i][j]);
        }
        printf("\n");
    }

    printf("\nResultant Matrix (A x B):\n");
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%4d ", C[i][j]);
        }
        printf("\n");
    }

    printf("\nTotal time for %d multiplications: %ld ns\n", REPEAT, ns);
    printf("Average time per multiplication: %.2f ns\n", avg_time);

    return 0;
}
