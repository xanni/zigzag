use strict;
use warnings;
use lib '.'; # To find Zigzag.pm when run from the project directory
use Test::More tests => 31;

# Mock user_error for testing purposes, as it's usually provided by the front-end
BEGIN {
    *main::user_error = sub {
        my ($error_code, $message) = @_;
        # The tests expect the message part to be in $@
        die $message;
    };
}

# Ensure the Zigzag module loads
BEGIN { use_ok('Zigzag'); }

# Setup data for all tests in slice 0
@Zigzag::Hash_Ref = ({}); 
my $test_slice = $Zigzag::Hash_Ref[0];

subtest 'reverse_sign' => sub {
    plan tests => 2;
    is( Zigzag::reverse_sign('+d.1'), '-d.1', 'positive to negative');
    is( Zigzag::reverse_sign('-d.test'), '+d.test', 'negative to positive');
};

subtest 'is_cursor' => sub {
    %$test_slice = Zigzag::initial_geometry();

    $test_slice->{'100'} = 'Cell 100 (cursor)';
    $test_slice->{'101'} = 'Cell 101 (target for cursor link)';
    $test_slice->{'102'} = 'Cell 102 (not a cursor)';
    Zigzag::link_make('100', '101', '+d.cursor');

    plan tests => 2;
    ok( Zigzag::is_cursor('100'), 'cell 100 is a cursor (returns 1)');
    ok( !Zigzag::is_cursor('102'), 'cell 102 is not a cursor (returns an empty string)');
};

subtest 'is_clone' => sub {
    %$test_slice = Zigzag::initial_geometry();

    $test_slice->{'200'} = 'Cell 200 (clone via -d.clone)';
    $test_slice->{'299'} = 'Helper cell for 200-d.clone link'; 
    Zigzag::link_make('299', '200', '+d.clone'); # Equivalent to 200-d.clone = 299

    $test_slice->{'201'} = 'Cell 201 (clone via +d.clone)';
    $test_slice->{'298'} = 'Helper cell for 201+d.clone link'; 
    Zigzag::link_make('201', '298', '+d.clone');

    $test_slice->{'202'} = 'Cell 202 (not a clone)';

    plan tests => 3;
    ok( Zigzag::is_clone('200'), 'cell 200 is a clone (returns 1)');
    ok( Zigzag::is_clone('201'), 'cell 201 is a clone (via +d.clone)');
    ok( !Zigzag::is_clone('202'), 'cell 202 is not a clone (returns an empty string)');
};

subtest 'is_essential' => sub {
    %$test_slice = Zigzag::initial_geometry();

    plan tests => 5;
    # Essential cell IDs are 0, $CURSOR_HOME (10), $SELECT_HOME (21), $DELETE_HOME (99)
    # These tests rely on initial_geometry
    ok( Zigzag::is_essential('0'), 'cell 0 is essential');
    ok( Zigzag::is_essential('10'), 'cell 10 (CURSOR_HOME) is essential');
    ok( Zigzag::is_essential('21'), 'cell 21 (SELECT_HOME) is essential');
    ok( Zigzag::is_essential('99'), 'cell 99 (DELETE_HOME) is essential');
    ok( !Zigzag::is_essential('50'), 'cell 50 is not essential'); # Test with a non-essential number
};

subtest 'get_accursed' => sub {
    %$test_slice = Zigzag::initial_geometry();

    # get_cursor(0) should return cell 11 (CURSOR_HOME +d.2 from initial_geometry)
    # We will make cell 111 the accursed cell for cursor 0 (cell 11)
    $test_slice->{'111'} = 'Cell 111 (accursed for cursor 0/cell 11)';
    # Note: cell '11' is established by initial_geometry.
    # We are modifying its '-d.cursor' link and creating the corresponding '+d.cursor' on '111'.
    $test_slice->{'11-d.cursor'} = '111'; 
    $test_slice->{'111+d.cursor'} = '11';

    plan tests => 1;
    is( Zigzag::get_accursed(0), '111', 'get_accursed(0): returns cell 111 (accursed for cursor 0/cell 11)');
};

subtest 'get_active_selection' => sub {
    %$test_slice = Zigzag::initial_geometry();

    my $SELECT_HOME = 21; # From Zigzag.pm constants (already in initial_geometry)

    # Define new cells for selections
    $test_slice->{'22'}  = 'Selection Head 1'; 
    $test_slice->{'400'} = 'Cell 400 for active selection';
    $test_slice->{'401'} = 'Cell 401 for active selection';

    # Active selection (selection 0, around $SELECT_HOME)
    Zigzag::link_make($SELECT_HOME, '400', '+d.mark');
    Zigzag::link_make('400', '401', '+d.mark');
    Zigzag::link_make('401', $SELECT_HOME, '+d.mark'); # Cycle complete

    plan tests => 1;
    is_deeply( [Zigzag::get_active_selection()], ['400', '401', $SELECT_HOME], 'returns cells 400, 401, and 21');
};

subtest 'get_selection' => sub {
    %$test_slice = Zigzag::initial_geometry();

    my $SELECT_HOME = 21; # From Zigzag.pm constants (already in initial_geometry)

    # Define new cells for selections
    $test_slice->{'22'}  = 'Selection Head 1'; 
    $test_slice->{'402'} = 'Cell 402 for secondary selection';

    # Secondary selection (selection 1, head cell 22)
    # Link new selection head 22 into the list of selections (21 <-> 22)
    $test_slice->{"${SELECT_HOME}+d.2"} = '22';    $test_slice->{'22-d.2'} = $SELECT_HOME;
    $test_slice->{'22+d.2'} = $SELECT_HOME;       # Cycle selection heads (21 is already -d.2 from 22 via initial_geometry if not overwritten)
    $test_slice->{"${SELECT_HOME}-d.2"} = '22';   # Explicitly make 21 point back to 22 in -d.2

    # Link cells to selection head 22
    $test_slice->{'22+d.mark'} = '402';            $test_slice->{'402-d.mark'} = '22';
    $test_slice->{'402+d.mark'} = '22';            $test_slice->{'22-d.mark'} = '402'; # Cycle complete

    plan tests => 1;
    is_deeply( [Zigzag::get_selection(1)], ['402', '22'], 'get_selection(1): returns cells 402 and 22');
};

subtest 'get_which_selection' => sub {
    %$test_slice = Zigzag::initial_geometry();

    my $SELECT_HOME = 21; # From Zigzag.pm constants (already in initial_geometry)

    # Define new cells for selections
    $test_slice->{'22'}  = 'Selection Head 1'; 
    $test_slice->{'400'} = 'Cell 400 for active selection';
    $test_slice->{'401'} = 'Cell 401 for active selection';
    $test_slice->{'402'} = 'Cell 402 for secondary selection';

    # Active selection (selection 0, around $SELECT_HOME)
    $test_slice->{"${SELECT_HOME}+d.mark"} = '400'; $test_slice->{'400-d.mark'} = $SELECT_HOME;
    $test_slice->{'400+d.mark'} = '401';           $test_slice->{'401-d.mark'} = '400';
    $test_slice->{'401+d.mark'} = $SELECT_HOME;    $test_slice->{"${SELECT_HOME}-d.mark"} = '401'; # Cycle complete

    # Secondary selection (selection 1, head cell 22)
    # Link new selection head 22 into the list of selections (21 <-> 22)
    $test_slice->{"${SELECT_HOME}+d.2"} = '22';    $test_slice->{'22-d.2'} = $SELECT_HOME;
    $test_slice->{'22+d.2'} = $SELECT_HOME;       # Cycle selection heads (21 is already -d.2 from 22 via initial_geometry if not overwritten)
    $test_slice->{"${SELECT_HOME}-d.2"} = '22';   # Explicitly make 21 point back to 22 in -d.2

    # Link cells to selection head 22
    $test_slice->{'22+d.mark'} = '402';            $test_slice->{'402-d.mark'} = '22';
    $test_slice->{'402+d.mark'} = '22';            $test_slice->{'22-d.mark'} = '402'; # Cycle complete

    plan tests => 3;
    is( Zigzag::get_which_selection('400'), '401', 'cell in active selection returns 401');
    is( Zigzag::get_which_selection('402'), '22', 'cell in secondary selection returns 22');
    is( Zigzag::get_which_selection('102'), undef, 'cell not in selection returns undef');
};

