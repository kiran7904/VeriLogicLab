# 🧠 5-Stage Pipelined RISC-V Processor (Verilog)

This project implements a simple 5-stage pipelined processor for a subset of RISC-V instructions using Verilog. The five stages of the pipeline are Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB).
| Field  | Bits     |
| ------ | -------- |
| imm    | [31:20] |
| rs1    | [19:15] |
| funct3 | [14:12] |
| rd     | [11:7]  |
| opcode | [6:0]   |
addi x1, x0, 1
Fields:
imm = 1 = 000000000001 (12 bits)

rs1 = x0 = 00000

funct3 = 000

rd = x1 = 00001

opcode = 0010011

Binary:
ini
Copy
Edit
imm     = 000000000001
rs1     = 00000
funct3  = 000
rd      = 00001
opcode  = 0010011
Concatenated:
000000000001 00000 000 00001 0010011

That’s:

Copy
Edit
00000000000100000000000010010011
Binary → Hex:

Copy
Edit
0x00100093
---
| Instruction | Opcode (binary) | Notes         |
| ----------- | --------------- | ------------- |
| addi        | 0010011         | I-type        |
| lw          | 0000011         | I-type load   |
| sw          | 0100011         | S-type store  |
| beq         | 1100011         | B-type branch |
| jal         | 1101111         | J-type jump   |
| Index | Hex Value  | Assembly Instruction   | Meaning / Purpose           |
| ----- | ---------- | ---------------------- | --------------------------- |
| 0     | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation (does nothing) |
| 1     | 0x00100093 | `addi x1, x0, 1`       | Set register x1 to 1        |
| 2     | 0x00200113 | `addi x2, x0, 2`       | Set register x2 to 2        |
| 3     | 0x00308193 | `addi x3, x1, 3`       | Set register x3 = x1 + 3    |
| 4     | 0x00410213 | `addi x4, x2, 4`       | Set register x4 = x2 + 4    |
| 5     | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 6     | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 7     | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 8     | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 9     | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 10    | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 11    | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 12    | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 13    | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 14    | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |
| 15    | 0x00000013 | `addi x0, x0, 0` (NOP) | No operation                |

## 🧩 Pipeline Stages

| Stage | Name           | Description                                                                 |
|-------|----------------|-----------------------------------------------------------------------------|
| 1     | IF (Fetch)     | Fetch instruction from the instruction memory                               |
| 2     | ID (Decode)    | Decode the instruction and read operands from the register file             |
| 3     | EX (Execute)   | Perform ALU operations                                                      |
| 4     | MEM (Memory)   | Memory access stage (not used here, placeholder)                            |
| 5     | WB (WriteBack) | Write the result back to the destination register                           |

---

## 💾 Instruction Memory Contents

These instructions are preloaded into `instr_mem` for demonstration.

| Index | Hex Value  | Assembly Instruction   | Meaning / Purpose           |
| ----- | ---------- | ---------------------- | --------------------------- |
| 0     | 0x00000013 | `addi x0, x0, 0`       | NOP (no operation)          |
| 1     | 0x00100093 | `addi x1, x0, 1`       | Set x1 = 0 + 1              |
| 2     | 0x00200113 | `addi x2, x0, 2`       | Set x2 = 0 + 2              |
| 3     | 0x00308193 | `addi x3, x1, 3`       | Set x3 = x1 + 3             |
| 4     | 0x00410213 | `addi x4, x2, 4`       | Set x4 = x2 + 4             |
| 5     | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 6     | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 7     | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 8     | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 9     | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 10    | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 11    | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 12    | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 13    | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 14    | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 15    | 0x00000013 | `addi x0, x0, 0`       | NOP                         |

---

## 🔧 Modules Used

### `reg_file.v`
Implements 32 registers (x0 to x31) with:
- Asynchronous reads
- Synchronous writes
- x0 is always zero

### `alu.v`
A basic ALU supporting:
- `add` operation (opcode control = 00)
- `sub` operation (opcode control = 01)

### `pipeline_5stage.v`
The top module that implements:
- Instruction fetch
- Register decode
- ALU execution
- Register write-back
- Pipeline stage registers (IF/ID, ID/EX, EX/MEM, MEM/WB)

---

## 📘 How Instructions Flow (Example)

For `addi x3, x1, 3`:

- IF: Fetch from `instr_mem[3]`
- ID: rs1 = x1 (value 1), imm = 3
- EX: ALU computes 1 + 3 = 4
- MEM: (No operation)
- WB: Write 4 into x3

---

## ✅ Features

- Instruction execution across 5 pipeline stages
- Support for `addi`, `add`, `sub` (easy to extend more)
- Simple NOPs to fill gaps between instructions
- Useful for beginners to understand how pipelines operate

---

## 🚫 Limitations

- No support for load/store or branches
- No hazard detection or data forwarding
- No control hazard handling
- ALU only supports add and sub

---

## 🙋 Author

**Kiran Kumar Siripurapu**  
3rd Year, Electronics and Communication Engineering  
RGUKT Srikakulam  
🔬 Passionate about VLSI and RISC-V architecture design

---
