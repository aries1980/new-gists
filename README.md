# new-gists

Kata to retrieve someones Github Gist as a shell script.

Retrieves a Github users latest gists and outputs a JSON with the URL to the Gist
and the time of the post.


## Usage

new-gists username [/path/to/timestamp-file] [--watch]


### Arguments

* **username**: (Required) The Github username of the person whose gists should be checked.

* **timestamp-file**: (Optional) A timestamp file that stores the last run's value.
This enables to retrieve the new gists' list. The default file is ~/.new-gists

* **--watch**: (Optional) Runs the script as a “daemon”, executes the Gist query in every
300 seconds (5 minutes) by default.


### Environment varaibles

* GITHUB_API_URL: The Github API endpoint URL.  This is used by the test scripts to set a stub.
Default value: `https://api.github.com`.

* DEFAULT_DATE_FROM: If the script runs for the first time, this is the date the script
lists the gist from.  Default: `20180101T00:00:00Z`. Use a second level granularity ISO-8601
date format.

* DEFAULT_WATCH_PERIOD: The seconds after the script automatically re-runs in `--watch` mode.
Default value: `300`.


## Requirements

* Bash >= 4.x
* cURL >= 7.x.x
* jq >= 1.5


## Tests

Go to the `tests` directory, and run the `test.sh` to execute the integration tests.
Don't worry, it runs against fixtures (stubs) and not against the Github API.