subtest 'get_lastcell' => sub {
    %$test_slice = Zigzag::initial_geometry();

    # Linear chain: 500 <-> 501 <-> 502 in d.testchain
    $test_slice->{'500'} = 'Cell 500 (start of linear chain)';
    $test_slice->{'501'} = 'Cell 501 (middle of linear chain)';
    $test_slice->{'502'} = 'Cell 502 (end of linear chain)';
    Zigzag::link_make('500', '501', '+d.testchain');
    Zigzag::link_make('501', '502', '+d.testchain');

    # Circular list: 600 <-> 601 <-> 602 <-> 600 in d.testcircle
    $test_slice->{'600'} = 'Cell 600 (part of circular list)';
    $test_slice->{'601'} = 'Cell 601 (part of circular list)';
    $test_slice->{'602'} = 'Cell 602 (part of circular list)';
    Zigzag::link_make('600', '601', '+d.testcircle');
    Zigzag::link_make('601', '602', '+d.testcircle');
    Zigzag::link_make('602', '600', '+d.testcircle');

    plan tests => 4;
    # Linear chain tests
    is( Zigzag::get_lastcell('500', '+d.testchain'), '502', '(linear +): start 500, end 502');
    is( Zigzag::get_lastcell('502', '-d.testchain'), '500', '(linear -): start 502, end 500');
    # Circular list tests
    is( Zigzag::get_lastcell('600', '+d.testcircle'), '602', '(circular +): start 600, returns cell before start (602)');
    is( Zigzag::get_lastcell('600', '-d.testcircle'), '601', '(circular -): start 600, returns cell before start (601)');
};

subtest 'get_distance' => sub {
    %$test_slice = Zigzag::initial_geometry();

    $test_slice->{'700'} = 'Cell 700 for get_distance';
    $test_slice->{'701'} = 'Cell 701 for get_distance';
    $test_slice->{'702'} = 'Cell 702 for get_distance';
    $test_slice->{'705'} = 'Cell 705 for get_distance (isolated)';
    # Chain: 700 <-> 701 <-> 702 in +d.testdist
    Zigzag::link_make('700', '701', '+d.testdist');
    Zigzag::link_make('701', '702', '+d.testdist');

    plan tests => 7;
    is( Zigzag::get_distance('700', '+d.testdist', '702'), 2, "('700', '+d.testdist', '702') is 2");
    is( Zigzag::get_distance('702', '-d.testdist', '700'), 2, "('702', '-d.testdist', '700') is 2");
    is( Zigzag::get_distance('700', '+d.testdist', '701'), 1, "('700', '+d.testdist', '701') is 1");
    is( Zigzag::get_distance('700', '+d.testdist', '700'), 0, "('700', '+d.testdist', '700') is 0");
    is( Zigzag::get_distance('700', '+d.testdist', '705'), undef, "('700', '+d.testdist', '705') is undef (not connected)");
    is( Zigzag::get_distance('700', '-d.testdist', '702'), undef, "('700', '-d.testdist', '702') is undef (wrong direction)");
    is( Zigzag::get_distance('700', '+d.otherdim', '701'), undef, "('700', '+d.otherdim', '701') is undef (wrong dimension)");
};

subtest 'get_outline_parent' => sub {
    %$test_slice = Zigzag::initial_geometry();

    $test_slice->{'800'} = 'Cell 800 (child for outline parent)';
    $test_slice->{'801'} = 'Cell 801 (parent for outline parent)';
    $test_slice->{'802'} = 'Cell 802 (intermediate for 800-d.2)';
    $test_slice->{'803'} = 'Cell 803 (unrelated for outline parent)'; # Not used by links, just defined

    # Case 1: 800 has parent 801 via 802
    Zigzag::link_make('802', '800', '+d.2'); # 800-d.2 = 802
    Zigzag::link_make('801', '802', '+d.1'); # 802-d.1 = 801

    # Case 2: 801 is its own "outline parent" (no -d.2 path to another -d.1)
    Zigzag::link_make('801', '801', '+d.2'); # Loop on itself in -d.2

    # Case 3: 810 has no outline parent (circular -d.2 chain without -d.1)
    $test_slice->{'810'} = 'Cell 810 (no outline parent)';
    $test_slice->{'811'} = 'Cell 811 (part of 810s -d.2 loop)';
    Zigzag::link_make('811', '810', '+d.2'); # 810-d.2 = 811
    Zigzag::link_make('810', '811', '+d.2'); # 811-d.2 = 810

    plan tests => 3;
    is( Zigzag::get_outline_parent('800'), '801', "('800') is '801'");
    is( Zigzag::get_outline_parent('801'), '801', "('801') (parent itself, -d.2 loops) is '801'");
    is( Zigzag::get_outline_parent('810'), '811', "('810') (circular -d.2, stops at 811) is '811'");
};

subtest 'get_cell_contents' => sub {
    %$test_slice = Zigzag::initial_geometry();

    $test_slice->{'850'} = 'Direct content for 850';
    $test_slice->{'851'} = 'Cell 851 (clone of 852)'; # This content is just a note
    $test_slice->{'852'} = 'Content from original cell 852';
    Zigzag::link_make('852', '851', '+d.clone'); # Equivalent to 851-d.clone = 852

    $test_slice->{'853'} = 'Cell 853 (clone of 854)'; # This content is just a note
    $test_slice->{'854'} = 'Content from original cell 854';
    Zigzag::link_make('853', '854', '+d.clone');

    $test_slice->{'855'} = '[10+20]'; # Special ZZMail-like content

    plan tests => 4;
    is( Zigzag::get_cell_contents('850'), 'Direct content for 850', "('850') returns direct content");
    is( Zigzag::get_cell_contents('851'), 'Content from original cell 852', "('851') returns content of original (-d.clone)");
    is( Zigzag::get_cell_contents('853'), 'Cell 853 (clone of 854)', "('853') returns its own content (only follows -d.clone)");
    is( Zigzag::get_cell_contents('855'), '[10+20]', "('855') returns raw ZZMail-like content when ZZMAIL_SUPPORT is false");
};

subtest 'get_cursor' => sub {
    %$test_slice = Zigzag::initial_geometry();

    # initial_geometry provides cursor 0 (11) and cursor 1 (16)
    # $CURSOR_HOME (10) -> 11 (cursor 0) -> 16 (cursor 1)
    $test_slice->{'900'} = 'Test Cursor 2';
    Zigzag::link_make('16', '900', '+d.2'); # Link from cursor 1 (cell 16) to cursor 2 (cell 900)
    # Cell 900 has no '+d.2' link, marking the end of the explicit cursor chain for testing die condition

    plan tests => 4;
    is( Zigzag::get_cursor(0), '11', "(0) returns cell 11 (from initial_geometry)");
    is( Zigzag::get_cursor(1), '16', "(1) returns cell 16 (from initial_geometry)");
    is( Zigzag::get_cursor(2), '900', "(2) returns cell 900 (added cursor)");

    my $invalid_cursor_num = 3;
    my $expected_error_msg_cursor = "No cursor $invalid_cursor_num";
    eval { Zigzag::get_cursor($invalid_cursor_num); };
    like($@, qr/\Q$expected_error_msg_cursor\E/, "with invalid index $invalid_cursor_num dies with message '$expected_error_msg_cursor'");
};

subtest 'get_dimension' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 7;
    my $cursor_cell_for_dim_test = Zigzag::get_cursor(0); # Should be 11
    # Expected dimensions based on initial_geometry for cursor 0 (cell 11):
    # 11 --(+d.1)--> 12 (content: '+d.1')
    # 12 --(+d.1)--> 13 (content: '+d.2')
    # 13 --(+d.1)--> 14 (content: '+d.3')
    is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'L'), '-d.1', "for L returns -d.1");
    is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'R'), '+d.1', "for R returns +d.1");
    is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'U'), '-d.2', "for U returns -d.2");
    is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'D'), '+d.2', "for D returns +d.2");
    is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'I'), '-d.3', "for I returns -d.3");
    is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'O'), '+d.3', "for O returns +d.3");

    my $invalid_dir = 'X';
    my $expected_error_msg_dim = "Invalid direction $invalid_dir";
    eval { Zigzag::get_dimension($cursor_cell_for_dim_test, $invalid_dir); };
    like($@, qr/\Q$expected_error_msg_dim\E/, "with invalid direction $invalid_dir dies with message '$expected_error_msg_dim'");
};

