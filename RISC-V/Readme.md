# 🧠 5-Stage Pipelined RISC-V Processor (Verilog)

This project implements a simplified 5-stage pipelined processor using Verilog for a subset of RISC-V instructions. It is designed to help learners understand the key concepts of pipelining in processor architecture.

## 📌 Overview

The pipeline consists of the following stages:

| Stage | Name           | Description                                                       |
|-------|----------------|-------------------------------------------------------------------|
| 1     | IF (Fetch)     | Fetch instruction from instruction memory                         |
| 2     | ID (Decode)    | Decode instruction and read registers                             |
| 3     | EX (Execute)   | Perform ALU operations                                            |
| 4     | MEM (Memory)   | Memory access (placeholder, not used in this project)             |
| 5     | WB (WriteBack) | Write the result back to the destination register                 |

---

## 💾 Instruction Memory Contents

The following instructions are preloaded into `instr_mem`:

| Index | Hex Value  | Assembly Instruction   | Description                 |
|-------|------------|------------------------|-----------------------------|
| 0     | 0x00000013 | `addi x0, x0, 0`       | NOP                         |
| 1     | 0x00100093 | `addi x1, x0, 1`       | Set x1 = 1                  |
| 2     | 0x00200113 | `addi x2, x0, 2`       | Set x2 = 2                  |
| 3     | 0x00308193 | `addi x3, x1, 3`       | x3 = x1 + 3                 |
| 4     | 0x00410213 | `addi x4, x2, 4`       | x4 = x2 + 4                 |
| 5–15  | 0x00000013 | `addi x0, x0, 0`       | NOPs to flush pipeline      |

---

## 🧩 Instruction Format Breakdown

### Example: `addi x1, x0, 1`

| Field     | Bits     | Value          |
|-----------|----------|----------------|
| `imm`     | [31:20]  | `000000000001` |
| `rs1`     | [19:15]  | `00000` (x0)   |
| `funct3`  | [14:12]  | `000`          |
| `rd`      | [11:7]   | `00001` (x1)   |
| `opcode`  | [6:0]    | `0010011`      |
| Binary    |          | `00000000000100000000000010010011` |
| Hex       |          | `0x00100093`   |

---

## 🧮 Supported Instructions

### R-Type

| Instruction | `funct7`  | `funct3` | Opcode    | Description                        |
|-------------|-----------|----------|-----------|------------------------------------|
| `add`       | 0000000   | 000      | 0110011   | x[rd] = x[rs1] + x[rs2]            |
| `sub`       | 0100000   | 000      | 0110011   | x[rd] = x[rs1] - x[rs2]            |
| `and`       | 0000000   | 111      | 0110011   | x[rd] = x[rs1] & x[rs2]            |
| `or`        | 0000000   | 110      | 0110011   | x[rd] = x[rs1] \| x[rs2]           |
| `xor`       | 0000000   | 100      | 0110011   | x[rd] = x[rs1] ^ x[rs2]            |
| `sll`       | 0000000   | 001      | 0110011   | x[rd] = x[rs1] << x[rs2]           |
| `srl`       | 0000000   | 101      | 0110011   | x[rd] = x[rs1] >> x[rs2]           |
| `sra`       | 0100000   | 101      | 0110011   | Arithmetic right shift             |

### I-Type

| Instruction | Opcode   | Description                     |
|-------------|----------|---------------------------------|
| `addi`      | 0010011  | x[rd] = x[rs1] + imm            |
| `lw`        | 0000011  | Load word (not implemented yet) |

### S-Type

| Instruction | Opcode   | Description                     |
|-------------|----------|---------------------------------|
| `sw`        | 0100011  | Store word (not implemented)    |

### Other

| Instruction | Opcode   | Type      |
|-------------|----------|-----------|
| `beq`       | 1100011  | B-type    |
| `jal`       | 1101111  | J-type    |

---

## 🔧 Modules

### `reg_file.v`
- Implements 32 registers (x0 to x31)
- x0 is hardwired to 0
- Asynchronous reads
- Synchronous writes

### `alu.v`
- Supports `add` and `sub` operations
- Controlled via 2-bit ALU control signal

### `pipeline_5stage.v`
- Top module
- Implements all 5 pipeline stages
- Includes:
  - Pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB)
  - Instruction decoding and control signals
  - Simple data path for ALU and register file

---

## 📘 Instruction Flow (Example)

For `addi x3, x1, 3`:

| Stage | Operation                                  |
|-------|--------------------------------------------|
| IF    | Fetch from `instr_mem[3]`                  |
| ID    | Read x1 = 1, immediate = 3                 |
| EX    | ALU computes 1 + 3 = 4                     |
| MEM   | (Skipped – no memory access)               |
| WB    | Write result (4) into register x3          |

---

## ✅ Features

- 5-stage pipelined execution
- Instruction memory with preload support
- Easy-to-understand pipeline registers and control flow
- Basic `add`, `sub`, `addi` support
- Useful for beginners and educational demos

---

## 🚫 Limitations

- No hazard detection or forwarding
- No branching or jumps implemented
- No memory operations (`lw`, `sw`)
- ALU only supports limited operations

---

## 👨‍💻 Author

**Kiran Kumar Siripurapu**  
3rd Year B.Tech, Electronics and Communication Engineering  
RGUKT Srikakulam  
📍 Passionate about VLSI and RISC-V architecture design  

---

## 📂 License

This project is for educational and personal use. Feel free to fork, contribute, or extend for learning purposes.
