#!/bin/bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 /path/to/input_dir /path/to/output_dir [--max_depth N]"
  exit 1
fi

ID="$1"
OD="$2"
MD=""
MDA=""

if [[ ! -d "$ID" ]]; then
  echo "Error: input directory '$ID' does not exist."
  exit 1
fi

if [[ "${3:-}" == "--max_depth" ]]; then
  if [[ -z "${4:-}" || ! "${4}" =~ ^[0-9]+$ ]]; then
    echo "Error: --max_depth requires a numeric value."
    exit 1
  fi
  MD="$4"
  MDA="-maxdepth $MD"
fi

mkdir -p "$OD"

find "$ID" $MDA -type f -print0 | while IFS= read -r -d '' file; do
  base_name="$(basename "$file")"
  dest_path="$OD/$base_name"

  if [[ ! -e "$dest_path" ]]; then
    cp -p "$file" "$dest_path"
  else
    name="${base_name%.*}"
    ext="${base_name##*.}"
    if [[ "$name" == "$ext" ]]; then
      ext=""
    else
      ext=".$ext"
    fi

    i=1
    while [[ -e "$OD/${name}_$i$ext" ]]; do
      ((i++))
    done
    cp -p "$file" "$OD/${name}_$i$ext"
  fi
done

echo "All files successfully copied to $OD"