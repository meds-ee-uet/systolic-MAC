# 4x4 INT Systolic Architecture Based Accelerator for Efficient Matrix Multiplication

Welcome to the documentation for the **4x4 INT Systolic Array Based Accelerator** designed for efficient matrix multiplication.

This documentation is organized into the following sections:

---

## User Guide
Everything you need to *use* the chip — setup, input/output formats, ready-valid protocol, and basic simulation instructions.  
[Go to User Guide](user-guide.md)

---

## Developer Guide
For engineers and students who want to understand or modify the design. Includes design principles, internal modules, and detailed architecture.  
[Go to Developer Guide](developer-guide.md)

---

## 🔩 Modules
Detailed documentation for each hardware block:

- [MAC Unit](mac-unit.md)
- [Processing Element (PE)](processing-element.md)
- [Data Feeders](data-feeders.md)
- [Interface](interface.md)
- [Systolic Top](systolic-top.md)
- [Input Datapath](input-datapath.md)
- [Output Datapath](output-datapath.md)
- [Counter](counter.md)

---
TESTING

We tested by six examples , two are shown below :

### Simulation:

![systolic_top](./systolic_simulation.png)

---

## (8) RESULT
## Transcript:
![transcript](./transcript.png)
## Benchmarks
We used a custom benchmark written in C language, which multiplied two randomly generated 8 bit 4x4 matrices into 4x4 32 bit result. We ran it on different processors 6 times and took the average of the findings. The results are shown in the table below.  

![table](benchmark.png)

Hence we observe that the systolic array is approximately **50-160** times faster than main-stream general purpose cpus. 

---

## 📄 Repository
The full source code and Makefiles are available here:  
➡️ [GitHub Repository](https://github.com/meds-ee-uet/systolic-MAC.git)

---