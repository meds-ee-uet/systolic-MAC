import numpy as np
import time

# Generate two random 4x4 matrices
A = np.random.randint(0, 10, (4, 4))
B = np.random.randint(0, 10, (4, 4))

print("Matrix A:\n", A)
print("Matrix B:\n", B)

# Measure multiplication time
start = time.perf_counter_ns()
C = np.dot(A, B)   # Matrix multiplication
end = time.perf_counter_ns()

print("Resultant Matrix (A x B):\n", C)
print(f"Time taken: {end - start} ns")
