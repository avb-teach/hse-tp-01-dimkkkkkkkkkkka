#!/bin/bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 /path/to/input_dir /path/to/output_dir [--max_depth N]"
  exit 1
fi

ID="$1"
OD="$2"

if [[ ! -d "$ID" ]]; then
  echo "Error: input directory '$ID' does not exist."
  exit 1
fi

MDA=""
if [[ "${3:-}" == "--max_depth" ]]; then
  if [[ -z "${4:-}" || ! "${4}" =~ ^[0-9]+$ ]]; then
    echo "Error: --max_depth requires a numeric value."
    exit 1
  fi
  MDA="-maxdepth $4"
fi

mkdir -p "$OD"

generate_unique_name() {
  local dest_dir="$1"
  local base_name="$2"
  local name="${base_name%.*}"
  local ext="${base_name##*.}"
  local i=1

  if [[ "$name" == "$ext" ]]; then
    ext=""
  else
    ext=".$ext"
  fi

  local new_name="$base_name"
  while [[ -e "$dest_dir/$new_name" ]]; do
    new_name="${name}_$i$ext"
    ((i++))
  done

  echo "$new_name"
}

find "$ID" $MDA -type f -print0 | while IFS= read -r -d '' file; do
  base_name="$(basename "$file")"
  dest_path="$OD/$base_name"

  if [[ ! -e "$dest_path" ]]; then
    cp -p -- "$file" "$dest_path"
  else
    unique_name=$(generate_unique_name "$OD" "$base_name")
    cp -p -- "$file" "$OD/$unique_name"
  fi
done

exit 0