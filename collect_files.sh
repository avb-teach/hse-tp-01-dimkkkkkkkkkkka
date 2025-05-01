#!/bin/bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 /path/to/input_dir /path/to/output_dir [--max_depth N]"
  exit 1
fi

ID="$1"
OD="$2"
shift 2

if [[ ! -d "$ID" ]]; then
  echo "Error: input directory '$ID' does not exist."
  exit 1
fi

MDA=""
if [[ "${1:-}" == "--max_depth" ]]; then
  if [[ -z "${2:-}" || ! "${2}" =~ ^[0-9]+$ ]]; then
    echo "Error: --max_depth requires a numeric value."
    exit 1
  fi
  MDA="-maxdepth $2"
fi

mkdir -p "$OD"

generate_unique_name() {
  local dir="$1"
  local name="$2"
  local base="${name%.*}"
  local ext="${name##*.}"
  if [[ "$base" == "$ext" ]]; then
    ext=""
  else
    ext=".$ext"
  fi
  local i=1
  local new_name="$name"
  while [[ -e "$dir/$new_name" ]]; do
    new_name="${base}_$i$ext"
    ((i++))
  done
  echo "$new_name"
}

find "$ID" $MDA -type f -print0 | while IFS= read -r -d '' file; do
  rel_path="${file#$ID/}"
  dest_dir="$(dirname "$OD/$rel_path")"
  base_name="$(basename "$file")"

  mkdir -p "$dest_dir"

  dest_path="$dest_dir/$base_name"
  if [[ -e "$dest_path" ]]; then
    unique_name=$(generate_unique_name "$dest_dir" "$base_name")
    cp -p -- "$file" "$dest_dir/$unique_name"
  else
    cp -p -- "$file" "$dest_path"
  fi
done

exit 0