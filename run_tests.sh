#!/bin/bash

ENV=$1

if [ -z "$ENV" ]; then
   ENV=local
fi

echo "Testing " $ENV
echo
echo

#==========
# API tests
#==========

echo "API tests. Match should be first in the result list."
echo "----------------------------------------------------"

sed -i 's/priorityThresh\": [0-9]\+/priorityThresh\": 1/' test_cases/*

result=$(npm test -- -e $ENV | grep "success rate")
echo -n  "api / all: " && echo "$result"
result=$(npm test -- -e $ENV -t national | grep "success rate")
echo -n  "api / national: " && echo "$result"
result=$(npm test -- -e $ENV -t hsl | grep "success rate")
echo -n  "api / hsl: " && echo "$result"
result=$(npm test -- -e $ENV -t address | grep "success rate")
echo -n  "api / hsl address: " && echo "$result"
result=$(npm test -- -e $ENV -t streetname | grep "success rate")
echo -n  "api / hsl address: " && echo "$result"
result=$(npm test -- -e $ENV -t poi | grep "success rate")
echo -n  "api / hsl poi: " && echo "$result"
result=$(npm test -- -e $ENV -t localization | grep "success rate")
echo -n  "api / hsl localization: " && echo "$result"

echo
echo

#====================
# Data coverage tests
#====================

echo "Data tests. Match does not have to come first."
echo "----------------------------------------------"

sed -i 's/priorityThresh\": [0-9]\+/priorityThresh\": 10/' test_cases/*

result=$(npm test -- -e $ENV | grep "success rate")
echo -n  "data / all: " && echo "$result"
result=$(npm test -- -e $ENV -t national | grep "success rate")
echo -n  "data / national: " && echo "$result"
result=$(npm test -- -e $ENV -t hsl | grep "success rate")
echo -n  "data / hsl: " && echo "$result"
result=$(npm test -- -e $ENV -t address | grep "success rate")
echo -n  "data / hsl address: " && echo "$result"
result=$(npm test -- -e $ENV -t streetname | grep "success rate")
echo -n  "api / hsl address: " && echo "$result"
result=$(npm test -- -e $ENV -t poi | grep "success rate")
echo -n  "data / hsl poi: " && echo "$result"
result=$(npm test -- -e $ENV -t localization | grep "success rate")
echo -n  "data / hsl localization: " && echo "$result"

echo
