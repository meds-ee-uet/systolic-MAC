#  4x4 INT Systolic Architecture Based Accelerator for Efficient Matrix Multiplication




## Introduction:
In parallel computer architectures, a **systolic array** is a homogeneous network of tightly coupled **data processing units (DPUs)** which is used for many purposes . It has a lot of Applications .

## Purpose of Our Systolic Array:
We made a 4 by 4 systolic array for efficient Matrix Multiplication. 

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

```

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

📖 [Documentation](https://systolic-mac.readthedocs.io/en/latest/)

---


