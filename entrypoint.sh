#!/bin/sh

export DISTRIBUTION="25"
export TARGET=".github/CODEOWNERS"

if [ -n "$INPUT_DISTRIBUTION" ]; then
  DISTRIBUTION="$INPUT_DISTRIBUTION"
  echo "Action defined distribution to $DISTRIBUTION%"
fi

if [ -n "$INPUT_PATH" ]; then
  TARGET="$INPUT_PATH"
  echo "Action defined target path to be $TARGET"
fi

if [ -n "$INPUT_GRANULAR" ]; then
  echo "Action enabled granular file processing"
fi

owners() {
  files=""

  if [ -n "$INPUT_GRANULAR" ]; then
    files=$(git ls-files)
  else
    dirs=$(git ls-tree -d -r --name-only HEAD)
    files=$(git ls-tree --name-only HEAD)
    files=$(printf "%s\n%s" "$dirs" "$files" | sort | uniq)
  fi

  for file in $files; do
    users=$( \
      git fame -eswMC --incl "$file/?[^/]*\.?[^/]*$" \
      | tr '/' '|' \
      | awk -v "dist=$DISTRIBUTION" -F '|' '(NR>6 && $6>=dist) {gsub(/ /, "", $2); print $2}' \
    )
    if [ "$?" -eq 0 ]; then
      if [ -n "$users" ]; then
        if [ -n "$INPUT_GRANULAR" ]; then
          echo "/$file $users"
        else
          if echo "$dirs" | grep -w "$file" > /dev/null; then
              echo "/$file/* $users"
          else
              echo "/$file $users"
          fi
        fi
      fi
    else
      echo "::error:: git fame command did not succeed"
      exit 1
    fi
  done
}

echo "Update code owners..."

owners | tee "$TARGET"
