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

echo "Extracting external libraries from: $file_name"
echo "================================================"
echo ""

readelf -d "$file_name" 2>/dev/null | grep NEEDED

echo ""
echo "================================================"
echo "External libraries found:"
echo ""

external_libs=$(readelf -d "$file_name" 2>/dev/null | \
grep NEEDED | \
awk -F'[\\[(\\]]' '{print $3}' | \
sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ -z "$external_libs" ]; then
    echo "No external libraries found."
else
    echo "$external_libs"
    echo "$external_libs" > "$script_dir/external_library.txt"
    echo ""
    echo "✓ Created external_library.txt"
fi
