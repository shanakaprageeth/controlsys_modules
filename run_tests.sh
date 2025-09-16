#!/bin/bash
#
# Test runner script for ControlSys Modules
# Runs all tests and generates a summary report
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TEST_RESULTS=()

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}ControlSys Modules - Test Suite Runner${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Function to run a single test
run_test() {
    local test_name=$1
    echo -e "${YELLOW}Running test: $test_name${NC}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if make test_$test_name > /tmp/test_$test_name.log 2>&1; then
        echo -e "${GREEN}✓ $test_name PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        TEST_RESULTS+=("PASS: $test_name")
    else
        echo -e "${RED}✗ $test_name FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        TEST_RESULTS+=("FAIL: $test_name")
        
        # Show last few lines of error log
        echo -e "${RED}Error details:${NC}"
        tail -10 /tmp/test_$test_name.log | sed 's/^/  /'
    fi
    echo ""
}

# Change to project directory
cd "$PROJECT_DIR"

# List of tests to run
TESTS=(
    "bldc_commutation"
    "pwm_out"
    "filter_basic_fixed"
    "uart"
    "encoder_interface"
    "dac712_interface"
    "quadrature_encoder_interface"
)

echo -e "${BLUE}Available tests:${NC}"
for test in "${TESTS[@]}"; do
    echo "  - $test"
done
echo ""

# Run all tests
echo -e "${BLUE}Starting test execution...${NC}"
echo ""

for test in "${TESTS[@]}"; do
    run_test "$test"
done

# Generate summary report
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Test Summary Report${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo -e "Total Tests:  ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed Tests: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed Tests: ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! 🎉${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo -e "${YELLOW}Test Results:${NC}"
    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == PASS* ]]; then
            echo -e "  ${GREEN}$result${NC}"
        else
            echo -e "  ${RED}$result${NC}"
        fi
    done
    exit 1
fi