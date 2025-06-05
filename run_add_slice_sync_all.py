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

target_subtest_name = 'slice_sync_all'

# Idempotency: Check if subtest already exists
if f"subtest '{target_subtest_name}'" in original_content:
    print(f"Subtest '{target_subtest_name}' already considered to be in {test_file_path}. Skipping insertion.")
    # Optionally, could run tests here: subprocess.run(["perl", test_file_path])
    # For this sequential execution, we assume if it's present, it's from a successful prior run.
    exit(0)


new_subtest_code = """
subtest 'slice_sync_all' => sub {
    plan tests => 5;
    local @Zigzag::DB_Ref = ();

    Zigzag::slice_sync_all();
    ok(1, 'slice_sync_all runs with empty @DB_Ref');

    my $sync_called_1 = 0;
    eval 'package MockDB; sub new { my $class = shift; bless {@_}, $class; } sub sync { my $self = shift; ${$self->{sync_count}}++; }' if !defined &MockDB::sync;
    my $mock_db_1 = bless { sync_count => \$sync_called_1 }, 'MockDB';
    @Zigzag::DB_Ref = ($mock_db_1);
    Zigzag::slice_sync_all();
    is($sync_called_1, 1, 'sync called once for one mock DB object');

    @Zigzag::DB_Ref = ();
    my $sync_called_2 = 0;
    my $mock_db_2 = bless { sync_count => \$sync_called_2 }, 'MockDB';
    my $sync_called_3 = 0;
    my $mock_db_3 = bless { sync_count => \$sync_called_3 }, 'MockDB';
    @Zigzag::DB_Ref = ($mock_db_2, $mock_db_3);
    Zigzag::slice_sync_all();
    is($sync_called_2, 1, 'sync called once for mock_db_2 in multi-DB setup');
    is($sync_called_3, 1, 'sync called once for mock_db_3 in multi-DB setup');

    @Zigzag::DB_Ref = (undef);
    eval { Zigzag::slice_sync_all(); };
    like($@, qr/Can't call method "sync" on an undefined value/, 'slice_sync_all dies if @DB_Ref contains undef');

    @Zigzag::DB_Ref = ();
};

"""

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

# This script will not run the tests itself, to allow sequential execution by the agent
print(f"Script {__file__} finished processing.")
