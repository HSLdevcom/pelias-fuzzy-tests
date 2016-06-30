#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
   ENV=local
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

# param1: test id
# param2: printed label for test
function subtest {
    result=$(npm test -- -e $ENV -t $1 | grep "success rate")
    rate=$(echo $result | sed 's/[^0-9]//g')
    avg="$(($avg+$rate))"
    testcount="$((testcount+1))"
    echo "$2: $result" | tee -a $FILE
}

echo
echo "Logging test results to " $FILE
echo

#start logged output
echo "Testing " $ENV | tee $FILE
echo | tee -a $FILE
echo | tee -a $FILE


#==========
# API tests
#==========

echo "API tests. Match should be first in the result list." | tee -a $FILE
echo "----------------------------------------------------" | tee -a $FILE

#set priorityThresh of all tests to 1
sed -i 's/priorityThresh\": [0-9]\+/priorityThresh\": 1/' test_cases/*

avg=0 # reset average counting
testcount=0

subtest national "api / national"
subtest hsl "api / old reittiopas.fi"
subtest address "api / hsl address"
subtest poi "api / hsl poi"
subtest localization "api / hsl localization"
subtest postalcode "api / postal code"

echo | tee -a $FILE
avg="$(($avg/$testcount))"
echo "api: average success rate $avg%" | tee -a $FILE

echo | tee -a $FILE
echo | tee -a $FILE


#====================
# Data coverage tests
#====================

echo "Data tests. Match does not have to come first." | tee -a $FILE
echo "----------------------------------------------" | tee -a $FILE

#set priorityThresh of all tests to 10
sed -i 's/priorityThresh\": [0-9]\+/priorityThresh\": 10/' test_cases/*

avg=0 # reset avergae counting
testcount=0

subtest national "data / national"
subtest hsl "data / old reittiopas.fi"
subtest address "data / hsl address"
subtest poi "data / hsl poi"
subtest localization "data / hsl localization"
subtest postalcode "data / postal code"

echo | tee -a $FILE
avg="$(($avg/$testcount))"
echo "data: average success rate $avg%" | tee -a $FILE

echo | tee -a $FILE


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

PASS=1

count=${#OLD[@]}
count=$((count-1))

echo  | tee -a $FILE
echo "Comparing values.."  | tee -a $FILE
echo  | tee -a $FILE

for i in $(seq 0 $count)
do
    test1=${OLD[$i]}
    test2=${NEW[$i]}

    #simple sed use to drop all but percetage value
    val1=$(echo $test1 | sed 's/[^0-9]//g')
    val2=$(echo $test2 | sed 's/[^0-9]//g')

    if [ "$val1" -gt "$val2" ]; then
	echo "Regression: $test2 < $val1%"  | tee -a $FILE
	PASS=0
    fi
done

echo  | tee -a $FILE

if [ "$PASS" -ne "1" ]; then
    exit 1
fi

echo "No regressions detected"  | tee -a $FILE
echo  | tee -a $FILE
