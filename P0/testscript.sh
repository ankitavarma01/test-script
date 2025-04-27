#!/bin/bash

set +e

FAIL_COUNT=0

compare_files() {
    local actual="$1"
    local expected="$2"
    local label="$3"

    local diff_output
    diff_output=$(diff "$actual" "$expected")
    if [ -n "$diff_output" ]; then
        echo "Actual ($actual):"
        cat -A "$actual"
        echo "Expected ($expected):"
        cat -A "$expected"
        echo ""
        return 1
    fi
    return 0
}

cleanup_files() {
    for file in "$@"; do
        rm -f "$file"
    done
}

if [ $# -eq 0 ]; then
  EXEC="./p0"
  echo "No executable specified. Defaulting to $EXEC"
else
  EXEC="./$1"
  echo "Using executable: $EXEC"
fi

# Check that the specified executable exists and is executable.
if [ ! -x "$EXEC" ]; then
  echo "Error: $EXEC not found or not executable."
  exit 1
fi

echo "-------------------------------------------------"
echo "Test 1: Running with file redirection"
TEST1_INPUT="test_inputs/test1_input.txt"
EXP_PRE="expected/out.preorder"
EXP_IN="expected/out.inorder"
EXP_POST="expected/out.postorder"
OUT_PRE="out.preorder"
OUT_IN="out.inorder"
OUT_POST="out.postorder"

# Test 1: Run with file redirection.
$EXEC < "$TEST1_INPUT"

# Check if output files were created.
if [ -f "$OUT_PRE" ] && [ -f "$OUT_IN" ] && [ -f "$OUT_POST" ]; then
    error=0
    compare_files "$OUT_PRE" "$EXP_PRE" "out.preorder" || error=1
    compare_files "$OUT_IN" "$EXP_IN" "out.inorder" || error=1
    compare_files "$OUT_POST" "$EXP_POST" "out.postorder" || error=1

    if [ $error -eq 0 ]; then
       echo "Test 1 Passed."
    else
       echo "Test 1 Failed: Output file contents do not match expected output."
       FAIL_COUNT=$((FAIL_COUNT+1))
    fi
else
    echo "Test 1 Failed: One or more output files were not created."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi

# Clean up output files from Test 1.
cleanup_files "$OUT_PRE" "$OUT_IN" "$OUT_POST"

echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 2: With file argument - .4280fs24 extension in current directory"
TEST2_BASENAME="test2"
TEST2_FILE="${TEST2_BASENAME}.4280fs24"

if [ ! -f "$TEST2_FILE" ]; then
    echo "Test 2 Skipped: Input file $TEST2_FILE not found."
    FAIL_COUNT=$((FAIL_COUNT+1))
else
    EXP_PRE="expected/${TEST2_BASENAME}.preorder"
    EXP_IN="expected/${TEST2_BASENAME}.inorder"
    EXP_POST="expected/${TEST2_BASENAME}.postorder"
    OUT_PRE="${TEST2_BASENAME}.preorder"
    OUT_IN="${TEST2_BASENAME}.inorder"
    OUT_POST="${TEST2_BASENAME}.postorder"

    $EXEC "$TEST2_BASENAME"

    if [ -f "$OUT_PRE" ] && [ -f "$OUT_IN" ] && [ -f "$OUT_POST" ]; then
        error=0
        compare_files "$OUT_PRE" "$EXP_PRE" "${TEST2_BASENAME}.preorder" || error=1
        compare_files "$OUT_IN" "$EXP_IN" "${TEST2_BASENAME}.inorder" || error=1
        compare_files "$OUT_POST" "$EXP_POST" "${TEST2_BASENAME}.postorder" || error=1

        if [ $error -eq 0 ]; then
            echo "Test 2 Passed."
        else
            echo "Test 2 Failed: Output file contents do not match expected output."
            FAIL_COUNT=$((FAIL_COUNT+1))
        fi
    else
        echo "Test 2 Failed: One or more output files were not created."
        FAIL_COUNT=$((FAIL_COUNT+1))
    fi

    cleanup_files "$OUT_PRE" "$OUT_IN" "$OUT_POST"
fi


echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 3: Too many command line arguments"
$EXEC arg1 arg2 > test3_output.txt 2>&1
if grep -i -q "error" test3_output.txt; then
    echo "Test 3 Passed."
else
    echo "Test 3 Failed: Expected error message not found."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi
cleanup_files test3_output.txt

echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 4: Duplicate Inputs"
TEST_INPUT4="test_inputs/test4_input.txt"
EXP_PRE="expected/out.preorder"
EXP_IN="expected/out.inorder"
EXP_POST="expected/out.postorder"
OUT_PRE="out.preorder"
OUT_IN="out.inorder"
OUT_POST="out.postorder"

$EXEC < "$TEST_INPUT4"

if [ -f "$OUT_PRE" ] && [ -f "$OUT_IN" ] && [ -f "$OUT_POST" ]; then
    error=0
    compare_files "$OUT_PRE" "$EXP_PRE" "out.preorder" || error=1
    compare_files "$OUT_IN" "$EXP_IN" "out.inorder" || error=1
    compare_files "$OUT_POST" "$EXP_POST" "out.postorder" || error=1

    if [ $error -eq 0 ]; then
       echo "Test 4 Passed."
    else
       echo "Test 4 Failed: Output file contents do not match expected output."
       FAIL_COUNT=$((FAIL_COUNT+1))
    fi
else
    echo "Test 4 Failed: One or more output files were not created."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi
cleanup_files "$OUT_PRE" "$OUT_IN" "$OUT_POST"

echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 5: Single String Input"
TEST_INPUT5="test_inputs/test5_input.txt"
EXP_PRE="expected/test5.preorder"
EXP_IN="expected/test5.inorder"
EXP_POST="expected/test5.postorder"

$EXEC < "$TEST_INPUT5"

if [ -f "$OUT_PRE" ] && [ -f "$OUT_IN" ] && [ -f "$OUT_POST" ]; then
    error=0
    compare_files "$OUT_PRE" "$EXP_PRE" "out.preorder" || error=1
    compare_files "$OUT_IN" "$EXP_IN" "out.inorder" || error=1
    compare_files "$OUT_POST" "$EXP_POST" "out.postorder" || error=1

    if [ $error -eq 0 ]; then
       echo "Test 5 Passed."
    else
       echo "Test 5 Failed: Output file contents do not match expected output."
       FAIL_COUNT=$((FAIL_COUNT+1))
    fi
else
    echo "Test 5 Failed: One or more output files were not created."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi
cleanup_files "$OUT_PRE" "$OUT_IN" "$OUT_POST"

echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 6: Empty Input File"
TEST6_INPUT="test_inputs/test6_input.txt"   # This file should be empty.
EXP_PRE="expected/empty.preorder"
EXP_IN="expected/empty.inorder"
EXP_POST="expected/empty.postorder"
OUT_PRE="out.preorder"
OUT_IN="out.inorder"
OUT_POST="out.postorder"

$EXEC < "$TEST6_INPUT"

if [ -f "$OUT_PRE" ] && [ -f "$OUT_IN" ] && [ -f "$OUT_POST" ]; then
    error=0
    compare_files "$OUT_PRE" "$EXP_PRE" "out.preorder" || error=1
    compare_files "$OUT_IN" "$EXP_IN" "out.inorder" || error=1
    compare_files "$OUT_POST" "$EXP_POST" "out.postorder" || error=1
    if [ $error -eq 0 ]; then
         echo "Test 6 Passed."
    else
         echo "Test 6 Failed: Output file contents do not match expected output for empty input."
         FAIL_COUNT=$((FAIL_COUNT+1))
    fi
else
    echo "Test 6 Failed: One or more output files were not created for empty input."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi
cleanup_files "$OUT_PRE" "$OUT_IN" "$OUT_POST"

echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 7: Unreadable File"
TEST8_BASENAME="test8"
TEST8_FILE="${TEST8_BASENAME}.4280fs24"
# Create the file with valid test data and then remove read permissions.
cp "test_inputs/test1_input.txt" "$TEST8_FILE"
chmod 000 "$TEST8_FILE"
$EXEC "$TEST8_BASENAME" > test8_output.txt 2>&1
if grep -i -q "error" test8_output.txt; then
    echo "Test 7 Passed."
else
    echo "Test 7 Failed: Expected error message for unreadable file not found."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi
# Restore permissions so the file can be deleted.
chmod 644 "$TEST8_FILE"
cleanup_files "$TEST8_FILE" test8_output.txt

echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 8: Whitespace Variations in Input"
TEST9_INPUT="test_inputs/test9_input.txt"  # This file should include tabs, multiple spaces, and newlines.
EXP_PRE="expected/test9.preorder"
EXP_IN="expected/test9.inorder"
EXP_POST="expected/test9.postorder"
OUT_PRE="out.preorder"
OUT_IN="out.inorder"
OUT_POST="out.postorder"

$EXEC < "$TEST9_INPUT"

if [ -f "$OUT_PRE" ] && [ -f "$OUT_IN" ] && [ -f "$OUT_POST" ]; then
    error=0
    compare_files "$OUT_PRE" "$EXP_PRE" "out.preorder" || error=1
    compare_files "$OUT_IN" "$EXP_IN" "out.inorder" || error=1
    compare_files "$OUT_POST" "$EXP_POST" "out.postorder" || error=1
    if [ $error -eq 0 ]; then
         echo "Test 8 Passed."
    else
         echo "Test 8 Failed: Output file contents do not match expected output for whitespace variation test."
         FAIL_COUNT=$((FAIL_COUNT+1))
    fi
else
    echo "Test 8 Failed: One or more output files were not created for whitespace variation test."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi
cleanup_files "$OUT_PRE" "$OUT_IN" "$OUT_POST"

echo ""
read -p "Press Enter to continue to the next test"
echo ""

echo "-------------------------------------------------"
echo "Test 9: Non-existent file argument"
$EXEC non_existent_file > test9_output.txt 2>&1
if grep -i -q "error" test9_output.txt; then
    echo "Test 9 Passed."
else
    echo "Test 9 Failed: Expected error message for missing file not found."
    FAIL_COUNT=$((FAIL_COUNT+1))
fi
cleanup_files test9_output.txt

echo ""
read -p "Press Enter for final result"
echo ""

echo "-------------------------------------------------"
echo "Testing complete."
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "All tests passed."
else
    echo "$FAIL_COUNT test(s) failed."
fi

# Exit with the number of failed tests as the exit code.
exit "$FAIL_COUNT"

