#!/usr/bin/env bash

##
# @file Runs integration tests against new-gists.sh using stubs.
##

setenv() {
  DEFAULT_TIMESTAMP_FILE="$HOME/.new-gists"

  __TRED="\033[1;31m"
  __TGREEN="\033[1;32m"
  __TRESET="\033[0m"

  __PASS="${__TGREEN} Passed${__TRESET}"
  __FAIL="${__TRED} Failed${__TRESET}"
  __TESTS="
    custom_timestamp_file_doesnt_exit_yet
    default_timestamp_file_doesnt_exit_yet
    timestamp_file_contains_a_valid_date
  "
}

##
# Used to minimise race-conditions when you run cmd more than once in the same second.
##
unique_id() {
  echo $(( $(shuf -i 000001-999999 -n1) * $(shuf -i 000001-999999 -n1) ))
}

cleanup() {
  [[ -n "$1" ]] && [[ -f $1 ]] && rm -rf $1
}

custom_timestamp_file_doesnt_exit_yet() {
  echo -n "Creates custom a timestamp file if hasn't been created… "

  path_to_file="/tmp/$(unique_id)"

  STUB_GITHUB_API_URL="file://${PWD}/stubs/stub_valid_full.json" \
    ../new-gists.sh x $path_to_file 2> /dev/null

  [[ -f $path_to_file ]] && echo -e $__PASS || echo -e $__FAIL

  cleanup $path_to_file
}

default_timestamp_file_doesnt_exit_yet() {
  echo -n "Creates a default timestamp file if hasn't been created… "

  # Sorry, but we are testing carte blance here.
  [[ -f $DEFAULT_TIMESTAMP_FILE ]] && rm $DEFAULT_TIMESTAMP_FILE
  STUB_GITHUB_API_URL="file://${PWD}/stubs/stub_valid_full.json" \
    ../new-gists.sh x 2> /dev/null

  [[ -f $DEFAULT_TIMESTAMP_FILE ]] && echo -e $__PASS || echo -e $__FAIL
  
  cleanup $DEFAULT_TIMESTAMP_FILE
}

timestamp_file_contains_a_valid_date() {
  echo -n "The timestamp file contains a valid date… "

  path_to_file="/tmp/$(unique_id)"

  STUB_GITHUB_API_URL="file://${PWD}/stubs/stub_valid_full.json" \
    ../new-gists.sh x $path_to_file 2> /dev/null

  if [ -f $path_to_file ]; then
    local __content=$(cat $path_to_file)
    # Trick, because date() returns with the current timestamp on empty string.
    local content=${__content:-'invalid date'}

    if date -d "${date_from}" &> /dev/null; then
      echo -e $__PASS
    else
      echo -e $__FAIL
    fi
  fi
}


##
# Runs the tests.
##
run_tests() {
  for i in $__TESTS; do
    $i
  done
}

setenv
run_tests
