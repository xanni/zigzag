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

# Idempotency Check
if f"subtest '{target_subtest_name}'" in original_content:
    print(f"Subtest '{target_subtest_name}' already considered to be in {test_file_path}. Skipping insertion.")
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

    Zigzag::cell_excise($SELECT_HOME, 'd.mark');
    Zigzag::link_make($SELECT_HOME, $orig_cell_B_id, '+d.mark');
    Zigzag::link_make($orig_cell_B_id, $orig_cell_C_id, '+d.mark');
    Zigzag::link_make($orig_cell_C_id, $SELECT_HOME, '+d.mark');

    Zigzag::link_make($orig_cell_B_id, $orig_cell_C_id, '+d.testcopy');

    my $neutral_accursed_target = '800';
    $test_slice->{$neutral_accursed_target} = 'Neutral Accursed for TC2';
    $cursor0_obj_cell = Zigzag::get_cursor(0);
    Zigzag::cell_excise($cursor0_obj_cell, 'd.cursor');
    $test_slice->{"${cursor0_obj_cell}-d.cursor"} = $neutral_accursed_target;
    $test_slice->{"${neutral_accursed_target}+d.cursor"} = $cursor0_obj_cell;

    my $next_cell_id_at_start_tc2 = $test_slice->{'n'};
    Zigzag::atcursor_copy(0);

    my $new_cell_B_id = $next_cell_id_at_start_tc2;
    my $new_cell_C_id = $next_cell_id_at_start_tc2 + 1;
    my $new_cell_SH_id = $next_cell_id_at_start_tc2 + 2; # Copy of SELECT_HOME

    ok(exists $test_slice->{$new_cell_B_id}, '2.1: New cell B exists');
    is(Zigzag::cell_get($new_cell_B_id), "Copy of Original B", '2.2: New cell B content');
    ok(exists $test_slice->{$new_cell_C_id}, '2.3: New cell C exists');
    is(Zigzag::cell_get($new_cell_C_id), "Copy of Original C", '2.4: New cell C content');
    is(Zigzag::cell_nbr($new_cell_B_id, '+d.testcopy'), undef, '2.5: Link between new B and new C NOT copied');

    is(Zigzag::get_accursed(0), $new_cell_SH_id, '2.6: Accursed is new copy of SELECT_HOME');

    is(Zigzag::cell_nbr($new_cell_B_id, "-d.clone"), undef, '2.7: New cell B no -d.clone link');
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

print(f"Script {__file__} finished processing.")
