
  # If no cell number selected, just move the cursor instead
  if (!defined $Input_Buffer)
  {
     cursor_move_dimension($curs, $dim);
  }
  elsif (!defined cell_get($Input_Buffer))
  {
     user_error(6, $Input_Buffer);
  }
  else
  {
    cell_insert($Input_Buffer, get_lastcell($curs, "-d.cursor"), $dim);
    undef $Input_Buffer;

    display_dirty();
  }
}

sub atcursor_break_link(@)
# Break a link in a given dimension
{
  my $curs = get_cursor($_[0]);
  my $dim = get_dimension($curs, $_[1]);
  my $cell = get_lastcell($curs, "-d.cursor");

  # Not in the Cursor dimension!
  return if $dim eq "d.cursor";
