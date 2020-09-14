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

identification() {
  read -r email
  if [ -n "$INPUT_USERNAME" ] && [ -n "$email" ]; then
    if ! username=$( \
      curl "https://api.github.com/search/users?q=$email+in:email" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: Bearer $INPUT_TOKEN" \
        | jq -r -e '.items[0].login' \
    );
    then
      if ! commit_username_json=$( \
        curl "https://api.github.com/search/commits?q=author-email:$email&sort=author-date&per_page=1" \
          -H "Accept: application/vnd.github.cloak-preview" \
          -H "Authorization: Bearer $INPUT_TOKEN" \
      );
      then
        echo "$email"
      else
        if ! commit_username=$(echo "$commit_username_json" | jq -r -e '.items[0].author.login');
        then
          >&2 echo "::warning:: $commit_username_json"
          echo "$email"
        else
          echo "@$commit_username"
        fi
      fi
    else
      echo "@$username"
    fi
  else
    echo "$email"
  fi
}

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
    if ! users=$( \
      git fame -eswMC --incl "$file/?[^/]*\.?[^/]*$" \
      | tr '/' '|' \
      | awk -v "dist=$DISTRIBUTION" -F '|' '(NR>6 && $6>=dist) {gsub(/ /, "", $2); print $2}' \
      | identification
    );
    then
      echo "::error:: git fame command did not succeed"
      exit 1
    else
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
    fi
  done
}

echo "Update code owners..."

owners | tee "$TARGET"
