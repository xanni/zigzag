import re
import subprocess
import os

test_file_path = "t/Zigzag.t"

# Read existing test file content
try:
    with open(test_file_path, "r") as f:
        original_content = f.read()
except FileNotFoundError:
    print(f"Error: {test_file_path} not found.")
    exit(1) # Use exit codes to indicate script failure

# New subtest code for slice_sync_all
new_subtest_code = """
subtest 'slice_sync_all' => sub {
    # Plan for this subtest
    plan tests => 5;

    # Localize @Zigzag::DB_Ref to avoid interfering with other tests or global state
    local @Zigzag::DB_Ref = ();

    # Test Case 1: @DB_Ref is empty
    Zigzag::slice_sync_all(); # Should not die
    ok(1, 'slice_sync_all runs with empty @DB_Ref');

    # Test Case 2: @DB_Ref with one mock object
    my $sync_called_1 = 0;
    # Define MockDB package if not already defined in this scope (e.g. if tests run in separate processes or if 'local' affects package definitions - unlikely for 'local @array')
    # To be safe, ensure MockDB is available or define it here.
    # For this script, we assume it's fine to define it once if subtests run in same Perl interpreter instance.
    # If MockDB was defined in another subtest, it might be available.
    # Let's define it here to be sure it's scoped or available.
    eval 'package MockDB; sub new { my $class = shift; bless {@_}, $class; } sub sync { my $self = shift; ${$self->{sync_count}}++; }' if !defined &MockDB::sync;

    my $mock_db_1 = bless { sync_count => \$sync_called_1 }, 'MockDB';
    @Zigzag::DB_Ref = ($mock_db_1);
    Zigzag::slice_sync_all();
    is($sync_called_1, 1, 'sync called once for one mock DB object');

    # Test Case 3: @DB_Ref with multiple mock objects
    @Zigzag::DB_Ref = (); # Clear from previous test
    my $sync_called_2 = 0;
    my $mock_db_2 = bless { sync_count => \$sync_called_2 }, 'MockDB';
    my $sync_called_3 = 0;
    my $mock_db_3 = bless { sync_count => \$sync_called_3 }, 'MockDB';
    @Zigzag::DB_Ref = ($mock_db_2, $mock_db_3);
    Zigzag::slice_sync_all();
    is($sync_called_2, 1, 'sync called once for mock_db_2 in multi-DB setup');
    is($sync_called_3, 1, 'sync called once for mock_db_3 in multi-DB setup');

    # Test Case 4: @DB_Ref contains undef (should die)
    @Zigzag::DB_Ref = (undef);
    eval { Zigzag::slice_sync_all(); };
    like($@, qr/Can't call method "sync" on an undefined value/, 'slice_sync_all dies if @DB_Ref contains undef');

    @Zigzag::DB_Ref = ();
};

"""

# Find insertion point logic
subtest_names = re.findall(r"subtest\s+'([^']+)'", original_content)
target_subtest_name = 'slice_sync_all'
all_sorted_names = sorted(list(set(subtest_names + [target_subtest_name])))

modified_content = original_content
inserted = False
new_tests_count_for_plan = 0 # Will hold the new total plan count

