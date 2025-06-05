  $Filename = $FILENAME if (not defined $Filename) and ($#Filename < 0);
  if (-e $Filename)
  {
    # we have an existing datafile - back it up!
    move($Filename, $Filename . $BACKUP_FILE_SUFFIX)
      || die "Can't rename data file \"$Filename\": $!\n";
    copy($Filename . $BACKUP_FILE_SUFFIX, $Filename)
      || die "Can't copy data file \"$Filename\": $!\n";
    $DB_Ref = tie %hash, 'DB_File', $Filename, O_RDWR
