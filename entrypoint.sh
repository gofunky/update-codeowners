#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Executing git fame
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Update code owners..."

owners() {
  files=""
  if [ -n "$INPUT_GRANULAR" ]; then
    files=$(git ls-files)
  else
    dirs=$(git ls-tree -d -r --name-only HEAD)
    files=$(git ls-tree --name-only HEAD)
    files=$(printf "%s\n%s" "$dirs" "$files" | sort | uniq)
  fi

  for f in $files; do
    users=$( \
      git fame -eswMC --incl "$f/?([^/]*)$" \
      | tr '/' '|' \
      | awk -v DISTRIBUTION="$INPUT_DISTRIBUTION" -F '|' '(NR>6 && $6>=DISTRIBUTION) {print $2}' \
      | xargs echo \
      )
    if [ -n "$users" ]; then
      echo "$f $users"
    fi
  done
}

owners | tee "$INPUT_PATH"
