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
  MDA="-maxdepth $4"
fi

mkdir -p "$OD"

find "$ID" $MDA -type f -print0 | while IFS= read -r -d '' file; do
  rel_path="${file#$ID/}"
  safe_name="${rel_path//\//__}"

  dest_path="$OD/$safe_name"

  if [[ ! -e "$dest_path" ]]; then
    cp -p "$file" "$dest_path"
  else
    base="${safe_name%.*}"
    ext="${safe_name##*.}"
    [[ "$base" == "$ext" ]] && ext="" || ext=".$ext"

    i=1
    while [[ -e "$OD/${base}_$i$ext" ]]; do
      ((i++))
    done
    cp -p "$file" "$OD/${base}_$i$ext"
  fi

done

echo "All files collected into $OD"