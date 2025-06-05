import re
import subprocess
import os

test_file_path = "t/Zigzag.t"

try:
    with open(test_file_path, "r") as f:
        original_content = f.read()
except FileNotFoundError:
    print(f"Error: {test_file_path} not found.")
    exit(1)

target_subtest_name = 'atcursor_copy'

# Check if subtest already exists to prevent duplicate insertion by this script
if f"subtest '{target_subtest_name}'" in original_content:
    print(f"Subtest '{target_subtest_name}' already exists in {test_file_path}. Running tests as-is.")
    try:
        process = subprocess.run(["perl", test_file_path], capture_output=True, text=True, timeout=60)
        stdout_full = process.stdout; stderr_full = process.stderr; stdout_lower = stdout_full.lower()
        if process.returncode == 0 and "not ok" not in stdout_lower and "dubious" not in stdout_lower and "fail" not in stdout_lower:
            print("Tests passed (existing subtest).")
        else:
            print(f"Tests failed or had issues (existing subtest). RC: {process.returncode}")
        if stdout_full.strip(): print("STDOUT:\n" + stdout_full)
        if stderr_full.strip(): print("STDERR:\n" + stderr_full)
    except Exception as e:
        print(f"Error running tests for existing subtest: {e}")
    exit(0)


new_subtest_code = """
subtest 'atcursor_copy' => sub {
    plan tests => 12;

    my $SELECT_HOME = 21;
    my $CURSOR_OBJECT_CELL_ID_0 = 11;

    local *main::display_dirty = sub { return; };

    # Test Case 1: Copy single accursed cell (no active selection)
    %$test_slice = Zigzag::initial_geometry();
    Zigzag::cell_excise($SELECT_HOME, 'd.mark'); # Ensure no active selection elements

    my $orig_cell_A_id = '700';
    $test_slice->{$orig_cell_A_id} = 'Original A Content';

    my $cursor0_obj_cell = Zigzag::get_cursor(0);
    Zigzag::cell_excise($cursor0_obj_cell, 'd.cursor');
    # Explicitly set $orig_cell_A_id as the accursed cell for cursor 0
    $test_slice->{"${cursor0_obj_cell}-d.cursor"} = $orig_cell_A_id;
    $test_slice->{"${orig_cell_A_id}+d.cursor"} = $cursor0_obj_cell;

    my $next_cell_id_at_start_tc1 = $test_slice->{'n'};
    Zigzag::atcursor_copy(0);

    my $new_cell_A_id = $next_cell_id_at_start_tc1;

    ok(exists $test_slice->{$new_cell_A_id}, '1.1: New cell for accursed copy exists');
    is(Zigzag::cell_get($new_cell_A_id), "Copy of Original A Content", '1.2: New cell has copied content');
    is(Zigzag::get_accursed(0), $new_cell_A_id, '1.3: Accursed cell of Cursor 0 is the new copied cell');
    is(Zigzag::cell_nbr($new_cell_A_id, "-d.clone"), undef, '1.4: New cell does not have a -d.clone link');
    is(Zigzag::cell_nbr($orig_cell_A_id, "+d.clone"), undef, '1.5: Original cell does not have a +d.clone link');

    # Test Case 2: Copy multiple selected cells (B, C, and SELECT_HOME itself)
    %$test_slice = Zigzag::initial_geometry();
    my $orig_cell_B_id = '701'; $test_slice->{$orig_cell_B_id} = 'Original B';
    my $orig_cell_C_id = '702'; $test_slice->{$orig_cell_C_id} = 'Original C';
    # SELECT_HOME (21) has content "Selection" from initial_geometry

    Zigzag::cell_excise($SELECT_HOME, 'd.mark');
    Zigzag::link_make($SELECT_HOME, $orig_cell_B_id, '+d.mark');    # SELECT_HOME -> B
    Zigzag::link_make($orig_cell_B_id, $orig_cell_C_id, '+d.mark'); # B -> C
    Zigzag::link_make($orig_cell_C_id, $SELECT_HOME, '+d.mark');    # C -> SELECT_HOME (completes selection loop)

    Zigzag::link_make($orig_cell_B_id, $orig_cell_C_id, '+d.testcopy'); # Link between B and C

    my $neutral_accursed_target = '800';
    $test_slice->{$neutral_accursed_target} = 'Neutral Accursed for TC2';
    $cursor0_obj_cell = Zigzag::get_cursor(0);
    Zigzag::cell_excise($cursor0_obj_cell, 'd.cursor');
    $test_slice->{"${cursor0_obj_cell}-d.cursor"} = $neutral_accursed_target;
    $test_slice->{"${neutral_accursed_target}+d.cursor"} = $cursor0_obj_cell;

    my $next_cell_id_at_start_tc2 = $test_slice->{'n'};
    Zigzag::atcursor_copy(0); # Operates on active selection (B, C, SELECT_HOME)

    # Order of processing by get_active_selection -> cells_row: B (701), C (702), SELECT_HOME (21)
    my $new_cell_B_id = $next_cell_id_at_start_tc2;
    my $new_cell_C_id = $next_cell_id_at_start_tc2 + 1;
    my $new_cell_SH_id = $next_cell_id_at_start_tc2 + 2; # Copy of SELECT_HOME

    ok(exists $test_slice->{$new_cell_B_id}, '2.1: New cell B exists');
    is(Zigzag::cell_get($new_cell_B_id), "Copy of Original B", '2.2: New cell B content');
    ok(exists $test_slice->{$new_cell_C_id}, '2.3: New cell C exists');
    is(Zigzag::cell_get($new_cell_C_id), "Copy of Original C", '2.4: New cell C content');
    is(Zigzag::cell_nbr($new_cell_B_id, '+d.testcopy'), undef, '2.5: Link between new B and new C NOT copied');

    # Corrected expectation: $last_new_cell in atcursor_clone will be $new_cell_SH_id (copy of SELECT_HOME)
    is(Zigzag::get_accursed(0), $new_cell_SH_id, '2.6: Accursed is new copy of SELECT_HOME');

    is(Zigzag::cell_nbr($new_cell_B_id, "-d.clone"), undef, '2.7: New cell B no -d.clone link');
};

"""

