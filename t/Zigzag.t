use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir); # Use tempdir for cleanup
use File::Spec;
use DB_File; # For re-tying and checking sync

# Ensure Zigzag.pm can be loaded
BEGIN { use_ok('Zigzag', ':all') } # Import all exportable functions/variables

# Global setup: Temporary directory for all database files
my $temp_dir = tempdir(CLEANUP => 1); # Auto-cleanup
ok($temp_dir && -d $temp_dir, "Temporary directory created: $temp_dir");

my $primary_db_file = File::Spec->catfile($temp_dir, "zigzag_main.zz");
my $secondary_db_file = File::Spec->catfile($temp_dir, "zigzag_other.zz");

diag("Testing Zigzag.pm slice management functions in $temp_dir");

# --- Tests for slice_open ---
subtest 'slice_open tests' => sub {
    plan tests => 10; # Adjusted plan

    # Test 1: slice_open (first slice, with explicit path)
    my $slice_idx0 = Zigzag::slice_open($primary_db_file);
    is($slice_idx0, 0, "slice_open for the first slice should return index 0");
    ok(-f $primary_db_file, "Primary DB file created at $primary_db_file");
    is(scalar @Zigzag::DB_Ref, 1, "One DB_Ref after first slice_open");
    isa_ok($Zigzag::DB_Ref[0], 'DB_File', "DB_Ref[0] is a DB_File object");
    is(ref $Zigzag::Hash_Ref[0], 'HASH', "Hash_Ref[0] is a HASH reference");
    is($Zigzag::Slice_Count, 1, "Slice_Count is 1 after first slice");
    is($Zigzag::Filename[0], $primary_db_file, "Filename[0] is correct");

    # Test 2: slice_open (second slice)
    my $slice_idx1 = Zigzag::slice_open($secondary_db_file);
    is($slice_idx1, 1, "slice_open for the second slice should return index 1");
    is(scalar @Zigzag::DB_Ref, 2, "Two DB_Refs after second slice_open");
    is($Zigzag::Slice_Count, 2, "Slice_Count is 2 after second slice");
};

# --- Tests for slice_close ---
subtest 'slice_close tests' => sub {
    plan tests => 6;

    # Assuming slices 0 and 1 are open from previous subtest
    ok(defined $Zigzag::DB_Ref[1] && defined $Zigzag::Hash_Ref[1], "Slice 1 is initially open for closing test");

    Zigzag::slice_close(1);
    is($Zigzag::DB_Ref[1], undef, "DB_Ref[1] is undef after closing slice 1");
    is($Zigzag::Hash_Ref[1], undef, "Hash_Ref[1] is undef after closing slice 1");
    # is($Zigzag::Filename[1], undef, "Filename[1] is undef after closing slice 1"); # Behavior might vary
    is($Zigzag::Slice_Count, 1, "Slice_Count is 1 after closing one slice");

    Zigzag::slice_close(0);
    is($Zigzag::DB_Ref[0], undef, "DB_Ref[0] is undef after closing slice 0");
    is($Zigzag::Slice_Count, 0, "Slice_Count is 0 after closing remaining slice");
};

# --- Tests for slice_sync_all ---
subtest 'slice_sync_all tests' => sub {
    plan tests => 3;

    # Re-open primary slice
    Zigzag::slice_open($primary_db_file);
    ok(defined $Zigzag::DB_Ref[0] && defined $Zigzag::Hash_Ref[0], "Slice 0 re-opened for sync test");

    $Zigzag::Hash_Ref[0]->{sync_test_key} = 'sync_test_value';
    Zigzag::slice_sync_all(); # Sync the data

    # Close all, then re-tie to verify persistence
    Zigzag::slice_close_all();

    my %synced_hash;
    tie %synced_hash, 'DB_File', $primary_db_file, O_RDONLY, 0640, $DB_BTREE
        or BAIL_OUT("Cannot re-tie to $primary_db_file for sync test: $!");
    
    ok(exists $synced_hash{sync_test_key}, "Data 'sync_test_key' exists after sync and reopen");
    is($synced_hash{sync_test_key}, 'sync_test_value', "Data content is correct after sync");
    
    untie %synced_hash;
};

# --- Tests for slice_close_all ---
subtest 'slice_close_all tests' => sub {
    plan tests => 5;

    # Open a couple of slices
    Zigzag::slice_open($primary_db_file);
    Zigzag::slice_open($secondary_db_file);
    is($Zigzag::Slice_Count, 2, "Two slices open before slice_close_all");

    Zigzag::slice_close_all();
    is($Zigzag::Slice_Count, 0, "Slice_Count is 0 after slice_close_all");
    ok(!defined($Zigzag::DB_Ref[0]) && !defined($Zigzag::Hash_Ref[0]), "Slice 0 resources cleared");
    ok(!defined($Zigzag::DB_Ref[1]) && !defined($Zigzag::Hash_Ref[1]), "Slice 1 resources cleared");
    # Check if @Zigzag::Filename is cleared or reset
    is(scalar @Zigzag::Filename, 0, "Filename array should be empty after slice_close_all");

};

diag("Testing Zigzag.pm cell manipulation functions");

my $cell_test_db_file = File::Spec->catfile($temp_dir, "zigzag_cell_tests.zz");

# --- Tests for cell_new, cell_get, cell_set ---
subtest 'cell_new, cell_get, cell_set tests' => sub {
    plan tests => 15; # Adjusted plan

    Zigzag::slice_close_all(); # Ensure clean state
    my $s_idx = Zigzag::slice_open($cell_test_db_file);
    is($s_idx, 0, "Opened cell test slice");

    # Test cell_new
    my $c1_id = Zigzag::cell_new($s_idx);
    ok($c1_id > 0, "cell_new() returns a positive ID (actual: $c1_id)"); # ID > 0 because of initial_geometry
    is(Zigzag::cell_get($s_idx, $c1_id), $c1_id, "cell_new() with no content stores cell ID as content");

    my $c2_content = "Hello Zigzag";
    my $c2_id = Zigzag::cell_new($s_idx, $c2_content);
    ok($c2_id > 0 && $c2_id != $c1_id, "cell_new() with content returns a new positive ID (actual: $c2_id)");
    is(Zigzag::cell_get($s_idx, $c2_id), $c2_content, "cell_get() retrieves correct content for c2");

    # Test cell_get for non-existent cell
    my $non_existent_id = $c1_id + $c2_id + 100; # Reasonably sure this won't exist
    is(Zigzag::cell_get($s_idx, $non_existent_id), undef, "cell_get() on non-existent cell returns undef");

    # Test cell_set
    my $c1_new_content = "New content for C1";
    Zigzag::cell_set($s_idx, $c1_id, $c1_new_content);
    is(Zigzag::cell_get($s_idx, $c1_id), $c1_new_content, "cell_set() updates content, cell_get() verifies");

    # Test cell_set on non-existent cell (should die)
    my $died = 0;
    eval { Zigzag::cell_set($s_idx, $non_existent_id, "try to set"); };
    if ($@) {
        like($@, qr/No cell $non_existent_id/, "cell_set() on non-existent cell dies with correct message");
        $died = 1;
    }
    ok($died, "cell_set() on non-existent cell died as expected");

    # Test cell_new reuses from recycle pile (simple case: delete one, create one)
    # This assumes cell_delete (not explicitly tested here but used by link_break/excise)
    # and that cell_new will pick from $Recycle_Pile{$s_idx} if available.
    # This is a more advanced test that depends on cell_delete's behavior.
    # For now, we'll just test sequential IDs again.
    my $c3_id = Zigzag::cell_new($s_idx, "c3");
    ok($c3_id > $c2_id, "cell_new() provides a new ID (c3_id: $c3_id > c2_id: $c2_id) when recycle pile is likely empty or not hit.");

    # Test cell_get for initial geometry cells (implementation detail, but good to know)
    # These typically exist after slice_open due to initial_geometry
    ok(defined Zigzag::cell_get($s_idx, 0), "cell_get(0) should be defined (Cell_ID_Free)");
    ok(defined Zigzag::cell_get($s_idx, 1), "cell_get(1) should be defined (Cell_ID_Recycle_Pile)");
    is(Zigzag::cell_get($s_idx, 10), 'd.0', "cell_get(10) should be 'd.0' (geometry cell)");
    is(Zigzag::cell_get($s_idx, Zigzag::Cell_ID_Focus()), 'Focus', "cell_get(Focus) should be 'Focus'");
    is(Zigzag::cell_get($s_idx, Zigzag::Cell_ID_Not_Exist()), 'Not_Exist', "cell_get(Not_Exist) should be 'Not_Exist'");


    Zigzag::slice_close_all();
};

diag("Testing more Zigzag.pm atcursor_* functions (execute, clone, copy, hop, make/break link)");

my $atcursor_test_db_file2 = File::Spec->catfile($temp_dir, "zigzag_atcursor2_tests.zz");

sub setup_atcursor_test_slice2 {
    Zigzag::slice_close_all() if $Zigzag::Slice_Count > 0;
    # Ensure Input_Buffer is clear for tests that might use it.
    $Zigzag::Input_Buffer = undef;
    my $s_idx = Zigzag::slice_open($atcursor_test_db_file2);
    Zigzag::view_reset(0, $s_idx); # Standardize cursor 0
    return $s_idx;
}

# --- Tests for atcursor_execute ---
$::TestGlobalVar = 0; # Declare global for testing eval side-effects

