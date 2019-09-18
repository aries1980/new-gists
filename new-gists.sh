#!/usr/bin/env bash

set -eu

# Checks for debugging mode.
DEBUG=${DEBUG:-''}
[ -n "$DEBUG" ] && set -x

setenv() {
  GITHUB_API_URL=${STUB_GITHUB_API_URL:-'https://api.github.com'}
  DEFAULT_DATE_FROM=${DEFAULT_DATE_FROM:-'20180101T00:00:00Z'}
}

##
# Returns with the usage of the script.
##
usage() {
  echo "new-gists.sh"
  echo "Returns with the latest Github gists of a user."
  echo ""
  echo "Usage: new-gists.sh github-usernme [/path/to/timestamp-file] [--wait]"
  echo
  echo "If the timestamp file option is not given, ~/.new-gists will be used."
}

##
# Calls the Github API to retrieve the Gists
#
# @param $1: The username.
# @param $2: The “since” date.
# @param $STUB_REST_PATH: (Optional) The location to the stub file,
#   relative to the STUB_API_URL.
#
# @return
#   The exit code for non-HTTP-2xx, or the output of the Gists in JSON.
#   It can be an empty array.
##
call_github_api() {
  local username=$1
  local date_from=$2
  local rest_path=${STUB_REST_PATH:-"users/$username/gists?since=$date_from"}

  set +e
  result=$(curl -fs \
    ${GITHUB_API_URL}/${rest_path} \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/json" \
    -X GET
  )

  exit_code=$?
  if [[ "$exit_code" != 0 ]]; then
    echo "Calling the Github API failed with exit code: $exit_code"
    exit 1
  fi
  set -e

  echo $result
}

##
# Returns with the gists.
#
# @param: $1: The username of the owner of the gist.
# @param: $2: Path to the file that contains the last retrieval time.
#
# @TODO: Mixing JSON and raw string limits the usefulness of this function.
##
get_gist() {
  local username=$1
  local path_to_file=$(touch $2; realpath $2)
  local __date_from=$(cat $path_to_file)
  # Trick, because date() returns with the current timestamp on empty string.
  local date_from=${__date_from:-'invalid date'}

  if ! date -d "${date_from}" &> /dev/null; then
    date_from=$DEFAULT_DATE_FROM
  fi

  github_gists=$(call_github_api $username $date_from | jq '.[] | {url: .html_url, created_at: .created_at}')
  
  if [ -n "$github_gists" ]; then
    echo "Since $date_from the $username posted the following gists:"
    echo $github_gists
  else
    echo "No new gist by $username since $date_from ."
  fi

  date --iso-8601=seconds > $path_to_file 
}

##
# Main function.
##
main() {
  if [ $# -lt 1 ]; then
    usage
    exit 1
  fi
  
  local path_to_file=${2:-"$HOME/.new-gists"}
  local watch_enabled=${3:-''}
  
  # If the 3rd argument is --wait, loop it for 300 secs (5 mins).
  if [ -n "$watch_enabled" ] && [[ "$watch_enabled" == "--watch" ]]; then
    watch -n 300 get_gist $1 $path_to_file
  else
    get_gist $1 $path_to_file
  fi
}

setenv
# Remove this if you want to use it as a lib.
main "$@"
