    last if $@;
  }
  chomp $@;
  user_error(4, $@) if ($@);
}

sub atcursor_clone($;$)
# Clone all the cells in the current selection
# If the current selection is empty, clone just the accursed cell.
# Move the given cursor to the first of the new clones.
# Optional second argument specifies which of several clone-ish operations
# to perform.  Presently supported:
#  clone: as before
#  copy: copy cells instead of cloning, and copy links also.
{
  my $curs = get_cursor($_[0]);
  my $op = $_[1] || 'clone';
  my $last_new_cell;

  my @selection = get_active_selection;
  if (@selection == 0)
  { @selection = (get_lastcell($curs, "-d.cursor")); }