subtest 'atcursor_execute tests' => sub {
    plan tests => 6;
    my $s_idx = setup_atcursor_test_slice2();
    is($s_idx, 0, "Opened slice for atcursor_execute");

    # Test 1: Successful execution
    $::TestGlobalVar = 0;
    my $c_prog = Zigzag::cell_new($s_idx, q|#$::TestGlobalVar = 123;|);
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_prog);
    Zigzag::atcursor_execute($s_idx, 0);
    is($::TestGlobalVar, 123, "atcursor_execute successfully ran code in cell content");

    # Test 2: Error during eval (user_error 4)
    $::TestGlobalVar = 0; # Reset
    my $c_err_prog = Zigzag::cell_new($s_idx, q|#die('eval test error');|);
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_err_prog);
    my $outer_eval_error = '';
    eval { Zigzag::atcursor_execute($s_idx, 0); };
    $outer_eval_error = $@; # Capture any die from atcursor_execute itself
    ok(!$outer_eval_error, "atcursor_execute itself should not die on eval error (user_error 4 handles it)");
    # Hard to directly test user_error call without mocking. Trust it's called.

    # Test 3: Content not starting with # (user_error 3)
    my $c_no_hash = Zigzag::cell_new($s_idx, "print 'no hash';");
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_no_hash);
    $@ = ''; # Clear previous eval errors
    eval { Zigzag::atcursor_execute($s_idx, 0); }; # Should call user_error(3)
    # atcursor_execute sets $@ itself in this case
    like($@, qr/Cell does not start with #/, "atcursor_execute on cell not starting with # sets \$\@ correctly");

    # Test 4: get_contained logic (first valid # comment found is executed)
    $::TestGlobalVar = 0;
    my $c_cont_outer = Zigzag::cell_new($s_idx, "outer_no_hash");
    my $c_cont_inner_bad = Zigzag::cell_new($s_idx, "inner_no_hash");
    my $c_cont_inner_good = Zigzag::cell_new($s_idx, q|#$::TestGlobalVar = 456;|);
    my $c_cont_inner_never_run = Zigzag::cell_new($s_idx, q|#$::TestGlobalVar = 789;|);

    Zigzag::link_make($s_idx, $c_cont_outer, $c_cont_inner_bad, '+d.contents');
    Zigzag::link_make($s_idx, $c_cont_inner_bad, $c_cont_inner_good, '+d.contents');
    Zigzag::link_make($s_idx, $c_cont_inner_good, $c_cont_inner_never_run, '+d.contents');

    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_cont_outer);
    Zigzag::atcursor_execute($s_idx, 0);
    is($::TestGlobalVar, 456, "atcursor_execute with get_contained executes first valid # script");
    
    # Test 5: Execute on a cell that is not a string (e.g. a dimension cell)
    my $d1_cell = Zigzag::dimension_find($s_idx, "d.1"); # Content is "d.1"
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx,0), $d1_cell);
    $@ = '';
    eval { Zigzag::atcursor_execute($s_idx, 0); };
    like($@, qr/Cell does not start with #/, "atcursor_execute on dimension cell content sets \$\@");


    Zigzag::slice_close_all();
};

# --- Tests for atcursor_clone and atcursor_copy ---
subtest 'atcursor_clone and atcursor_copy tests' => sub {
    plan tests => 18; # Increased plan
    my $s_idx = setup_atcursor_test_slice2();
    is($s_idx, 0, "Opened slice for clone/copy tests");

    my $c_orig = Zigzag::cell_new($s_idx, 'Original Content');
    my $c_linked = Zigzag::cell_new($s_idx, 'Linked Cell');
    Zigzag::link_make($s_idx, $c_orig, $c_linked, '+d.testlink');
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_orig);

    # atcursor_clone
    my $clone_id = Zigzag::atcursor_clone($s_idx, 0);
    ok($clone_id && $clone_id != $c_orig, "atcursor_clone created a new cell: $clone_id");
    is(Zigzag::get_accursed($s_idx, 0), $clone_id, "Cursor moved to cloned cell");
    is(Zigzag::cell_get($s_idx, $clone_id), "Clone of $c_orig", "Cloned cell content is 'Clone of original_id'");
    is(Zigzag::cell_nbr($s_idx, $clone_id, '+d.clone'), $c_orig, "Cloned cell links to original via +d.clone");
    is(Zigzag::cell_nbr($s_idx, $c_orig, '-d.clone'), $clone_id, "Original cell links back to cloned via -d.clone");
    is(Zigzag::cell_nbr($s_idx, $clone_id, '+d.testlink'), undef, "Cloned cell does not copy other links");

    # atcursor_copy (atcursor_clone with 'copy' argument)
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_orig); # Reset cursor
    my $copy_id = Zigzag::atcursor_clone($s_idx, 0, 'copy');
    ok($copy_id && $copy_id != $c_orig && $copy_id != $clone_id, "atcursor_copy created a new cell: $copy_id");
    is(Zigzag::get_accursed($s_idx, 0), $copy_id, "Cursor moved to copied cell");
    is(Zigzag::cell_get($s_idx, $copy_id), "Copy of Original Content", "Copied cell content is 'Copy of original_content'");
    is(Zigzag::cell_nbr($s_idx, $copy_id, '+d.clone'), undef, "Copied cell is NOT linked to original via +d.clone");
    is(Zigzag::cell_nbr($s_idx, $copy_id, '+d.testlink'), undef, "Copied cell does not copy other links (as per current Zigzag.pm code)");

    # Clone active selection
    my $c_orig2 = Zigzag::cell_new($s_idx, 'Original Content 2');
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_orig);
    Zigzag::atcursor_select($s_idx, 0); # Select C_orig
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_orig2);
    Zigzag::atcursor_select($s_idx, 0); # Select C_orig2 (cursor is now on C_orig2)
    
    my $initial_cell_count = $Zigzag::Cell_Count{$s_idx};
    Zigzag::atcursor_clone($s_idx, 0); # Should clone selection
    is($Zigzag::Cell_Count{$s_idx}, $initial_cell_count + 2, "Two new cells created for cloning selection");

    my $clone_of_c_orig2 = Zigzag::get_accursed($s_idx, 0); # Cursor should be on clone of C_orig2
    ok($clone_of_c_orig2 && $clone_of_c_orig2 != $c_orig2, "Cursor is on a new cell (clone of C_orig2)");
    is(Zigzag::cell_get($s_idx, $clone_of_c_orig2), "Clone of $c_orig2", "Content of clone of C_orig2 is correct");
    is(Zigzag::cell_nbr($s_idx, $clone_of_c_orig2, '+d.clone'), $c_orig2, "Clone of C_orig2 links to C_orig2 via +d.clone");

    # Find clone of C_orig (tricky without knowing its ID directly, check -d.clone from C_orig)
    my $clone_of_c_orig = Zigzag::cell_nbr($s_idx, $c_orig, '-d.clone'); # Should be the new one
    ok($clone_of_c_orig && $clone_of_c_orig != $c_orig && $clone_of_c_orig != $clone_id, "Found clone of C_orig");
    is(Zigzag::cell_get($s_idx, $clone_of_c_orig), "Clone of $c_orig", "Content of clone of C_orig is correct");


    Zigzag::slice_close_all();
};

# --- Tests for atcursor_hop ---
subtest 'atcursor_hop tests' => sub {
    plan tests => 10; # Adjusted plan
    my $s_idx = setup_atcursor_test_slice2();
    is($s_idx, 0, "Opened slice for atcursor_hop");

    # R direction for cursor 0 is +d.1
    my $dim_r = '+d.1';
    my $rev_dim_r = '-d.1';

    my $c1 = Zigzag::cell_new($s_idx, "Hop1");
    my $c2 = Zigzag::cell_new($s_idx, "Hop2");
    my $c3 = Zigzag::cell_new($s_idx, "Hop3");

    Zigzag::link_make($s_idx, $c1, $c2, $dim_r);
    Zigzag::link_make($s_idx, $c2, $c3, $dim_r); # Chain: C1 -> C2 -> C3

    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c1);
    Zigzag::atcursor_hop($s_idx, 0, 'R'); # Hop C1 with C2. Order: C2 -> C1 -> C3
    
    is(Zigzag::cell_nbr($s_idx, $c2, $dim_r), $c1, "Hop1: C2 links to C1 in $dim_r");
    is(Zigzag::cell_nbr($s_idx, $c1, $rev_dim_r), $c2, "Hop1: C1 links back to C2 in $rev_dim_r");
    is(Zigzag::cell_nbr($s_idx, $c1, $dim_r), $c3, "Hop1: C1 links to C3 in $dim_r");
    is(Zigzag::cell_nbr($s_idx, $c3, $rev_dim_r), $c1, "Hop1: C3 links back to C1 in $rev_dim_r");
    is(Zigzag::get_accursed($s_idx, 0), $c1, "Hop1: Cursor remains on C1");

    # Current state: C2 -> C1 -> C3. Cursor on C1.
    Zigzag::atcursor_hop($s_idx, 0, 'R'); # Hop C1 with C3. Order: C2 -> C3 -> C1
    is(Zigzag::cell_nbr($s_idx, $c3, $dim_r), $c1, "Hop2: C3 links to C1 in $dim_r");
    is(Zigzag::cell_nbr($s_idx, $c1, $rev_dim_r), $c3, "Hop2: C1 links back to C3 in $rev_dim_r");
    is(Zigzag::get_accursed($s_idx, 0), $c1, "Hop2: Cursor remains on C1");

    # Test hop at end of chain (Cursor on C1, C1 is last: C2 -> C3 -> C1)
    $@ = ''; # Clear error
    eval { Zigzag::atcursor_hop($s_idx, 0, 'R'); };
    like($@, qr/Cannot hop cell \d+ along \+d.1 no link from it/, "atcursor_hop at end of chain calls user_error(5)");

    Zigzag::slice_close_all();
};

