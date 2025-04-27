nitialize counters for passed, failed tests, and syntax errors
passed_tests=0
failed_tests=0
syntax_error_count=0

echo "Starting tests..."

# Loop over all test files (P2_test1.txt, P2_test2.txt, etc.)
for i in {1..8}
do
    echo "----------------------------------"
    echo "Running Test $i: P2_test${i}.txt"
    
    # Run the test with P2_a as the parser
    ./P2_a P2_test${i}.txt > test_output.txt
    
    # Compare the output with the expected output
    diff -u expected_output${i}.txt test_output.txt > diff_output.txt
    
    # Check if the outputs are identical (no syntax error)
    if [ $? -eq 0 ]; then
        echo "✅ Test $i Passed"
        ((passed_tests++))
    else
        # If there's a mismatch, check if it's a syntax error
        echo "❌ Test $i Failed"
        
        # Optionally, print the diff to see the mismatches
        cat diff_output.txt
    fi
    echo "----------------------------------"
done

# Summary
echo "Summary: $passed_tests Passed, $failed_tests Failed"
