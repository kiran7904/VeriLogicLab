# 🧠 5-Stage Pipelined RISC-V Processor (Verilog)

            ┌──────────┐
 clk,reset→│ IF_stage │ → pc_out, instruction
            └──────────┘
                   ↓
            ┌──────────┐
           │ ID_stage │ → rs1, rs2, reg_data1, imm_out
            └──────────┘
                   ↓
            ┌──────────┐
           │ EX_stage │ → alu_result = reg_data1 + imm
            └──────────┘
                   ↓
            ┌──────────┐
           │ MEM_stage│ → mem_out (no memory access for now)
            └──────────┘
                   ↓
            ┌──────────┐
           │ WB_stage │ → wb_data → goes back to RegFile[rd]
            └──────────┘


The processor follows the classic 5-stage RISC-V pipeline:

### 1. Instruction Fetch (IF) Stage
- Fetches a 32-bit instruction from a predefined instruction memory (`instr_mem`) using the input program counter (`pc_in`).
- Updates the program counter (`pc_out`) by incrementing it by 4 (assuming 32-bit instructions).
- Addressing is aligned using `pc_in[5:2]`.

### 2. Instruction Decode (ID) Stage
- Decodes the fetched instruction to extract:
  - `rs1`, `rs2`: Source registers
  - `rd`: Destination register
  - `imm`: Sign-extended immediate value (currently supports I-type format)
- Future support for other instruction types (R, S, B, U, J) can be added.

### 3. Execute (EX) Stage
- Performs ALU operations. For demonstration, only the `addi` operation (`read_data1 + imm`) is implemented.
- Easily extendable for additional operations like `sub`, `and`, `or`, etc.

### 4. Memory Access (MEM) Stage
- Acts as a pass-through stage in this version.
- Placeholder for future integration of data memory to support instructions like `lw` and `sw`.

### 5. Write Back (WB) Stage
- Takes the result from the MEM stage and writes it back to the register file.
- Currently writes the ALU result directly to the destination register.

## 🧾 Register File
- Implements 32 general-purpose registers.
- Supports dual-read and single-write.
- Prevents writes to register `x0` to adhere to RISC-V specification.

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

| Index | Hex Value  | Assembly          | Type | `opcode` | `rd`  | `funct3` | `rs1` | `rs2/imm` | `funct7` | Meaning                            |    |
| ----- | ---------- | ----------------- | ---- | -------- | ----- | -------- | ----- | --------- | -------- | ---------------------------------- | -- |
| 0     | `00000013` | `ADDI x0, x0, 0`  | I    | 0010011  | 00000 | 000      | 00000 | 0         | —        | NOP (no operation)                 |    |
| 1     | `00100093` | `ADDI x1, x0, 1`  | I    | 0010011  | 00001 | 000      | 00000 | 1         | —        | x1 = x0 + 1                        |    |
| 2     | `00200113` | `ADDI x2, x0, 2`  | I    | 0010011  | 00010 | 000      | 00000 | 2         | —        | x2 = x0 + 2                        |    |
| 3     | `00308193` | `ADDI x3, x1, 3`  | I    | 0010011  | 00011 | 000      | 00001 | 3         | —        | x3 = x1 + 3                        |    |
| 4     | `00410213` | `ADDI x4, x2, 4`  | I    | 0010011  | 00100 | 000      | 00010 | 4         | —        | x4 = x2 + 4                        |    |
| 5     | `002081B3` | `ADD  x3, x1, x2` | R    | 0110011  | 00011 | 000      | 00001 | 00010     | 0000000  | x3 = x1 + x2                       |    |
| 6     | `0020F233` | `AND  x4, x1, x2` | R    | 0110011  | 00100 | 111      | 00001 | 00010     | 0000000  | x4 = x1 & x2                       |    |
| 7     | `0020E2B3` | `OR   x5, x1, x2` | R    | 0110011  | 00101 | 110      | 00001 | 00010     | 0000000  | x5 = x1                            | x2 |
| 8     | `00209233` | `SLL  x4, x1, x2` | R    | 0110011  | 00100 | 001      | 00001 | 00010     | 0000000  | x4 = x1 << x2 (logical shift left) |    |
| 9     | `401101B3` | `SUB  x3, x2, x1` | R    | 0110011  | 00011 | 000      | 00010 | 00001     | 0100000  | x3 = x2 - x1                       |    |


---
| **Opcode (7 bits)** | **Binary** | **Hex** | **Instruction Type**             | **Example Instructions** |
| ------------------- | ---------- | ------- | -------------------------------- | ------------------------ |
| `0110011`           | `0x33`     | R-type  | `ADD`, `SUB`, `AND`, `OR`, `SLL` |                          |
| `0010011`           | `0x13`     | I-type  | `ADDI`, `SLTI`, `XORI`           |                          |
| `0000011`           | `0x03`     | I-type  | `LW`, `LH`, `LB`                 |                          |
| `0100011`           | `0x23`     | S-type  | `SW`, `SH`, `SB`                 |                          |
| `1100011`           | `0x63`     | B-type  | `BEQ`, `BNE`, `BLT`              |                          |
| `1101111`           | `0x6F`     | J-type  | `JAL`                            |                          |
| `1100111`           | `0x67`     | I-type  | `JALR`                           |                          |
| `0110111`           | `0x37`     | U-type  | `LUI` (Load Upper Immediate)     |                          |
| `0010111`           | `0x17`     | U-type  | `AUIPC`                          |                          |
| `1110011`           | `0x73`     | I-type  | `ECALL`, `EBREAK`                |                          |

| Instruction | `opcode` | `funct3` | `funct7` |
| ----------- | -------- | -------- | -------- |
| `ADD`       | 0110011  | 000      | 0000000  |
| `SUB`       | 0110011  | 000      | 0100000  |
| `AND`       | 0110011  | 111      | 0000000  |
| `OR`        | 0110011  | 110      | 0000000  |
| `SLL`       | 0110011  | 001      | 0000000  |

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
