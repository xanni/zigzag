use strict;
use warnings;
use lib '.'; # To find Zigzag.pm when run from the project directory
use Test::More tests => 66;

# Ensure the Zigzag module loads
BEGIN { use_ok('Zigzag'); }

# Setup data for all tests in slice 0
# Note: is_essential tests do not require data setup in @Zigzag::Hash_Ref
# as they rely on constants defined in Zigzag.pm (CURSOR_HOME, etc.)
# and direct comparison with cell IDs.
@Zigzag::Hash_Ref = ({}); 
my $test_slice = $Zigzag::Hash_Ref[0];
%{$test_slice} = Zigzag::initial_geometry(); # Load initial geometry

# --- Setup for is_cursor tests ---
# These will overwrite/add to initial_geometry for specific test needs
$test_slice->{'100'} = 'Cell 100 (cursor)';
$test_slice->{'101'} = 'Cell 101 (target for cursor link)';
$test_slice->{'102'} = 'Cell 102 (not a cursor)';
$test_slice->{'100+d.cursor'} = '101'; $test_slice->{'101-d.cursor'} = '100';

# --- Setup for get_accursed tests ---
# get_cursor(0) should return cell 11 (CURSOR_HOME +d.2 from initial_geometry)
# We will make cell 111 the accursed cell for cursor 0 (cell 11)
$test_slice->{'111'} = 'Cell 111 (accursed for cursor 0/cell 11)';
$test_slice->{'11-d.cursor'} = '111'; $test_slice->{'111+d.cursor'} = '11';

# --- Setup for is_clone tests ---
$test_slice->{'200'} = 'Cell 200 (clone via -d.clone)';
$test_slice->{'299'} = 'Helper cell for 200-d.clone link'; 
$test_slice->{'200-d.clone'} = '299'; $test_slice->{'299+d.clone'} = '200'; 

$test_slice->{'201'} = 'Cell 201 (clone via +d.clone)';
$test_slice->{'298'} = 'Helper cell for 201+d.clone link'; 
$test_slice->{'201+d.clone'} = '298'; $test_slice->{'298-d.clone'} = '201';

$test_slice->{'202'} = 'Cell 202 (not a clone)';

# --- Setup for get_active_selection and get_selection tests ---
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

# --- Test reverse_sign ---
is( Zigzag::reverse_sign('+d.1'), '-d.1', 'reverse_sign: positive to negative');
is( Zigzag::reverse_sign('-d.test'), '+d.test', 'reverse_sign: negative to positive');

# --- Test is_cursor ---
ok( Zigzag::is_cursor('100'), 'is_cursor: cell 100 is a cursor (returns 1)');
ok( !Zigzag::is_cursor('102'), 'is_cursor: cell 102 is not a cursor (returns an empty string)');

# --- Test is_clone ---
ok( Zigzag::is_clone('200'), 'is_clone: cell 200 is a clone (returns 1)');
ok( Zigzag::is_clone('201'), 'is_clone: cell 201 is a clone (via +d.clone)');
ok( !Zigzag::is_clone('202'), 'is_clone: cell 202 is not a clone (returns an empty string)');

# Test is_essential
# Essential cell IDs are 0, $CURSOR_HOME (10), $SELECT_HOME (21), $DELETE_HOME (99)
# These tests rely on initial_geometry
ok( Zigzag::is_essential('0'), 'is_essential: cell 0 is essential');
ok( Zigzag::is_essential('10'), 'is_essential: cell 10 (CURSOR_HOME) is essential');
ok( Zigzag::is_essential('21'), 'is_essential: cell 21 (SELECT_HOME) is essential');
ok( Zigzag::is_essential('99'), 'is_essential: cell 99 (DELETE_HOME) is essential');
ok( !Zigzag::is_essential('50'), 'is_essential: cell 50 is not essential'); # Test with a non-essential number

# --- Test get_accursed ---
is( Zigzag::get_accursed(0), '111', 'get_accursed(0): returns cell 111 (accursed for cursor 0/cell 11)');

# --- Test get_active_selection ---
is_deeply( [Zigzag::get_active_selection()], ['400', '401', $SELECT_HOME], 'get_active_selection: returns cells 400, 401, and 21');

