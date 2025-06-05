{
  my @list;
  my %hash;
  add_contents($_[0], \@list, \%hash);
  return @list;
}

sub get_links_to($)
# Returns a list of all the links back to the specified cell
{
  my $cell = $_[0];
  my $index = dimension_home();
  my @result;

  do
  {
    my $dim = cell_get($index);
    push @result, cell_nbr($cell, "-$dim") . "+$dim"
      if defined cell_nbr($cell, "-$dim");
    push @result, cell_nbr($cell, "+$dim") . "-$dim"
      if defined cell_nbr($cell, "+$dim");
    $index = cell_nbr($index, "+d.2");
    die "Dimension list broken" unless defined $index;
  } until $index == dimension_home();
  return @result;
}

#
# Multiple-cell operations
# Named do_*
#
sub do_shear($$$;$$)
# Given a row of cells starting at $first_cell,
# move them all $n cells in the $dir direction.
# Cells that were linked in the $link direction
# have their links broken and relinked to new cells.
#
# Before: do_shear(A1, d.1, d.2, 1);
#
# ---> d.1
# V d.2
#
# A1 --- B1 --- C1 --- D1 --- E1
# |      |             |      |
# A2 --- B2 --- C2 --- D2 --- E2
#
# After:
#
#        A1 --- B1 --- C1 --- D1 --- E1
#        |      |             |
# A2 --- B2 --- C2 --- D2 --- E2
#
# Optional fourth argument $n defaults to 1.
# Optional fifth argument $hang says whether the cell on the end
# should be linked back at the beginning or whether it should just
# be left hanging.  $hang = false: Back at beginning.
# $hang = true: Leave hanging.  Default: false.
{
  my ($first_cell, $dir, $link, $n, $hang) = @_;
