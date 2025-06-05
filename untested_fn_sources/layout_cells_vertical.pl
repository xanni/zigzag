}

sub atcursor_shear($$$)
# Arguments: $curs = cursor/window number
# $sheardir = direction and +/-
# $linkdir = direction and +/-
# directions name axes.  They get turned into dimensions
# for the do_shear call.
# Head cell of the shear is the accursed cell
{
  my ($number, $shear_dir, $link_dir) = @_;

  my $cursor = get_cursor($number);
  my $shear_dim = get_dimension($cursor, $shear_dir);
  my $link_dim  = get_dimension($cursor, $link_dir);

  my $headcell = get_accursed($number);
