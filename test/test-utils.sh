#!/bin/bash
# A copy paste from `bats-support` lib, if we need more functions then probably better if we just install the lib (which is a bit of a hassle)
# see: https://github.com/ztombol/bats-docs#installation

fail() {
  (( $# == 0 )) && batslib_err || batslib_err "$@"
  return 1
}

batslib_err() {
  { if (( $# > 0 )); then
      echo "$@"
    else
      cat -
    fi
  } >&2
}