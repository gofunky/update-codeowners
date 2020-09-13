#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Executing git fame
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Update code owners..."

owners() {
  for f in $(git ls-files); do
    printf "%s " "$f"
    git fame -esnwMC --incl "$f" | tr '/' '|' \
      | awk -v DISTRIBUTION="$INPUT_DISTRIBUTION" -F '|' '(NR>6 && $6>=$DISTRIBUTION) {print $2}' \
      | xargs echo
  done
}

owners | tee "invalid"