subtest 'get_links_to' => sub {
    %$test_slice = Zigzag::initial_geometry();

    # Define target and source cells
    $test_slice->{'950'} = 'Target cell for links';
    $test_slice->{'951'} = 'Source cell 1';
    $test_slice->{'952'} = 'Source cell 2';
    $test_slice->{'953'} = 'Source cell 3';
    $test_slice->{'960'} = 'Cell with no links';
    Zigzag::link_make('951', '950', '+d.1');
    Zigzag::link_make('952', '950', '+d.2');
    Zigzag::link_make('953', '950', '+d.clone');

    plan tests => 4;
    my @links_to_950 = sort(Zigzag::get_links_to('950'));
    is(scalar @links_to_950, 3, '(950): returns 3 links (using standard dimensions)');
    is_deeply(\@links_to_950, [sort ('951+d.1', '952+d.2', '953+d.clone')], '(950): lists correct incoming links (standard dimensions)');

    my @links_to_960 = Zigzag::get_links_to('960');
    is(scalar @links_to_960, 0, '(960): returns 0 links for cell with no connections');
    is_deeply(\@links_to_960, [], '(960): returns empty list for cell with no connections');
};

subtest 'wordbreak' => sub {
    plan tests => 4;
    is( Zigzag::wordbreak("short string", 20), "short string", "string shorter than limit");
    is( Zigzag::wordbreak("long string with spaces", 10), "long", "breaks at space before limit");
    is( Zigzag::wordbreak("longstringnospaces", 10), "longstring", "no space, breaks at limit");
    is( Zigzag::wordbreak("string with newline\nrest of string", 25), "string with newline ", "breaks at newline and adds space");
};

subtest 'dimension_is_essential' => sub {
    plan tests => 10;
    ok( Zigzag::dimension_is_essential('d.1'), "d.1 is essential");
    ok( Zigzag::dimension_is_essential('+d.2'), "+d.2 is essential");
    ok( Zigzag::dimension_is_essential('-d.cursor'), "-d.cursor is essential");
    ok( Zigzag::dimension_is_essential('d.clone'), "d.clone is essential");
    ok( Zigzag::dimension_is_essential('d.inside'), "d.inside is essential");
    ok( Zigzag::dimension_is_essential('d.contents'), "d.contents is essential");
    ok( Zigzag::dimension_is_essential('d.mark'), "d.mark is essential");
    ok( !Zigzag::dimension_is_essential('d.foo'), "d.foo is not essential");
    ok( !Zigzag::dimension_is_essential('+d.bar'), "+d.bar is not essential");
    ok( !Zigzag::dimension_is_essential('d.12'), "d.12 is not essential");
};

subtest 'dimension_rename' => sub {
    # Ensure $Zigzag::Hash_Ref[0] is a fresh, empty hash for this test
    $test_slice = $Zigzag::Hash_Ref[0] = {};

    # Populate with initial data
    $test_slice->{'1'} = 'd.oldname';       # Dimension cell to be renamed
    $test_slice->{'10'} = 'Cursor home';    # CURSOR_HOME
    Zigzag::link_make('10', '1', '+d.1');  # Link CURSOR_HOME to dimension cell

    $test_slice->{'100'} = 'Cell 100';
    $test_slice->{'101'} = 'Cell 101';
    Zigzag::link_make('100', '101', '+d.oldname'); # Link using the old dimension name

    $test_slice->{'n'} = 200;               # Next cell ID counter

    # Initial setup for dimension_find to see 'd.oldname' in cell '1'
    # CURSOR_HOME ('10') -> +d.1 -> '1'. '1' is the start of d.2 chain for dimensions.
    # No other dimensions initially, so '1+d.2' and '1-d.2' can be self-referential or point to '1'
    # to signify it's the only one in the list connected to CURSOR_HOME's +d.1 path.

    plan tests => 14;

    # 1. Call dimension_rename
    Zigzag::dimension_rename('d.oldname', 'd.newname');

    # 2. Assert dimension cell content
    is($test_slice->{'1'}, 'd.newname', 'Dimension cell 1 content updated to d.newname');

    # 3. Verify hash key renaming and value preservation (EXPECTING KEYS TO BE RENAMED NOW)
    ok(!exists $test_slice->{'100+d.oldname'}, 'Old key 100+d.oldname removed after rename');
    ok(exists $test_slice->{'100+d.newname'}, 'New key 100+d.newname exists after rename');
    is($test_slice->{'100+d.newname'}, '101', 'Value for renamed key 100+d.newname is preserved');

    ok(!exists $test_slice->{'101-d.oldname'}, 'Old key 101-d.oldname removed after rename');
    ok(exists $test_slice->{'101-d.newname'}, 'New key 101-d.newname exists after rename');
    is($test_slice->{'101-d.newname'}, '100', 'Value for renamed key 101-d.newname is preserved');

    # 4. Test renaming a non-existent dimension
    Zigzag::dimension_rename('d.nonexistent', 'd.anothername');
    is(Zigzag::dimension_find('d.anothername'), 0, 'dimension_find for d.anothername returns 0 (false) after trying to rename non-existent');
    # Keys successfully renamed earlier should still exist
    ok(exists $test_slice->{'100+d.newname'}, 'Key 100+d.newname still exists after attempting to rename non-existent dimension');
    ok(!exists $test_slice->{'100+d.nonexistent'}, 'Key 100+d.nonexistent was not created');

    # 5. Test renaming to an existing dimension name
    # Create 'd.existingname' in cell '2' and link it into the dimension list after '1'
    $test_slice->{'2'} = 'd.existingname';
    # Proper linking for dimension_find: '1' is head of list from CURSOR_HOME+d.1
    # '2' is next in d.2 chain from '1'.
    Zigzag::link_make('1', '2', '+d.2');

    Zigzag::dimension_rename('d.newname', 'd.existingname'); # This call should do nothing as d.existingname already exists
    
    is(Zigzag::dimension_find('d.newname'), '1', 'dimension_find for d.newname still returns cell 1');
    is($test_slice->{'1'}, 'd.newname', 'Dimension cell 1 content remains d.newname after trying to rename to existing');
    ok(exists $test_slice->{'100+d.newname'}, 'Key 100+d.newname still exists after attempting to rename to existing dimension');
    ok(!exists $test_slice->{'100+d.existingname'}, 'Key 100+d.existingname was not created from 100+d.newname');
};

