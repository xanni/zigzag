        || ((!defined($_ = cell_nbr($cell, "-$dim"))
            || ($_ == $cell)
            || defined cell_nbr($_, "-d.cursor"))
          && (!defined($_ = cell_nbr($cell, "+$dim"))
            || ($_ == $cell)
            || defined cell_nbr($_, "-d.cursor")));

      # Excise $cell from dimension $dim
      cell_excise($cell, $dim);

      # Proceed to the next dimension
      $index = cell_nbr($index, "+d.2");
      die "Dimension list broken" unless defined $index;
    } until ($index == $dhome);
    $neighbour = 0 unless defined $neighbour;

    # Move $cell to the recycle pile
    cell_insert($cell, $DELETE_HOME, "+d.2");
