# fuzzy tests

This repository contains digitransit specific Pelias API tests.

## prerequisites

You will need to have `npm` version `2.0` or higher installed.

## Setup

```bash
$ npm install
```

You will also need the digitransit-specific branch of the Pelias fuzzy tester. 

1. Clone the repository from [pelias-fuzzy-tester](https://github.com/hsldevcom/pelias-fuzzy-tester) 
2. run `npm install` in the created directory.
3. run `npm link` command in ?? directory (CLARIFY THIS!)
4. run `npm link xxx` command in ?? directory (CLARIFY THIS!)
5. Create pelias-fuzzy-tester/pelias.json config file as follows:
```javascript
{
  "acceptance-tests": {
    "endpoints": {
        "local": "http://localhost:3100/v1/",
        "dev": "http://dev.digitransit.fi/pelias/v1/",
        "prod": "http://dev.digitransit.fi/pelias/v1/"
    }
  }
}
```
6. Set environment variable `PELIAS_CONFIG` to the path at which the file can be found. So do something like this, but
with your path.

```bash
$ export PELIAS_CONFIG=/etc/config.json
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
[pelias-fuzzy-tester](https://github.com/HSLdevcom/pelias-fuzzy-tester) documentation
