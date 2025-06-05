#
#  my $i;
#  for ($i = 0; $i < @cell_links; $i++)
#  {
#    my @links = @{$cell_links[$i]};
#    my $old = $selection[$i];
#    my $new = $new{$old};
#    my $dim;
#    foreach $dim (@links)
#    {
#      # If the linked cell is selected, then copy the link
#      if ($selected{cell_nbr($old, $dim)})
#      {
#	$ZZ{"$new$dim"} = $new{$ZZ{"$old$dim"}};
#	# Warning:  Doesn't use `link_make'.
#      }
#    }
