#!/bin/bash

set -e

function usage() {
  echo "Usage: $0 [-d|--debug] [-s|--skip number] 'chain | of | piped | commands'"
  exit 1
}

DEBUG=false
SKIP=0

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--debug)
      DEBUG=true
      shift # past argument
      ;;
    -s|--skip)
      SKIP="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      usage
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ "$#" -ne 1 ]; then
  usage  
fi

chain="$1"
debug_command=""

tempdir=$(mktemp -d)
i=0

IFS='|' read -ra commands <<< "$chain"
for dirty_cmd in "${commands[@]}"; do
  cmd=$(sed 's/^[[:space:]]*//' <<< "$dirty_cmd")
  echo -e "\n> $cmd" > "$tempdir/$i"
  if [ -z "$debug_command" ]; then
    debug_command="$cmd"
  else
    debug_command="$debug_command | tee -a \"$tempdir/$((i-1))\" | $cmd"
  fi
  i=$((i+1))
done

if $DEBUG; then
  echo "Evaluating: $debug_command"
fi

eval "$debug_command >> \"$tempdir/$i\""
find "$tempdir" -type f | sort | tail -n "+$((SKIP+1))" | xargs cat

if ! $DEBUG; then
  rm -rf "$tempdir"
fi
