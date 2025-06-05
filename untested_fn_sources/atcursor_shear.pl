    my $new = cell_new();
    cell_insert($new, get_lastcell($curs, "-d.cursor"), $dim);

    display_dirty();
  }
}

sub atcursor_delete($)
# Delete the cell under a given cursor
{
  my $curs = get_cursor($_[0]);
  my $cell = get_lastcell($curs, "-d.cursor");
  my $dhome = dimension_home();
  my $index = $dhome;
  my $neighbour;
