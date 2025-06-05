  link_break($cell, $next, "+$dim") if defined($next);
  link_make($prev, $next, "+$dim") if defined($prev) && defined($next);
}

sub cell_new(;$)
# Create a new cell in slice 0 (or recycle one from the recycle pile)
{
  my $new = cell_nbr($DELETE_HOME, "-d.2");

  # Are there any cells left on the recycle pile?
  if ($new == $DELETE_HOME)
  { $new = $Hash_Ref[0]{"n"}++; }
  else
  { cell_excise($new, "d.2"); }