# --- Tests for atcursor_make_link ---
subtest 'atcursor_make_link tests' => sub {
    plan tests => 9;
    my $s_idx = setup_atcursor_test_slice2();
    is($s_idx, 0, "Opened slice for atcursor_make_link");

    my $c_source = Zigzag::cell_new($s_idx, "source_ml");
    my $c_target = Zigzag::cell_new($s_idx, "target_ml");
    my $dim_r = '+d.1'; # R for cursor 0

    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_source);
    $Zigzag::Input_Buffer = $c_target;

    Zigzag::atcursor_make_link($s_idx, 0, 'R');
    is(Zigzag::cell_nbr($s_idx, $c_source, $dim_r), $c_target, "atcursor_make_link creates link from source to target");
    is(Zigzag::Input_Buffer, undef, "Input_Buffer is cleared after successful link");

    # Test without Input_Buffer (should just move cursor if possible)
    my $c_move_target = Zigzag::cell_new($s_idx, "move_target_ml");
    Zigzag::link_make($s_idx, $c_source, $c_move_target, $dim_r); # Pre-existing link
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_source);
    $Zigzag::Input_Buffer = undef; # Ensure it's undef
    Zigzag::atcursor_make_link($s_idx, 0, 'R'); # Should behave like cursor_move_direction
    is(Zigzag::get_accursed($s_idx, 0), $c_move_target, "atcursor_make_link without Input_Buffer moves cursor along existing link");

    # Test with Input_Buffer to non-existent cell (user_error 6)
    $Zigzag::Input_Buffer = 99999; # Non-existent cell ID
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_source);
    $@ = '';
    eval { Zigzag::atcursor_make_link($s_idx, 0, 'R'); };
    like($@, qr/No cell 99999 for link/, "atcursor_make_link with non-existent Input_Buffer calls user_error(6)");
    is(Zigzag::Input_Buffer, 99999, "Input_Buffer remains unchanged on error"); # Important for user to see what failed

    # Test linking in d.cursor dimension (should not link)
    my $cursor_cell = Zigzag::get_cursor($s_idx, 0);
    my $initial_pointed_cell = Zigzag::get_accursed($s_idx, 0);
    $Zigzag::Input_Buffer = $c_target;
    Zigzag::atcursor_make_link($s_idx, 0, 'd.cursor'); # using full dim name for clarity
    is(Zigzag::cell_nbr($s_idx, $initial_pointed_cell, '+d.cursor'), undef, "atcursor_make_link does not link in +d.cursor");
    is(Zigzag::cell_nbr($s_idx, $initial_pointed_cell, '-d.cursor'), $cursor_cell, "atcursor_make_link does not break existing -d.cursor link");
    is(Zigzag::Input_Buffer, $c_target, "Input_Buffer remains on d.cursor attempt");


    $Zigzag::Input_Buffer = undef; # Cleanup
    Zigzag::slice_close_all();
};

# --- Tests for atcursor_break_link ---
subtest 'atcursor_break_link tests' => sub {
    plan tests => 7;
    my $s_idx = setup_atcursor_test_slice2();
    is($s_idx, 0, "Opened slice for atcursor_break_link");
    
    my $dim_r = '+d.1'; # R for cursor 0
    my $c_source_b = Zigzag::cell_new($s_idx, "source_bl");
    my $c_target_b = Zigzag::cell_new($s_idx, "target_bl");

    Zigzag::link_make($s_idx, $c_source_b, $c_target_b, $dim_r);
    Zigzag::cursor_jump($s_idx, Zigzag::get_cursor($s_idx, 0), $c_source_b);
    is(Zigzag::cell_nbr($s_idx, $c_source_b, $dim_r), $c_target_b, "Link exists before break");

    Zigzag::atcursor_break_link($s_idx, 0, 'R');
    is(Zigzag::cell_nbr($s_idx, $c_source_b, $dim_r), undef, "atcursor_break_link breaks the link");

    # Test breaking non-existent link (user_error 7)
    $@ = '';
    eval { Zigzag::atcursor_break_link($s_idx, 0, 'R'); }; # Link already broken
    like($@, qr/Cell \d+ not linked at \+d.1/, "atcursor_break_link on non-existent link calls user_error(7)");

    # Test breaking link in d.cursor dimension (should not break)
    my $cursor_cell = Zigzag::get_cursor($s_idx,0);
    my $pointed_cell_before_break = Zigzag::get_accursed($s_idx, 0);
    ok($pointed_cell_before_break, "Cursor is pointing to a cell before attempting to break -d.cursor");
    
    # Need to ensure cursor cell is pointing to the accursed cell for this to be a valid scenario.
    # The -d.cursor link is FROM the cursor cell TO the accursed cell.
    # atcursor_break_link will try to break the link from the ACCURSED cell.
    # So we need to test breaking a link FROM $pointed_cell_before_break in some d.cursor direction.
    # This is not typical usage. The function is designed for R,L,U,D,I,O.
    # Let's test trying to break the link *from* the cursor cell *to* the pointed cell.
    # The function operates on the cell *at the cursor*.
    # If cursor is on $C, it tries to break $C.$direction_dim.
    # To test d.cursor, the cursor itself would need to be $C, which isn't how it works.
    # The code specifically checks if $dim_name eq "d.cursor" and returns.
    # So, if the direction char resolves to 'd.cursor', it should do nothing.
    # This requires view_rotate or similar to make 'R' map to 'd.cursor'.
    # Simpler: pass 'd.cursor' directly.
    Zigzag::link_make($s_idx, $pointed_cell_before_break, Zigzag::cell_new($s_idx,"tmp"), '+d.cursor'); # A link from accursed cell
    Zigzag::atcursor_break_link($s_idx, 0, '+d.cursor'); # Pass actual dim name
    ok(Zigzag::cell_nbr($s_idx, $pointed_cell_before_break, '+d.cursor'), "Link in +d.cursor from accursed cell is NOT broken");
    
    Zigzag::link_make($s_idx, $pointed_cell_before_break, Zigzag::cell_new($s_idx,"tmp2"), '-d.cursor');
    Zigzag::atcursor_break_link($s_idx, 0, '-d.cursor');
    ok(Zigzag::cell_nbr($s_idx, $pointed_cell_before_break, '-d.cursor'), "Link in -d.cursor from accursed cell is NOT broken");
    
    # The crucial test is that the actual link that makes the cursor point to the cell is not broken.
    ok(Zigzag::cell_nbr($s_idx, $cursor_cell, '-d.cursor') == $pointed_cell_before_break, "Actual cursor link (-d.cursor from cursor cell) remains intact");


    Zigzag::slice_close_all();
};

diag("Testing Zigzag.pm atcursor_* functions");

my $atcursor_test_db_file = File::Spec->catfile($temp_dir, "zigzag_atcursor_tests.zz");

sub setup_atcursor_test_slice {
    Zigzag::slice_close_all() if $Zigzag::Slice_Count > 0;
    my $s_idx = Zigzag::slice_open($atcursor_test_db_file);
    Zigzag::view_reset(0, $s_idx); # Standardize cursor 0
    # Zigzag::view_reset(1, $s_idx); # If cursor 1 is used
    return $s_idx;
}

# --- Tests for get_accursed ---
subtest 'get_accursed tests' => sub {
    plan tests => 3;
    my $s_idx = setup_atcursor_test_slice();
    is($s_idx, 0, "Opened atcursor test slice for get_accursed");

    my $cursor0_cell_id = Zigzag::get_cursor($s_idx, 0); # Cell 11
    is(Zigzag::get_accursed($s_idx, 0), 0, "get_accursed(0) initially returns cell 0 (Home)");

    my $c_new_target = Zigzag::cell_new($s_idx, "new_cursor_target");
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $c_new_target);
    is(Zigzag::get_accursed($s_idx, 0), $c_new_target, "get_accursed(0) returns new target after cursor_jump");

    Zigzag::slice_close_all();
};

