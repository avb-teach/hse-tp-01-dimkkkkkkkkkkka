#!/bin/bash

if [[ "$#" -lt 2 ]]; then
    echo "Usage: $0 [--max_depth N] input_dir output_dir"
    exit 1
fi

MD=""
if [[ "$1" == "--max_depth" ]]; then
    if [[ -z "$2" || -z "$3" ]]; then
        echo "Usage: $0 [--max_depth N] input_dir output_dir"
        exit 1
    fi
    MDA="$2"
    ID="$3"
    OD="$4"
    MD="$MDA"
else
    ID="$1"
    OD="$2"
fi

if [[ ! -d "$ID" ]]; then
    echo "Input directory does not exist: $ID"
    exit 1
fi

mkdir -p "$OD"

if [[ -z "$MD" ]]; then
    find "$ID" -type f | while read -r FILE; do
        BASENAME=$(basename "$FILE")
        DEST="$OD/$BASENAME"
        COUNTER=1
        while [[ -e "$DEST" ]]; do
            DEST="$OD/${BASENAME%.*}$COUNTER.${BASENAME##*.}"
            ((COUNTER++))
        done
        cp "$FILE" "$DEST"
    done
else
    find "$ID" -mindepth 1 -maxdepth "$MD" -type f | while read -r FILE; do
        REL_PATH=$(realpath --relative-to="$ID" "$(dirname "$FILE")")
        DEST_DIR="$OD/$REL_PATH"
        mkdir -p "$DEST_DIR"

        BASENAME=$(basename "$FILE")
        DEST="$DEST_DIR/$BASENAME"
        COUNTER=1
        while [[ -e "$DEST" ]]; do
            DEST="$DEST_DIR/${BASENAME%.*}$COUNTER.${BASENAME##*.}"
            ((COUNTER++))
        done
        cp "$FILE" "$DEST"
    done
fi

echo "Files collected successfully."
exit 0