# Alphabetical insertion logic
subtest_names_orig = re.findall(r"subtest\s+'([^']+)'", original_content)
all_sorted_names = sorted(list(set(subtest_names_orig + [target_subtest_name])))

modified_content = original_content
inserted = False
new_tests_count_for_plan = 0

try:
    new_idx = all_sorted_names.index(target_subtest_name)
    fallback_anchor_regex_str = r"(@Zigzag::Hash_Ref = \(\{\}\);\s*\nmy \$test_slice = \$Zigzag::Hash_Ref\[0\];\s*\n)"

    if new_idx == 0:
        match_obj = re.search(fallback_anchor_regex_str, original_content)
        if not match_obj: match_obj = re.search(r"(BEGIN\s*\{\s*use_ok\('Zigzag'\);\s*\}\s*\n)", original_content)
        if match_obj:
            insertion_point = match_obj.end()
            modified_content = original_content[:insertion_point] + "\n" + new_subtest_code + original_content[insertion_point:]
            inserted = True
        else: raise Exception("Could not find initial insertion point.")
    else:
        preceding_subtest_name = all_sorted_names[new_idx - 1]
        insertion_anchor_regex = re.compile(r"(subtest\s+'" + re.escape(preceding_subtest_name) + r"'\s*=>\s*sub\s*\{.*?\n^\};\s*\n)", re.DOTALL | re.MULTILINE)
        match_iter = list(insertion_anchor_regex.finditer(original_content))
        if match_iter:
            insertion_point = match_iter[-1].end()
            modified_content = original_content[:insertion_point] + "\n" + new_subtest_code + original_content[insertion_point:]
            inserted = True
        else:
            print(f"Warning: Could not find specific end of subtest '{preceding_subtest_name}'. Using general fallback.")
            all_subtest_blocks = list(re.finditer(r"(subtest\s+'[^']+'\s*=>\s*sub\s*\{.*?\n^\};\s*\n)", original_content, re.DOTALL | re.MULTILINE))
            if all_subtest_blocks: insertion_point = all_subtest_blocks[-1].end()
            else:
                match_obj = re.search(fallback_anchor_regex_str, original_content)
                if match_obj: insertion_point = match_obj.end()
                else: raise Exception("Primary and all fallback insertion anchors not found.")
            modified_content = original_content[:insertion_point] + "\n" + new_subtest_code + original_content[insertion_point:]
            inserted = True

    if not inserted: raise Exception("Failed to insert new subtest.")

    plan_match = re.search(r"(use Test::More tests => )(\d+)(;)", modified_content)
    if plan_match:
        current_tests = int(plan_match.group(2))
        new_tests_count_for_plan = current_tests + 1
        modified_content = modified_content[:plan_match.start(2)] + str(new_tests_count_for_plan) + modified_content[plan_match.end(2):]
        print(f"Updated test plan from {current_tests} to {new_tests_count_for_plan}.")
    else:
        print("Warning: Could not find test plan to update automatically.")
        new_tests_count_for_plan = -1

    with open(test_file_path, "w") as f: f.write(modified_content)
    print(f"Inserted subtest '{target_subtest_name}' into {test_file_path}.")

