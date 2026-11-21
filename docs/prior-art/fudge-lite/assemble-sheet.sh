#!/bin/bash
# assemble-sheet.sh: Read game state files, validate format, generate gamestate.txt, display character sheet
# Usage: assemble-sheet.sh

set -euo pipefail

# ANSI color codes
B=$'\x1b[1;33m'  # Bold Yellow (for headings)
C=$'\x1b[1;36m'  # Bold Cyan (for labels)
W=$'\x1b[1;37m'  # Bold White (for values)
R=$'\x1b[1;31m'  # Bold Red (for health/danger)
G=$'\x1b[1;32m'  # Bold Green (for good status)
NC=$'\x1b[0m'    # No Color

# File paths (relative to script location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME_FILE="$SCRIPT_DIR/name.txt"
HEALTH_FILE="$SCRIPT_DIR/health.txt"
DESC_FILE="$SCRIPT_DIR/description.txt"
LOC_FILE="$SCRIPT_DIR/location.txt"
ABILITIES_FILE="$SCRIPT_DIR/abilities.txt"
SKILLS_FILE="$SCRIPT_DIR/skills.txt"
POWERS_FILE="$SCRIPT_DIR/powers.txt"
GIFTS_FILE="$SCRIPT_DIR/gifts.txt"
FAULTS_FILE="$SCRIPT_DIR/faults.txt"
INVENTORY_FILE="$SCRIPT_DIR/inventory.txt"
OBJECTIVES_FILE="$SCRIPT_DIR/objectives.txt"
GAMESTATE_FILE="$SCRIPT_DIR/gamestate.txt"

# Error handler
error_exit() {
  printf "${R}ERROR: %s${NC}\n" "$1" >&2
  exit 1
}

# Validate file exists and is readable
require_file() {
  local file="$1"
  [[ -f "$file" ]] || error_exit "File not found: $file"
  [[ -r "$file" ]] || error_exit "File not readable: $file"
}

# Read single-line file
read_single_line() {
  local file="$1"
  require_file "$file"
  head -1 "$file"
}

# Read multi-line file
read_multi_line() {
  local file="$1"
  require_file "$file"
  cat "$file"
}

# Read key/value file and validate format
read_keyvalue() {
  local file="$1"
  require_file "$file"

  local output=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! echo "$line" | grep -qE '^\s*[^:=]+[:=].+'; then
      error_exit "Invalid format in $file (line: $line). Expected 'key: value' or 'key=value'"
    fi
    output+="$line"$'\n'
  done < "$file"

  printf '%s' "${output%$'\n'}"
}

# Read list file (one item per line)
read_list() {
  local file="$1"
  require_file "$file"
  cat "$file"
}

# Read all state files
name=$(read_single_line "$NAME_FILE")
health=$(read_single_line "$HEALTH_FILE")
description=$(read_multi_line "$DESC_FILE")
location=$(read_multi_line "$LOC_FILE")
abilities=$(read_keyvalue "$ABILITIES_FILE")
skills=$(read_keyvalue "$SKILLS_FILE")
powers=$(read_list "$POWERS_FILE")
gifts=$(read_list "$GIFTS_FILE")
faults=$(read_list "$FAULTS_FILE")
inventory=$(read_list "$INVENTORY_FILE")
objectives=$(read_list "$OBJECTIVES_FILE")

# Generate gamestate.txt
{
  printf "%s\n" "${B}═══════════════════════════════════════${NC}"
  printf "%s\n" "${C}CHARACTER: ${W}${name}${NC}"
  printf "%s\n" "${B}═══════════════════════════════════════${NC}"
  printf "\n"
  printf "%s\n" "${C}HEALTH:${NC} ${W}${health}${NC}"
  printf "\n"
  printf "%s\n" "${C}DESCRIPTION:${NC}"
  printf "%s\n" "${W}${description}${NC}"
  printf "\n"
  printf "%s\n" "${C}LOCATION & SCENE:${NC}"
  printf "%s\n" "${W}${location}${NC}"
  printf "\n"
  printf "%s\n" "${B}─ ABILITIES ─${NC}"
  printf "%s\n" "${W}${abilities}${NC}"
  printf "\n"
  printf "%s\n" "${B}─ SKILLS ─${NC}"
  printf "%s\n" "${W}${skills}${NC}"
  printf "\n"
  printf "%s\n" "${B}─ POWERS ─${NC}"
  printf "%s\n" "${W}${powers}${NC}"
  printf "\n"
  printf "%s\n" "${B}─ GIFTS ─${NC}"
  printf "%s\n" "${W}${gifts}${NC}"
  printf "\n"
  printf "%s\n" "${B}─ FAULTS ─${NC}"
  printf "%s\n" "${W}${faults}${NC}"
  printf "\n"
  printf "%s\n" "${B}─ INVENTORY ─${NC}"
  printf "%s\n" "${W}${inventory}${NC}"
  printf "\n"
  printf "%s\n" "${B}─ OBJECTIVES ─${NC}"
  printf "%s\n" "${W}${objectives}${NC}"
  printf "\n"
  printf "%s\n" "${B}═══════════════════════════════════════${NC}"
} | tee "$GAMESTATE_FILE"
