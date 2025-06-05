  # Don't bother if there's nowhere to go
  return if (!defined($_ = cell_nbr($cell, $dir)) ||
             ($_ == $cell) || defined cell_nbr($_, "-d.cursor"));

  # Now move the cursor
  $cell = get_lastcell($_, "+d.cursor");
  cell_excise($curs, "d.cursor");
  cell_insert($curs, $cell, "+d.cursor");

  display_dirty();
}

sub cursor_jump($$)
# Jump cursor to specified destination
{
  my ($curs, $dest) = @_;

  # Must jump to a valid non-cursor cell
  if (!defined cell_get($dest) || defined cell_nbr($dest, "-d.cursor"))
  { user_error(3, $dest); }
  else
  {
    # Move the cursor
    cell_excise($curs, "d.cursor");
    cell_insert($curs, get_lastcell($dest, "+d.cursor"), "+d.cursor");

    display_dirty();
  }
}

sub cursor_move_direction($$)
# Move given cursor in a given direction
{
  my $curs = get_cursor($_[0]);

  cursor_move_dimension($curs, get_dimension($curs, $_[1]));
}

#
# Functions that operate on the cell under a cursor
# Named atcursor_*
#
sub atcursor_execute($)
# Execute the contents of a progcell under a given cursor
{
  my $cell;
  foreach $cell (get_contained(get_lastcell(get_cursor($_[0]), "-d.cursor")))
  {
#    $_ = cell_get(get_lastcell($cell, "-d.clone"));
    $_ = get_cell_contents($cell);
