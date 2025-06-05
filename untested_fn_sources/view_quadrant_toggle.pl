# Functions that lay out cells in a window
# Named: layout_*
#
sub layout_cells_horizontal($$$$$)
# Layout cells horizontally at row starting at cell
{
  my ($lref, $cell, $row, $dim, $sign) = @_;

  # Layout at most half a screen of cells
  for (my $i = 1; defined $cell && ($i <= int($Hcells / 2)); $i++)
  {
    # Find the next cell, if any
    if (defined ($cell = cell_nbr($cell, $dim)))
    {
      my $col = $sign * $i;
      $$lref{"$col,$row"} = $cell;
