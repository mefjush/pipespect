#!/bin/bash

set -e

function usage() {
  >&2 echo "Usage: $0 [-d|--debug] [-s|--skip number] [-v|--verbose] 'chain | of | piped | commands'"
  exit 1
}

function trim() {
  sed 's/^[ \t]*//;s/[ \t]*$//'
}

function join_by {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

function parse_commands() {
  result=''
  inside=''
  prev=''
  while IFS= read -r -n1 char; do
    if [[ $inside ]] ; then
      if [[ $char == "$inside" ]] && [[ $char != '"' || $prev != \\ ]] ; then
        inside=''
      fi
    else
      if [[ $char == "'" || $char == '"' ]] ; then
        inside=$char
      elif [[ $char == '|' ]] ; then
        commands+=("$(echo "$result" | trim)")
        char=''
        result=''
      fi
    fi
    result+=$char
    prev=$char
  done

  if [[ $inside ]] ; then
    >&2 echo Error parsing "$result"
    exit 1
  fi
  commands+=("$(echo "$result" | trim)")
}

DEBUG=false
PRINT_OUTPUT=false
PRINT_HEADER=false
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
    -v|--verbose)
      PRINT_OUTPUT=true
      PRINT_HEADER=true
      shift # past argument
      ;;
    -*)
      >&2 echo "Unknown option $1"
      usage
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [ "$#" -gt 1 ]; then
  usage
fi

tempdir=$(mktemp -d)

commands=()
if [ "$#" -eq 1 ]; then
  parse_commands <<< "$1"
else
  parse_commands
fi

# prepare a modified command that intercepts the intermediate outputs
i=0
for cmd in "${commands[@]}"; do
  debug_command="${debug_command:+$debug_command | }$cmd"
  if [[ "$PRINT_OUTPUT" == true || "$((i+1))" -lt "${#commands[@]}" ]]; then
    output="$tempdir/$i"
    debug_command="$debug_command | tee -a \"$output\""
  fi
  i=$((i+1))
done

if $DEBUG; then
  >&2 echo "Evaluating: $debug_command"
fi
eval "$debug_command"

# annotate the intercepted outputs
i=0
for cmd in "${commands[@]}"; do
  { echo; echo "↑ $cmd"; echo; } >> "$tempdir/$i"
  i=$((i+1))
done

if $PRINT_HEADER; then
  >&2 echo "== Pipespection =="
  >&2 echo "> $(join_by " | " "${commands[@]}")"
fi

# print the inspected outputs
find "$tempdir" -type f | sort -r | head -n "-$((SKIP))" | >&2 xargs cat

# cleanup
if ! $DEBUG; then
  rm -rf "$tempdir"
fi
