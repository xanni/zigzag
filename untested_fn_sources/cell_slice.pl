    die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
    $slice = cell_slice("$cell1$dir");
    die "$cell1 has no link in direction $dir" unless defined $slice;
    die "$cell1 is not linked to $cell2 in direction $dir"
      unless $cell2 == $Hash_Ref[$slice]{"$cell1$dir"};
  }
  else
  {
    ($cell1, $dir) = @_;
    die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
