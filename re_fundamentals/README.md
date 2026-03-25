# RE Fundamentals - Reverse Engineering Binary Analysis

## Project Overview

This project focuses on reverse engineering fundamentals for analyzing ELF (Executable and Linkable Format) binary files.

**Target Binaries**: `task0`, `task1`, `task2`

**Allowed Tools**: `readelf`, `objdump`, `ldd`

**Environment**: Kali Linux / Linux-based systems

---

## General Requirements

- Use only allowed tools: objdump, readelf, ldd
- All scripts must be executable and runnable on Kali Linux
- Use relative paths only (no hardcoded paths)
- Validate binary integrity before analyzing
- Organized and clearly formatted output
- Local analysis only (no online tools/services)

---

## Task 0: ELF Header Extraction

**File**: `get_entry_point.sh`

**Objective**: Extract and display information from the ELF header of a given file

### What the Script Extracts

- **Magic Number**: The identifier of the file as an ELF file
- **Class**: Whether the ELF file is 32-bit or 64-bit
- **Byte Order**: The endianness of the file (little or big endian)
- **Entry Point Address**: The memory address where program execution starts after loading

### Requirements

1. Accept the ELF file name as a command-line argument
2. Check if the file exists and is valid
3. Display an error message if the file is not an ELF file or does not exist
4. Use readelf to extract the required data
5. Use `messages.sh` to format and display the output

### Usage

```bash
./get_entry_point.sh <ELF_file>
```

### Output Format

```
Header Information for '<file_name>':
--------------------------------
Magic Number: <magic_number>
Class: <class>
Byte Order: <byte_order>
Entry Point Address: <entry_point_address>
```

### Example

```bash
./get_entry_point.sh /bin/ls
```

Output:
```
Header Information for '/bin/ls':
--------------------------------
Magic Number: 7f454c46
Class: ELF64
Byte Order: 2's complement, little endian
Entry Point Address: 0x6760
```

### Implementation

```bash
#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$script_dir/messages.sh" ]; then
    source "$script_dir/messages.sh"
else
    echo "Error: messages.sh not found."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Error: No file provided. Usage: $0 <ELF_file>"
    exit 1
fi

file_name="$1"

if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist."
    exit 1
fi

header_info=$(readelf -h "$file_name" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$header_info" ]; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

magic_number=$(head -c 4 "$file_name" | od -An -tx1 | tr -d ' \n')

class=$(echo "$header_info" | grep "Class:" | sed 's/.*Class:[[:space:]]*//')

byte_order=$(echo "$header_info" | grep "Data:" | sed 's/.*Data:[[:space:]]*//')

entry_point_address=$(echo "$header_info" | grep "Entry point address:" | awk '{print $NF}')

display_elf_header_info
```

### Error Handling

- No argument: `Error: No file provided. Usage: $0 <ELF_file>`
- File doesn't exist: `Error: File '<filename>' does not exist.`
- Invalid ELF format: `Error: '<filename>' is not a valid ELF file.`
- messages.sh missing: `Error: messages.sh not found.`

---

## Task 1: Section Enumeration & Analysis

**File**: `enumerate_sections.sh`

**Output Files**: 
- `size.txt` - Size of the unusual section
- `command.txt` - Command used to identify sections

**Objective**: Analyze a binary file and identify unusual sections

### What the Script Does

1. Identify all sections in the binary
2. Use readelf -S to list all ELF sections (or objdump -h)
3. Identify unusual/non-standard sections
4. Extract and document the size of the unusual section

### Requirements

1. Use readelf -S to list all sections of the ELF file
2. Identify unusual sections (not part of standard ELF)
3. Determine the size of the unusual section
4. Create `size.txt` containing the section size
5. Create `command.txt` containing the command used

### Usage

```bash
./enumerate_sections.sh <ELF_file>
```

### Output Files

**size.txt**: Contains the size of the unusual section
```
4
```

**command.txt**: Contains the command used
```
readelf -S task1
```