except Exception as e:
    print(f"An error occurred during file modification: {type(e).__name__}: {e}")
    exit(1)

# Run tests
try:
    perl_executable = "perl"
    try: subprocess.run([perl_executable, "-v"], capture_output=True, check=True, timeout=10)
    except Exception as e_perl: print(f"Error: perl executable not found or not working: {e_perl}"); exit(1)

    process = subprocess.run([perl_executable, test_file_path], capture_output=True, text=True, timeout=60)
    stdout_full = process.stdout; stderr_full = process.stderr; stdout_lower = stdout_full.lower()

    tests_passed_flag = False
    if process.returncode == 0:
        if "not ok" in stdout_lower or "dubious" in stdout_lower or "fail" in stdout_lower :
             print(f"Tests ran (exit 0) but STDOUT indicates some tests failed or had issues.")
        elif new_tests_count_for_plan > 0:
            match_ran_tests = re.search(r"^1\.\." + str(new_tests_count_for_plan) + r"\s*$", stdout_full, re.MULTILINE)
            if match_ran_tests:
                print("All tests passed successfully after adding new subtest and updating plan.")
                tests_passed_flag = True
            else:
                if "all tests successful" in stdout_lower: # Fallback check
                    print("All tests passed successfully (based on 'all tests successful' message). Plan count match with '1..N' failed.")
                    tests_passed_flag = True
                else:
                    print(f"Tests ran (exit code 0) but test count in output did not match updated plan ({new_tests_count_for_plan}).")
        else:
            if "all tests successful" in stdout_lower: # Fallback check
                 print("All tests passed successfully (based on exit code 0 and 'all tests successful' message). Plan was not updated by script.")
                 tests_passed_flag = True
            else:
                print("Tests ran (exit code 0, no failure strings). Plan was not updated by script. Output needs manual check for success.")
    else:
        print(f"Tests failed. Return code: {process.returncode}")

    if not tests_passed_flag:
        if stdout_full.strip(): print("STDOUT:\n" + stdout_full)

    if stderr_full.strip(): print("STDERR:\n" + stderr_full)

except subprocess.TimeoutExpired: print("Test execution timed out."); exit(1)
except Exception as e: print(f"Error running tests: {type(e).__name__}: {e}"); exit(1)
