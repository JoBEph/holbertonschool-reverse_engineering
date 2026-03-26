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
   The flag is constructed dynamically on the stack, character by character, to evade the `strings` command.
   
   Hexadecimal values stored on the stack:
   ```
   0x48=H, 0x4f=O, 0x4c=L, 0x42=B, 0x7b={, 0x52=R, 0x65=e, 0x76=v, 0x65=e, 
   0x72=r, 0x73=s, 0x65=e, 0x5f=_, 0x45=E, 0x6e=n, 0x67=g, 0x69=i, 0x6e=n, 
   0x65=e, 0x65=e, 0x72=r, 0x69=i, 0x6e=n, 0x67=g, 0x5f=_, 0x69=i, 0x73=s, 
   0x5f=_, 0x46=F, 0x75=u, 0x6e=n, 0x7d=}
   ```
5. **Result**
   ```
   HOLB{Reverse_Engineering_is_Fun}
   ```

---

## Task 1

**Objective:** main1  
**Goal:** 1-flag.txt

### Steps to Decrypt the Flag

1. **Analyze binary symbols**
   ```bash
   nm main1 | grep -E "encrypt|key|encrypted_flag"
   ```
   Identifies:
   - `encrypt` function at `0x1229`
   - `key` variable at `0x4020`
   - `encrypted_flag` at `0x4050`

2. **Extract the key and data**
   ```bash
   objdump -s -j .data main1
   ```
   Key: `mysecretkey` (11 bytes)

3. **Find the encrypted flag**
   ```bash
   objdump -s -j .rodata main1 | grep -A 20 "2000"
   ```
   Encrypted flag (hex): `9E89846A786585866A977D797C8463807C7F6B67848BAB907B698370896B997C797C8D6C6F7E81AE866AB36D7B7F669D7E6A7F96678F9382898263B474`

4. **Analyze the encrypt function**
   ```bash
   objdump -M intel -d main1 | grep -A 30 "<encrypt>:"
   ```
   
   **Encryption algorithm:**
   ```
   encrypted[i] = (input[i] XOR key[i % 11]) + key[(i+1) % 11]
   ```
   
   **Decryption algorithm:**
   ```
   input[i] = (encrypted[i] - key[(i+1) % 11]) XOR key[i % 11]
   ```

6. **Result**
   ```
   Holberton{implementing_decrypt_function_on_your_own_is_done!}
   ```

---

## Task 2

**Objective:** main2  
**Goal:** 2-flag.txt

### Steps to Optimize and Decrypt

1. **Analyze binary symbols**
   ```bash
   nm main2 | grep -E "decrypt|modulus|exponent"
   ```
   Identifies:
   - `naive_modular_exponentiation` function (SLOW - inefficient)
   - `slow_decrypt_flag` function at `0x1286`
   - `encrypted_flag` at `0x4020` (56 bytes)
   - `exponent` at `0x4058` (8 bytes)
   - `modulus` at `0x4060` (8 bytes)

2. **Extract encrypted data and parameters**
   ```bash
   objdump -s -j .data main2
   ```
   Data at offsets:
   - encrypted_flag: `8e82d972b66c836fa896da60a7779a69...a763f700`
   - exponent: `ffffffff ffff0000` (little-endian: 0xffffffffffff)
   - modulus: `fbffffff ffffff0f` (little-endian: 0xffffffffffffffb)

3. **Identify the bottleneck**
   ```bash
   objdump -M intel -d main2 | grep -A 40 "<naive_modular_exponentiation>:"
   ```
   
   **Problem:** Naïve algorithm does O(exponent) multiplications
   ```
   result = 1
   for i in range(exponent):
       result = (result * base) mod modulus
   ```
   With exponent = 281474976710655, this takes BILLIONS of iterations!

4. **Solution: Use Binary Exponentiation**
   **Key insight:** Use Python's built-in `pow(base, exp, mod)` which implements binary exponentiation.
   ```
   Time Complexity: O(log exponent) instead of O(exponent)
   Speedup: From 2^48 operations to 48 operations!
   ```

5. **Implement optimized decryption**
   - Parse exponent: `0xffffffffffff`
   - Parse modulus: `0xffffffffffffffb`
   - Compute key: `key = pow(2, exponent, modulus)` using binary exponentiation
   - Decrypt by computing modular exponentiation for each 8-byte chunk to retrieve ASCII values

