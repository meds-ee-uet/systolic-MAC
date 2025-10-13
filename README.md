#  4x4 INT Systolic Architecture Based Accelerator for Efficient Matrix Multiplication

<p align="center">
  <img src="docs/logo.png" alt="Systolic logo" width="200"/>
</p>



This repository includes custom RTL and testbenches implementation in system verilog for a 4 by 4 matrix multiplication accelerator using Systolic Array Architecture built from scratch. 


## Directory Structure:
```
├── docs
├── benchmark.c
├── Makefile
├── mkdocs.yml
├── README.md
├── rtl
│   ├── controlled_counter.sv
│   ├── counter.sv
│   ├── data_feeder.sv
│   ├── input_datapath.sv
│   ├── mac_unit.sv
│   ├── output_datapath.sv
│   ├── pe.sv
│   ├── Readme.md
│   ├── reg_def.sv
│   ├── rv_protocol.sv
│   └── systolic.sv
├── testbench
│   ├── counter_tb.sv
│   ├── data_feeder_tb.sv
│   ├── input_datapath_tb.sv
│   ├── mac_unit_tb.sv
│   ├── output_datapath_tb.sv
│   ├── pe_tb.sv
│   ├── rv_protocol_tb.sv
│   ├── systolic_tb.sv
│   └── systolic_top_tb.sv
├── LICENSE
├── .readthedocs.yaml
├── .gitignore


```

## How to Run:

### Steps 1:
### Clone the repository:

Type the below command:

```
git clone git@github.com:ee-uet/systolic-MAC.git
```


---

### Step 2:
### Install All the Required Pre-requisites:

1. Modelsim / Questasim
2. GTK-Wave
3. install `make`
4. gcc --> for benchmark

### Step 3:
### Using Makefile :
You can see the simulations in GTK-Wave using the Makefile. You have to write following command :
```
make TOP=module_name all
```

***Or you can alternatively use **Modelsim** or Questasim as well !***



---
## BenchMark:

| Processor        | Time (ns) (avg from 6 runs) |
|------------------|-----------------------------|
| M1               | 1000                        |
| i7-1185G7        | 1239                        |
| i7-1355U         | 715                         |
| i5-10310U        | 1784                        |
| i5-6300U         | 2455                        |
| i7-8665U         | 1792                        |
| *Systolic @ 3GHz*| *~15 (from simulation)*     |

Hence we observe that the systolic array is approximately **50-160** times faster than main-stream general purpose cpus. 


# Documentation :

Click here to see the detailed Documentation: 

📖 [Documentation](https://4x4-systolic-array.readthedocs.io/en/latest/)

---


