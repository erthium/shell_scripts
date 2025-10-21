#!/bin/bash

# Usage:
#   ./script.sh [-v] -e ext1 [ext2 ...] [directory]
#
# Example:
#   ./script.sh -v -e py js sh src/

VERBOSE=false
EXTENSIONS=()
DIRECTORY="."

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -e|-x)
      shift
      while [[ $# -gt 0 ]] && [[ ! "$1" =~ ^- ]]; do
        if [[ -d "$1" ]]; then
          DIRECTORY="$1"
          shift
          break
        fi
        EXTENSIONS+=("$1")
        shift
      done
      ;;
    *)
      if [[ -d "$1" ]]; then
        DIRECTORY="$1"
        shift
      else
        echo "Unknown argument: $1"
        exit 1
      fi
      ;;
  esac
done

if [[ ${#EXTENSIONS[@]} -eq 0 ]]; then
  echo "No extensions specified! Use -e or -x to provide extensions."
  exit 1
fi

TOTAL=0

for ext in "${EXTENSIONS[@]}"; do
  FILES=$(find "$DIRECTORY" -type f -name "*.${ext}")
  for file in $FILES; do
    COUNT=$(wc -l < "$file")
    TOTAL=$((TOTAL + COUNT))
    if $VERBOSE; then
      echo "$file: $COUNT"
    fi
  done
done

echo "Total lines of code: $TOTAL"
