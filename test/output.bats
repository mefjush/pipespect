#!/usr/bin/env bats

source 'test-utils.sh'

@test "preserves the original output" {

  original_output=$(echo "foo bar" | sed "s/bar/baz/g" | tr " " "-")
  pipespected_output=$(../pipespect.sh -v 'echo "foo bar" | sed "s/bar/baz/g" | tr " " "-"')

  [[ "${original_output}" = "${pipespected_output}" ]] || fail "The pipespected output (${pipespected_output}) does not match the original (${original_output})"

}