6. **Result**
   ```
   Holberton{optimizingslowcode_isannoying_but_is_a_must}
   ```

---

## Task 3

**Objective:** main3  
**Goal:** 3-flag.txt

### Steps to Reverse Engineer the Obfuscated Flag

1. **Analyze binary symbols**
   ```bash
   nm main3 | grep -E "check_flag"
   ```
   Identifies:
   - `check_flag` function at `0x11c9`

2. **Disassemble the check_flag function**
   ```bash
   objdump -M intel -d main3 | grep -A 30 "<check_flag>:"
   ```
   Reveals 59 hardcoded obfuscated DWORD values stored on the stack.

3. **Extract the obfuscated values**
   Stack setup shows:
   ```
   0x80, 0xe4, 0x08, 0x18, 0x4a, 0x58, 0xb8, 0xe4, 0xac, 0x34,
   0x58, 0xe4, 0x7e, 0xbc, 0x9e, 0x8c, 0x7e, 0xd0, 0xc0, 0x7c,
   0xac, 0xf4, 0x7e, 0x28, 0x9e, 0x04, 0x7e, 0xbc, 0x9e, 0x8c,
   0x7e, 0x5c, 0x14, 0x4c, 0x7e, 0x5c, 0x7e, 0x6c, 0x02, 0x14,
   0xb8, 0x4c, 0x14, 0xa4, 0x9e, 0x08, 0x7e, 0xe4, 0xf4, 0x08,
   0x6a, 0x14, 0xa6, 0x5c, 0xb8, 0x7c, 0x9e, 0x28, 0x3e,
   ```

4. **Analyze the verification loop**
   ```bash
   objdump -M intel -d main3 | grep -A 50 "1401:"
   ```
   
   **Obfuscation algorithm discovered:**
   ```
   for i in range(59):
       if i % 2 == 0:  # even position
           transformed = (input_char * 0xd2) ^ 0x90
       else:  # odd position
           transformed = (input_char * 0x3c) ^ 0xe0
       
       transformed = transformed & 0xFF
       if transformed != obfuscated[i]:
           return False  # Incorrect flag
   ```

5. **Reverse the obfuscation**
   For each obfuscated value, brute-force the original character by testing all ASCII printable values (32-126) against the formula until finding matches. Handle collisions by preferring lowercase letters and underscores.

6. **Result**
   ```
   Holberton{Do_you_think_now_you_are_a_master_of_obfuscation?}
   ```

---

## Task 4

**Objective:** task4.asm  
**Goal:** 4-flag.txt

### Steps to Reverse Engineer the Assembly Code

1. **Analyze the assembly structure**
   ```bash
   cat task4.asm
   ```
   Key sections:
   - `obfuscated_flag`: 28 DWORD values containing obfuscated characters
   - `divisor`: 3
   - `check_loop`: Verification loop iterating through all 28 values

2. **Understand the obfuscation operations**
   
   **Key transformations in the check_loop:**
   ```asm
   mov ebx, [edi + ecx * 4]    ; Load obfuscated DWORD value
   xor ebx, 0x55               ; ebx ^= 0x55
   sub ebx, 7                  ; ebx -= 7
   idiv dword [divisor]        ; Divide by 3
   ```

3. **Extract the obfuscated values**
   All 28 DWORD values from the `.data` section:
   ```
   0x8a, 0x101, 0x11e, 0x178, 0x163, 0x108, 0x136, 0x101, 0x104, 0x12d,
   0x178, 0x17f, 0x165, 0x11d, 0x171, 0x136, 0x101, 0x171, 0x17f, 0x135,
   0x135, 0x163, 0x11b, 0x178, 0x11e, 0x127, 0x3f, 0x12b
   ```

4. **Derive the deobfuscation formula**
   
   By analyzing the assembly operations:
   1. Each obfuscated value is XORed with 0x55
   2. Then 7 is subtracted
   3. The result is divided by 3
   
   **Deobfuscation formula:**
   ```
   character = ((obfuscated ^ 0x55) - 7) / 3
   ```

5. **Apply deobfuscation**
   For each of the 28 obfuscated values, apply the formula and convert to ASCII.

6. **Result**
   ```
   Holberton{back_to_assembly!}
   ```