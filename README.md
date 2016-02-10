# fuzzy tests

This repository contains digitransit specific Pelias API tests.

## prerequisites

You will need to have `npm` version `2.0` or higher installed.

## Setup

```bash
$ npm install
```

You will also need the digitransit-specific branch of the Pelias fuzzy tester.

- Clone the repository from [pelias-fuzzy-tester](https://github.com/hsldevcom/pelias-fuzzy-tester)
- Make pelias-fuzzy-tester the current directory (`cd pelias-fuzzy-tester`)
- Run `npm install`
- Run `sudo npm link` command to make the local tester module available for other pelias components
- Make pelias-fuzzy-tests the current directory (`cd ../pelias-fuzzy-tests`)
- Run `npm link pelias-fuzzy-tests` command to link the tests with the previously installed tester
- In order to use your local pelias setup the way you like, you will need a pelias configuration file.
  You can clone a default configuration from [pelias/config repository](https://github.com/pelias/config).
  For example `config/default.json is a good starting point. Store the configuration file to a suitable path.
  A good place is in your home directory, `~/pelias.json`, because Pelias searches it from there automatically.
  Then add the test specific section below to the configuration:

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
- If you did not store configuration to your home directory but to a custom path, set environment
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
[pelias-fuzzy-tester](https://github.com/HSLdevcom/pelias-fuzzy-tester) documentation
