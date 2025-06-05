  do_shear($headcell, $shear_dim, $link_dim, 1);
}

sub atcursor_make_link($$)
# Link two cells along a given dimension
{
  my $curs = get_cursor($_[0]);
  my $dim = get_dimension($curs, $_[1]);

  # Not in the Cursor dimension!
