#!/usr/bin/env bats

source 'test-utils.sh'

@test "does not modify pipe chars inside strings" {

  original_output=$(echo '[ { "values": [0] }, { "values": [ 1, 2 ] } ]' | jq '[.[].values[]] | length')
  pipespected_output=$(../pipespect.sh "echo '[ { \"values\": [0] }, { \"values\": [ 1, 2 ] } ]' | jq '[.[].values[]] | length'")

  [[ "${original_output}" = "${pipespected_output}" ]] || fail "The pipespected output (${pipespected_output}) does not match the original (${original_output})"

}

@test "handles pipes without surrounding whitespace" {

  pipespected_with_spaces_output=$(../pipespect.sh "echo 'foo' | sed 's/foo/bar/g'" 2>&1 >/dev/null)
  pipespected_without_spaces_output=$(../pipespect.sh "echo 'foo'|sed 's/foo/bar/g'" 2>&1 >/dev/null)

  [[ "${pipespected_with_spaces_output}" = "${pipespected_without_spaces_output}" ]] || fail "The output without spaces (${pipespected_without_spaces_output}) does not match the wanted (${pipespected_with_spaces_output})"

}
