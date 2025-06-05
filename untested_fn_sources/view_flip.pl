    {
      $$lref{"0,-$y"} = $i;
      $$lref{"0|-$y"} = $TRUE;
      layout_cells_horizontal($lref, $i, -$y, $left, -1);
      layout_cells_horizontal($lref, $i, -$y, $right, 1);
    }
  }

  for ($y = 1, $i = $cell; defined $i && ($y <= int($Vcells / 2)); $y++)
  {
    # Find the next cell below, if any
