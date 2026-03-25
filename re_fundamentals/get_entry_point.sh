#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/messages.sh"

if [ $# -eq 0 ]; then
    echo "Error: No file provided. Usage: $0 <ELF_file>"
    exit 1
fi

file_name="$1"

if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist."
    exit 1
fi

header_info=$(readelf -h "$file_name" 2>&1)

if echo "$header_info" | grep -q "Error:"; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

magic_number=$(head -c 4 "$file_name" | od -An -tx1 | \
tr -d ' \n')

class=$(echo "$header_info" | grep "Class:" | \
sed 's/.*Class:[[:space:]]*//')

byte_order=$(echo "$header_info" | grep "Data:" | \
sed 's/.*Data:[[:space:]]*//')

entry_point_address=$(echo "$header_info" | \
grep "Entry point address:" | awk '{print $4}')

display_elf_header_info