Or with objdump:
```
objdump -h task1
```

### Standard ELF Sections (Filtered Out)

- `.text`, `.data`, `.bss`, `.rodata` - Code and data sections
- `.symtab`, `.strtab`, `.shstrtab` - Symbol and string tables
- `.rel*`, `.rela*` - Relocation sections
- `.dynamic`, `.init`, `.fini` - Linker and init sections
- `.plt`, `.got` - Linkage tables
- `.gnu.*`, `.note*`, `.eh_frame*`, `.comment` - Metadata sections

### Unusual Sections (Task 1 Binary)

| Section | Size | Type |
|---|---|---|
| `.hbtn-custom` | 4 bytes | PROGBITS |
| `.mydata` | 61 bytes | PROGBITS |

---

## Task 2: External Libraries

**File**: `get_external_libraries.sh`

**Output File**: 
- `external_library.txt` - Names of external libraries needed by the binary

**Objective**: Identify and list the external libraries required by the binary

### What the Script Does

1. Analyze the binary to find dynamic library dependencies
2. Use ldd, readelf, or objdump to identify external libraries
3. Extract library names (e.g., libc.so.6, libm.so.6, etc.)
4. Create `external_library.txt` with the list of external libraries

### Requirements

1. Use ldd, readelf, or objdump to identify external libraries
2. Identify only external libraries (not libc if it's standard)
3. Create `external_library.txt` containing the library names
4. One library name per line

### Usage

```bash
./get_external_libraries.sh <ELF_file>
```

### Output File

**external_library.txt**: Contains external library names

Example:
```
libc.so.6
libm.so.6
libpthread.so.0
```

Or minimal (only non-standard):
```
libcustom.so
libhbtn.so
```

### Tools Available

- **ldd**: List dynamic library dependencies
  ```bash
  ldd <binary>
  ```
  
- **readelf -d**: Show dynamic section
  ```bash
  readelf -d <binary> | grep NEEDED
  ```
  
- **objdump**: Display dependencies
  ```bash
  objdump -p <binary> | grep NEEDED
  ```

### Standard Libraries (Common)

- `libc.so.6` - C standard library
- `libm.so.6` - Math library
- `libpthread.so.0` - POSIX threads
- `libdl.so.2` - Dynamic linking loader
- `libgcc_s.so.1` - GCC runtime

### Implementation Notes

The script should:
1. Accept binary filename as argument
2. Validate file exists and is ELF
3. Extract library dependencies
4. Parse output to get library names only (not paths)
5. Save to `external_library.txt`

### Example

```bash
./get_external_libraries.sh task2
```

Output to `external_library.txt`:
```
libc.so.6
libm.so.6
```

---

## Tasks Summary

| Task | Script | Purpose | Output |
|---|---|---|---|
| 0 | `get_entry_point.sh` | Extract ELF header info | Console display |
| 1 | `enumerate_sections.sh` | Identify unusual sections | `size.txt`, `command.txt` |
| 2 | `get_external_libraries.sh` | Find external libraries | `external_library.txt` |

---

### Supporting Files

#### messages.sh

```bash
function display_elf_header_info() {
    echo "Header Information for '$file_name':"
    echo "--------------------------------"
    echo "Magic Number: $magic_number"
    echo "Class: $class"
    echo "Byte Order: $byte_order"
    echo "Entry Point Address: $entry_point_address"
}
```

#### Task Binaries

- `task0` - Binary for testing ELF header extraction
- `task1` - Binary with custom `.hbtn-custom` section (4 bytes)
- `task2` - Binary with external library dependencies

---

## Quick Reference

Extract ELF header info:
```bash
./get_entry_point.sh task0
```

Identify unusual sections:
```bash
./enumerate_sections.sh task1
```

Extract external libraries:
```bash
./get_external_libraries.sh task2
```

Check output files:
```bash
cat size.txt
cat command.txt
cat external_library.txt
```

---

**Last Updated**: March 25, 2026
