#!/usr/bin/env bats

@test "gsd-init.sh --help returns usage information" {
  run bash bin/gsd-init.sh --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"[GSD Integration Bridge]"* ]]
}

@test "gsd-init.sh --version returns version" {
  run bash bin/gsd-init.sh --version
  [ "$status" -eq 0 ]
}