# --- Test get_selection ---
is_deeply( [Zigzag::get_selection(1)], ['402', '22'], 'get_selection(1): returns cells 402 and 22');

# --- Test get_which_selection ---
is( Zigzag::get_which_selection('400'), '401', 'get_which_selection(400): cell in active selection returns 401');
is( Zigzag::get_which_selection('402'), '22', 'get_which_selection(402): cell in secondary selection returns 22');
is( Zigzag::get_which_selection('102'), undef, 'get_which_selection(102): cell not in selection returns undef');

# --- Setup for get_lastcell tests ---
# Linear chain: 500 <-> 501 <-> 502 in d.testchain
$test_slice->{'500'} = 'Cell 500 (start of linear chain)';
$test_slice->{'501'} = 'Cell 501 (middle of linear chain)';
$test_slice->{'502'} = 'Cell 502 (end of linear chain)';
$test_slice->{'500+d.testchain'} = '501'; $test_slice->{'501-d.testchain'} = '500';
$test_slice->{'501+d.testchain'} = '502'; $test_slice->{'502-d.testchain'} = '501';

# Circular list: 600 <-> 601 <-> 602 <-> 600 in d.testcircle
$test_slice->{'600'} = 'Cell 600 (part of circular list)';
$test_slice->{'601'} = 'Cell 601 (part of circular list)';
$test_slice->{'602'} = 'Cell 602 (part of circular list)';
$test_slice->{'600+d.testcircle'} = '601'; $test_slice->{'601-d.testcircle'} = '600';
$test_slice->{'601+d.testcircle'} = '602'; $test_slice->{'602-d.testcircle'} = '601';
$test_slice->{'602+d.testcircle'} = '600'; $test_slice->{'600-d.testcircle'} = '602';

# --- Setup for get_distance tests ---
$test_slice->{'700'} = 'Cell 700 for get_distance';
$test_slice->{'701'} = 'Cell 701 for get_distance';
$test_slice->{'702'} = 'Cell 702 for get_distance';
$test_slice->{'705'} = 'Cell 705 for get_distance (isolated)';
# Chain: 700 <-> 701 <-> 702 in +d.testdist
$test_slice->{'700+d.testdist'} = '701'; $test_slice->{'701-d.testdist'} = '700';
$test_slice->{'701+d.testdist'} = '702'; $test_slice->{'702-d.testdist'} = '701';

# --- Setup for get_outline_parent tests ---
$test_slice->{'800'} = 'Cell 800 (child for outline parent)';
$test_slice->{'801'} = 'Cell 801 (parent for outline parent)';
$test_slice->{'802'} = 'Cell 802 (intermediate for 800-d.2)';
$test_slice->{'803'} = 'Cell 803 (unrelated for outline parent)'; # Not used by links, just defined

# Case 1: 800 has parent 801 via 802
$test_slice->{'800-d.2'} = '802'; $test_slice->{'802+d.2'} = '800';
$test_slice->{'802-d.1'} = '801'; $test_slice->{'801+d.1'} = '802';

# Case 2: 801 is its own "outline parent" (no -d.2 path to another -d.1)
$test_slice->{'801-d.2'} = '801'; $test_slice->{'801+d.2'} = '801'; # Loop on itself in -d.2

# Case 3: 810 has no outline parent (circular -d.2 chain without -d.1)
$test_slice->{'810'} = 'Cell 810 (no outline parent)';
$test_slice->{'811'} = 'Cell 811 (part of 810s -d.2 loop)';
$test_slice->{'810-d.2'} = '811'; $test_slice->{'811+d.2'} = '810';
$test_slice->{'811-d.2'} = '810'; $test_slice->{'810+d.2'} = '811';

# --- Setup for get_links_to tests ---
# Define target and source cells
$test_slice->{'950'} = 'Target cell for links';
$test_slice->{'951'} = 'Source cell 1';
$test_slice->{'952'} = 'Source cell 2';
$test_slice->{'953'} = 'Source cell 3';
$test_slice->{'960'} = 'Cell with no links';
$test_slice->{'951+d.1'} = '950'; $test_slice->{'950-d.1'} = '951';
$test_slice->{'952+d.2'} = '950'; $test_slice->{'950-d.2'} = '952';
$test_slice->{'953+d.clone'} = '950'; $test_slice->{'950-d.clone'} = '953';

