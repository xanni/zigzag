
  do_shear($SELECT_HOME, '-d.2', '+d.mark', $shear_count);
  undef $Input_Buffer;
}

sub push_selection()
# Push the current selection onto the selection stack.
# All saved selections move +d.2ward one step.
# The current selection is now empty.
{
  my $num_selections = cells_row($SELECT_HOME, "+d.2");
  my $new_sel = cell_new("Selection #$num_selections");
  cell_insert($new_sel, $SELECT_HOME, "+d.2");
  do_shear($SELECT_HOME, "+d.2", "+d.mark", 1);
}


sub atcursor_insert($$)
# Insert a new cell at a given cursor in a given direction
{
  my $curs = get_cursor($_[0]);
  my $dim = get_dimension($curs, $_[1]);

  # Can't insert if it's the cursor or clone dimension
  if ($dim =~ /^[+-]d\.(clone|cursor)$/)
  {
     user_error(9, $dim);
  }
  else
