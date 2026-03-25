#!/bin/bash

# Source messages.sh en premier (fail-fast si absent)
source ./messages.sh || { echo "Error: messages.sh not found."; exit 1; }

# Vérification de l'argument
if [ -z "$1" ]; then
    echo "Usage: $0 <ELF file>"
    exit 1
fi

file_name="$1"

# Vérification existence du fichier
if [ ! -f "$file_name" ]; then
    echo "Error: File '$file_name' does not exist."
    exit 1
fi

# Vérification que c'est bien un ELF
if ! file "$file_name" | grep -q "ELF"; then
    echo "Error: '$file_name' is not a valid ELF file."
    exit 1
fi

# Extraction des champs ELF
magic_number=$(readelf -h "$file_name" | grep "Magic:" | awk '{for(i=2; i<=NF; i++) printf "%s ", $i}' | sed 's/ $//')
class=$(readelf -h "$file_name" | grep "Class:" | awk '{print $2}')
byte_order=$(readelf -h "$file_name" | grep "Data:" | sed 's/.*Data:\s*//' | sed 's/^[[:space:]]*//')
entry_point_address=$(readelf -h "$file_name" | grep "Entry point address:" | awk '{print $NF}')

display_elf_header_info