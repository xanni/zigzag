
  cursor_jump($curs, $last_new_cell);

  display_dirty();
}

sub atcursor_copy($)
# Convenience routine: See atcursor_clone
{
  atcursor_clone($_[0], 'copy');
}

sub atcursor_select($)
# select or unselect the current cell
{
  my $curs = get_cursor($_[0]);
  my $cell = get_lastcell($curs, "-d.cursor");
  my $already_selected = is_selected($cell);
  my $which_selection =  get_which_selection($cell) if $already_selected;

  cell_excise($cell, "d.mark");

  # If it wasn't already selected in the active selection, deselect it.
  # (The excise did this already, so we need only print a message.)
  # Otherwise add it to the active selection and deliver a message.
  if ($already_selected && $which_selection == $SELECT_HOME)
  {
    display_status_draw("Deselected cell $cell");
  }
  else
  {
    cell_insert($cell, $SELECT_HOME, "+d.mark");
    display_status_draw("Selected cell $cell");
  }
  #cursor_move_dimension($curs, "+d.mark");

  display_dirty();
}

sub rotate_selection ()
# Exchange the current selection with one of the saved selections.  If
# there's an input buffer, it holds the number of the desired
# selection, so shear all the selections +d.2ward by that many.
# (Selection #0 is currently active.)  Otherwise, just shear by 1.
{
  my $shear_count = (defined($Input_Buffer) ? $Input_Buffer : 1);