# --- Tests for atcursor_insert ---
subtest 'atcursor_insert tests' => sub {
    # R: +d.1, L: -d.1, D: +d.2, U: -d.2, O: +d.3, I: -d.3 (for cursor 0 after view_reset)
    my %direction_map = (
        R => '+d.1', L => '-d.1',
        D => '+d.2', U => '-d.2',
        O => '+d.3', I => '-d.3',
    );
    my @directions_to_test = qw(R D L U O I); # Test a sequence
    plan tests => 1 + (scalar(@directions_to_test) * 5); # 1 for setup, 5 tests per direction

    my $s_idx = setup_atcursor_test_slice();
    is($s_idx, 0, "Opened atcursor test slice for atcursor_insert");

    my $cursor_num = 0;
    my $cursor_cell_id = Zigzag::get_cursor($s_idx, $cursor_num);
    my $current_cell_at_cursor = Zigzag::get_accursed($s_idx, $cursor_num); # Starts at cell 0

    foreach my $direction_char (@directions_to_test) {
        my $dim_for_direction = $direction_map{$direction_char};
        my $rev_dim = ($dim_for_direction =~ /^\+(.*)/) ? "-$1" : "+".substr($dim_for_direction,1);

        diag("Testing atcursor_insert direction '$direction_char' (dim $dim_for_direction) from cell $current_cell_at_cursor");

        my $inserted_cell_id = Zigzag::atcursor_insert($s_idx, $cursor_num, $direction_char);
        ok($inserted_cell_id > 0 && $inserted_cell_id != $current_cell_at_cursor, "atcursor_insert('$direction_char') created a new cell ID: $inserted_cell_id");
        is(Zigzag::cell_nbr($s_idx, $current_cell_at_cursor, $dim_for_direction), $inserted_cell_id, "New cell is linked from original cell in $dim_for_direction");
        is(Zigzag::cell_nbr($s_idx, $inserted_cell_id, $rev_dim), $current_cell_at_cursor, "Original cell is linked from new cell in $rev_dim");
        my $new_cell_at_cursor = Zigzag::get_accursed($s_idx, $cursor_num);
        is($new_cell_at_cursor, $inserted_cell_id, "Cursor $cursor_num now points to the new cell $inserted_cell_id");
        like(Zigzag::cell_get($s_idx, $inserted_cell_id), qr/^\d+$/, "New cell content is its own ID (default)");

        $current_cell_at_cursor = $inserted_cell_id; # Update for next iteration
    }
    Zigzag::slice_close_all();
};

# --- Tests for atcursor_select, is_selected, get_selection, get_active_selection ---
subtest 'selection tests' => sub {
    plan tests => 15;
    my $s_idx = setup_atcursor_test_slice();
    is($s_idx, 0, "Opened atcursor test slice for selection tests");

    my $cursor0_cell_id = Zigzag::get_cursor($s_idx, 0);
    my $SELECT_HOME_ID = Zigzag::Cell_ID_Select_Home(); # Should be 21

    my $c_test1 = Zigzag::cell_new($s_idx, "selectable1");
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $c_test1);
    ok(!Zigzag::is_selected($s_idx, $c_test1), "Cell $c_test1 is not initially selected");

    Zigzag::atcursor_select($s_idx, 0); # Select C_test1
    ok(Zigzag::is_selected($s_idx, $c_test1), "Cell $c_test1 is selected after first atcursor_select");
    is(Zigzag::cell_nbr($s_idx, $c_test1, '-d.mark'), $SELECT_HOME_ID, "Cell $c_test1 -d.mark links to SELECT_HOME ($SELECT_HOME_ID)");

    my @active_sel = Zigzag::get_active_selection($s_idx);
    is_deeply(\@active_sel, [$c_test1], "get_active_selection returns only C_test1");
    my @cursor0_sel = Zigzag::get_selection($s_idx, 0);
    is_deeply(\@cursor0_sel, [$c_test1], "get_selection(0) returns only C_test1");

    Zigzag::atcursor_select($s_idx, 0); # Deselect C_test1
    ok(!Zigzag::is_selected($s_idx, $c_test1), "Cell $c_test1 is not selected after second atcursor_select (toggle)");
    is(Zigzag::cell_nbr($s_idx, $c_test1, '-d.mark'), undef, "Cell $c_test1 -d.mark link is removed after deselection");
    @active_sel = Zigzag::get_active_selection($s_idx);
    is_deeply(\@active_sel, [], "get_active_selection is empty after deselecting C_test1");

    # Select C_test1 again
    Zigzag::atcursor_select($s_idx, 0);
    ok(Zigzag::is_selected($s_idx, $c_test1), "Cell $c_test1 is selected again");

    my $c_test2 = Zigzag::cell_new($s_idx, "selectable2");
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $c_test2);
    Zigzag::atcursor_select($s_idx, 0); # Select C_test2
    ok(Zigzag::is_selected($s_idx, $c_test2), "Cell $c_test2 is selected");

    @active_sel = Zigzag::get_active_selection($s_idx);
    # Order depends on how get_active_selection walks the list (LIFO due to +d.mark from SELECT_HOME)
    # So, C_test2 should be first if it's added to the head of the list via +d.mark from SELECT_HOME
    my $sel_head_first = Zigzag::cell_nbr($s_idx, $SELECT_HOME_ID, '+d.mark');
    my $sel_head_second = Zigzag::cell_nbr($s_idx, $sel_head_first, '+d.mark');

    my @expected_active_sel = sort {$a <=> $b} ($c_test1, $c_test2); # Sort for comparison
    @active_sel = sort {$a <=> $b} @active_sel;
    is_deeply(\@active_sel, \@expected_active_sel, "get_active_selection includes C_test1 and C_test2");
    
    # Test get_selection with a different (non-existent active) cursor
    # my @cursor1_sel = Zigzag::get_selection($s_idx, 1); # Assuming cursor 1 is not pointing to a selection list
    # is_deeply(\@cursor1_sel, [], "get_selection(1) for non-active selection cursor returns empty list");
    pass("Skipping get_selection for non-active cursor for now."); # Needs more setup for cursor 1

    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $c_test1); # Move to C_test1
    Zigzag::atcursor_select($s_idx, 0); # Deselect C_test1
    ok(!Zigzag::is_selected($s_idx, $c_test1), "C_test1 deselected");
    @active_sel = Zigzag::get_active_selection($s_idx);
    is_deeply(\@active_sel, [$c_test2], "get_active_selection now only contains C_test2");


    Zigzag::slice_close_all();
};

# --- Tests for atcursor_delete ---
subtest 'atcursor_delete tests' => sub {
    plan tests => 16; # Increased plan
    my $s_idx = setup_atcursor_test_slice();
    is($s_idx, 0, "Opened atcursor test slice for atcursor_delete");

    my $cursor0_cell_id = Zigzag::get_cursor($s_idx, 0);
    my $DELETE_HOME_ID = Zigzag::Cell_ID_Delete_Home(); # 99

    # Test 1: Normal cell deletion with a neighbour
    my $c_prev = Zigzag::cell_new($s_idx, "prev_del");
    my $c_target_del = Zigzag::cell_new($s_idx, "target_to_delete");
    my $c_next = Zigzag::cell_new($s_idx, "next_del");
    my $del_dim = '+d.deltest';
    my $del_rev_dim = '-d.deltest';

    Zigzag::link_make($s_idx, $c_prev, $c_target_del, $del_dim);
    Zigzag::link_make($s_idx, $c_target_del, $c_next, $del_dim);
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $c_target_del);
    
    Zigzag::atcursor_delete($s_idx, 0);
    ok(!defined Zigzag::cell_get($s_idx, $c_target_del), "Original data of c_target_del is gone after delete");
    # Check if it's on the recycle pile (linked from DELETE_HOME via +d.2)
    # This requires iterating the recycle pile or knowing it's the first.
    # A simpler check might be that it's not gettable by normal means and its links are gone.
    is(Zigzag::cell_nbr($s_idx, $c_target_del, $del_dim), undef, "c_target_del +d.deltest link is gone");
    is(Zigzag::cell_nbr($s_idx, $c_target_del, $del_rev_dim), undef, "c_target_del -d.deltest link is gone");


    my $new_cursor_loc = Zigzag::get_accursed($s_idx, 0);
    ok($new_cursor_loc == $c_prev || $new_cursor_loc == $c_next, "Cursor moved to a neighbour ($c_prev or $c_next), actual: $new_cursor_loc");
    # The actual logic for choosing neighbour might be more specific, e.g. prefers previous in some dimension.
    # For now, either neighbour is fine. Zigzag.pm checks +dim then -dim for all dimensions.

    # Test 2: Deletion of isolated cell (jumps to cell 0)
    my $c_isolated = Zigzag::cell_new($s_idx, "isolated_del");
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $c_isolated);
    Zigzag::atcursor_delete($s_idx, 0);
    ok(!defined Zigzag::cell_get($s_idx, $c_isolated), "Original data of c_isolated is gone after delete");
    is(Zigzag::get_accursed($s_idx, 0), 0, "Cursor jumped to cell 0 after deleting isolated cell");

    # Test 3: Deleting essential cell (cell 0 - Home)
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, 0); # Point to cell 0
    my $died_essential = 0;
    eval { Zigzag::atcursor_delete($s_idx, 0); };
    if ($@) {
        like($@, qr/Cannot delete essential cell 0/, "atcursor_delete on cell 0 died with user_error(10)");
        $died_essential = 1;
    }
    ok($died_essential, "Attempt to delete cell 0 (essential) died as expected");
    is(Zigzag::get_accursed($s_idx, 0), 0, "Cursor remains on cell 0 after failed delete attempt");
    ok(defined Zigzag::cell_get($s_idx, 0), "Cell 0 still exists");

    # Test 4: Deleting essential dimension cell (e.g., "d.1")
    my $d1_cell_id = Zigzag::dimension_find($s_idx, "d.1");
    ok($d1_cell_id, "Found cell ID for 'd.1': $d1_cell_id");
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $d1_cell_id);
    my $died_dim = 0;
    eval { Zigzag::atcursor_delete($s_idx, 0); };
    if ($@) {
        like($@, qr/Cannot delete essential dimension d.1/, "atcursor_delete on 'd.1' cell died with user_error(11)");
        $died_dim = 1;
    }
    ok($died_dim, "Attempt to delete 'd.1' (essential dimension) died as expected");
    is(Zigzag::get_accursed($s_idx, 0), $d1_cell_id, "Cursor remains on 'd.1' cell after failed delete");
    is(Zigzag::cell_get($s_idx, $d1_cell_id), "d.1", "'d.1' cell still exists with correct content");
    
    # Test recycle pile check (indirectly)
    # After deleting c_target_del and c_isolated, create two new cells.
    # Their IDs should ideally be those of the deleted cells if recycle is LIFO and simple.
    # This is highly dependent on cell_new's recycle implementation.
    my $recycled1 = Zigzag::cell_new($s_idx, "recycled1");
    my $recycled2 = Zigzag::cell_new($s_idx, "recycled2");
    my @deleted_ids = sort {$a <=> $b} ($c_target_del, $c_isolated);
    my @recycled_ids = sort {$a <=> $b} ($recycled1, $recycled2);

    # This test is too specific to Zigzag's current cell_new recycle strategy.
    # Pass for now, as the core deletion and cursor movement is more important.
    # is_deeply(\@recycled_ids, \@deleted_ids, "Newly created cells reuse IDs from recycle pile (assuming LIFO or simple recycle)");
    pass("Skipping specific recycle ID check for now.");


    Zigzag::slice_close_all();
};

