import re
import subprocess
import os # For os.path.exists

test_file_path = "t/Zigzag.t"

# Read existing test file content
try:
    with open(test_file_path, "r") as f:
        original_content = f.read()
except FileNotFoundError:
    print(f"Error: {test_file_path} not found.")
    exit(1)

# New subtest code for is_active_selected
new_subtest_code = """
subtest 'is_active_selected' => sub {
    plan tests => 5; # Number of assertions
    my $SELECT_HOME = 21; # As defined in Zigzag.pm

    # Test Case 1: Cell is part of the active selection
    %$test_slice = Zigzag::initial_geometry(); # Reset state
    $test_slice->{'300'} = 'Cell in active selection';
    Zigzag::link_make($SELECT_HOME, '300', '+d.mark');
    Zigzag::link_make('300', $SELECT_HOME, '+d.mark'); # Complete the loop for a single item selection
    ok(Zigzag::is_active_selected('300'), 'Cell 300 is active_selected');
    # Minimal cleanup of links for this specific setup to avoid interference if not fully reset by initial_geometry
    delete $test_slice->{"${SELECT_HOME}+d.mark"}; delete $test_slice->{"300-d.mark"};
    delete $test_slice->{"300+d.mark"}; delete $test_slice->{"${SELECT_HOME}-d.mark"};


    # Test Case 2: SELECT_HOME itself is not considered active_selected
    %$test_slice = Zigzag::initial_geometry();
    # Ensure SELECT_HOME exists as per initial_geometry
    ok(!Zigzag::is_active_selected($SELECT_HOME), "SELECT_HOME ($SELECT_HOME) itself is not active_selected");

    # Test Case 3: Cell in a non-active selection
    %$test_slice = Zigzag::initial_geometry();
    my $other_selection_head = '22'; # Different from SELECT_HOME
    $test_slice->{$other_selection_head} = 'Other Selection Head';
    $test_slice->{'301'} = 'Cell in other selection';
    Zigzag::link_make($other_selection_head, '301', '+d.mark');
    Zigzag::link_make('301', $other_selection_head, '+d.mark');
    ok(!Zigzag::is_active_selected('301'), 'Cell 301 (in non-active selection) is not active_selected');
    # Cleanup
    delete $test_slice->{"${other_selection_head}+d.mark"}; delete $test_slice->{"301-d.mark"};
    delete $test_slice->{"301+d.mark"}; delete $test_slice->{"${other_selection_head}-d.mark"};

    # Test Case 4: Cell not selected at all
    %$test_slice = Zigzag::initial_geometry();
    $test_slice->{'302'} = 'Unselected Cell';
    ok(!Zigzag::is_active_selected('302'), 'Cell 302 (not selected) is not active_selected');

    # Test Case 5: Cell that exists but has no -d.mark link at all.
    %$test_slice = Zigzag::initial_geometry();
    $test_slice->{'303'} = 'Cell 303 no d.mark';
    # Ensure no d.mark links for 303
    delete $test_slice->{'303-d.mark'}; # Ensure no link in -d.mark
    delete $test_slice->{'303+d.mark'}; # Ensure no link in +d.mark
    ok(!Zigzag::is_active_selected('303'), 'Cell 303 (exists, no d.mark links) is not active_selected');

};
"""

# Find insertion point
subtest_names = re.findall(r"subtest\s+'([^']+)'", original_content)
# Add the new subtest name to sort and find its place
target_subtest_name = 'is_active_selected'
all_sorted_names = sorted(list(set(subtest_names + [target_subtest_name])))

insertion_marker_found = False
modified_content = original_content

