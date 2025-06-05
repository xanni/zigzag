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

target_subtest_name = 'is_active_selected'


if f"subtest '{target_subtest_name}'" in original_content:
    print(f"Subtest '{target_subtest_name}' already considered to be in {test_file_path}. Skipping insertion.")
    exit(0)

new_subtest_code = """
subtest 'is_active_selected' => sub {
    plan tests => 5;
    my $SELECT_HOME = 21;

    local *main::display_dirty = sub { return; }; # Mock if necessary
    local *main::display_status_draw = sub { return; }; # Mock if necessary

    %$test_slice = Zigzag::initial_geometry();
    $test_slice->{'300'} = 'Cell in active selection';
    Zigzag::link_make($SELECT_HOME, '300', '+d.mark');
    Zigzag::link_make('300', $SELECT_HOME, '+d.mark');
    ok(Zigzag::is_active_selected('300'), 'Cell 300 is active_selected');
    delete $test_slice->{"${SELECT_HOME}+d.mark"}; delete $test_slice->{"300-d.mark"};
    delete $test_slice->{"300+d.mark"}; delete $test_slice->{"${SELECT_HOME}-d.mark"};

    %$test_slice = Zigzag::initial_geometry();
    ok(!Zigzag::is_active_selected($SELECT_HOME), "SELECT_HOME ($SELECT_HOME) itself is not active_selected");

    %$test_slice = Zigzag::initial_geometry();
    my $other_selection_head = '22';
    $test_slice->{$other_selection_head} = 'Other Selection Head';
    $test_slice->{'301'} = 'Cell in other selection';
    Zigzag::link_make($other_selection_head, '301', '+d.mark');
    Zigzag::link_make('301', $other_selection_head, '+d.mark');
    ok(!Zigzag::is_active_selected('301'), 'Cell 301 (in non-active selection) is not active_selected');
    delete $test_slice->{"${other_selection_head}+d.mark"}; delete $test_slice->{"301-d.mark"};
    delete $test_slice->{"301+d.mark"}; delete $test_slice->{"${other_selection_head}-d.mark"};

    %$test_slice = Zigzag::initial_geometry();
    $test_slice->{'302'} = 'Unselected Cell';
    ok(!Zigzag::is_active_selected('302'), 'Cell 302 (not selected) is not active_selected');

    %$test_slice = Zigzag::initial_geometry();
    $test_slice->{'303'} = 'Cell 303 no d.mark';
    delete $test_slice->{'303-d.mark'};
    delete $test_slice->{'303+d.mark'};
    ok(!Zigzag::is_active_selected('303'), 'Cell 303 (exists, no d.mark links) is not active_selected');
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
