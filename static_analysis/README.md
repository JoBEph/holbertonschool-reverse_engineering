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

7. **Save the flag**
   ```bash
   echo 'Holberton{implementing_decrypt_function_on_your_own_is_done!}' > 1-flag.txt
   ```