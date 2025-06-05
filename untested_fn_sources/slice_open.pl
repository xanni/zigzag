  dimension_rename("d.Mark", "d.mark");
  dimension_rename("d.Contain", "d.inside");
  dimension_rename("d.Contain2", "d.contents");
  dimension_rename("d.contentlist", "d.contents");
  dimension_rename("d.contain", "d.inside");
  dimension_rename("d.containment", "d.inside");

  # Make sure $SELECT_HOME exists (from v0.57)
  if (not defined cell_get($SELECT_HOME))
  {
    cell_set($SELECT_HOME, "Selection");
    link_make($SELECT_HOME, $SELECT_HOME, "+d.2");
    cell_insert($SELECT_HOME, $CURSOR_HOME, "-d.1");
  }

  # Rename the "Midden" to the "Recycle pile" (from v0.62)
  cell_set($DELETE_HOME, "Recycle pile") if cell_get($DELETE_HOME) eq "Midden";

  # Make sure recycle pile is a circular queue (from v0.67)
  my $first = get_lastcell($DELETE_HOME, "-d.2");
  link_make($first, get_lastcell($DELETE_HOME, "+d.2"), "-d.2")
    unless defined cell_nbr($first, "-d.2");
}

sub slice_open(;$)
{
  # If there's a parameter, use it as the filename
  my %hash;
  my $DB_Ref;
  my $Filename = shift;
