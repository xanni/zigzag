#
#                 Original state                 New state
#                 --------------               -------------
# | +d.cursor      old-----new                  old-----new
# V dimension       |       |                    |       |
#                  XXX     YYY                  XXX     YYY
#                   |                            |       |
#                 $curs                         ZZZ    $curs
#                   |
#                  ZZZ
#
# NOTE: If there are many cursors it would be more efficient to insert the
# cursor next to "new", but Ted prefers the visualisation that the most
# recent cursor is the one furthest along the cursor dimension.
{
  my ($curs, $dir) = @_;
  die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
  my $cell = get_lastcell($curs, "-d.cursor");