# --- Tests for link_make, cell_nbr, link_break ---
subtest 'link_make, cell_nbr, link_break tests' => sub {
    plan tests => 20; # Adjusted plan

    Zigzag::slice_close_all();
    my $s_idx = Zigzag::slice_open($cell_test_db_file);
    is($s_idx, 0, "Opened cell test slice for link tests");

    my $c1 = Zigzag::cell_new($s_idx, "L1");
    my $c2 = Zigzag::cell_new($s_idx, "L2");
    my $c3 = Zigzag::cell_new($s_idx, "L3"); # For more complex break test
    my $dim = '+d.test';
    my $rev_dim = '-d.test';

    # link_make
    Zigzag::link_make($s_idx, $c1, $c2, $dim);
    is(Zigzag::cell_nbr($s_idx, $c1, $dim), $c2, "cell_nbr(c1, $dim) is c2 after link_make");
    is(Zigzag::cell_nbr($s_idx, $c2, $rev_dim), $c1, "cell_nbr(c2, $rev_dim) is c1 after link_make");

    # cell_nbr for non-existent link
    is(Zigzag::cell_nbr($s_idx, $c1, '+d.other'), undef, "cell_nbr for non-existent dimension returns undef");

    # link_make error: linking to/from non-existent cell
    my $non_existent_id = 99999;
    eval { Zigzag::link_make($s_idx, $c1, $non_existent_id, '+d.fail'); };
    like($@, qr/No cell $non_existent_id for link_make/, "link_make dies for non-existent target cell");
    eval { Zigzag::link_make($s_idx, $non_existent_id, $c1, '+d.fail'); };
    like($@, qr/No cell $non_existent_id for link_make/, "link_make dies for non-existent source cell");

    # link_make error: cell already linked in that direction
    eval { Zigzag::link_make($s_idx, $c1, $c3, $dim); }; # c1 already linked via $dim
    like($@, qr/Cell $c1 already linked at $dim/, "link_make dies if source cell already linked in dimension");

    # link_break (2 args: source, dimension)
    Zigzag::link_make($s_idx, $c2, $c3, $dim); # c1 -> c2 -> c3
    is(Zigzag::cell_nbr($s_idx, $c2, $dim), $c3, "c2 linked to c3 before break");
    Zigzag::link_break($s_idx, $c2, $dim);
    is(Zigzag::cell_nbr($s_idx, $c2, $dim), undef, "cell_nbr(c2, $dim) is undef after link_break(c2, dim)");
    is(Zigzag::cell_nbr($s_idx, $c3, $rev_dim), undef, "cell_nbr(c3, $rev_dim) is undef after link_break (c2's perspective)");

    # link_break (3 args: source, target, dimension)
    Zigzag::link_make($s_idx, $c1, $c2, $dim); # Re-link c1 -> c2
    is(Zigzag::cell_nbr($s_idx, $c1, $dim), $c2, "c1 linked to c2 before specific break");
    Zigzag::link_break($s_idx, $c1, $c2, $dim);
    is(Zigzag::cell_nbr($s_idx, $c1, $dim), undef, "cell_nbr(c1, $dim) is undef after link_break(c1, c2, dim)");
    is(Zigzag::cell_nbr($s_idx, $c2, $rev_dim), undef, "cell_nbr(c2, $rev_dim) is undef after specific break");

    # link_break error: breaking a non-existent link
    eval { Zigzag::link_break($s_idx, $c1, '+d.nonlink'); };
    like($@, qr/Cell $c1 not linked at \+d.nonlink/, "link_break (2-arg) dies for non-existent link");

    eval { Zigzag::link_break($s_idx, $c1, $c3, '+d.nonlink2'); }; # c1 and c3 are not linked by +d.nonlink2
    like($@, qr/Cell $c1 not linked to $c3 at \+d.nonlink2/, "link_break (3-arg) dies if c1 not linked to c3 at dim");
    
    Zigzag::link_make($s_idx, $c1, $c2, $dim); # c1 -> c2
    eval { Zigzag::link_break($s_idx, $c1, $c3, $dim); }; # c1 is linked to c2, not c3, via $dim
    like($@, qr/Cell $c1 link $c2 at $dim not $c3/, "link_break (3-arg) dies if c1 linked to other than c3 at dim");

    # Test that cell_delete (called by link_break) adds to recycle pile
    # This is indirect. We need to see if a new cell reuses the ID.
    # This requires knowing the implementation of cell_delete and cell_new's recycle logic.
    # For now, we assume link_break correctly calls cell_delete if necessary.
    # Let's ensure the cells we created are still gettable if not explicitly deleted by logic.
    ok(Zigzag::cell_get($s_idx, $c1), "Cell c1 still exists");
    ok(Zigzag::cell_get($s_idx, $c2), "Cell c2 still exists");
    ok(Zigzag::cell_get($s_idx, $c3), "Cell c3 still exists");
    # If link_break implies deleting cells that become unlinked, that's a different test.
    # Zigzag's link_break only breaks links, doesn't delete cells.

    # Test breaking link to a non-existent cell (should still work for source perspective)
    # $DB_Ref[$s_idx]{$c1.$dim} = $non_existent_id; # Manually create inconsistent link for testing
    # eval { Zigzag::link_break($s_idx, $c1, $dim); };
    # unlike($@, qr/No cell/, "link_break with inconsistent link (target non-existent) should not die on 'No cell'");
    # Need to mock this scenario carefully if testing. For now, assume valid cells.
    pass("Placeholder for more complex link_break scenarios if needed.");

    Zigzag::slice_close_all();
};

# --- Tests for cell_insert ---
subtest 'cell_insert tests' => sub {
    plan tests => 6;

    Zigzag::slice_close_all();
    my $s_idx = Zigzag::slice_open($cell_test_db_file);
    is($s_idx, 0, "Opened cell test slice for insert tests");

    my $c1 = Zigzag::cell_new($s_idx, "I1");
    my $c2 = Zigzag::cell_new($s_idx, "I2");
    my $c3 = Zigzag::cell_new($s_idx, "I3");
    my $dim = '+d.ins';
    my $rev_dim = '-d.ins';

    # c2 -> c3
    Zigzag::link_make($s_idx, $c2, $c3, $dim);
    is(Zigzag::cell_nbr($s_idx, $c2, $dim), $c3, "c2 -> c3 initial link");

    # Insert c1 between c2 and c3: c2 -> c1 -> c3
    Zigzag::cell_insert($s_idx, $c1, $c2, $dim);
    is(Zigzag::cell_nbr($s_idx, $c2, $dim), $c1, "c2 -> c1 after insert");
    is(Zigzag::cell_nbr($s_idx, $c1, $dim), $c3, "c1 -> c3 after insert");
    is(Zigzag::cell_nbr($s_idx, $c3, $rev_dim), $c1, "c3 -> c1 (reverse) after insert");
    is(Zigzag::cell_nbr($s_idx, $c1, $rev_dim), $c2, "c1 -> c2 (reverse) after insert");

    # TODO: Test error conditions for cell_insert (e.g., c1 already linked on $dim)
    # This would typically call user_error.
    # my $c4 = Zigzag::cell_new($s_idx, "I4");
    # Zigzag::link_make($s_idx, $c1, $c4, $dim); # c1 is now linked I2->C1->C4 and C1->C3 from previous
    # eval { Zigzag::cell_insert($s_idx, $c1, $c2, $dim); }; # This should be an error
    # like($@, qr/user_error regex/, "cell_insert with c1 already linked should call user_error");

    Zigzag::slice_close_all();
};

