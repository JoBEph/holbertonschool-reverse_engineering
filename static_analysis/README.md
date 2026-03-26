# Static Analysis in Reverse Engineering

## Task 0

**Objective:** main0  
**Goal:** 0-flag.txt

### Steps to Extract the Flag

1. **Extract strings from the binary**
   ```bash
   strings main0 > strings.txt
   ```
   This reveals all human-readable text in the binary.

2. **Look for interesting functions**
   ```bash
   nm main0 | grep flag
   ```
   Identifies the `check_flag` function at address `0x401ea4`.

3. **Disassemble the function**
   ```bash
   objdump -d main0 | grep -A 100 "check_flag"
   ```
   Shows the assembly code where the flag is hardcoded as byte values.

4. **Decode the hex bytes to ASCII**
   The assembly shows bytes being moved into memory:
    ```
   - 0x48=H, 0x4f=O, 0x4c=L, 0x42=B, 0x7b={, 0x52=R, 0x65=e, 0x76=v, 0x65=e, 0x72=r, 0x73=s, 0x65=e, 0x5f=_, 0x45=E, 0x6e=n, 0x67=g, 0x69=i, 0x6e=n, 0x65=e, 0x65=e, 0x72=r, 0x69=i, 0x6e=n, 0x67=g, 0x5f=_, 0x69=i, 0x73=s, 0x5f=_, 0x46=F, 0x75=u, 0x6e=n, 0x7d=}
    ```
5. **Result**
   ```
   HOLB{Reverse_Engineering_is_Fun}
   ```

6. **Save the flag**
   ```bash
   echo "HOLB{Reverse_Engineering_is_Fun}" > 0-flag.txt
   ```