#!/bin/bash

chain="$1"

debug_command=""

function debug() {
  >&2 echo "dupa $1"
  cat
}

tempdir=$(mktemp -d)
i=0

IFS='|' read -ra commands <<< "$chain"
for dirty_cmd in "${commands[@]}"; do
  cmd=$(sed 's/^[[:space:]]*//' <<< "$dirty_cmd")
  echo "$cmd" > "$tempdir/$i"
  if [ -z "$debug_command" ]; then
    debug_command="$cmd"
  else
    debug_command="$debug_command | tee -a \"$tempdir/$((i-1))\" | $cmd"
  fi
  i=$((i+1))
done


echo "aa"
echo "$debug_command"

eval "$debug_command >> \"$tempdir/$i\""

cat "$tempdir"/*
