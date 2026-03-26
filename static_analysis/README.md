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

5. **Implement decryption script**
   Create `decrypt.py` with the reverse algorithm and apply it to the encrypted bytes.

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
   Create `solve.py` script:
   - Parse exponent: `0xffffffffffff`
   - Parse modulus: `0xffffffffffffffb`
   - Compute key: `key = pow(2, exponent, modulus)` using binary exponentiation
   - Decrypt by computing modular exponentiation for each 8-byte chunk to retrieve ASCII values

6. **Result**
   ```
   Holberton{optimizingslowcode_isannoying_but_is_a_must}
   ```