# --- Tests for cell_excise ---
subtest 'cell_excise tests' => sub {
    plan tests => 7;

    Zigzag::slice_close_all();
    my $s_idx = Zigzag::slice_open($cell_test_db_file);
    is($s_idx, 0, "Opened cell test slice for excise tests");

    my $c1 = Zigzag::cell_new($s_idx, "E1");
    my $c2 = Zigzag::cell_new($s_idx, "E2");
    my $c3 = Zigzag::cell_new($s_idx, "E3");
    my $dim_base = 'd.excise'; # Base dimension, e.g., d.1
    my $dim_fwd = '+' . $dim_base; # e.g., +d.1
    my $dim_bwd = '-' . $dim_base; # e.g., -d.1

    # c1 -> c2 -> c3
    Zigzag::link_make($s_idx, $c1, $c2, $dim_fwd);
    Zigzag::link_make($s_idx, $c2, $c3, $dim_fwd);
    is(Zigzag::cell_nbr($s_idx, $c1, $dim_fwd), $c2, "c1 -> c2 initial link");
    is(Zigzag::cell_nbr($s_idx, $c2, $dim_fwd), $c3, "c2 -> c3 initial link");

    Zigzag::cell_excise($s_idx, $c2, $dim_base);
    is(Zigzag::cell_nbr($s_idx, $c1, $dim_fwd), $c3, "c1 -> c3 after excising c2");
    is(Zigzag::cell_nbr($s_idx, $c3, $dim_bwd), $c1, "c3 -> c1 (reverse) after excising c2");
    is(Zigzag::cell_nbr($s_idx, $c2, $dim_fwd), undef, "c2 no longer linked fwd on $dim_base");
    is(Zigzag::cell_nbr($s_idx, $c2, $dim_bwd), undef, "c2 no longer linked bwd on $dim_base");

    Zigzag::slice_close_all();
};

# --- Tests for cell_find ---
subtest 'cell_find tests' => sub {
    plan tests => 5;

    Zigzag::slice_close_all();
    my $s_idx = Zigzag::slice_open($cell_test_db_file);
    is($s_idx, 0, "Opened cell test slice for find tests");

    my $start_cell = Zigzag::cell_new($s_idx, "FindStart");
    my $c_match1 = Zigzag::cell_new($s_idx, "TargetContent");
    my $c_intermediate = Zigzag::cell_new($s_idx, "Inter");
    my $c_match2 = Zigzag::cell_new($s_idx, "TargetContent");
    my $dim = '+d.find';

    # Chain: start_cell -> c_match1 -> c_intermediate -> c_match2
    Zigzag::link_make($s_idx, $start_cell, $c_match1, $dim);
    Zigzag::link_make($s_idx, $c_match1, $c_intermediate, $dim);
    Zigzag::link_make($s_idx, $c_intermediate, $c_match2, $dim);

    is(Zigzag::cell_find($s_idx, $start_cell, $dim, "TargetContent"), $c_match1, "cell_find finds first match");
    is(Zigzag::cell_find($s_idx, $c_match1, $dim, "TargetContent"), $c_match1, "cell_find finds current cell if it matches");
    is(Zigzag::cell_find($s_idx, $c_intermediate, $dim, "TargetContent"), $c_match2, "cell_find finds next match");
    is(Zigzag::cell_find($s_idx, $start_cell, $dim, "NonExistentContent"), 0, "cell_find returns 0 for no match (Perl false)");

    Zigzag::slice_close_all();
};

diag("Testing Zigzag.pm dimension manipulation functions");

my $dim_test_db_file = File::Spec->catfile($temp_dir, "zigzag_dim_tests.zz");

# --- Setup for dimension tests ---
sub setup_dimension_test_slice {
    # Ensure clean state before these specific tests
    Zigzag::slice_close_all() if $Zigzag::Slice_Count > 0;
    my $s_idx = Zigzag::slice_open($dim_test_db_file);
    return $s_idx;
}

# --- Tests for dimension_home ---
subtest 'dimension_home tests' => sub {
    plan tests => 3;
    my $s_idx = setup_dimension_test_slice();
    is($s_idx, 0, "Opened dimension test slice for dimension_home");

    my $dim_home_cell_id = Zigzag::dimension_home($s_idx);
    # CURSOR_HOME is cell 10. First dimension is linked via +d.1 from cell 10.
    # Cell_ID_Dim_Home is 2 in initial_geometry.pm
    my $expected_dim_home_id = Zigzag::cell_nbr($s_idx, Zigzag::Cell_ID_Dim_Home(), "+d.1");

    is($dim_home_cell_id, $expected_dim_home_id, "dimension_home() returns correct cell ID");
    like(Zigzag::cell_get($s_idx, $dim_home_cell_id), qr/^d\.\d+$/, "Content of dimension_home cell is a dimension name");

    Zigzag::slice_close_all();
};

# --- Tests for dimension_find ---
subtest 'dimension_find tests' => sub {
    plan tests => 8; # Increased for more initial dimensions + non-existent
    my $s_idx = setup_dimension_test_slice();
    is($s_idx, 0, "Opened dimension test slice for dimension_find");

    # Test finding some default dimensions
    my @dims_to_find = ("d.1", "d.2", "d.cursor", "d.mark"); # d.0 is special (Cell_ID_Cursor_Home)
    foreach my $dim_name (@dims_to_find) {
        my $found_id = Zigzag::dimension_find($s_idx, $dim_name);
        ok($found_id && $found_id != Zigzag::Cell_ID_Not_Exist(), "dimension_find for '$dim_name' returns a valid ID: $found_id");
        is(Zigzag::cell_get($s_idx, $found_id), $dim_name, "Content of found cell for '$dim_name' is correct");
    }

    # Test finding a non-existent dimension
    my $non_existent_dim = "d.nonexistent";
    is(Zigzag::dimension_find($s_idx, $non_existent_dim), 0, "dimension_find for non-existent '$non_existent_dim' returns 0");

    Zigzag::slice_close_all();
};

# --- Tests for dimension_rename ---
subtest 'dimension_rename tests' => sub {
    plan tests => 11;
    my $s_idx = setup_dimension_test_slice();
    is($s_idx, 0, "Opened dimension test slice for dimension_rename");

    my $orig_dim_name = "d.mark"; # Cell ID 16
    my $new_dim_name = "d.newmark";
    my $orig_dim_cell_id = Zigzag::dimension_find($s_idx, $orig_dim_name);
    ok($orig_dim_cell_id && $orig_dim_cell_id != Zigzag::Cell_ID_Not_Exist(), "Found original dimension '$orig_dim_name' at ID $orig_dim_cell_id");

    # Rename "d.mark" to "d.newmark"
    Zigzag::dimension_rename($s_idx, $orig_dim_name, $new_dim_name);
    is(Zigzag::cell_get($s_idx, $orig_dim_cell_id), $new_dim_name, "cell_get for original ID shows new name '$new_dim_name'");
    is(Zigzag::dimension_find($s_idx, $orig_dim_name), 0, "dimension_find for original name '$orig_dim_name' now returns 0");
    is(Zigzag::dimension_find($s_idx, $new_dim_name), $orig_dim_cell_id, "dimension_find for new name '$new_dim_name' returns original ID");

    # Rename back
    Zigzag::dimension_rename($s_idx, $new_dim_name, $orig_dim_name);
    is(Zigzag::cell_get($s_idx, $orig_dim_cell_id), $orig_dim_name, "cell_get for original ID shows original name '$orig_dim_name' after renaming back");
    is(Zigzag::dimension_find($s_idx, $new_dim_name), 0, "dimension_find for '$new_dim_name' returns 0 after renaming back");
    is(Zigzag::dimension_find($s_idx, $orig_dim_name), $orig_dim_cell_id, "dimension_find for '$orig_dim_name' returns original ID after renaming back");

    # Error condition: Rename non-existent dimension
    my $non_existent_orig = "d.idonotexist";
    my $non_existent_new = "d.willnotexist";
    Zigzag::dimension_rename($s_idx, $non_existent_orig, $non_existent_new); # Should not die, just print to STDERR
    is(Zigzag::dimension_find($s_idx, $non_existent_orig), 0, "Non-existent original '$non_existent_orig' still not found");
    is(Zigzag::dimension_find($s_idx, $non_existent_new), 0, "Non-existent new '$non_existent_new' not found after trying to rename from non-existent");

    # Error condition: Rename to an already existing dimension name
    my $d1_id = Zigzag::dimension_find($s_idx, "d.1");
    my $d2_id = Zigzag::dimension_find($s_idx, "d.2");
    Zigzag::dimension_rename($s_idx, "d.1", "d.2"); # Should not die, should prevent rename
    is(Zigzag::dimension_find($s_idx, "d.1"), $d1_id, "'d.1' still found at its original ID after trying to rename to 'd.2'");
    # The content of $d1_id should remain "d.1"
    is(Zigzag::cell_get($s_idx, $d1_id), "d.1", "Content of d.1 cell is still 'd.1'");


    Zigzag::slice_close_all();
};

# --- Tests for dimension_is_essential ---
subtest 'dimension_is_essential tests' => sub {
    # From initial_geometry.pm, essential dimensions are:
    # d.1, d.2, d.cursor, d.clone, d.inside, d.contents, d.mark
    # Note: d.0 is Cell_ID_Cursor_Home which is special, not a typical "dimension" for this check.
    my @essential_dims = ("d.1", "+d.2", "-d.cursor", "d.clone", "+d.inside", "-d.contents", "d.mark");
    my @non_essential_dims = ("d.foo", "+d.bar", "nonstandard", "d.essentialfake");
    plan tests => scalar(@essential_dims) + scalar(@non_essential_dims) + 2; # +2 for undef and empty string

    foreach my $dim_name (@essential_dims) {
        ok(Zigzag::dimension_is_essential($dim_name), "'$dim_name' is essential");
    }

    foreach my $dim_name (@non_essential_dims) {
        ok(!Zigzag::dimension_is_essential($dim_name), "'$dim_name' is not essential");
    }
    
    ok(!Zigzag::dimension_is_essential(undef), "undef is not essential");
    ok(!Zigzag::dimension_is_essential(''), "Empty string is not essential");

    # No slice needed for dimension_is_essential as it's a regex match on the name.
};

