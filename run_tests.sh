#!/bin/bash

# Function to execute a command and check its output against the expected output
function run_test() {
    local name="$1"
    local command="$2"
    local args="$3"
    local expected_output="$4"

    echo "Running test: $name"
    actual_output=$(eval "$command $args" 2>&1)

    if [[ $actual_output =~ $expected_output ]]; then
        echo "Test Passed!"
    else
        echo "Test Failed!"
        echo "Expected Output: $expected_output"
        echo "Actual Output  : $actual_output"
    fi
    echo
}

# Read test cases from YAML file and execute each test
while IFS= read -r line; do
    # Parse YAML line and extract relevant data
    if [[ "$line" =~ ^\s*- ]]; then
        name=$(grep -oP '(?<=name: ").*(?=")' <<< "$line")
        command=$(grep -oP '(?<=command: ").*(?=")' <<< "$line")
        args=$(grep -oP '(?<=args: \[).*?(?=\])' <<< "$line")
        expected_output=$(grep -oP '(?<=expectedOutput: \[).*?(?=\])' <<< "$line")

        # Convert the arguments to an array
        IFS=',' read -ra args_array <<< "$args"
        args="${args_array[*]}"

        # Convert the expected output to a regex pattern
        expected_output=$(sed -e 's/\\\[/"\[/' -e 's/\\\]/"\]/' -e 's/,/","/g' <<< "$expected_output")
        expected_output=".*$expected_output.*"

        # Call the run_test function with the parsed data
        run_test "$name" "$command" "$args" "$expected_output"
    fi
done < tests.yml