subtest 'cell_new' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 14;

    # Test Case 1: Create a new cell with default content.
    my $new_cell_id_default = Zigzag::cell_new();
    like($new_cell_id_default, qr/^\d+$/, "1.1: New cell ID ($new_cell_id_default) is a number");
    ok(exists $test_slice->{$new_cell_id_default}, "1.2: New cell ($new_cell_id_default) exists in hash");
    is($test_slice->{$new_cell_id_default}, "$new_cell_id_default", "1.3: New cell ($new_cell_id_default) content is its own ID by default");

    # Test Case 2: Create a new cell with specified content.
    my $custom_content = "custom content for cell_new";
    my $new_cell_id_content = Zigzag::cell_new($custom_content);
    like($new_cell_id_content, qr/^\d+$/, "2.1: New cell ID with content ($new_cell_id_content) is a number");
    is($test_slice->{$new_cell_id_content}, $custom_content, "2.2: New cell ($new_cell_id_content) has specified content");

    # Test Case 3: Create multiple new cells to ensure unique IDs.
    # 'n' is initialized by initial_geometry() and managed by cell_new()
    my $next_id_before_multi = $test_slice->{"n"};
    my $cell_id1_multi = Zigzag::cell_new();
    my $cell_id2_multi = Zigzag::cell_new();
    isnt($cell_id1_multi, $cell_id2_multi, "3.1: Multiple new cell IDs ($cell_id1_multi, $cell_id2_multi) are different");
    is($cell_id1_multi, $next_id_before_multi, "3.2: First new cell ID ($cell_id1_multi) is as expected ($next_id_before_multi)");
    is($cell_id2_multi, $next_id_before_multi + 1, "3.3: Second new cell ID ($cell_id2_multi) is incremented from first");
    is($test_slice->{"n"}, $next_id_before_multi + 2, "3.4: Global 'n' is updated correctly after multiple creations");

    # Test Case 4: Recycle a cell.
    my $DELETE_HOME = 99; # Defined in Zigzag.pm
    my $recyclable_cell_id = '3010'; # Arbitrary high number for recycle test
    $test_slice->{$recyclable_cell_id} = "Recyclable";

    # Put $recyclable_cell_id onto the recycle pile (making it the only item)
    $test_slice->{"${DELETE_HOME}-d.2"} = $recyclable_cell_id; # DELETE_HOME points to it
    $test_slice->{"${recyclable_cell_id}+d.2"} = $DELETE_HOME; # It points back to DELETE_HOME
    $test_slice->{"${recyclable_cell_id}-d.2"} = $DELETE_HOME; # It's the only one, so it's newest and oldest relative to DELETE_HOME

    my $recycled_content = "New content for recycled cell";
    my $recycled_cell_id_actual = Zigzag::cell_new($recycled_content);

    is($recycled_cell_id_actual, $recyclable_cell_id, "4.1: Recycled cell ID ($recycled_cell_id_actual) is the expected one ($recyclable_cell_id)");
    is($test_slice->{$recycled_cell_id_actual}, $recycled_content, "4.2: Recycled cell has new content");
    is($test_slice->{"${DELETE_HOME}-d.2"}, $DELETE_HOME, "4.3: DELETE_HOME -d.2 link updated (points to self as pile is empty)");
    is($test_slice->{"${recycled_cell_id_actual}+d.2"}, undef, "4.4: Recycled cell's +d.2 link is removed");
    is($test_slice->{"${recycled_cell_id_actual}-d.2"}, undef, "4.5: Recycled cell's -d.2 link is removed");
};

subtest 'cell_excise' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 17;

    my $dim = 'd.testex'; # Common dimension for most tests
    my $cell_A = '4000'; my $cell_B = '4001'; my $cell_C = '4002';
    my $cell_S = '4003'; # Standalone
    my $cell_circA = '4004'; my $cell_circB = '4005'; my $dim_circ = 'd.testex_circ';

    # Pre-define cells to ensure they exist for tests if not linked
    $test_slice->{$cell_A} = 'Cell A'; $test_slice->{$cell_B} = 'Cell B'; $test_slice->{$cell_C} = 'Cell C';
    $test_slice->{$cell_S} = 'Standalone Cell S';
    $test_slice->{$cell_circA} = 'Circular Cell A'; $test_slice->{$cell_circB} = 'Circular Cell B';

    # Test Case 1: Excise cell from middle of a 3-cell chain.
    # A <--(d.testex)--> B <--(d.testex)--> C
    Zigzag::link_make($cell_A, $cell_B, "+$dim");
    Zigzag::link_make($cell_B, $cell_C, "+$dim");
    Zigzag::cell_excise($cell_B, $dim);
    is($test_slice->{"$cell_B+$dim"}, undef, "1.1: Excised cell B+$dim is undef");
    is($test_slice->{"$cell_B-$dim"}, undef, "1.2: Excised cell B-$dim is undef");
    is($test_slice->{"$cell_A+$dim"}, $cell_C, "1.3: Former prev A+$dim links to former next C");
    is($test_slice->{"$cell_C-$dim"}, $cell_A, "1.4: Former next C-$dim links to former prev A");
    Zigzag::link_break($cell_A, "+$dim");    # Cleanup for Test 1

    # Test Case 2: Excise cell from beginning of a chain (has only +dim neighbor).
    # B <--(d.testex)--> C
    Zigzag::link_make($cell_B, $cell_C, "+$dim");
    Zigzag::cell_excise($cell_B, $dim);
    is($test_slice->{"$cell_B+$dim"}, undef, "2.1: Excised cell B+$dim (start of chain) is undef");
    is($test_slice->{"$cell_B-$dim"}, undef, "2.2: Excised cell B-$dim (start of chain) is undef");
    is($test_slice->{"$cell_C-$dim"}, undef, "2.3: Former next C-$dim (start of chain) is undef");

    # Test Case 3: Excise cell from end of a chain (has only -dim neighbor).
    # A <--(d.testex)--> B
    Zigzag::link_make($cell_A, $cell_B, "+$dim");
    Zigzag::cell_excise($cell_B, $dim);
    is($test_slice->{"$cell_B+$dim"}, undef, "3.1: Excised cell B+$dim (end of chain) is undef");
    is($test_slice->{"$cell_B-$dim"}, undef, "3.2: Excised cell B-$dim (end of chain) is undef");
    is($test_slice->{"$cell_A+$dim"}, undef, "3.3: Former prev A+$dim (end of chain) is undef");

    # Test Case 4: Excise standalone cell.
    # Cell S ('4003') has no links in $dim.
    Zigzag::cell_excise($cell_S, $dim); # Should not die
    is($test_slice->{"$cell_S+$dim"}, undef, "4.1: Standalone cell S+$dim remains undef");
    is($test_slice->{"$cell_S-$dim"}, undef, "4.2: Standalone cell S-$dim remains undef");
    # No specific link cleanup needed as it was standalone in $dim

    # Test Case 5: Excise cell from a 2-cell circular list.
    # circA <--(dim_circ)--> circB <--(dim_circ)--> circA
    Zigzag::link_make($cell_circA, $cell_circB, "+$dim_circ");
    Zigzag::link_make($cell_circB, $cell_circA, "+$dim_circ"); # Complete the circle
    Zigzag::cell_excise($cell_circA, $dim_circ);
    is($test_slice->{"$cell_circA+$dim_circ"}, undef, "5.1: Excised cell circA+$dim_circ is undef");
    is($test_slice->{"$cell_circA-$dim_circ"}, undef, "5.2: Excised cell circA-$dim_circ is undef");
    is($test_slice->{"$cell_circB+$dim_circ"}, $cell_circB, "5.3: Neighbor circB+$dim_circ is self (was circA)");
    is($test_slice->{"$cell_circB-$dim_circ"}, $cell_circB, "5.4: Neighbor circB-$dim_circ is self (was circA)");

    # Test Case 6: Error - cell does not exist.
    my $non_existent_cell = 'nonexistent_cell_excise';
    eval { Zigzag::cell_excise($non_existent_cell, $dim); };
    like($@, qr/No cell $non_existent_cell/, "6.1: Die when cell does not exist");
};

subtest 'link_make' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 7; # 2 for success, 5 for die cases

    # Test 1: Successful link
    $test_slice->{'1000'} = 'Cell 1000 for link_make';
    $test_slice->{'1001'} = 'Cell 1001 for link_make';
    $test_slice->{'1002'} = 'Cell 1002 for link_make';
    Zigzag::link_make('1000', '1001', '+d.testlink');
    is($test_slice->{'1000+d.testlink'}, '1001', "link_make: 1000+d.testlink is 1001");
    is($test_slice->{'1001-d.testlink'}, '1000', "link_make: 1001-d.testlink is 1000");

    # Test 2: Error case: $cell1 does not exist
    eval { Zigzag::link_make('nonexistent1', '1002', '+d.testlink'); };
    like($@, qr/No cell nonexistent1/, "link_make: die when cell1 does not exist");

    # Test 3: Error case: $cell2 does not exist
    eval { Zigzag::link_make('1000', 'nonexistent2', '+d.testlink'); };
    like($@, qr/No cell nonexistent2/, "link_make: die when cell2 does not exist");

    # Test 4: Error case: Invalid direction
    eval { Zigzag::link_make('1000', '1002', 'd.invalid'); };
    like($@, qr/Invalid direction d.invalid/, "link_make: die on invalid direction");

    # Test 5: Error case: $cell1 already linked in $dir
    # Cells 1000 and 1001 are already linked from Test 1.
    $test_slice->{'1003'} = 'Cell 1003 for link_make';
    eval { Zigzag::link_make('1000', '1003', '+d.testlink'); }; # 1000 already has +d.testlink to 1001
    like($@, qr/1000 already linked/, "link_make: die when cell1 already linked");

    # Test 6: Error case: $cell2 already linked in reverse_sign($dir)
    # Per problem: Link '1002' ('X') and '1003' ('B') with '+d.testlink' ('+D').
    # This creates B-D = X. ('1003-d.testlink' = '1002')
    # Then attempt link_make('1004' ('A'), '1003' ('B'), '+d.testlink' ('+D')).
    # This should fail because '1003-d.testlink' (B-D) is already set.
    $test_slice->{'1002'} = 'Cell 1002 for link_make (X)'; # Renamed from original test plan for clarity
    $test_slice->{'1003'} = 'Cell 1003 for link_make (B/cell2)'; # Re-used 1003, content updated
    $test_slice->{'1004'} = 'Cell 1004 for link_make (A/cell1)';
    Zigzag::link_make('1002', '1003', '+d.testlink_t6'); # X to B with +D
    # Now 1003 is linked from 1002 via -d.testlink_t6 (1003-d.testlink_t6 = 1002)
    eval { Zigzag::link_make('1004', '1003', '+d.testlink_t6'); }; # A to B with +D
    like($@, qr/1003 already linked/, "link_make: die when cell2 already linked in reverse_sign(dir)");
};