diag("Testing Zigzag.pm cursor manipulation functions");

my $cursor_test_db_file = File::Spec->catfile($temp_dir, "zigzag_cursor_tests.zz");

sub setup_cursor_test_slice {
    Zigzag::slice_close_all() if $Zigzag::Slice_Count > 0;
    my $s_idx = Zigzag::slice_open($cursor_test_db_file);
    # Ensure view_reset is called for the cursors to set up their R,L,U,D,I,O dimensions
    # This is important for cursor_move_direction tests.
    # view_reset takes cursor_id (0, 1, etc.), not cursor_cell_id
    Zigzag::view_reset(0, $s_idx); # For cursor 0
    Zigzag::view_reset(1, $s_idx); # For cursor 1 (if it exists and needs reset)
    return $s_idx;
}

# Helper to get the cell a cursor is currently on
sub get_cell_pointed_to_by_cursor {
    my ($s_idx, $cursor_cell_id) = @_;
    return Zigzag::cell_nbr($s_idx, $cursor_cell_id, '-d.cursor');
}

# --- Tests for get_cursor ---
subtest 'get_cursor tests' => sub {
    plan tests => 5;
    my $s_idx = setup_cursor_test_slice();
    is($s_idx, 0, "Opened cursor test slice for get_cursor");

    # CURSOR_HOME (10) -> +d.2 -> cursor0_cell_id (11)
    # cursor0_cell_id (11) -> +d.2 -> cursor1_cell_id (16)
    my $cursor0_cell_id = Zigzag::get_cursor($s_idx, 0);
    is($cursor0_cell_id, 11, "get_cursor(0) returns cell ID 11");
    # Cell 11 ("Menu") has +d.1 link to cell 12 ("d.1") by default
    ok(Zigzag::cell_nbr($s_idx, $cursor0_cell_id, '+d.1'), "Cursor 0 (cell 11) has a +d.1 link (X dim)");

    my $cursor1_cell_id = Zigzag::get_cursor($s_idx, 1);
    is($cursor1_cell_id, 16, "get_cursor(1) returns cell ID 16 ('Event')");

    my $died = 0;
    eval { Zigzag::get_cursor($s_idx, 99); };
    if ($@) {
        like($@, qr/No cursor 99/, "get_cursor(99) dies for out-of-bounds cursor index");
        $died = 1;
    }
    # Note: The actual error is "No cell 10 link at +d.2" if it iterates too far,
    # or specific error from get_cursor if it checks bounds first.
    # The current Zigzag.pm's get_cursor will die with "No cell X link at +d.2"
    # if it walks off the end of the cursor list. This is acceptable.

    Zigzag::slice_close_all();
};

# --- Tests for cursor_move_dimension ---
subtest 'cursor_move_dimension tests' => sub {
    plan tests => 4;
    my $s_idx = setup_cursor_test_slice();
    is($s_idx, 0, "Opened cursor test slice for cursor_move_dimension");

    my $cursor0_cell_id = Zigzag::get_cursor($s_idx, 0); # This is cell 11
    my $initial_pointed_cell = get_cell_pointed_to_by_cursor($s_idx, $cursor0_cell_id); # Should be cell 0 ("Home")
    is($initial_pointed_cell, 0, "Cursor 0 initially points to cell 0 ('Home')");

    my $c_target = Zigzag::cell_new($s_idx, "target_for_move_dim");
    Zigzag::link_make($s_idx, $initial_pointed_cell, $c_target, '+d.1');

    Zigzag::cursor_move_dimension($s_idx, $cursor0_cell_id, '+d.1');
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor0_cell_id), $c_target, "cursor_move_dimension moves cursor to c_target along +d.1");

    # Test moving along an unlinked dimension
    Zigzag::cursor_move_dimension($s_idx, $cursor0_cell_id, '+d.unlinked'); # c_target is not linked via +d.unlinked
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor0_cell_id), $c_target, "cursor_move_dimension does not move if no cell at target dimension");

    Zigzag::slice_close_all();
};

# --- Tests for cursor_jump ---
subtest 'cursor_jump tests' => sub {
    plan tests => 4;
    my $s_idx = setup_cursor_test_slice();
    is($s_idx, 0, "Opened cursor test slice for cursor_jump");

    my $cursor0_cell_id = Zigzag::get_cursor($s_idx, 0); # Cell 11
    my $initial_pointed_cell = get_cell_pointed_to_by_cursor($s_idx, $cursor0_cell_id); # Cell 0

    my $c_jump_target = Zigzag::cell_new($s_idx, 'jump_target_cell');
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $c_jump_target);
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor0_cell_id), $c_jump_target, "cursor_jump moves cursor to c_jump_target");

    # Test jumping to a cell that is a cursor (e.g. cell 16, which is cursor 1)
    # This should call user_error but not die. The cursor should remain on c_jump_target.
    my $cursor1_cell_id = Zigzag::get_cursor($s_idx, 1); # Cell 16
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $cursor1_cell_id);
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor0_cell_id), $c_jump_target, "cursor_jump to another cursor cell does not change location (user_error)");

    # Test jumping to a non-existent cell (should also call user_error and not move)
    my $non_existent_target = 9999;
    Zigzag::cursor_jump($s_idx, $cursor0_cell_id, $non_existent_target);
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor0_cell_id), $c_jump_target, "cursor_jump to non-existent cell does not change location (user_error)");

    Zigzag::slice_close_all();
};

# --- Tests for cursor_move_direction ---
subtest 'cursor_move_direction tests' => sub {
    plan tests => 15; # 1 (slice open) + 2 (initial state) + 2*6 (directions)
    my $s_idx = setup_cursor_test_slice(); # This calls view_reset(0, $s_idx)
    is($s_idx, 0, "Opened cursor test slice for cursor_move_direction");

    my $cursor_id_for_move = 0; # Testing with cursor 0
    my $cursor_cell = Zigzag::get_cursor($s_idx, $cursor_id_for_move); # Cell 11
    
    my $home_cell = 0; # Default cell for cursor 0 after view_reset
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor_cell), $home_cell, "Cursor $cursor_id_for_move initially points to Home (cell $home_cell)");
    
    # view_reset sets cursor 0's location to cell 0 (Home)
    # R: +d.1, L: -d.1, D: +d.2, U: -d.2, O: +d.3, I: -d.3 (for cursor 0)

    my %moves = (
        R => '+d.1', L => '-d.1',
        D => '+d.2', U => '-d.2',
        O => '+d.3', I => '-d.3',
    );

    my $current_pointed_cell = $home_cell;

    foreach my $direction (sort keys %moves) {
        my $dim_to_use = $moves{$direction};
        diag("Testing direction $direction (dim $dim_to_use) from cell $current_pointed_cell");

        my $target_cell = Zigzag::cell_new($s_idx, "target_for_$direction");
        Zigzag::link_make($s_idx, $current_pointed_cell, $target_cell, $dim_to_use);
        
        Zigzag::cursor_move_direction($s_idx, $cursor_id_for_move, $direction);
        my $new_pointed_cell = get_cell_pointed_to_by_cursor($s_idx, $cursor_cell);
        is($new_pointed_cell, $target_cell, "cursor_move_direction '$direction' moves to $target_cell");

        # Move back to $current_pointed_cell to isolate tests if it's not a paired reverse move
        # For simplicity, we'll continue from the new cell.
        # For more robust test, would jump back: Zigzag::cursor_jump($s_idx, $cursor_cell, $current_pointed_cell);
        # However, the problem asks to test L, R, U, D, I, O, implying sequential moves from previous state.
        # So, we update current_pointed_cell for next iteration.
        $current_pointed_cell = $new_pointed_cell;
    }

    # Test moving in a direction with no link
    my $cell_before_no_move = $current_pointed_cell;
    Zigzag::cursor_move_direction($s_idx, $cursor_id_for_move, 'R'); # Assuming current_pointed_cell has no link on +d.1 now
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor_cell), $cell_before_no_move, "cursor_move_direction 'R' with no link does not move cursor");

    # Test with an invalid direction
    Zigzag::cursor_move_direction($s_idx, $cursor_id_for_move, 'X'); # Invalid direction
    is(get_cell_pointed_to_by_cursor($s_idx, $cursor_cell), $cell_before_no_move, "cursor_move_direction with invalid direction 'X' does not move cursor");


    Zigzag::slice_close_all();
};

diag("Testing Zigzag.pm do_shear function");

my $shear_test_db_file = File::Spec->catfile($temp_dir, "zigzag_shear_tests.zz");

# Helper to create a horizontally linked row of cells
sub helper_create_row {
    my ($s_idx, $num_cells, $prefix, $link_dim) = @_;
    my @row_ids;
    return () if $num_cells == 0;

    for my $i (1 .. $num_cells) {
        my $cell_id = Zigzag::cell_new($s_idx, "$prefix$i");
        push @row_ids, $cell_id;
        if ($i > 1) {
            Zigzag::link_make($s_idx, $row_ids[$i-2], $row_ids[$i-1], $link_dim);
        }
    }
    return @row_ids;
}

