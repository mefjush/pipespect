#!/bin/bash

set -e

function usage() {
  >&2 echo "Usage: $0 [-d|--debug] [-s|--skip number] 'chain | of | piped | commands'"
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

if [ "$#" -ne 1 ]; then
  usage  
fi

tempdir=$(mktemp -d)

# tokenize the chain
string="$1"
results=()
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
    elif [[ $char == ' ' ]] ; then
      char=''
      results+=("$result")
      result=''
    fi
  fi
  result+=$char
done
if [[ $inside ]] ; then
  >&2 echo Error parsing "$result"
  exit 1
else
  results+=("$result")
fi

# split the chain of piped commands
commands=()
i=0
for token in "${results[@]}"; do
  if [ "$token" == "|" ]; then
    i=$((i+1))
    commands+=("$cmd")
    unset cmd
  else
    cmd="${cmd:+$cmd }$token"
  fi
done
commands+=("$cmd")

# prepare a modified command that intercepts the intermediate outputs
i=0
for cmd in "${commands[@]}"; do
  output="$tempdir/$i"
  debug_command="${debug_command:+$debug_command | }$cmd | tee -a \"$output\""
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
  echo -e "\n↑ $cmd\n" >> "$output"
  i=$((i+1))
done

# print the inspected outputs
find "$tempdir" -type f | sort -r | head -n "-$((SKIP))" | xargs cat | >&2 tail +2

# cleanup
if ! $DEBUG; then
  rm -rf "$tempdir"
fi

