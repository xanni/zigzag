    my $prev = cell_nbr($cell, reverse_sign($dim));
    my $next = cell_nbr($neighbour, $dim);

    link_break($cell, $neighbour, $dim);
    if (defined $prev)
    {
      link_break($prev, $cell, $dim);
      link_make($prev, $neighbour, $dim);
    }
    if (defined $next)
    {
      link_break($neighbour, $next, $dim);
      link_make($cell, $next, $dim);
    }
    link_make($neighbour, $cell, $dim);

    display_dirty();
