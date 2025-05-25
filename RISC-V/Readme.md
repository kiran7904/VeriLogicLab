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
