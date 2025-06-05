    push @Hash_Ref, \%hash;
    slice_upgrade() if $#DB_Ref < 0;
  }
  else
  {
    # no initial data file
    $DB_Ref = tie %hash, 'DB_File', $Filename, O_RDWR | O_CREAT
      || die "Can't create data file \"$Filename\": $!\n";
    # resort to initial geometry for first (home) slice
    %hash = initial_geometry() if $#Hash_Ref < 0;