subtest 'link_break' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 12; # 2x2 for success cases, 8 for die cases

    # Setup cells for link_break tests
    $test_slice->{'2000'} = 'Cell 2000 for link_break';
    $test_slice->{'2001'} = 'Cell 2001 for link_break';
    $test_slice->{'2002'} = 'Cell 2002 for link_break';
    $test_slice->{'2003'} = 'Cell 2003 for link_break';
    $test_slice->{'2004'} = 'Cell 2004 for link_break'; # For test 6
    $test_slice->{'2005'} = 'Cell 2005 for link_break'; # For test 7
    $test_slice->{'2006'} = 'Cell 2006 for link_break'; # For test 7
    $test_slice->{'2007'} = 'Cell 2007 for link_break'; # For test 7
    $test_slice->{'2008'} = 'Cell 2008 for link_break'; # For test 10

    # Test 1: Successful break (3 arguments)
    Zigzag::link_make('2000', '2001', '+d.testbreak_s3');
    Zigzag::link_break('2000', '2001', '+d.testbreak_s3');
    is($test_slice->{'2000+d.testbreak_s3'}, undef, "link_break(3 args): cell1 link is undef");
    is($test_slice->{'2001-d.testbreak_s3'}, undef, "link_break(3 args): cell2 link is undef");

    # Test 2: Successful break (2 arguments)
    Zigzag::link_make('2002', '2003', '+d.testbreak_s2');
    Zigzag::link_break('2002', '+d.testbreak_s2');
    is($test_slice->{'2002+d.testbreak_s2'}, undef, "link_break(2 args): cell1 link is undef");
    is($test_slice->{'2003-d.testbreak_s2'}, undef, "link_break(2 args): cell2 link is undef");

    # Test 3: Error case (3 args): $cell1 does not exist
    eval { Zigzag::link_break('nonexistent_lb1', '2001', '+d.testbreak_e1'); };
    like($@, qr/nonexistent_lb1 has no link in direction \+d.testbreak_e1/, "link_break(3 args): die when cell1 does not exist (actual msg check)");

    # Test 4: Error case (3 args): $cell2 does not exist
    Zigzag::link_make('2000', '2001', '+d.testbreak_e2'); # Re-link for this test
    eval { Zigzag::link_break('2000', 'nonexistent_lb2', '+d.testbreak_e2'); };
    like($@, qr/2000 is not linked to nonexistent_lb2 in direction \+d.testbreak_e2/, "link_break(3 args): die when cell2 does not exist (actual msg check)");
    Zigzag::link_break('2000', '+d.testbreak_e2'); # Clean up

    # Test 5: Error case (3 args): Invalid direction
    # Need to ensure cells are linked for this not to be caught by other checks first
    Zigzag::link_make('2000', '2001', '+d.testbreak_e3');
    eval { Zigzag::link_break('2000', '2001', 'd.invalid_lb'); };
    like($@, qr/Invalid direction d.invalid_lb/, "link_break(3 args): die on invalid direction");
    Zigzag::link_break('2000', '+d.testbreak_e3'); # Clean up

    # Test 6: Error case (3 args): $cell1 has no link in $dir
    eval { Zigzag::link_break('2004', '2000', '+d.testbreak_e4'); }; # 2004 is not linked
    like($@, qr/2004 has no link in direction \+d.testbreak_e4/, "link_break(3 args): die when cell1 has no link in dir");

    # Test 7: Error case (3 args): $cell1 not linked to $cell2 in $dir
    Zigzag::link_make('2005', '2006', '+d.testbreak_e5'); # 2005 linked to 2006
    # Cell 2007 is defined but 2005 is not linked to 2007
    eval { Zigzag::link_break('2005', '2007', '+d.testbreak_e5'); };
    like($@, qr/2005 is not linked to 2007 in direction \+d.testbreak_e5/, "link_break(3 args): die when cell1 not linked to cell2");
    Zigzag::link_break('2005', '+d.testbreak_e5'); # Clean up

    # Test 8: Error case (2 args): $cell1 does not exist
    eval { Zigzag::link_break('nonexistent_lb3', '+d.testbreak_e6'); };
    like($@, qr/nonexistent_lb3 has no link in direction \+d.testbreak_e6/, "link_break(2 args): die when cell1 does not exist (actual msg check)");

    # Test 9: Error case (2 args): Invalid direction
    # Need to ensure cell1 exists for this not to be caught by other checks
    eval { Zigzag::link_break('2000', 'd.invalid_lb2'); };
    like($@, qr/Invalid direction d.invalid_lb2/, "link_break(2 args): die on invalid direction");

    # Test 10: Error case (2 args): $cell1 has no link in $dir
    eval { Zigzag::link_break('2008', '+d.testbreak_e7'); }; # 2008 is not linked
    like($@, qr/2008 has no link in direction \+d.testbreak_e7/, "link_break(2 args): die when cell1 has no link in dir");
};

subtest 'dimension_find' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 9;

    # CURSOR_HOME is 10. dimension_home() should return the cell linked via +d.1 from CURSOR_HOME.
    # In initial_geometry, 10+d.1 -> 1. So, dimension_home() returns 1.
    # Cell 1 contains 'd.1'. Cell 2 contains 'd.2'. Cell 8 contains 'd.cursor'.

    # Test Case 1: Find existing dimensions.
    is( Zigzag::dimension_find('d.1'), '1', "dimension_find('d.1') returns cell '1'");
    is( Zigzag::dimension_find('d.cursor'), '8', "dimension_find('d.cursor') returns cell '8'");
    is( Zigzag::dimension_find('d.2'), '2', "dimension_find('d.2') returns cell '2'");

    # Test Case 2: Search for a non-existent dimension.
    is( Zigzag::dimension_find('d.nonexistent'), 0, "dimension_find('d.nonexistent') returns 0");
    is( Zigzag::dimension_find(''), 0, "dimension_find('') returns 0");

    # Test Case 3: Search with a modified/empty dimension list.
    my $CURSOR_HOME = 10; # As per Zigzag.pm and initial_geometry
    my $dim_home_link_key = "${CURSOR_HOME}+d.1";
    my $original_dim_home_link = $test_slice->{$dim_home_link_key};

    # Temporarily break the dimension list
    $test_slice->{$dim_home_link_key} = undef;
    is( Zigzag::dimension_find('d.1'), 0, "dimension_find('d.1') returns 0 when CURSOR_HOME+d.1 is undef");
    $test_slice->{$dim_home_link_key} = $original_dim_home_link; # Restore

    # Temporarily point CURSOR_HOME+d.1 to an isolated cell
    my $isolated_cell_id = '999';
    $test_slice->{$isolated_cell_id} = 'd.isolated_dim_test'; # Content for the isolated cell
    $test_slice->{$dim_home_link_key} = $isolated_cell_id; # Point CURSOR_HOME+d.1 to it

    # 'd.1' is no longer findable as the chain from dimension_home (now 999) doesn't contain it.
    is( Zigzag::dimension_find('d.1'), 0, "dimension_find('d.1') returns 0 when CURSOR_HOME+d.1 points to isolated cell '$isolated_cell_id'");
    # 'd.isolated_dim_test' should be findable because cell '999' (dimension_home) contains the searched name.
    # The +d.2 link is not strictly necessary if the first cell itself matches.
    is( Zigzag::dimension_find('d.isolated_dim_test'), $isolated_cell_id, "dimension_find('d.isolated_dim_test') returns '$isolated_cell_id' as cell '$isolated_cell_id' (dimension_home) contains the name");

    # Making '999' part of a d.2 list (even to itself) should still find it.
    $test_slice->{"${isolated_cell_id}+d.2"} = $isolated_cell_id;
    is( Zigzag::dimension_find('d.isolated_dim_test'), $isolated_cell_id, "dimension_find('d.isolated_dim_test') returns '$isolated_cell_id' after self-linking +d.2");
};

