#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
   ENV=local
fi

THRESHOLD=$2
if [ -z "$THRESHOLD" ]; then
   THRESHOLD=100 #cannot fail
fi

BENCHMARK=benchmark.txt
LATEST=latest.txt

if [ -e "$BENCHMARK" ]; then
    FILE="$LATEST"
    if [ -e "$LATEST" ]; then
	#backup
	mv "$LATEST"  "_$LATEST"
    fi
else
    FILE=$BENCHMARK
fi

# output to stdio and log file
function log {
    echo -e $1 | tee -a $FILE
}

# param1: test id
# param2: printed label for test
function subtest {
    result=$(npm test -- -e $ENV -t $1 | grep "success rate")
    rate=$(echo $result | sed 's/[^0-9.]//g')
    avg=$(echo "$avg + $rate" | bc)
    testcount="$((testcount+1))"
    log "$2: $result"
}

echo
echo "Logging test results to " $FILE
echo

#start logged output
log "Testing " $ENV "\n\n"


#==========
# API tests
#==========

log "API tests. Match should be first in the result list."
log "----------------------------------------------------\n"

#set priorityThresh of all tests to 1
sed -i 's/priorityThresh\": [0-9.]\+/priorityThresh\": 1/' test_cases/*

avg=0 # reset average counting
testcount=0

subtest national "api / national"
subtest hsl "api / old reittiopas"
subtest address "api / hsl address"
subtest poi "api / hsl poi"
subtest localization "api / hsl localization"
subtest postalcode "api / postal code"
subtest acceptance "api / acceptance"

avg=$(echo "$avg / $testcount" | bc)
log "\napi: average success rate $avg%\n\n"


#====================
# Data coverage tests
#====================

log "Data tests. Match does not have to come first."
log "----------------------------------------------\n"

#set priorityThresh of all tests to 10
sed -i 's/priorityThresh\": [0-9.]\+/priorityThresh\": 10/' test_cases/*

avg=0 # reset avergae counting
testcount=0

subtest national "data / national"
subtest hsl "data / old reittiopas"
subtest address "data / hsl address"
subtest poi "data / hsl poi"
subtest localization "data / hsl localization"
subtest postalcode "data / postal code"
subtest acceptance "data / acceptance"

avg=$(echo "$avg / $testcount" | bc)
log "\ndata: average success rate $avg%\n\n\n"

#=================
# Regression check
#=================


if [ "$FILE" == "$BENCHMARK" ]; then
    #this was the first test run, nothing to compare with
    exit;
fi

#read test values into 2 arrays
mapfile -t OLD < <(grep "success rate" $BENCHMARK)
mapfile -t NEW < <(grep "success rate" $LATEST)

REGR=0
FAIL=0

count=${#OLD[@]}
count=$((count-1))

log "Checking regressions"
log "--------------------\n"

for i in $(seq 0 $count)
do
    test1=${OLD[$i]}
    test2=${NEW[$i]}

    #simple sed use to drop all but decimal percentage value
    val1=$(echo $test1 | sed 's/[^0-9.]//g')
    val2=$(echo $test2 | sed 's/[^0-9.]//g')

    regr=$(echo "$val1 > $val2" | bc -l)

    if [ $regr -eq 1 ]; then
	log "Regression: $test2 < $val1%"  | sed 's/success //g'
	REGR=1
    fi

    fail=$(echo "$val1 > $val2 + $THRESHOLD" | bc -l)
    if [ $fail -eq 1 ]; then
	FAIL=1
    fi

done

if [ "$REGR" -eq "0" ]; then
    log "No regressions detected\n"
fi


if [ "$FAIL" -ne "0" ]; then
    log "\nRegression threshold exceeded, test failed\n"
    exit 1
fi

