# Developer’s Guide

# Conceptual Overview

### What is a Systolic Array?
- In parallel computer architectures, a **systolic array** is a homogeneous network of tightly coupled **data processing units (DPUs)** called *cells* or *nodes*.  
- Each node or DPU:
  - Independently computes a partial result as a function of the data received from its upstream neighbours.  
  - Stores the result within itself.  
  - Passes it downstream.  



---

### Applications of Systolic Arrays
🔹 **Deep Learning Accelerators (ML)**  
Efficiently perform parallel matrix multiplications in neural networks like **CNNs** and **Transformers**.  

🔹 **Image & Signal Processing (DSP)**  
Enable real-time convolution operations for filtering, edge detection, and motion estimation.  

🔹 **DNA Sequence Alignment (Biology)**  
Accelerate alignment algorithms like **Smith-Waterman** using parallel dataflow for fast genome matching.  

🔹 **MIMO Signal Processing (DSP/Comms)**  
Support high-throughput matrix operations for channel equalization and beamforming in wireless systems.  

...and much more.  

---

## Main Parts of a Systolic Array
- [mac-unit](mac-unit-conceptual.md)
- [processing-element](processing-element-conceptual.md)
- [systolic-array](systolic-array-conceptual.md)


# DESIGN OVERVIEW

## Specialty & Performance

- We built the entire **Systolic Array** completely from scratch, covering all modules and interconnections.  
- On a **3 GHz machine**, the full computation completed in just **~15 ns**.  
- This results in a performance that is nearly **50-160** times faster than a general purpose cpu(check the benchmarks section). 

---

# Explanation of Our Design

---
- [mac-unit](mac-unit.md)
- [processing-element](processing-element.md)
- [data-feeders](data-feeders.md)
- [systolic-top](systolic-top.md)
- [interface](interface.md)
- [systolic-array](systolic.md)