subtest 'cell_find' => sub {
    %$test_slice = Zigzag::initial_geometry(); # Fresh slice
    plan tests => 13;

    # Setup cells for testing
    $test_slice->{'1000'} = 'ContentA';
    $test_slice->{'1001'} = 'ContentB';
    $test_slice->{'1002'} = 'ContentC';
    $test_slice->{'1003'} = 'ContentA'; # Duplicate content

    # Link them: 1000 --(+d.testfind)--> 1001 --(+d.testfind)--> 1002
    Zigzag::link_make('1000', '1001', '+d.testfind');
    Zigzag::link_make('1001', '1002', '+d.testfind');

    # Circular list for another test: 2000 -> 2001 -> 2002 -> 2000
    $test_slice->{'2000'} = 'CircleA';
    $test_slice->{'2001'} = 'CircleB';
    $test_slice->{'2002'} = 'CircleC';
    Zigzag::link_make('2000', '2001', '+d.circlefind');
    Zigzag::link_make('2001', '2002', '+d.circlefind');
    Zigzag::link_make('2002', '2000', '+d.circlefind');

    # Test Case 1: Find existing cell content.
    is( Zigzag::cell_find('1000', '+d.testfind', 'ContentB'), '1001', "Find 'ContentB' starting from '1000'");
    is( Zigzag::cell_find('1000', '+d.testfind', 'ContentC'), '1002', "Find 'ContentC' starting from '1000'");

    # Test Case 2: Content at start cell.
    is( Zigzag::cell_find('1000', '+d.testfind', 'ContentA'), '1000', "Find 'ContentA' at start cell '1000'");
    is( Zigzag::cell_find('1001', '+d.testfind', 'ContentB'), '1001', "Find 'ContentB' at start cell '1001'");

    # Test Case 3: Content not found.
    is( Zigzag::cell_find('1000', '+d.testfind', 'ContentNonExistent'), 0, "Content 'NonExistent' not found");
    is( Zigzag::cell_find('1002', '+d.testfind', 'ContentA'), 0, "Content 'ContentA' not found starting from '1002' in +d.testfind (end of chain)");

    # Test Case 4: Search in a short/broken chain.
    $test_slice->{'1005'} = 'OnlyCell';
    is( Zigzag::cell_find('1005', '+d.testfind', 'OtherContent'), 0, "Search in unlinked cell for other content");
    is( Zigzag::cell_find('1005', '+d.testfind', 'OnlyCell'), '1005', "Search in unlinked cell for its own content");

    # Test Case 5: Search in a circular list.
    is( Zigzag::cell_find('2000', '+d.circlefind', 'CircleC'), '2002', "Find 'CircleC' in circular list");
    is( Zigzag::cell_find('2000', '+d.circlefind', 'CircleA'), '2000', "Find 'CircleA' (start) in circular list");
    is( Zigzag::cell_find('2000', '+d.circlefind', 'CircleNonExistent'), 0, "Not found in circular list");

    # Test Case 6: Invalid direction (expects die).
    eval { Zigzag::cell_find('1000', 'd.badformat', 'ContentA'); };
    like($@, qr/Invalid direction d\.badformat/, "Dies on invalid direction format 'd.badformat'");

    # Test Case 7: Start cell does not exist (expects 0, not die).
    # Based on cell_find implementation: (defined $cell) check for $cell = $start first.
    # If $start is 'nonexistent_cell', $Zigzag::Hash_Ref[0]{'nonexistent_cell'} is undef.
    # So, (defined cell_get($cell)) would be false. Loop condition `(not defined $cell)` might hit if cell_nbr returns undef.
    # The loop is `do { ... $cell = cell_nbr($cell, $dir); } until $found or (not defined $cell) or ($cell eq $start);`
    # If $start is 'nonexistent_cell', it's likely cell_get($cell) is undef, $found remains 0.
    # cell_nbr('nonexistent_cell', $dir) likely returns undef. So loop terminates.
    is( Zigzag::cell_find('nonexistent_cell_id', '+d.testfind', 'ContentA'), 0, "Search from non-existent cell returns 0");
};

subtest 'is_selected and is_active_selected' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 8;
    my $SELECT_HOME = 21; # From Zigzag.pm constants

    $test_slice->{'300'} = 'SelectableCell';
    $test_slice->{'301'} = 'OtherSelectionHead';

    # Test Case 1: Cell not in any selection.
    ok(!Zigzag::is_selected('300'), "Cell 300 is initially not selected");
    ok(!Zigzag::is_active_selected('300'), "Cell 300 is initially not active_selected");

    # Test Case 2: Cell in active selection.
    # Link '300' to SELECT_HOME (active selection head)
    $test_slice->{"${SELECT_HOME}+d.mark"} = '300'; $test_slice->{'300-d.mark'} = $SELECT_HOME;
    $test_slice->{'300+d.mark'} = $SELECT_HOME;    $test_slice->{"${SELECT_HOME}-d.mark"} = '300'; # Circular list for a single item

    ok(Zigzag::is_selected('300'), "Cell 300 is selected (part of active selection)");
    ok(Zigzag::is_active_selected('300'), "Cell 300 is active_selected");

    # Cleanup for Test Case 2
    Zigzag::link_break('300', '+d.mark');

    # Test Case 3: Cell in a non-active (saved) selection.
    # Create a new selection head '301' and link it into the selection list (making it non-active)
    # SELECT_HOME(+d.2) -> 301, 301(-d.2) -> SELECT_HOME
    # 301(+d.2) -> SELECT_HOME, SELECT_HOME(-d.2) -> 301 (circular list of selection heads)
    $test_slice->{"${SELECT_HOME}+d.2"} = '301';
    $test_slice->{'301-d.2'} = $SELECT_HOME;
    $test_slice->{'301+d.2'} = $SELECT_HOME; # For simplicity, make it a 2-item list with SELECT_HOME
    $test_slice->{"${SELECT_HOME}-d.2"} = '301';

    # Link '300' to this new selection head '301'
    $test_slice->{'301+d.mark'} = '300'; $test_slice->{'300-d.mark'} = '301';
    $test_slice->{'300+d.mark'} = '301'; $test_slice->{'301-d.mark'} = '300'; # Circular list for a single item

    ok(Zigzag::is_selected('300'), "Cell 300 is selected (part of non-active selection 301)");
    ok(!Zigzag::is_active_selected('300'), "Cell 300 is NOT active_selected (it's in saved selection 301)");

    # Test Case 4: SELECT_HOME itself (should not be considered selected by these functions).
    ok(!Zigzag::is_selected($SELECT_HOME), "SELECT_HOME ($SELECT_HOME) itself is not considered selected");
    ok(!Zigzag::is_active_selected($SELECT_HOME), "SELECT_HOME ($SELECT_HOME) itself is not considered active_selected");
};

