  if (is_essential($cell))
  {
    user_error(10);
  }
  elsif ((cell_find($cell, "-d.2", cell_get($dhome)) == $dhome) and
    dimension_is_essential(cell_get($cell)))
  {
    user_error(11, cell_get($cell))
  }
  else
  {
    # Pass the torch if this cell has clone(s)
    if (!defined cell_nbr($cell, "-d.clone") &&
	($_ = cell_nbr($cell, "+d.clone")))
    { cell_set($_, cell_get($cell)); }

    do
    {
      my $dim = cell_get($index);
      # Try and find any valid non-cursor neighbour