try:
    new_idx = all_sorted_names.index(target_subtest_name)

    preceding_subtest_name_for_regex = None
    insertion_anchor_regex = None
    fallback_anchor_regex_str = r"(@Zigzag::Hash_Ref = \(\{\}\);\s*\nmy \$test_slice = \$Zigzag::Hash_Ref\[0\];\s*\n)"

    if new_idx == 0: # New subtest is alphabetically first
        # Try to find the end of the global setup block
        match_obj = re.search(fallback_anchor_regex_str, original_content)
        if not match_obj: # Second fallback if the primary one isn't there
             match_obj = re.search(r"(BEGIN\s*\{\s*use_ok\('Zigzag'\);\s*\}\s*\n)", original_content)

        if match_obj:
            insertion_point = match_obj.end()
            modified_content = original_content[:insertion_point] + new_subtest_code + original_content[insertion_point:]
            inserted = True
        else:
            print("Error: Could not find suitable initial insertion point for the first subtest.")
            exit(1)
    else:
        preceding_subtest_name_for_regex = all_sorted_names[new_idx - 1]
        # Regex to find the end of the preceding subtest block.
        insertion_anchor_regex = re.compile(
            r"(subtest\s+'" + re.escape(preceding_subtest_name_for_regex) + r"'\s*=>\s*sub\s*\{.*?\n^\};\s*\n)",
            re.DOTALL | re.MULTILINE
        )

        match_iter = list(insertion_anchor_regex.finditer(original_content))
        if match_iter:
            last_match = match_iter[-1]
            insertion_point = last_match.end()
            modified_content = original_content[:insertion_point] + new_subtest_code + original_content[insertion_point:]
            inserted = True
        else: # Fallback if specific preceding subtest regex fails
            print(f"Warning: Could not find the specific end of subtest '{preceding_subtest_name_for_regex}'. Using general fallback.")
            match_obj = re.search(fallback_anchor_regex_str, original_content) # Fallback to end of global setup
            if match_obj:
                insertion_point = match_obj.end()
                # This fallback inserts after global setup, which might break alphabetical order if not first.
                # A better fallback for non-first might be end of last subtest found.
                all_subtest_blocks = list(re.finditer(r"(subtest\s+'[^']+'\s*=>\s*sub\s*\{.*?\n^\};\s*\n)", original_content, re.DOTALL | re.MULTILINE))
                if all_subtest_blocks:
                    insertion_point = all_subtest_blocks[-1].end()
                    print(f"Fallback: Inserting '{target_subtest_name}' after the last detected subtest block.")
                else: # If no subtests at all, use the initial setup point
                     print(f"Fallback: Inserting '{target_subtest_name}' after initial setup block as no other subtests were found for anchoring.")

                modified_content = original_content[:insertion_point] + new_subtest_code + original_content[insertion_point:]
                inserted = True
            else:
                print("Error: Primary and fallback insertion anchors not found.")
                exit(1)

    if not inserted:
        print("Error: Failed to insert the new subtest for an unknown reason.")
        exit(1)

    # Increment test plan count
    plan_match = re.search(r"use Test::More tests => (\d+);", modified_content)
    if plan_match:
        current_tests = int(plan_match.group(1))
        new_tests_count_for_plan = current_tests + 1
        modified_content = re.sub(r"use Test::More tests => \d+;", f"use Test::More tests => {new_tests_count_for_plan};", modified_content, 1)
        print(f"Updated test plan from {current_tests} to {new_tests_count_for_plan}.")
    else:
        print("Warning: Could not find test plan to update automatically.")
        # Not exiting, as the test might still run and report its own plan. User should manually verify.

    with open(test_file_path, "w") as f:
        f.write(modified_content)
    print(f"Inserted subtest '{target_subtest_name}' into {test_file_path}.")

except Exception as e:
    print(f"An error occurred during file modification: {type(e).__name__} {e}")
    exit(1)

# Run tests
try:
    perl_executable = "perl"
    # Basic check if perl is available
    try:
        subprocess.run([perl_executable, "-v"], capture_output=True, check=True, timeout=10)
    except Exception as e_perl:
        print(f"Error: perl executable not found or not working: {e_perl}")
        exit(1)

    process = subprocess.run([perl_executable, test_file_path], capture_output=True, text=True, timeout=60)

    stdout_lower = process.stdout.lower()

    if process.returncode == 0:
        # Check for explicit failure messages first
        if "not ok" in stdout_lower or "dubious" in stdout_lower or "failed" in stdout_lower:
             print(f"Tests ran (exit 0) but STDOUT indicates some tests failed or had issues.")
        elif new_tests_count_for_plan > 0: # If we updated the plan
            match_ran_tests = re.search(r"^1\.\.(\d+)\s*$", process.stdout, re.MULTILINE) # Match "1..N" at end of output or on its own line
            if match_ran_tests:
                planned_tests_in_output = int(match_ran_tests.group(1))
                if planned_tests_in_output == new_tests_count_for_plan:
                     print("All tests passed successfully after adding new subtest and updating plan.")
                else:
                    print(f"Tests ran (exit code 0) but number of tests run ({planned_tests_in_output}) does not match updated plan ({new_tests_count_for_plan}).")
            else: # Could not parse 1..N from output
                print("All tests passed successfully (based on exit code 0 and no explicit failure messages in STDOUT). Could not verify test count from output.")
        else: # Did not update plan, but exit 0 and no failure strings
            print("All tests passed successfully (based on exit code 0 and no explicit failure messages in STDOUT). Plan was not updated by script.")
    else: # Non-zero exit code
        print(f"Tests failed after adding new subtest. Return code: {process.returncode}")

    # Always print STDOUT/STDERR if they are not empty for review
    if process.stdout.strip():
        print("STDOUT:\n" + process.stdout)
    if process.stderr.strip():
        print("STDERR:\n" + process.stderr)

except subprocess.TimeoutExpired:
    print("Test execution timed out after 60 seconds.")
except Exception as e:
    print(f"An error occurred while running tests: {type(e).__name__} {e}")