subtest 'get_contained' => sub {
    %$test_slice = Zigzag::initial_geometry();
    plan tests => 8;

    # Define cells
    $test_slice->{'400'} = 'ContainerA';
    $test_slice->{'401'} = 'InsideB';
    $test_slice->{'402'} = 'ContentsC';
    $test_slice->{'403'} = 'InsideD_PeerToB';
    $test_slice->{'405'} = 'NestedContainerF_UnderC';
    $test_slice->{'406'} = 'InsideG_InF';
    $test_slice->{'407'} = 'StandaloneH';


    # Test Case 1: Single cell, no containment links.
    is_deeply([sort(Zigzag::get_contained('407'))], [sort ('407')], "TC1: get_contained on standalone cell '407' returns itself");

    # Test Case 2: Simple `+d.inside` link.
    # A('400') -> B('401') (inside)
    Zigzag::link_make('400', '401', '+d.inside');
    is_deeply([sort(Zigzag::get_contained('400'))], [sort ('400', '401')], "TC2: A('400') with B('401') +d.inside");

    # Test Case 3: `+d.inside` then `+d.contents`.
    # A('400') -> B('401') (inside), B('401') -> C('402') (contents)
    Zigzag::link_make('401', '402', '+d.contents');
    is_deeply([sort(Zigzag::get_contained('400'))], [sort ('400', '401', '402')], "TC3: A->B(+d.inside), B->C(+d.contents)");
    Zigzag::link_break('401', '+d.contents'); # Cleanup

    # Test Case 4: A contains B, and B contains D (both via `+d.inside`).
    Zigzag::link_make('401', '403', '+d.inside'); # B contains D
    is_deeply([sort(Zigzag::get_contained('400'))], [sort ('400', '401', '403')], "TC4: A->B(+d.inside), B->D(+d.inside)");
    Zigzag::link_break('401', '+d.inside'); # Cleanup

    # Test Case 5: Nested structure.
    # A('400') -> B('401') (+d.inside)
    # B('401') -> C('402') (+d.contents)
    # C('402') -> F('405') (+d.inside)
    # F('405') -> G('406') (+d.inside)
    Zigzag::link_make('401', '402', '+d.contents');
    Zigzag::link_make('402', '405', '+d.inside');
    Zigzag::link_make('405', '406', '+d.inside');
    is_deeply([sort(Zigzag::get_contained('400'))], [sort ('400', '401', '402', '405', '406')], "TC5: Nested A->B(i), B->C(c), C->F(i), F->G(i)");
    Zigzag::link_break('401', '+d.contents');
    Zigzag::link_break('402', '+d.inside');
    Zigzag::link_break('405', '+d.inside'); # Cleanup

    # Test Case 6: Circular `+d.inside` reference.
    # A ('400') -> B ('401') (inside), B ('401') -> A ('400') (inside)
    Zigzag::link_make('401', '400', '+d.inside'); # Circular link
    is_deeply([sort(Zigzag::get_contained('400'))], [sort ('400', '401')], "TC6: Circular +d.inside: A->B, B->A");
    delete $test_slice->{'401+d.inside'}; delete $test_slice->{'400-d.inside'}; # Cleanup

    # Test Case 7: Circular `+d.contents` reference.
    # A('400') -> B('401') (inside)
    # B('401') -> C('402') (contents), C('402') -> B('401') (contents)
    Zigzag::link_make('401', '402', '+d.contents');
    Zigzag::link_make('402', '401', '+d.contents'); # Circular link
    is_deeply([sort(Zigzag::get_contained('400'))], [sort ('400', '401', '402')], "TC7: Circular +d.contents: A->B(i), B->C(c), C->B(c)");

    # Test Case 8: Start cell does not exist.
    is_deeply([sort(Zigzag::get_contained('nonexistent_cell_gc'))], [sort ('nonexistent_cell_gc')], "TC8: get_contained on non-existent cell returns cell itself in list");
};

subtest 'dimension_home' => sub {
    plan tests => 1;
    %$test_slice = Zigzag::initial_geometry();

    is( Zigzag::dimension_home(), 1, "dimension_home() returns cell 1 (10+d.1 from initial_geometry)");
};

subtest 'cells_row' => sub {
    %$test_slice = Zigzag::initial_geometry();

    # Define cells for testing
    $test_slice->{'100'} = 'Cell 100 for cells_row';
    $test_slice->{'101'} = 'Cell 101 for cells_row';
    $test_slice->{'102'} = 'Cell 102 for cells_row';
    $test_slice->{'103'} = 'Cell 103 for cells_row (single)';

    my ($dim_linear, $dim_circular) = ('+d.testlinear', '+d.testcircular');

    # Linear chain: 100 -> 101 -> 102
    Zigzag::link_make('100', '101', $dim_linear);
    Zigzag::link_make('101', '102', $dim_linear);

    # Circular list: 200 -> 201 -> 202 -> 200
    $test_slice->{'200'} = 'Cell 200 for cells_row circular';
    $test_slice->{'201'} = 'Cell 201 for cells_row circular';
    $test_slice->{'202'} = 'Cell 202 for cells_row circular';
    Zigzag::link_make('200', '201', $dim_circular);
    Zigzag::link_make('201', '202', $dim_circular);
    Zigzag::link_make('202', '200', $dim_circular); # Completes the circle

    plan tests => 8;
    is_deeply( [sort { $a <=> $b } Zigzag::cells_row('100', $dim_linear)], [qw(100 101 102)], "Linear chain from start");
    is_deeply( [sort { $a <=> $b } Zigzag::cells_row('101', $dim_linear)], [qw(101 102)], "Linear chain from middle (broken chain)");
    is( scalar Zigzag::cells_row('100', $dim_linear), 3, "Scalar context: Linear chain count");

    is_deeply( [sort { $a <=> $b } Zigzag::cells_row('200', $dim_circular)], [qw(200 201 202)], "Circular list from start");
    is( scalar Zigzag::cells_row('200', $dim_circular), 3, "Scalar context: Circular list count");

    is_deeply( [Zigzag::cells_row('103', $dim_linear)], ['103'], "Single cell (no links in dim)");

    my @empty_row = Zigzag::cells_row('nonexistent_cell_cr', $dim_linear);
    is( scalar @empty_row, 0, "Non-existent starting cell returns empty list");

    is_deeply( [Zigzag::cells_row('100', '+d.otherdim_cr')], ['100'], "Cell with no links in specified other dimension");
};

