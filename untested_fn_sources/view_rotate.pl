}

sub layout_Iraster($$$$)
# Horizontal ("I raster") window layout starting at cell
{
  my ($lref, $cell, $right, $down) = @_;
  my $left = reverse_sign($right);
  my $up = reverse_sign($down);
  my ($y, $i);

  $$lref{"0,0"} = $cell;
  layout_cells_horizontal($lref, $cell, 0, $left, -1);
  layout_cells_horizontal($lref, $cell, 0, $right, 1);

  for ($y = 1, $i = $cell; defined $i && ($y <= int($Vcells / 2)); $y++)
  {
    # Find the next cell above, if any
