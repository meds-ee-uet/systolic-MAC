#include <stdio.h>
#include <time.h>

#define N 4

int main() {
    int A[N][N] = {
        {4, 7, 1, 6},
        {0, 2, 3, 8},
        {5, 9, 4, 2},
        {6, 3, 7, 1}
    };

    int B[N][N] = {
        {3, 8, 6, 2},
        {1, 7, 5, 9},
        {4, 0, 2, 3},
        {7, 5, 1, 4}
    };

    int C[N][N] = {0};

    struct timespec start, end;

    // Record start time
    clock_gettime(CLOCK_MONOTONIC, &start);

    // Matrix multiplication
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            for (int k = 0; k < N; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    // Record end time
    clock_gettime(CLOCK_MONOTONIC, &end);

    // Calculate time in nanoseconds
    long ns = (end.tv_sec - start.tv_sec) * 1000000000L +
              (end.tv_nsec - start.tv_nsec);

    // Print matrices and result
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

    printf("\nTime taken: %ld ns\n", ns);

    return 0;
}
