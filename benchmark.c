#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#define N 4

// Function to get current time in nanoseconds
static inline long long get_ns() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (long long)ts.tv_sec * 1000000000LL + ts.tv_nsec;
}

int main() {
    int8_t A[N][N], B[N][N];
    int32_t C[N][N] = {0};

    // Seed random generator
    srand(time(NULL));

    // Fill matrices A and B with random 8-bit values
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            A[i][j] = (int8_t)(rand() % 256 - 128); // random [-128,127]
            B[i][j] = (int8_t)(rand() % 256 - 128);
        }
    }

    // Record start time
    long long start = get_ns();

    // Matrix multiplication: C = A * B
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            int32_t sum = 0;
            for (int k = 0; k < N; k++) {
                sum += (int32_t)A[i][k] * (int32_t)B[k][j];
            }
            C[i][j] = sum;
        }
    }

    // Record end time
    long long end = get_ns();

    // Print matrices
    printf("\nMatrix A:\n");
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

    printf("\nResult Matrix (C = A * B):\n");
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            printf("%6d ", C[i][j]);
        }
        printf("\n");
    }

    // Print elapsed time
    printf("\nTime taken: %lld ns\n", (end - start));

    return 0;
}