# --- Setup for get_cell_contents tests ---
$test_slice->{'850'} = 'Direct content for 850';
$test_slice->{'851'} = 'Cell 851 (clone of 852)'; # This content is just a note
$test_slice->{'852'} = 'Content from original cell 852';
$test_slice->{'851-d.clone'} = '852'; $test_slice->{'852+d.clone'} = '851';

$test_slice->{'853'} = 'Cell 853 (clone of 854)'; # This content is just a note
$test_slice->{'854'} = 'Content from original cell 854';
$test_slice->{'853+d.clone'} = '854'; $test_slice->{'854-d.clone'} = '853';

$test_slice->{'855'} = '[10+20]'; # Special ZZMail-like content

# --- Setup for get_cursor tests ---
# initial_geometry provides cursor 0 (11) and cursor 1 (16)
# $CURSOR_HOME (10) -> 11 (cursor 0) -> 16 (cursor 1)
$test_slice->{'900'} = 'Test Cursor 2';
$test_slice->{'16+d.2'} = '900'; # Link from cursor 1 (cell 16) to cursor 2 (cell 900)
$test_slice->{'900-d.2'} = '16'; # Bidirectional link
# Cell 900 has no '+d.2' link, marking the end of the explicit cursor chain for testing die condition

# --- Test get_lastcell ---
# Linear chain tests
is( Zigzag::get_lastcell('500', '+d.testchain'), '502', 'get_lastcell (linear +): start 500, end 502');
is( Zigzag::get_lastcell('502', '-d.testchain'), '500', 'get_lastcell (linear -): start 502, end 500');
# Circular list tests
is( Zigzag::get_lastcell('600', '+d.testcircle'), '602', 'get_lastcell (circular +): start 600, returns cell before start (602)');
is( Zigzag::get_lastcell('600', '-d.testcircle'), '601', 'get_lastcell (circular -): start 600, returns cell before start (601)');

# --- Test get_distance ---
is( Zigzag::get_distance('700', '+d.testdist', '702'), 2, "get_distance('700', '+d.testdist', '702') is 2");
is( Zigzag::get_distance('702', '-d.testdist', '700'), 2, "get_distance('702', '-d.testdist', '700') is 2");
is( Zigzag::get_distance('700', '+d.testdist', '701'), 1, "get_distance('700', '+d.testdist', '701') is 1");
is( Zigzag::get_distance('700', '+d.testdist', '700'), 0, "get_distance('700', '+d.testdist', '700') is 0");
is( Zigzag::get_distance('700', '+d.testdist', '705'), undef, "get_distance('700', '+d.testdist', '705') is undef (not connected)");
is( Zigzag::get_distance('700', '-d.testdist', '702'), undef, "get_distance('700', '-d.testdist', '702') is undef (wrong direction)");
is( Zigzag::get_distance('700', '+d.otherdim', '701'), undef, "get_distance('700', '+d.otherdim', '701') is undef (wrong dimension)");

# --- Test get_outline_parent ---
is( Zigzag::get_outline_parent('800'), '801', "get_outline_parent('800') is '801'");
is( Zigzag::get_outline_parent('801'), '801', "get_outline_parent('801') (parent itself, -d.2 loops) is '801'");
is( Zigzag::get_outline_parent('810'), '811', "get_outline_parent('810') (circular -d.2, stops at 811) is '811'");

# --- Test get_cell_contents ---
is( Zigzag::get_cell_contents('850'), 'Direct content for 850', "get_cell_contents('850') returns direct content");
is( Zigzag::get_cell_contents('851'), 'Content from original cell 852', "get_cell_contents('851') returns content of original (-d.clone)");
is( Zigzag::get_cell_contents('853'), 'Cell 853 (clone of 854)', "get_cell_contents('853') returns its own content (only follows -d.clone)");
is( Zigzag::get_cell_contents('855'), '[10+20]', "get_cell_contents('855') returns raw ZZMail-like content when ZZMAIL_SUPPORT is false");

