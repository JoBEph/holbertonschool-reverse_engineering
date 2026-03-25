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
echo "Identifying all sections with their sizes..."
echo ""

readelf -S "$file_name" 2>/dev/null | awk '
/^\s*\[/ {
    name = $2
    getline
    size = $1
    print name " Size: " size
}' | tee /tmp/sections_all.txt

echo ""
echo "Looking for unusual sections (non-standard ELF sections)..."
echo ""

unusual=$(readelf -S "$file_name" 2>/dev/null | awk '
/^\s*\[/ {
    name = $2
    getline
    size = $1
    if (name !~ /^\.text$|^\.data$|^\.bss$|^\.rodata$|^\.symtab$|^\.strtab$|^\.shstrtab$|^\.rel|^\.rela|^\.dynamic$|^\.note|^\.gnu|^\.init|^\.fini|^\.plt|^\.got|^\.eh_frame|^\.comment/) {
        print name " " size
    }
}')

if [ -n "$unusual" ]; then
    echo "$unusual"
    echo ""
    echo "Unusual section found!"
    unusual_count=$(echo "$unusual" | wc -l)
    
    if [ "$unusual_count" -eq 1 ]; then
        unusual_name=$(echo "$unusual" | awk '{print $1}')
        unusual_size=$(echo "$unusual" | awk '{print $2}')
        echo "Section: $unusual_name"
        echo "Size: $unusual_size"
        
        echo "$unusual_size" > "$script_dir/size.txt"
        echo "readelf -S $file_name" > "$script_dir/command.txt"
        
        echo ""
        echo "✓ Created size.txt with: $unusual_size"
        echo "✓ Created command.txt"
    else
        echo "Multiple unusual sections found."
        echo "$unusual"
    fi
else
    echo "No obvious unusual sections found."
    echo "All sections appear to be standard ELF sections."
fi
