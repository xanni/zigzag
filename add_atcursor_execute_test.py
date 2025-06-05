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

target_subtest_name = 'atcursor_execute'

if f"subtest '{target_subtest_name}'" in original_content:
    print(f"Subtest '{target_subtest_name}' already exists. Exiting.")
    exit(0)

new_subtest_code = """
subtest 'atcursor_execute' => sub {
    plan tests => 14;

    my $CURSOR_OBJECT_CELL_ID_0 = 11;
    my $accursed_cell_id = '800'; # Default accursed cell for many tests
    my $prog_cell_1_id = '801';
    my $prog_cell_2_id = '802';
    my $clone_cell_id = '803';
    my $original_prog_id = '804';
    my $prog_err_id = '805';
    my $non_prog_id = '806';
    my $accursed_prog_id = '807'; # Used when accursed cell itself is the progcell

    my @user_error_calls;
    local *main::user_error = sub { push @user_error_calls, [@_]; };
    local *main::display_dirty = sub {};
    my $db_sync_call_count = 0; # Assuming atcursor_execute calls a global main::db_sync
    local *main::db_sync = sub { $db_sync_call_count++; };


    $main::test_var_for_execute = undef;

    my $cursor0 = Zigzag::get_cursor(0);

    # Helper sub to reset state for each test case
    my $setup_test_case = sub {
        my ($current_accursed_id_for_setup) = @_;

        %$test_slice = Zigzag::initial_geometry();

        # Pre-define all cell IDs that might be used by name in link_make or cell_insert
        # This ensures they exist before Zigzag functions try to cell_get them.
        my @all_test_cell_ids = ($accursed_cell_id, $prog_cell_1_id, $prog_cell_2_id,
                                 $clone_cell_id, $original_prog_id, $prog_err_id,
                                 $non_prog_id, $accursed_prog_id);
        foreach my $id (@all_test_cell_ids) {
            $test_slice->{$id} = "Placeholder for $id"; # Initial placeholder content
        }
        # Specifically set content for the cell that will be accursed in this setup
        $test_slice->{$current_accursed_id_for_setup} = "Accursed content for $current_accursed_id_for_setup";


        Zigzag::cell_excise($cursor0, 'd.cursor');
        # Now $current_accursed_id_for_setup is guaranteed to exist for cell_get inside cell_insert
        Zigzag::cell_insert($cursor0, $current_accursed_id_for_setup, '-d.cursor');

        $main::test_var_for_execute = 0;
        @user_error_calls = ();
        $Zigzag::Command_Count = 1;
        $db_sync_call_count = 0;
    };

    # --- Test Case 1: Single progcell executes ---
    $setup_test_case->($accursed_cell_id);
    $test_slice->{$prog_cell_1_id} = '# $main::test_var_for_execute = 123;';
    Zigzag::link_make($accursed_cell_id, $prog_cell_1_id, '+d.inside');

    Zigzag::atcursor_execute(0);
    is($main::test_var_for_execute, 123, '1.1: Single progcell executed');
    is(scalar @user_error_calls, 0, '1.2: No user_error for successful single progcell');
    is($Zigzag::Command_Count, 0, '1.3: Command_Count reset after successful progcell');

    # --- Test Case 2: Multiple progcells execute sequentially ---
    $setup_test_case->($accursed_cell_id);
    $test_slice->{$prog_cell_1_id} = '# $main::test_var_for_execute = 10;';
    $test_slice->{$prog_cell_2_id} = '# $main::test_var_for_execute += 5;';
    Zigzag::link_make($accursed_cell_id, $prog_cell_1_id, '+d.inside');
    Zigzag::link_make($prog_cell_1_id, $prog_cell_2_id, '+d.inside');

    Zigzag::atcursor_execute(0);
    is($main::test_var_for_execute, 15, '2.1: Multiple progcells executed sequentially');
    is(scalar @user_error_calls, 0, '2.2: No user_error for successful multiple progcells');

    # --- Test Case 3: Cloned progcell ---
    $setup_test_case->($accursed_cell_id);
    $test_slice->{$original_prog_id} = '# $main::test_var_for_execute = 456;';
    # $clone_cell_id's direct content is placeholder, get_cell_contents will fetch from $original_prog_id
    Zigzag::link_make($accursed_cell_id, $clone_cell_id, '+d.inside');
    Zigzag::link_make($original_prog_id, $clone_cell_id, '+d.clone');

    Zigzag::atcursor_execute(0);
    is($main::test_var_for_execute, 456, '3.1: Cloned progcell executed');
    is(scalar @user_error_calls, 0, '3.2: No user_error for successful cloned progcell');

    # --- Test Case 4: Progcell causes eval error ---
    $setup_test_case->($accursed_cell_id);
    $test_slice->{$prog_err_id} = "# die 'eval error test';";
    Zigzag::link_make($accursed_cell_id, $prog_err_id, '+d.inside');

    Zigzag::atcursor_execute(0);
    is(scalar @user_error_calls, 1, '4.1: user_error called for eval error');
    is($user_error_calls[0][0], 4, '4.2: user_error code is 4 for eval error');
    like($user_error_calls[0][1], qr/eval error test/, '4.3: user_error message contains eval error string');

    # --- Test Case 5: First progcell fails, second not executed ---
    $setup_test_case->($accursed_cell_id);
    $test_slice->{$prog_err_id}   = "# die 'first error here';";
    $test_slice->{$prog_cell_1_id} = '# $main::test_var_for_execute = 789;'; # Should not run
    Zigzag::link_make($accursed_cell_id, $prog_err_id, '+d.inside');
    Zigzag::link_make($prog_err_id, $prog_cell_1_id, '+d.inside');

    Zigzag::atcursor_execute(0);
    is($main::test_var_for_execute, 0, '5.1: Second progcell not executed after first fails');

    # --- Test Case 6: Cell content does not start with # ---
    $setup_test_case->($accursed_cell_id);
    $test_slice->{$non_prog_id} = "No hash here";
    Zigzag::link_make($accursed_cell_id, $non_prog_id, '+d.inside');

    Zigzag::atcursor_execute(0);
    is(scalar @user_error_calls, 1, '6.1: user_error called for non-progcell content');
    like($user_error_calls[0][1], qr/Cell does not start with #/, '6.2: user_error message for non-progcell');

    # --- Test Case 7: Accursed cell itself is progcell ---
    $setup_test_case->($accursed_prog_id);
    $test_slice->{$accursed_prog_id} = '# $main::test_var_for_execute = 999;';
    Zigzag::cell_excise($accursed_prog_id, 'd.inside'); # Ensure no +d.inside children

    Zigzag::atcursor_execute(0);
    is($main::test_var_for_execute, 999, '7.1: Accursed cell itself is executed if progcell');
};

"""