subtest 'cell_insert' => sub {
    my ($dim, $rev_dim) = ('+d.testinsert', '-d.testinsert');

    # Define cell IDs at a scope visible to all test sections
    my ($cellA, $cellB, $cellC, $cellD, $cellE) = '5000' .. '5004';

    plan tests => 11;

    subtest 'Insert B between A and C (A - C  =>  A - B - C)' => sub {
        plan tests => 4;
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci'; $test_slice->{$cellC} = 'CellC_ci';
        Zigzag::link_make($cellA, $cellC, $dim);
        Zigzag::cell_insert($cellB, $cellA, $dim);
        is(Zigzag::cell_nbr($cellA, $dim), $cellB, "T1.1: A links to B in $dim");
        is(Zigzag::cell_nbr($cellB, $rev_dim), $cellA, "T1.2: B links back to A in $rev_dim");
        is(Zigzag::cell_nbr($cellB, $dim), $cellC, "T1.3: B links to C in $dim");
        is(Zigzag::cell_nbr($cellC, $rev_dim), $cellB, "T1.4: C links back to B in $rev_dim");
    };

    subtest 'Insert B at the end of A (A  =>  A - B)' => sub {
        plan tests => 3;
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci';
        Zigzag::cell_insert($cellB, $cellA, $dim);
        is(Zigzag::cell_nbr($cellA, $dim), $cellB, "T2.1: A links to B in $dim");
        is(Zigzag::cell_nbr($cellB, $rev_dim), $cellA, "T2.2: B links back to A in $rev_dim");
        is(Zigzag::cell_nbr($cellB, $dim), undef, "T2.3: B has no link in $dim (end of chain)");
    };

    subtest 'Insert B at the beginning of A (A => B - A)' => sub {
        plan tests => 3;
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci';
        Zigzag::cell_insert($cellB, $cellA, $rev_dim); # Insert B "before" A
        is(Zigzag::cell_nbr($cellA, $rev_dim), $cellB, "T3.1: A links to B in $rev_dim");
        is(Zigzag::cell_nbr($cellB, $dim), $cellA, "T3.2: B links back to A in $dim");
        is(Zigzag::cell_nbr($cellB, $rev_dim), undef, "T3.3: B has no link in $rev_dim (start of chain)");
    };

    subtest 'Error: cell1 (to insert, B) already linked in reverse_sign(dir)' => sub {
        plan tests => 3;
        # Condition: defined(cell_nbr($cell1, reverse_sign($dir)))
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci'; $test_slice->{$cellC} = 'CellC_ci';
        Zigzag::link_make($cellB, $cellC, $rev_dim); # B is already linked to C in -dim (B <- C)
        eval { Zigzag::cell_insert($cellB, $cellA, $dim); }; # Try to insert B after A in +dim
        like($@, qr/\Q$cellB $dim $cellA\E/, "T4.1: Dies if cell1 already linked in rev_dim (user_error 2)");
        is(Zigzag::cell_nbr($cellB, $rev_dim), $cellC, "T4.2: B's original link to C remains");
        is(Zigzag::cell_nbr($cellA, $dim), undef, "T4.3: A remains unlinked to B");
    };

    subtest 'Error: cell1 (B) linked in dir, cell2 (A) also linked in dir (to C)' => sub {
        plan tests => 3;
        # Condition: defined(cell_nbr($cell1, $dir)) && defined($cell3) where $cell3 = cell_nbr($cell2, $dir)
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci'; $test_slice->{$cellC} = 'CellC_ci'; $test_slice->{$cellD} = 'CellD_ci';
        Zigzag::link_make($cellA, $cellC, $dim); # A -> C
        Zigzag::link_make($cellB, $cellD, $dim); # B -> D
        eval { Zigzag::cell_insert($cellB, $cellA, $dim); };
        like($@, qr/\Q$cellB $dim $cellA\E/, "T5.1: Dies if cell1 and cell2 both have outgoing links in dir (user_error 2)");
        is(Zigzag::cell_nbr($cellA, $dim), $cellC, "T5.2: A's link to C remains");
        is(Zigzag::cell_nbr($cellB, $dim), $cellD, "T5.3: B's link to D remains");
    };

    subtest 'Error: cell1 (cell to insert) does not exist' => sub {
        plan tests => 1;
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci';
        eval { Zigzag::cell_insert('nonexistent_ci1', $cellA, $dim); };
        like($@, qr/No cell nonexistent_ci1/, "T6.1: Dies if cell1 does not exist");
    };

    subtest 'Error: cell2 (target cell) does not exist' => sub {
        plan tests => 1;
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellB} = 'CellB_ci';
        eval { Zigzag::cell_insert($cellB, 'nonexistent_ci2', $dim); };
        like($@, qr/No cell nonexistent_ci2/, "T7.1: Dies if cell2 does not exist");
    };

    subtest 'Error: Invalid direction' => sub {
        plan tests => 1;
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci';
        eval { Zigzag::cell_insert($cellB, $cellA, 'invaliddir'); };
        like($@, qr/Invalid direction invaliddir/, "T8.1: Dies on invalid direction");
    };

    subtest 'Insert C between A and B, where A and B are already linked (A-B => A-C-B)' => sub {
        plan tests => 4;
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci'; $test_slice->{$cellC} = 'CellC_ci';
        Zigzag::link_make($cellA, $cellB, $dim); # A -> B
        Zigzag::cell_insert($cellC, $cellA, $dim); # Insert C after A
        is(Zigzag::cell_nbr($cellA, $dim), $cellC, "T9.1: A links to C");
        is(Zigzag::cell_nbr($cellC, $rev_dim), $cellA, "T9.2: C links back to A");
        is(Zigzag::cell_nbr($cellC, $dim), $cellB, "T9.3: C links to B");
        is(Zigzag::cell_nbr($cellB, $rev_dim), $cellC, "T9.4: B links back to C");
    };

    subtest 'Error: cell1 linked in dir AND cell2 linked in dir (variation)' => sub {
        plan tests => 3;
        # (defined(cell_nbr($cell1, $dir)) && defined($cell3))
        # $cell1=B, $cell2=A, $dir=(+), $cell3=cell_nbr(A, +)
        # A -> D, B -> E. Insert B after A.
        # cell_nbr(B, +) is E (defined). cell_nbr(A, +) is D (defined as $cell3). This is an error condition.
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci'; $test_slice->{$cellD} = 'CellD_ci'; $test_slice->{$cellE} = 'CellE_ci';
        Zigzag::link_make($cellA, $cellD, $dim); # A -> D
        Zigzag::link_make($cellB, $cellE, $dim); # B -> E
        eval { Zigzag::cell_insert($cellB, $cellA, $dim); };
        like($@, qr/\Q$cellB $dim $cellA\E/, "T10.1: Dies if cell1 is linked in dir and cell2 is linked in dir (user_error 2 variation)");
        is(Zigzag::cell_nbr($cellA, $dim), $cellD, "T10.2: A still links to D");
        is(Zigzag::cell_nbr($cellB, $dim), $cellE, "T10.3: B still links to E");
    };

    subtest 'Error: cell1 linked in reverse_sign(dir) (variation)' => sub {
        plan tests => 4;
        # defined(cell_nbr($cell1, reverse_sign($dir)))
        # $cell1=B, $cell2=A, $dir=(+), rev_dir=(-)
        # E -> B (so B rev_dir E). Insert B after A.
        # cell_nbr(B, -) is E (defined). This is an error condition.
        %$test_slice = Zigzag::initial_geometry();
        $test_slice->{$cellA} = 'CellA_ci'; $test_slice->{$cellB} = 'CellB_ci'; $test_slice->{$cellE} = 'CellE_ci';
        Zigzag::link_make($cellE, $cellB, $dim); # E -> B, so B is linked from E ($cellB$rev_dim is $cellE)
        eval { Zigzag::cell_insert($cellB, $cellA, $dim); };
        like($@, qr/\Q$cellB $dim $cellA\E/, "T11.1: Dies if cell1 is linked in rev_dir (user_error 2 variation)");
        is(Zigzag::cell_nbr($cellE, $dim), $cellB, "T11.2: E still links to B");
        is(Zigzag::cell_nbr($cellB, $rev_dim), $cellE, "T11.3: B still links from E");
        is(Zigzag::cell_nbr($cellA, $dim), undef, "T11.4: A remains unlinked to B");
    };
};

subtest 'view_reset' => sub {
    %$test_slice = Zigzag::initial_geometry();

    local *main::display_dirty = sub { diag("display_dirty called for view_reset"); };

    plan tests => 7;

    # Setup: Get cursor 0 and its dimension-holding cells
    my $cursor0 = Zigzag::get_cursor(0); # Cell 11
    my $dim_cell_x = Zigzag::cell_nbr($cursor0, "+d.1"); # Cell 12, holds X-axis view setting
    my $dim_cell_y = Zigzag::cell_nbr($dim_cell_x, "+d.1"); # Cell 13, holds Y-axis view setting
    my $dim_cell_z = Zigzag::cell_nbr($dim_cell_y, "+d.1"); # Cell 14, holds Z-axis view setting

    # Pre-check initial state from initial_geometry for cursor 0
    is(Zigzag::cell_get($dim_cell_x), "+d.1", "Initial state of cursor 0 X-dim is +d.1");
    is(Zigzag::cell_get($dim_cell_y), "+d.2", "Initial state of cursor 0 Y-dim is +d.2");
    is(Zigzag::cell_get($dim_cell_z), "+d.3", "Initial state of cursor 0 Z-dim is +d.3");

    # Test 1: Modify dimensions, then reset
    Zigzag::cell_set($dim_cell_x, "+d.cursor"); # Change to something non-default
    Zigzag::cell_set($dim_cell_y, "+d.clone");
    Zigzag::cell_set($dim_cell_z, "+d.mark");

    Zigzag::view_reset(0); # Reset cursor 0

    is(Zigzag::cell_get($dim_cell_x), "+d.1", "After view_reset(0), X-dim is reset to +d.1");
    is(Zigzag::cell_get($dim_cell_y), "+d.2", "After view_reset(0), Y-dim is reset to +d.2");
    is(Zigzag::cell_get($dim_cell_z), "+d.3", "After view_reset(0), Z-dim is reset to +d.3");

    # Test 2: Reset again (should remain default)
    Zigzag::view_reset(0); # Call reset again
    is(Zigzag::cell_get($dim_cell_x), "+d.1", "After second view_reset(0), X-dim is still +d.1");
    # Y and Z dimensions would also remain +d.2 and +d.3 respectively.
};
