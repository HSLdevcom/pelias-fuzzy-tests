# fuzzy tests

This repository contains digitransit specific Pelias API tests.

## prerequisites

You will need to have `npm` version `2.0` or higher installed.

## Setup

Install the npm package as usual:

```bash
$ npm install
```

In order to use your local pelias setup the way you like, you will need a pelias configuration file.
You can clone a default configuration from [pelias/config repository](https://github.com/pelias/config).
For example `config/local.json` serves a starting point. Store the configuration file to a suitable path.
A good place is in your home directory, `~/pelias.json`, because Pelias searches it from there automatically.
Then add the test specific section below to the configuration:

```javascript
{
  "acceptance-tests": {
    "endpoints": {
        "local": "http://localhost:3100/v1/",
        "dev": "http://dev.digitransit.fi/pelias/v1/",
        "prod": "http://api.digitransit.fi/geocoding/v1/"
    }
  }
}
```
If you did not store configuration to your home directory but to a custom path, set environment
variable `PELIAS_CONFIG` to the path at which the file can be found. So do something like this, but
with your path:

```bash
$ export PELIAS_CONFIG=/etc/pelias.json
```

## Usage

default to running all tests against production

```bash
$ npm test &>results.txt
```

NOTE: Above, test output is redirected to a file. Test output to a terminal window
usually breaks prematurely, when the nodejs process exits.

specify an environment manually
```bash
$ npm test -- -e dev &>results.txt
```

specify an environment and only run tests that work against dev (a target subgroup defined in test cases)

```bash
$ npm test -- -e dev -t dev &>results.txt
```

dump results from failing tests into json files, one per failing test

```bash
$ npm test -- -e dev -o json
```


## Test Case Files

For a full description of what can go in tests, see the
[fuzzy-tester](https://github.com/HSLdevcom/fuzzy-tester) documentation


## Regression Test Bench

The bash script `run_test.sh` runs an extensive set of tests against a given geocoding endpoint.
When run first time, it initializes a log file 'benchmark.txt', which contains a summary of test results.
New run cycles thereafter log to a file called 'latest.txt', and compare the new test results with
the initial benchmark. To update the benchmark, just erase the benchmark file before starting the tests,
or rename 'latest.txt' as 'benchmark.txt' after running the tests.

The tested end point can be set as a command line parameter, the default value being 'local'. For example:

Local:
```bash
$ ./run_tests.sh
```

Dev: (service address defined in pelias.config, see the Setup note above)

```bash
$ ./run_tests.sh dev
```

Currently the test set includes about 6000 geocoding tests, which are run twice. The first test round
focuses on testing how well the Pelias api places good matches to the beginning of the result list.
The second round does not care about position of the best match - it is enough, that the result is found.
This serves as a data coverage test.

Note: running the test bench takes a long time, 15 minutes or so.

Note2: Fuzzy tester prints 'npm ERR! Test failed. ... ' to stderr when success rate is below full 100%.
Such messages can be ignored.

Note3: The test bench does not detect individual (=single address) regressions. Only the overall
score counts.

