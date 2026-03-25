re_fundamentals

## Overview
This project focuses on reverse engineering fundamentals, specifically analyzing ELF (Executable and Linkable Format) binary files. The `get_entry_point.sh` script extracts critical information from ELF headers to understand binary structure and execution flow.

## Tools Used
- **readelf**: Extracts ELF header information
- **od**: Converts binary data to hexadecimal format
- **grep/sed/awk**: Text processing utilities

## Script: get_entry_point.sh

### Purpose
Extracts and displays the following information from an ELF binary:
- **Magic Number**: The ELF file identifier (always `7f454c46` in hex)
- **Class**: 32-bit or 64-bit architecture
- **Byte Order**: Endianness (little or big endian)
- **Entry Point Address**: Memory address where program execution starts

### Code Explanation

#### 1. Script Initialization
```bash
#!/bin/bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/messages.sh"
```
- Determines the script's directory using relative paths (not hardcoded)
- Sources the `messages.sh` file which contains formatting functions
- **Requirement met**: Uses relative paths instead of hardcoded values

#### 2. Input Validation
```bash
if [ $# -eq 0 ]; then
    echo "Error: No file provided. Usage: $0 <ELF_file>"
    exit 1
fi
file_name="$1"
```
- Checks if a command-line argument is provided
- Stores the filename in a variable for later use
- Exits with error code 1 if no file is provided

#### 3. File Existence Check
```bash
if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist."
    exit 1
fi
```
- Verifies the file exists and is a regular file
- Prevents processing of non-existent or special files
- **Requirement met**: Validates input before analysis

#### 4. Extract Header Information
```bash
header_info=$(readelf -h "$file_name" 2>&1)
```
- Uses `readelf -h` to extract the ELF header
- Captures both stdout and stderr for error detection
- **Requirement met**: Uses only allowed tools (readelf)

#### 5. Binary Integrity Validation
```bash
if echo "$header_info" | grep -q "Error:"; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi
```
- Checks if readelf encountered an error (not a valid ELF file)
- Prevents analysis of corrupted or non-ELF binaries
- **Requirement met**: Validates integrity of binaries before analyzing

#### 6. Data Extraction Techniques

**Magic Number (First 4 bytes as hex)**
```bash
magic_number=$(head -c 4 "$file_name" | od -An -tx1 | tr -d ' \n')
```
- `head -c 4`: Extracts the first 4 bytes
- `od -An -tx1`: Converts to hexadecimal (one byte per line)
- `tr -d ' \n'`: Removes spaces and newlines for clean output
- Result: `7f454c46` (ELF magic number)

**Class (Architecture)**
```bash
class=$(echo "$header_info" | grep "Class:" | sed 's/.*Class:[[:space:]]*//')
```
- Searches for "Class:" line in readelf output
- Uses `sed` to remove everything before "Class:" and trailing spaces
- Extracts: `ELF32` or `ELF64`

**Byte Order (Endianness)**
```bash
byte_order=$(echo "$header_info" | grep "Data:" | sed 's/.*Data:[[:space:]]*//')
```
- Searches for "Data:" line containing endianness info
- Uses `sed` to extract only the value
- Extracts: `2's complement, little endian` or `2's complement, big endian`

**Entry Point Address**
```bash
entry_point_address=$(echo "$header_info" | grep "Entry point address:" | awk '{print $4}')
```
- Searches for "Entry point address:" line
- Uses `awk` to extract the 4th field (the address value)
- Extracts: Hex memory address (e.g., `0x6760`)

#### 7. Output Display
```bash
display_elf_header_info
```
- Calls the function from `messages.sh` to format and display results
- **Requirement met**: Organized and clearly formatted output

### Requirements Compliance Checklist

| Requirement | Status | Evidence |
|---|---|---|
| Allowed tools only (objdump, readelf, ldd) | ✓ | Uses `readelf`, `head`, `od` |
| Relative paths (no hardcoded paths) | ✓ | Uses `$script_dir` and `$1` |
| Validate binary integrity | ✓ | Error checking for valid ELF format |
| Executable on Kali Linux | ✓ | Standard bash script |
| Organized output | ✓ | Uses `messages.sh` for formatting |
| Local analysis only | ✓ | No external services or online tools |
| No modification of original files | ✓ | Read-only operations |

### Usage
```bash
./get_entry_point.sh <ELF_file>
```

**Example:**
```bash
./get_entry_point.sh /bin/ls
```

**Output:**
```
ELF Header Information for '/bin/ls':
----------------------------------------
Magic Number: 7f454c46
Class: ELF64
Byte Order: 2's complement, little endian
Entry Point Address: 0x6760
```

### Error Handling

- **No file provided**: Displays usage message
- **File doesn't exist**: Shows file not found error
- **Invalid ELF file**: Detects and reports non-ELF files
- All errors exit with status code 1