subtest_names_orig = re.findall(r"subtest\s+'([^']+)'", original_content)
all_sorted_names = sorted(list(set(subtest_names_orig + [target_subtest_name])))
modified_content = original_content; inserted = False; new_tests_count_for_plan = 0

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
            match_ran_tests = re.search(r"^1\.\." + str(new_tests_count_for_plan) + r"\s*(#.*)?$", stdout_full, re.MULTILINE)
            if match_ran_tests:
                ok_count = len(re.findall(r"^ok \d+", stdout_full, re.MULTILINE))
                if ok_count == new_tests_count_for_plan:
                    print("All tests passed successfully after adding new subtest and updating plan.")
                    tests_passed_flag = True
                else:
                    print(f"Tests ran (exit 0) and plan {new_tests_count_for_plan} matched, but only {ok_count} 'ok' assertions found.")
            else:
                if "all tests successful" in stdout_lower:
                    print("All tests passed successfully (based on 'all tests successful' message). Plan count '1..N' not found or mismatched.")
                    tests_passed_flag = True
                else:
                    print(f"Tests ran (exit code 0) but test count in output did not match updated plan ({new_tests_count_for_plan}) based on '1..N' line.")
        else:
            if "all tests successful" in stdout_lower:
                 print("All tests passed successfully (based on exit code 0 and 'all tests successful' message). Plan status unknown from script.")
                 tests_passed_flag = True
            else:
                print("Tests ran (exit code 0, no failure strings). Plan status unknown. Output needs manual check for success.")
    else:
        print(f"Tests failed. Return code: {process.returncode}")

    if not tests_passed_flag:
        if stdout_full.strip(): print("STDOUT:\n" + stdout_full)

    if stderr_full.strip(): print("STDERR:\n" + stderr_full)

except subprocess.TimeoutExpired: print("Test execution timed out."); exit(1)
except Exception as e: print(f"Error running tests: {type(e).__name__}: {e}"); exit(1)
