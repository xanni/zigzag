  if (!defined($_ = cell_nbr($cell, $dim)))
  {
     user_error(7, "$cell$dim");
  }
  else
  {
    link_break($cell, $_, $dim);

    display_dirty();
  }
}

#
# Functions that operate on groups of cells in a given dimension
# Named: cells_*
# (bad name?)
#
sub cells_row($$)
# Find all the cells in the row starting from $cell
# in the $dir dimension.  Return a list or a count
# depending on calling context.
{
  my ($cell1, $dir) = @_;

  return if !defined cell_get($cell1); # Check if cell actually exists

  my $cell;
  my @result = ($cell1);
  for ($cell = cell_nbr($cell1, $dir);
