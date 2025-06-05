}

sub cell_find($$$)
# From a starting cell, travel a given direction to find given cell contents
{
  my ($start, $dir, $contents) = @_;
  die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
  my $cell = $start;
  my $found = $FALSE;

  # Follow links until we find a match or return to where we started
  do
  {
    $found = $cell if (defined $cell) and (cell_get($cell) eq $contents);
    $cell = cell_nbr($cell, $dir);
  } until $found or (not defined $cell) or ($cell == $start);
  return $found;
}

sub cell_excise($$)
# Remove a cell from a given dimension
{
  my ($cell, $dim) = @_;
  die "No cell $cell" unless defined cell_get($cell);
  my $prev = cell_nbr($cell, "-$dim");
  my $next = cell_nbr($cell, "+$dim");
