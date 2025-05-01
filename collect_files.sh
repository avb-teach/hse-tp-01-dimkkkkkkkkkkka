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

mapfile -d '' FILES < <(find "$ID" $MDA -type f -print0)

for file in "${FILES[@]}"; do
  rel_path="${file#$ID/}"
  dir_part="$(dirname "$rel_path")"
  base_name="$(basename "$file")"

  if [[ "$dir_part" == "." ]]; then
    dest_name="$base_name"
  else
    safe_dir="${dir_part//\//_}"
    dest_name="${safe_dir}_${base_name}"
  fi

  dest_path="$OD/$dest_name"

  if [[ ! -e "$dest_path" ]]; then
    cp -p "$file" "$dest_path"
  else
    name="${dest_name%.*}"
    ext="${dest_name##*.}"
    if [[ "$name" == "$ext" ]]; then
      ext=""
    else
      ext=".$ext"
    fi

    index=1
    while [[ -e "$OD/${name}${index}${ext}" ]]; do
      ((index++))
    done

    cp -p "$file" "$OD/${name}${index}${ext}"
  fi
done

echo "All files successfully collected into $OD"