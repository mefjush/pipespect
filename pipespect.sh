#!/bin/bash

set -e

function usage() {
  >&2 echo "Usage: $0 [-d|--debug] [-s|--skip number] [-q|--quiet] 'chain | of | piped | commands'"
  exit 1
}

function trim() {
  sed 's/^[ \t]*//;s/[ \t]*$//'
}

DEBUG=false
PRINT_OUTPUT=true
PRINT_HEADER=true
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
    -q|--quiet)
      PRINT_OUTPUT=false
      PRINT_HEADER=false
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
if [ "$#" -eq 1 ]; then
  string="$1"
else
  string=$(cat)
fi

tempdir=$(mktemp -d)

# spit the chain of pipes
commands=()
result=''
inside=''
for (( i=0 ; i<${#string} ; i++ )) ; do
  char=${string:i:1}
  if [[ $inside ]] ; then
    if [[ $char == \\ ]] ; then
      if [[ $inside=='"' && ${string:i+1:1} == '"' ]] ; then
        let i++
        char=$inside
      fi
    elif [[ $char == $inside ]] ; then
      inside=''
    fi
  else
    if [[ $char == ["'"'"'] ]] ; then
      inside=$char
    elif [[ $char == '|' ]] ; then
      char=''
      commands+=("$(echo "$result" | trim)")
      result=''
    fi
  fi
  result+=$char
done
if [[ $inside ]] ; then
  >&2 echo Error parsing "$result"
  exit 1
fi
commands+=("$(echo "$result" | trim)")

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
  output="$tempdir/$i"
  echo >> "$output"
  echo "↑ $cmd" >> "$output"
  echo >> "$output"
  i=$((i+1))
done

if $PRINT_HEADER; then
  >&2 echo "== Pipespection =="
  >&2 echo "> $string"
fi

# print the inspected outputs
find "$tempdir" -type f | sort -r | head -n "-$((SKIP))" | >&2 xargs cat

# cleanup
if ! $DEBUG; then
  rm -rf "$tempdir"
fi