# --- Test get_cursor ---
is( Zigzag::get_cursor(0), '11', "get_cursor(0) returns cell 11 (from initial_geometry)");
is( Zigzag::get_cursor(1), '16', "get_cursor(1) returns cell 16 (from initial_geometry)");
is( Zigzag::get_cursor(2), '900', "get_cursor(2) returns cell 900 (added cursor)");

my $invalid_cursor_num = 3;
my $expected_error_msg_cursor = "No cursor $invalid_cursor_num";
eval { Zigzag::get_cursor($invalid_cursor_num); };
like($@, qr/\Q$expected_error_msg_cursor\E/, "get_cursor with invalid index $invalid_cursor_num dies with message '$expected_error_msg_cursor'");

# --- Test get_dimension ---
my $cursor_cell_for_dim_test = Zigzag::get_cursor(0); # Should be 11
# Expected dimensions based on initial_geometry for cursor 0 (cell 11):
# 11 --(+d.1)--> 12 (content: '+d.1')
# 12 --(+d.1)--> 13 (content: '+d.2')
# 13 --(+d.1)--> 14 (content: '+d.3')
is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'L'), '-d.1', "get_dimension for L returns -d.1");
is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'R'), '+d.1', "get_dimension for R returns +d.1");
is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'U'), '-d.2', "get_dimension for U returns -d.2");
is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'D'), '+d.2', "get_dimension for D returns +d.2");
is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'I'), '-d.3', "get_dimension for I returns -d.3");
is( Zigzag::get_dimension($cursor_cell_for_dim_test, 'O'), '+d.3', "get_dimension for O returns +d.3");

my $invalid_dir = 'X';
my $expected_error_msg_dim = "Invalid direction $invalid_dir";
eval { Zigzag::get_dimension($cursor_cell_for_dim_test, $invalid_dir); };
like($@, qr/\Q$expected_error_msg_dim\E/, "get_dimension with invalid direction $invalid_dir dies with message '$expected_error_msg_dim'");

# --- Test get_links_to ---
my @links_to_950 = sort(Zigzag::get_links_to('950'));
is(scalar @links_to_950, 3, 'get_links_to(950): returns 3 links (using standard dimensions)');
is_deeply(\@links_to_950, [sort ('951+d.1', '952+d.2', '953+d.clone')], 'get_links_to(950): lists correct incoming links (standard dimensions)');

my @links_to_960 = Zigzag::get_links_to('960');
is(scalar @links_to_960, 0, 'get_links_to(960): returns 0 links for cell with no connections');
is_deeply(\@links_to_960, [], 'get_links_to(960): returns empty list for cell with no connections');

# --- Test wordbreak ---
is( Zigzag::wordbreak("short string", 20), "short string", "wordbreak: string shorter than limit");
is( Zigzag::wordbreak("long string with spaces", 10), "long", "wordbreak: breaks at space before limit");
is( Zigzag::wordbreak("longstringnospaces", 10), "longstring", "wordbreak: no space, breaks at limit");
is( Zigzag::wordbreak("string with newline\nrest of string", 25), "string with newline ", "wordbreak: breaks at newline and adds space");

# --- Test dimension_is_essential ---
ok( Zigzag::dimension_is_essential('d.1'), "dimension_is_essential: d.1 is essential");
ok( Zigzag::dimension_is_essential('+d.2'), "dimension_is_essential: +d.2 is essential");
ok( Zigzag::dimension_is_essential('-d.cursor'), "dimension_is_essential: -d.cursor is essential");
ok( Zigzag::dimension_is_essential('d.clone'), "dimension_is_essential: d.clone is essential");
ok( Zigzag::dimension_is_essential('d.inside'), "dimension_is_essential: d.inside is essential");
ok( Zigzag::dimension_is_essential('d.contents'), "dimension_is_essential: d.contents is essential");
ok( Zigzag::dimension_is_essential('d.mark'), "dimension_is_essential: d.mark is essential");
ok( !Zigzag::dimension_is_essential('d.foo'), "dimension_is_essential: d.foo is not essential");
ok( !Zigzag::dimension_is_essential('+d.bar'), "dimension_is_essential: +d.bar is not essential");
ok( !Zigzag::dimension_is_essential('d.12'), "dimension_is_essential: d.12 is not essential");

done_testing();
