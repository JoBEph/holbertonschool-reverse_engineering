#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

echo "Analyzing sections in: $file_name"
echo "========================================"
echo ""

readelf -S "$file_name"

echo ""
echo "========================================"
echo "Identifying unusual sections..."
echo ""

sections=$(readelf -S "$file_name" 2>/dev/null | tail -n +6 | grep -v "^$" | \
awk '{print $2, $5}')

echo "Standard sections found:"
echo "$sections"

echo ""
echo "Looking for non-standard sections..."

unusual=$(readelf -S "$file_name" 2>/dev/null | tail -n +6 | grep -v "^$" | \
grep -v "\.text" | grep -v "\.data" | grep -v "\.bss" | grep -v "\.rodata" | \
grep -v "\.symtab" | grep -v "\.strtab" | grep -v "\.shstrtab" | \
grep -v "\.rel\|\.rela" | grep -v "\.dynamic" | grep -v "\.note" | \
grep -v "\.gnu" | grep -v "^ELF")

if [ -n "$unusual" ]; then
    echo "$unusual"
    echo ""
    echo "Unusual section found!"
    unusual_name=$(echo "$unusual" | awk '{print $2}')
    unusual_size=$(echo "$unusual" | awk '{print $5}')
    
    echo "Section: $unusual_name"
    echo "Size: $unusual_size"
    
    echo "$unusual_size" > "$script_dir/size.txt"
    echo "readelf -S $file_name" > "$script_dir/command.txt"
    
    echo ""
    echo "✓ Created size.txt with: $unusual_size"
    echo "✓ Created command.txt with the command"
else
    echo "No obvious unusual sections found."
    echo "All sections appear to be standard ELF sections."
fi
