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

magic_number=$(head -c 4 "$file_name" | od -An -tx1 | \
tr -d ' \n')

class=$(echo "$header_info" | grep "Class:" | \
sed 's/.*Class:[[:space:]]*//')

byte_order=$(echo "$header_info" | grep "Data:" | \
sed 's/.*Data:[[:space:]]*//')

entry_point_address=$(echo "$header_info" | \
grep "Entry point address:" | awk '{print $NF}')

display_elf_header_info