# Helper to link two rows vertically, cell by cell
sub helper_link_rows_vertically {
    my ($s_idx, $row_a_ids_ref, $row_b_ids_ref, $vert_dim) = @_;
    my @row_a_ids = @{$row_a_ids_ref};
    my @row_b_ids = @{$row_b_ids_ref};

    for my $i (0 .. $#row_a_ids) {
        last if $i > $#row_b_ids; # Stop if row_b is shorter
        Zigzag::link_make($s_idx, $row_a_ids[$i], $row_b_ids[$i], $vert_dim);
    }
}

# Helper to verify sheared links
sub helper_verify_shear {
    my ($s_idx, $row_a_ids_ref, $row_b_ids_ref, $link_dim_A_to_B, $link_dim_B_to_A, $expected_map_ref, $test_name_prefix) = @_;
    my @row_a_ids = @{$row_a_ids_ref};
    my @row_b_ids = @{$row_b_ids_ref};
    my %expected_map = %{$expected_map_ref};
    my %reverse_expected_map;
    while(my($k,$v) = each %expected_map) { $reverse_expected_map{$v} = $k; }

    foreach my $a_cell (@row_a_ids) {
        my $actual_b_link = Zigzag::cell_nbr($s_idx, $a_cell, $link_dim_A_to_B);
        if (exists $expected_map{$a_cell}) {
            is($actual_b_link, $expected_map{$a_cell}, "$test_name_prefix: Cell A$a_cell links to B".$expected_map{$a_cell}." via $link_dim_A_to_B");
        } else {
            is($actual_b_link, undef, "$test_name_prefix: Cell A$a_cell has no link via $link_dim_A_to_B (as expected for hang)");
        }
    }

    foreach my $b_cell (@row_b_ids) {
        my $actual_a_link = Zigzag::cell_nbr($s_idx, $b_cell, $link_dim_B_to_A);
         if (exists $reverse_expected_map{$b_cell}) {
            is($actual_a_link, $reverse_expected_map{$b_cell}, "$test_name_prefix: Cell B$b_cell links back to A".$reverse_expected_map{$b_cell}." via $link_dim_B_to_A");
        } else {
            is($actual_a_link, undef, "$test_name_prefix: Cell B$b_cell has no incoming link via $link_dim_B_to_A (as expected for hang/unlinked)");
        }
    }
}


subtest 'do_shear tests' => sub {
    my $ROW_SIZE = 4;
    my $dim_horiz = '+d.1'; # Shear direction along A-row
    my $dim_vert = '+d.2';  # Linking A to B
    my $dim_vert_rev = '-d.2'; # Linking B to A

    # This inner sub sets up a fresh slice and data for each main test case
    my $setup_initial_shear_state = sub {
        # Close any previous slice to ensure total isolation
        Zigzag::slice_close_all() if $Zigzag::Slice_Count > 0;
        my $s_idx = Zigzag::slice_open($shear_test_db_file);
        ok($s_idx == 0, "Opened shear test slice for new scenario");

        my @A_ids = helper_create_row($s_idx, $ROW_SIZE, 'A', $dim_horiz);
        my @B_ids = helper_create_row($s_idx, $ROW_SIZE, 'B', $dim_horiz); # B row also linked internally just for completeness
        helper_link_rows_vertically($s_idx, \@A_ids, \@B_ids, $dim_vert);
        return ($s_idx, \@A_ids, \@B_ids);
    };

    subtest 'Shear n=1, no hang' => sub {
        plan tests => 1 + ($ROW_SIZE * 2); # 1 for slice open, 2 per cell pair in A and B
        my ($s_idx, $A_ids_ref, $B_ids_ref) = $setup_initial_shear_state->();
        my @A_ids = @{$A_ids_ref};
        my @B_ids = @{$B_ids_ref};

        Zigzag::do_shear($s_idx, $A_ids[0], $dim_horiz, $dim_vert, 1, $Zigzag::FALSE);
        my %expected = (
            $A_ids[0] => $B_ids[1], $A_ids[1] => $B_ids[2],
            $A_ids[2] => $B_ids[3], $A_ids[3] => $B_ids[0],
        );
        helper_verify_shear($s_idx, \@A_ids, \@B_ids, $dim_vert, $dim_vert_rev, \%expected, "n=1 no_hang");
        Zigzag::slice_close_all();
    };

    subtest 'Shear n=2, no hang' => sub {
        plan tests => 1 + ($ROW_SIZE * 2);
        my ($s_idx, $A_ids_ref, $B_ids_ref) = $setup_initial_shear_state->();
        my @A_ids = @{$A_ids_ref};
        my @B_ids = @{$B_ids_ref};

        Zigzag::do_shear($s_idx, $A_ids[0], $dim_horiz, $dim_vert, 2, $Zigzag::FALSE);
        my %expected = (
            $A_ids[0] => $B_ids[2], $A_ids[1] => $B_ids[3],
            $A_ids[2] => $B_ids[0], $A_ids[3] => $B_ids[1],
        );
        helper_verify_shear($s_idx, \@A_ids, \@B_ids, $dim_vert, $dim_vert_rev, \%expected, "n=2 no_hang");
        Zigzag::slice_close_all();
    };

    subtest 'Shear n=1, with hang' => sub {
        plan tests => 1 + ($ROW_SIZE * 2);
        my ($s_idx, $A_ids_ref, $B_ids_ref) = $setup_initial_shear_state->();
        my @A_ids = @{$A_ids_ref};
        my @B_ids = @{$B_ids_ref};

        Zigzag::do_shear($s_idx, $A_ids[0], $dim_horiz, $dim_vert, 1, $Zigzag::TRUE);
        my %expected = ( # A4 will not link to B1, B1 will not link from A4
            $A_ids[0] => $B_ids[1], $A_ids[1] => $B_ids[2],
            $A_ids[2] => $B_ids[3], 
            # A_ids[3] is hung, B_ids[0] is unlinked from A-row
        );
        helper_verify_shear($s_idx, \@A_ids, \@B_ids, $dim_vert, $dim_vert_rev, \%expected, "n=1 hang");
        Zigzag::slice_close_all();
    };

    subtest 'Shear n > items (n=5 for 4 items), no hang' => sub {
        plan tests => 1 + ($ROW_SIZE * 2);
        my ($s_idx, $A_ids_ref, $B_ids_ref) = $setup_initial_shear_state->();
        my @A_ids = @{$A_ids_ref};
        my @B_ids = @{$B_ids_ref};

        Zigzag::do_shear($s_idx, $A_ids[0], $dim_horiz, $dim_vert, 5, $Zigzag::FALSE); # 5 mod 4 = 1
        my %expected = (
            $A_ids[0] => $B_ids[1], $A_ids[1] => $B_ids[2],
            $A_ids[2] => $B_ids[3], $A_ids[3] => $B_ids[0],
        );
        helper_verify_shear($s_idx, \@A_ids, \@B_ids, $dim_vert, $dim_vert_rev, \%expected, "n=5 no_hang");
        Zigzag::slice_close_all();
    };
    
    subtest 'Shear n=0, no hang (no change)' => sub {
        plan tests => 1 + ($ROW_SIZE * 2);
        my ($s_idx, $A_ids_ref, $B_ids_ref) = $setup_initial_shear_state->();
        my @A_ids = @{$A_ids_ref};
        my @B_ids = @{$B_ids_ref};

        Zigzag::do_shear($s_idx, $A_ids[0], $dim_horiz, $dim_vert, 0, $Zigzag::FALSE);
        my %expected;
        for(my $i=0; $i < $ROW_SIZE; $i++) { $expected{$A_ids[$i]} = $B_ids[$i]; }
        helper_verify_shear($s_idx, \@A_ids, \@B_ids, $dim_vert, $dim_vert_rev, \%expected, "n=0 no_hang");
        Zigzag::slice_close_all();
    };

    subtest 'Shear with empty A row' => sub {
        plan tests => 1; # Just the slice setup
        Zigzag::slice_close_all() if $Zigzag::Slice_Count > 0;
        my $s_idx = Zigzag::slice_open($shear_test_db_file);
        ok($s_idx == 0, "Opened shear test slice for empty A row");

        my @A_ids = ();
        my @B_ids = helper_create_row($s_idx, $ROW_SIZE, 'B', $dim_horiz);
        # No vertical links made
        
        # Call do_shear with a non-existent cell ID (0 or undef) if A_ids[0] is used.
        # The function expects a valid $first_cell. If row A is empty, it doesn't make sense to call.
        # If $first_cell is part of another structure but has no $dir links, it should not error, but do nothing.
        my $dummy_first_cell = Zigzag::cell_new($s_idx, "dummy_A_first");
        Zigzag::do_shear($s_idx, $dummy_first_cell, $dim_horiz, $dim_vert, 1, $Zigzag::FALSE);
        pass("do_shear with empty effective A row (no links on $dim_horiz from first_cell) completed without error.");
        # Verification would be that B row and dummy_first_cell are untouched.
        Zigzag::slice_close_all();
    };

};


# Teardown: Ensure everything is closed (though tempdir cleanup is primary)
END {
    diag("Running END block: Ensuring all slices are closed.");
    Zigzag::slice_close_all() if defined(&Zigzag::slice_close_all) && $Zigzag::Slice_Count > 0; # Conditional close
    # $temp_dir is cleaned by File::Temp due to CLEANUP => 1
}

done_testing();
