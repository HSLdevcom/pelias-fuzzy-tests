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

result=$(npm test -- -e $ENV | grep "success rate")
echo "api / all: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t national | grep "success rate")
echo "api / national: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t hsl | grep "success rate")
echo "api / hsl: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t address | grep "success rate")
echo "api / hsl address: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t streetname | grep "success rate")
echo "api / exact address: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t poi | grep "success rate")
echo "api / hsl poi: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t localization | grep "success rate")
echo "api / hsl localization: $result" | tee -a $FILE

echo | tee -a $FILE
echo | tee -a $FILE


#====================
# Data coverage tests
#====================

echo "Data tests. Match does not have to come first."
echo "----------------------------------------------"

#set priorityThresh of all tests to 10
sed -i 's/priorityThresh\": [0-9]\+/priorityThresh\": 10/' test_cases/*

result=$(npm test -- -e $ENV | grep "success rate")
echo "data / all: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t national | grep "success rate")
echo "data / national: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t hsl | grep "success rate")
echo "data / hsl: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t address | grep "success rate")
echo "data / hsl address: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t streetname | grep "success rate")
echo "api / exact address: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t poi | grep "success rate")
echo "data / hsl poi: $result" | tee -a $FILE
result=$(npm test -- -e $ENV -t localization | grep "success rate")
echo "data / hsl localization: $result" | tee -a $FILE

echo | tee -a $FILE


#=================
# Regression check
#=================

if [[ "$FILE" -eq "$BENCHMARK" ]]; then
    #this was the first test run, nothing to compare with
    exit;
fi

#read test values into 2 arrays
mapfile -t OLD < <(grep "success rate" $BENCHMARK)
mapfile -t NEW < <(grep "success rate" $LATEST)

PASS=1

count=${#OLD[@]}
count=$((count-1))

echo
echo "Comparing values.."
echo

for i in $(seq 0 $count)
do
    test1=${OLD[$i]}
    test2=${NEW[$i]}

    #simple sed use to drop all but percetage value
    val1=$(echo $test1 | sed 's/[^0-9]//g')
    val2=$(echo $test2 | sed 's/[^0-9]//g')

    if [ "$val1" -gt "$val2" ]; then
	echo "Regression: $test2 < $val1%"
	PASS=0
    fi
done

echo

if [ "$PASS" -ne "1" ]; then
   exit 1
fi