try:
    new_idx = all_sorted_names.index(target_subtest_name)

    if new_idx == 0: # New subtest is alphabetically first
        # Attempt to insert after the initial global setup block
        # A common pattern is 'my $test_slice = ...;'
        anchor_match = re.search(r"@Zigzag::Hash_Ref = \(\{\}\);\s*\nmy \$test_slice = \$Zigzag::Hash_Ref\[0\];\s*\n", original_content)
        if anchor_match:
            insertion_point = anchor_match.end()
            modified_content = original_content[:insertion_point] + new_subtest_code + original_content[insertion_point:]
            insertion_marker_found = True
        else:
            print("Error: Could not find default initial insertion point for the first subtest.")
            exit(1)
    else:
        # Find the subtest that should precede the new one
        preceding_subtest_name = all_sorted_names[new_idx - 1]

        # Regex to find the end of the preceding subtest block.
        # This looks for `subtest 'name' => sub { ... };\n`
        # It needs to be careful about nested blocks if any, but usually subtests are flat.
        preceding_block_end_regex = re.compile(
            r"(subtest\s+'" + re.escape(preceding_subtest_name) + r"'\s*=>\s*sub\s*\{.*?\n^\};\s*\n)",
            re.DOTALL | re.MULTILINE
        )

        match_iter = list(preceding_block_end_regex.finditer(original_content))
        if match_iter:
            last_match = match_iter[-1] # Get the last occurrence if name is somehow repeated
            insertion_point = last_match.end()
            modified_content = original_content[:insertion_point] + new_subtest_code + original_content[insertion_point:]
            insertion_marker_found = True
        else:
            print(f"Error: Could not find the end of subtest '{preceding_subtest_name}' to insert after.")
            # Fallback: if the specific preceding subtest isn't found (e.g., structure is unusual),
            # try inserting at the end of all subtests as a last resort, though it breaks perfect ordering.
            # This is better than failing outright if the regex is too brittle.
            # Find the last subtest block in the file
            all_subtest_blocks = list(re.finditer(r"(subtest\s+'[^']+'\s*=>\s*sub\s*\{.*?\n^\};\s*\n)", original_content, re.DOTALL | re.MULTILINE))
            if all_subtest_blocks:
                last_block_end = all_subtest_blocks[-1].end()
                modified_content = original_content[:last_block_end] + new_subtest_code + original_content[last_block_end:]
                insertion_marker_found = True
                print(f"Warning: Inserted '{target_subtest_name}' after the last detected subtest as a fallback.")
            else:
                print("Error: No subtests found to use as fallback insertion anchor.")
                exit(1)

    if not insertion_marker_found:
        print("Error: Failed to insert the new subtest due to unknown structural issue.")
        exit(1)

    with open(test_file_path, "w") as f:
        f.write(modified_content)
    print(f"Inserted subtest '{target_subtest_name}' into {test_file_path}")

except Exception as e:
    print(f"An error occurred during file modification: {e}")
    exit(1)

# Run tests
try:
    # Check if perl is available
    perl_executable = "perl"
    try:
        subprocess.run([perl_executable, "-v"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: perl executable not found or not working.")
        exit(1)

    process = subprocess.run([perl_executable, test_file_path], capture_output=True, text=True, timeout=60)

    stdout_lower = process.stdout.lower()
    stderr_lower = process.stderr.lower()

    # Test::More typically exits 0 if all tests passed or were skipped.
    # A non-zero exit code usually means a catastrophic error or some tests died.
    if process.returncode == 0:
        if "all tests successful" in stdout_lower:
            print("All tests passed successfully after adding new subtest.")
        elif re.search(r"files\s*=\s*0", stdout_lower) and re.search(r"tests\s*=\s*0", stdout_lower):
            print("Tests ran (exit 0), but reported 0 files/0 tests. This might indicate an issue with the test harness or no tests were executed.")
            print("STDOUT:\n" + process.stdout)
            print("STDERR:\n" + process.stderr)
        elif "no tests run" in stdout_lower:
            print("Tests ran (exit 0), but 'no tests run' was reported.")
            print("STDOUT:\n" + process.stdout)
            print("STDERR:\n" + process.stderr)
        elif "dubious" in stdout_lower or "not ok" in stdout_lower or "failed" in stdout_lower:
            print(f"Tests ran (exit 0) but some tests seem to have failed or had issues.")
            print("STDOUT:\n" + process.stdout)
            print("STDERR:\n" + process.stderr)
        else:
            # General success case if specific positive/negative markers aren't found but exit is 0
            print(f"Tests completed (exit code 0). Output suggests tests passed or were skipped as planned.")
            print("STDOUT:\n" + process.stdout)
            print("STDERR:\n" + process.stderr)
    else:
        print(f"Tests failed after adding new subtest. Return code: {process.returncode}")
        print("STDOUT:\n" + process.stdout)
        print("STDERR:\n" + process.stderr)

except subprocess.TimeoutExpired:
    print("Test execution timed out after 60 seconds.")
except Exception as e:
    print(f"An error occurred while running tests: {e}")
