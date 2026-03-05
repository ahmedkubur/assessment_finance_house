#!/bin/bash

# Run all test files one after another sequentially
# This provides better visibility into which specific test passes or fails

echo "========================================="
echo "Running all tests sequentially..."
echo "========================================="

# Define the test files to run
TEST_FILES=(
    "test/unit/auth_cubit_test.dart"
    "test/unit/beneficiaries_cubit_test.dart"
    "test/unit/profile_cubit_test.dart"
    "test/unit/top_up_cubit_test.dart"
    "test/unit/transactions_cubit_test.dart"
    "test/integration/auth_gate_integration_test.dart"
)

FAILED_TESTS=()
PASSED_TESTS=()

# Run each test file individually
for test_file in "${TEST_FILES[@]}"; do
    echo ""
    echo "-----------------------------------------"
    echo "Running: $test_file"
    echo "-----------------------------------------"
    
    flutter test "$test_file"
    
    if [ $? -eq 0 ]; then
        echo "✓ PASSED: $test_file"
        PASSED_TESTS+=("$test_file")
    else
        echo "✗ FAILED: $test_file"
        FAILED_TESTS+=("$test_file")
    fi
done

# Print summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Passed: ${#PASSED_TESTS[@]}"
echo "Failed: ${#FAILED_TESTS[@]}"

if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo ""
    echo "All tests passed!"
    exit 0
else
    echo ""
    echo "Failed tests:"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo "  - $failed_test"
    done
    exit 1
fi

