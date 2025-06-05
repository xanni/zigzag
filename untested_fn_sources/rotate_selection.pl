  my %new;
  my %selected;
  foreach $cell (@selection)
  {
    my $new = cell_new();
    $new{$cell} = $new;
    $selected{$cell} = 'yup';
    if ($op eq 'clone')
    {
      cell_set($new, "Clone of $cell");
