    }
  }
}

sub layout_cells_vertical($$$$$)
# Layout cells vertically at col starting at cell
{
  my ($lref, $cell, $col, $dim, $sign) = @_;

  # Layout at most half a screen of cells
  for (my $i = 1; defined $cell && ($i <= int($Vcells / 2)); $i++)
  {
    # Find the next cell, if any
    if (defined ($cell = cell_nbr($cell, $dim)))
    {
      my $row = $sign * $i;
