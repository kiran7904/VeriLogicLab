# 🧠 5-Stage Pipelined RISC-V Processor (Verilog)

This project implements a simple 5-stage pipelined processor for a subset of RISC-V instructions using Verilog. The five stages of the pipeline are Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB).
| Field Name | Bits     | # Bits | Example Value  | Purpose / Description                               |
| ---------- | -------- | ------ | -------------- | --------------------------------------------------- |
| `imm`      | [31:20] | 12     | `000000000001` | 12-bit signed immediate (constant to add)           |
| `rs1`      | [19:15] | 5      | `00000`        | Source register 1 (here, `x0` which is always zero) |
| `funct3`   | [14:12] | 3      | `000`          | Operation type: `000` = `ADDI`                      |
| `rd`       | [11:7]  | 5      | `00001`        | Destination register (here, `x1`)                   |
| `opcode`   | [6:0]   | 7      | `0010011`      | I-type ALU operation (`ADDI`, `SLTI`, `XORI`, etc.) |


| Instruction        | Format | Fields Breakdown                                                                                                              | Hex Code     | Description                |     |
| ------------------ | ------ | ----------------------------------------------------------------------------------------------------------------------------- | ------------ | -------------------------- | --- |
| `sub x5, x6, x7`   | R-type | funct7=`0100000`, rs2=`x7=00111`, rs1=`x6=00110`, funct3=`000`, rd=`x5=00101`, opcode=`0110011`                               | `0x40E3B2B3` | x5 = x6 - x7               |     |
| `and x8, x9, x10`  | R-type | funct7=`0000000`, rs2=`x10=01010`, rs1=`x9=01001`, funct3=`111`, rd=`x8=01000`, opcode=`0110011`                              | `0x00A4C433` | x8 = x9 & x10              |     |
| `or x11, x12, x13` | R-type | funct7=`0000000`, rs2=`x13=01101`, rs1=`x12=01100`, funct3=`110`, rd=`x11=01011`, opcode=`0110011`                            | `0x00D666B3` | x11 = x12                  | x13 |
| `sw x14, 8(x15)`   | S-type | imm=`0000000001000`, rs2=`x14=01110`, rs1=`x15=01111`, funct3=`010`, split imm:`0000000` (hi), `01000` (lo), opcode=`0100011` | `0x00E7A423` | store x14 at address x15+8 |     |

| Instruction | Type   | `funct7`  | `funct3` | Opcode    | Description                 |
| ----------- | ------ | --------- | -------- | --------- | --------------------------- |
| `add`       | R-type | `0000000` | `000`    | `0110011` | x\[rd] = x\[rs1] + x\[rs2]  |
| `sub`       | R-type | `0100000` | `000`    | `0110011` | x\[rd] = x\[rs1] - x\[rs2]  |
| `and`       | R-type | `0000000` | `111`    | `0110011` | x\[rd] = x\[rs1] & x\[rs2]  |
| `or`        | R-type | `0000000` | `110`    | `0110011` | x\[rd] = x\[rs1] \| x\[rs2] |
| `xor`       | R-type | `0000000` | `100`    | `0110011` | x\[rd] = x\[rs1] ^ x\[rs2]  |
| `sll`       | R-type | `0000000` | `001`    | `0110011` | x\[rd] = x\[rs1] << x\[rs2] |
| `srl`       | R-type | `0000000` | `101`    | `0110011` | x\[rd] = x\[rs1] >> x\[rs2] |
| `sra`       | R-type | `0100000` | `101`    | `0110011` | Arithmetic right shift      |

addi x1, x0, 1
Fields:
imm = 1 = 000000000001 (12 bits)

rs1 = x0 = 00000

funct3 = 000

rd = x1 = 00001

opcode = 0010011

Binary:
ini
imm     = 000000000001
rs1     = 00000
funct3  = 000
rd      = 00001
opcode  = 0010011
Concatenated:
000000000001 00000 000 00001 0010011

That’s:
00000000000100000000000010010011
Binary → Hex:
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
