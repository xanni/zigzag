  die "No cursor $number" unless defined($cell);
  return $cell;
}

sub get_dimension($$)
# Get the dimension for a given cursor and direction
# Requires that each cursor have the current screen X, Y and Z axis
# dimension mappings linked +d.1 from the cursor cell
{
  my ($curs, $dir) = @_;
  die "Invalid direction $dir" unless ($dir =~ /^[LRUDIO]$/);

  $curs = cell_nbr($curs, "+d.1");
  if ($dir eq "L")
  { return reverse_sign(cell_get($curs)); }
  if ($dir eq "R")
  { return cell_get($curs); }
  $curs = cell_nbr($curs, "+d.1");
  if ($dir eq "U")
  { return reverse_sign(cell_get($curs)); }
  if ($dir eq "D")
  { return cell_get($curs); }
  $curs = cell_nbr($curs, "+d.1");
