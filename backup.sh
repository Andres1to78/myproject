#!/bin/bash
show_help() {
  echo "Usage: $0 [OPTIONS] <source_dir>"
  echo "Options:"
  echo "  -h, --help          Show this help message"
  echo "  --modified N       Copy only files modified in the last N days"
  echo "  --not-empty        Copy only non-empty files"
  exit 0
}
if [[ $# -eq 0 ]]; then
  show_help
fi
if [[ $# -lt 1 ]]; then
  echo "Error: Not enough arguments provided. Use -h or --help for usage."
  exit 1
fi
MODIFIED_DAYS=""
NOT_EMPTY=false
SOURCE_DIR=""
DEST_DIR="backup"
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      ;;
    --modified)
      MODIFIED_DAYS=$2
      shift
      ;;
    --not-empty)
      NOT_EMPTY=true
      ;;
    *)
      if [[ -z "$SOURCE_DIR" ]]; then
        SOURCE_DIR=$1
      else
        echo "Error: Unexpected argument $1"
        exit 1
      fi
      ;;
  esac
  shift
done
if [[ -z "$SOURCE_DIR" ]]; then
  echo "Error: Source directory not specified. Use -h or --help for usage."
  exit 1
fi
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Error: Source directory $SOURCE_DIR does not exist."
  exit 1
fi
mkdir -p "$DEST_DIR"
find "$SOURCE_DIR"   -type f   \( ! -path "$DEST_DIR/*" \)   $( [[ -n "$MODIFIED_DAYS" ]] && echo "-mtime -$MODIFIED_DAYS" )   $( [[ "$NOT_EMPTY" == true ]] && echo "-size +0" ) |   while read file; do
    relative_path="${file#$SOURCE_DIR/}"
    dest_path="$DEST_DIR/$relative_path"
    mkdir -p "$(dirname "$dest_path")"
    cp "$file" "$dest_path"
    echo "Copied: $file -> $dest_path"
  done
echo "Backup completed."
