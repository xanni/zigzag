{
  my ($cell1, $cell2, $dir) = @_;
  die "No cell $cell1" unless defined cell_get($cell1);
  die "No cell $cell2" unless defined cell_get($cell2);
  die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
  my $back = reverse_sign($dir);
