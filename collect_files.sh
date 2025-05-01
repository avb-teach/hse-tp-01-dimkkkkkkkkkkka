#!/bin/bash

set -euo pipefail

if [[ "$#" -lt 2 ]]; then
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

ID="$(realpath "$ID")"
OD="$(realpath "$OD")"

mkdir -p "$OD"

declare -A FILE_COUNTER

while IFS= read -r -d '' file; do
  base_name="$(basename "$file")"

  if [[ -e "$OD/$base_name" ]]; then
    if [[ -n "${FILE_COUNTER[$base_name]+x}" ]]; then
      ((FILE_COUNTER[$base_name]++))
    else
      FILE_COUNTER[$base_name]=1
    fi

    name="${base_name%.*}"
    ext="${base_name##*.}"

    if [[ "$name" == "$ext" ]]; then
      ext=""
    else
      ext=".$ext"
    fi
    new_name="${name}${FILE_COUNTER[$base_name]}${ext}"
    cp -p "$file" "$OD/$new_name"
  else
    cp -p "$file" "$OD/$base_name"
    FILE_COUNTER[$base_name]=0
  fi

done < <(find "$ID" $MDA -type f -print0)

echo "All files successfully collected into $OD"