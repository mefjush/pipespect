#!/usr/bin/env bats

source 'test-utils.sh'

@test "does not modify pipe chars inside strings" {

  original_output=$(echo '[ { "values": [0] }, { "values": [ 1, 2 ] } ]' | jq '[.[].values[]] | length')
  pipespected_output=$(../pipespect.sh "echo '[ { \"values\": [0] }, { \"values\": [ 1, 2 ] } ]' | jq '[.[].values[]] | length'")

  [[ "${original_output}" = "${pipespected_output}" ]] || fail "The pipespected output (${pipespected_output}) does not match the original (${original_output})"

}
