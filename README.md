#### status of [pelias.mapzen.com](http://pelias.mapzen.com): [![Build Status](https://travis-ci.org/pelias/acceptance-tests.png)](https://travis-ci.org/pelias/acceptance-tests)

# acceptance tests

This repository contains all of the Pelias API "acceptance" tests, which are automated tests used to identify
improvements and regressions between various versions of the API and the underlying data. Since it's
difficult/impossible to manually verify whether things have begun silently failing (eg, a certain query stopped
returning the right results) after a data or search logic change, the acceptance tests should provide us with a
shotgun overview of the status of any Pelias instance.

## Usage

```
node test --help
```

## Test Case Files
Test-cases live in `test_cases/`, and are split into test *suites* in individual JSON files. Each file must contain the
following properties:

 + `name` is the suite title displayed when executing.
 + `priorityThresh` indicates the expected result must be found within the top N locations. This can be set for the entire suite as well as overwritten in individual test cases.
 + `tests` is an array of test cases that make up the suite.
 + `endpoint` the API endpoint (`search`, `reverse`, `suggest`) to target. Defaults to `search`.

`tests` consists of objects with the following properties:
 + `id` is a unique identifier within the test suite (this could be unnecessary, let's discuss)
 + `type` is simply a category to group the test under, to allowing running select groups of tests rather than all of
   them.
 + `status` is the optional expected status of this test-case (whether it should pass/fail/etc.), and will be used to
   identify improvements and regressions. May be either of `pass` or `fail`.
 + `user` is the name of the person that added the test case.
 + `endpoint` the API endpoint (`search`, `reverse`, `suggest`) to target. Defaults to `search`, which will override the
   `endpoint` specified by the test-suite.
 + `in` contains the API parameters that will be urlencoded and appended to the API url.
 + `expected` contains *expected* results. The object can contain a `priorityThresh` property, which will override the
   `priorityThresh` specified by the test-suite, and must contain a `properties` property. `properties` is mapped to an
   array of either of:

     + `object`: all of the key-value pairs will be tested against the objects returned by the API for exact matches.
     + `string`: a matching object will be looked up in the `locations.json` file. Allows you to easily reuse the same
      object for multiple test-cases.

   If `properties` is `null`, the test-case is assumed to be a placeholder.

+ `unexpected` is analogous to `expected`, except that you *cannot* specify a `priorityThresh` and the `properties`
  array does *not* support strings.

## output generators
The acceptance-tests support multiple different output generators, like an email and terminal output. See `node test
--help` for details on how to specify a generator besides the default. Note that the `email` generator requires an
AWS account, and that your `pelias-config` file contain the following configuration:

```javascript
{
	"acceptance-tests": {
		"email": {
			"ses": {
				"accessKeyId": "AWSACCESSKEY",
				"secretAccessKey": "AWS/Secret/key",
			},
			"recipients": ["recipient1@domain.com", "recipient2@domain.com"], // the list of recipients
		}
	}
}
```

## API URL aliases
The acceptance-tests runner recognizes a number of aliases for Pelias API URLs (eg, `stage` corresponds to
`pelias.stage.mapzen.com`), which can be specified as command-line arguments when running a test suite. You can
override the default aliases and define your own in `pelias-config`:

```javascript
{
	"acceptance-tests": {
		"endpoints": {
			"alias": "http://my.pelias.instance"
		}
	}
}
```
