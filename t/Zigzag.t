use strict;
use warnings;
use Test::More tests => 13;

# Ensure the Zigzag module loads
BEGIN { use_ok('Zigzag'); }

# Setup data for all tests in slice 0
# Note: is_essential tests do not require data setup in @Zigzag::Hash_Ref
# as they rely on constants defined in Zigzag.pm (CURSOR_HOME, etc.)
# and direct comparison with cell IDs.
@Zigzag::Hash_Ref = ({}); 
my $test_slice = $Zigzag::Hash_Ref[0];

# --- Setup for is_cursor tests ---
$test_slice->{'100'} = 'Cell 100 (cursor)';
$test_slice->{'101'} = 'Cell 101 (target for cursor link)';
$test_slice->{'102'} = 'Cell 102 (not a cursor)';
$test_slice->{'100+d.cursor'} = '101'; 
$test_slice->{'101-d.cursor'} = '100'; 

# --- Setup for is_clone tests ---
$test_slice->{'200'} = 'Cell 200 (clone via -d.clone)';
$test_slice->{'299'} = 'Helper cell for 200-d.clone link'; 
$test_slice->{'200-d.clone'} = '299'; 
$test_slice->{'299+d.clone'} = '200'; 

$test_slice->{'201'} = 'Cell 201 (clone via +d.clone)';
$test_slice->{'298'} = 'Helper cell for 201+d.clone link'; 
$test_slice->{'201+d.clone'} = '298';  
$test_slice->{'298-d.clone'} = '201';

$test_slice->{'202'} = 'Cell 202 (not a clone)';

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
ok( Zigzag::is_essential('0'), 'is_essential: cell 0 is essential');
ok( Zigzag::is_essential('10'), 'is_essential: cell 10 (CURSOR_HOME) is essential');
ok( Zigzag::is_essential('21'), 'is_essential: cell 21 (SELECT_HOME) is essential');
ok( Zigzag::is_essential('99'), 'is_essential: cell 99 (DELETE_HOME) is essential');
ok( !Zigzag::is_essential('50'), 'is_essential: cell 50 is not essential'); # Test with a non-essential number

done_testing();
