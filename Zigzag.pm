# Xanadu(R) ZigZag(tm) Hyperstructure Kit, $Revision: 0.66 $
#
# Designed by Ted Nelson
# Programmed by Andrew Pam ("xanni") and Bek Oberin ("gossamer")
# Copyright (c) 1997, 1998 Project Xanadu
#
# This is only a partial implementation, with only a few structure and view
# operations; however, they are enough to allow you to create, view and explore
# complex multidimensional structures in quantum hyperspace.
#
# A forthcoming tutorial will present you with strange spaces to explore,
# beginning with easy 2D concepts, the peculiar geography of this system and
# operating recommendations for getting around in it comfortably and changing
# your structures without losing cells or losing track of your stuff.  (This
# will emphasize pragmatic adaptations to the peculiarities of this limited
# implementation.)
#
# Forthcoming documentation will explain the space, the theory, structure
# operations, view operations, and the official planned extensions.
#
# For more information, visit http://www.xanadu.net/zz/
#
# This file "ZigZag.pm" contains the implementation of the ZigZag data
# structures and operations.  User interfaces for interactive manipulation of
# the ZigZag data structures can be created using the operations defined in
# this file.  Example interfaces include "zigzag" (a text-based interface using
# Curses) and "zizzle" (a web-based interface using HTML and HTTP).
#
# ===================== Change Log
#
# Inital ZigZag implementation
# $Id: Zigzag.pm,v 0.66 1999/01/07 07:15:30 xanni Exp $
#
# $Log: Zigzag.pm,v $
# Revision 0.66  1999/01/07 07:15:30  xanni
# Minor fixes to db_open()
# Replaced window_draw_* functions with new layout_* functions
#
# Revision 0.65  1999/01/07 04:04:52  xanni
# Derived from the monolithic zigzag 0.64
#
# Revision 0.64  1999/01/07 03:55:11  xanni
# Minor cosmetic changes
#
# Revision 0.63  1999/01/06 05:07:14  xanni
# Created display_dirty() and generally fixed up dirty handling
# Minor cleanup of error handling and Meta support
#
# Revision 0.62  1998/11/23 13:59:55  xanni
# Renamed the "Midden" cell to "Recycle pile", fixed Meta (aka Alt) support
#
# Revision 0.61  1998/11/21 16:46:33  xanni
# Defined $Hcells and $Vcells, fixed $Cell_Width bug,
# created display_draw_link_* functions, finished making
# window_draw_* functions independent of the UI toolkit.
#
# Revision 0.60  1998/11/21 08:24:21  xanni
# Introduced window_draw_preview, cleaned up display_draw_quad
#
# Older revisions are listed in the CHANGES file
#

package ZigZag;
use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw
  (
    %ZZ $Command_Count $Hcells $Vcells $Input_Buffer
    db_open
    db_close
    db_sync
    reverse_sign
    wordbreak
    is_cursor
    is_clone
    is_selected
    is_active_selected
    dimension_is_essential
    dimension_exists
    get_accursed
    get_active_selection
    get_selection
    get_which_selection
    get_lastcell
    get_distance
    get_outline_parent
    get_cell_contents
    get_cursor
    get_dimension
    get_contained
    get_links_to
    do_shear
    cell_create
    cell_insert
    cell_excise
    cursor_move_dimension
    cursor_jump
    cursor_move_direction
    atcursor_execute
    atcursor_clone
    atcursor_copy
    atcursor_select
    rotate_selection 
    push_selection
    atcursor_insert
    atcursor_delete
    atcursor_hop
    atcursor_shear
    atcursor_make_link
    atcursor_break_link
    cells_row
    layout_preview
    layout_Iraster
    layout_Hraster
    view_quadrant_toggle
    view_raster_toggle
    view_reset
    view_rotate
    view_flip
  );
@EXPORT_OK = qw(link_make link_break);

use integer;
use strict;
use POSIX;
use DB_File;
#use Fcntl;
use File::Copy;

# Import functions
*display_dirty = *::display_dirty;
*display_status_draw = *::display_status_draw;
*user_error = *::user_error;
*atcursor_edit = *::atcursor_edit;
*input_get_direction = *::input_get_direction;

# Note: We are using the following coding conventions:
# Constants are named in ALLCAPS
# Global variables are named with Initial Caps
# Local variables and functions are named in lowercase
# Put brackets around all function arguments
# Prototype the number and type of arguments expected by functions
# Matching braces should line up with each other vertically
# Use the $TRUE and $FALSE constants instead of "1" and "0"

# Define constants
use vars qw($VERSION);
#($VERSION) = q$Revision: 0.66 $ =~ /([\d\.]+)/;
$VERSION = do { my @r = (q$Revision: 0.66 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker
my $FALSE = 0;
my $TRUE = !$FALSE;
my $CURSOR_HOME = 10;            # NOTE!  This assumes it stays fixed!
my $SELECT_HOME = 21;            # NOTE!  This assumes it stays fixed!
my $DELETE_HOME = 99;            # NOTE!  This assumes it stays fixed!
my $FILENAME = "zigzag.zz";      # Default filename for initial slice
my $ZZMAIL_SUPPORT = $FALSE;	 # Enable preliminary ZZmail support
#my $COMMAND_SYNC_COUNT = 20;     # Sync the DB after this many commands
my $BACKUP_FILE_SUFFIX = ".bak";

# Declare globals
use vars qw(%ZZ $Command_Count $Hcells $Vcells $Input_Buffer);

#my %ZZ;                          # The ZigZag cells and links
#my $Input_Buffer;                # Cell number entered from the keyboard
#my $Command_Count;               # Counts commands between DB syncs
my $DB_Ref;                      # We use this for sync'ing.
#my $Hcells;			 # Horizontal cells per window
#my $Vcells;			 # Vertical cells per window


sub initial_geometry()
{
  return (
    0 =>        "Home",
      "0-d.1" =>	99,
      "0+d.2" =>	30,
      "0+d.cursor" =>	11,
    1 =>        "d.1",
      "1-d.1" =>	10,
      "1+d.1" =>	99,
      "1-d.2" =>	8,
      "1+d.2" =>	2,
    2 =>        "d.2",
      "2-d.2" =>	1,
      "2+d.2" =>	3,
    3 =>        "d.3",
      "3-d.2" =>	2,
      "3+d.2" =>	4,
    4 =>        "d.inside",
      "4-d.2" =>	3,
      "4+d.2" =>	5,
    5 =>        "d.contents",
      "5-d.2" =>	4,
      "5+d.2" =>	6,
    6 =>        "d.mark",
      "6-d.2" =>	5,
      "6+d.2" =>	7,
    7 =>        "d.clone",
      "7-d.2" =>	6,
      "7+d.2" =>	8,
    8 =>        "d.cursor",
      "8-d.2" =>	7,
      "8+d.2" =>	1,
   10 =>        "Cursor home",
      "10+d.1" =>	1,
      "10+d.2" =>	11,
      "10-d.1" =>	21,
   11 =>        "Action",
      "11+d.1" =>	12,
      "11-d.2" =>	10,
      "11+d.2" =>	16,
      "11-d.cursor" =>	0,
      "11+d.cursor" =>	16,
   12 =>        "+d.1",
      "12-d.1" =>	11,
      "12+d.1" =>	13,
   13 =>        "+d.2",
      "13-d.1" =>	12,
      "13+d.1" =>	14,
   14 =>        "+d.3",
      "14-d.1" =>	13,
      "14+d.1" =>	15,
   15 =>        "I",
      "15-d.1" =>	14,
   16 =>        "Data",
      "16+d.1" =>	17,
      "16-d.2" =>	11,
      "16-d.cursor" =>	11,
   17 =>        "+d.1",
      "17-d.1" =>	16,
      "17+d.1" =>	18,
   18 =>        "+d.2",
      "18-d.1" =>	17,
      "18+d.1" =>	19,
   19 =>        "+d.3",
      "19-d.1" =>	18,
      "19+d.1" =>	20,
   20 =>        "I",
      "20-d.1" =>	19,
   21 => "Selection",
      "21+d.1" =>       10, 
      "21+d.2" =>       21, 
      "21-d.2" =>       21, 
   30 =>        "#Edit\natcursor_edit(1);",
      "30+d.1" =>	35,
      "30-d.2" =>	0,
      "30+d.2" =>	40,
   35 =>        "#Clone\natcursor_clone(1);",
      "35-d.1" =>	30,
   40 =>        "#L-ins\natcursor_insert(1, 'L');",
      "40+d.1" =>	41,
      "40-d.2" =>	30,
      "40+d.2" =>	50,
   41 =>        "#R-ins\natcursor_insert(1, 'R');",
      "41-d.1" =>	40,
      "41+d.1" =>	42,
   42 =>        "#U-ins\natcursor_insert(1, 'U');",
      "42-d.1" =>	41,
      "42+d.1" =>	43,
   43 =>        "#D-ins\natcursor_insert(1, 'D');",
      "43-d.1" =>	42,
      "43+d.1" =>	44,
   44 =>        "#I-ins\natcursor_insert(1, 'I');",
      "44-d.1" =>	43,
      "44+d.1" =>	45,
   45 =>        "#O-ins\natcursor_insert(1, 'O');",
      "45-d.1" =>	44,
   50 =>        "#Delete\natcursor_delete(1);",
      "50+d.1" =>	51,
      "50-d.2" =>	40,
      "50+d.2" =>	60,
   51 =>        "#L-break\natcursor_break_link(1, 'L');",
      "51-d.1" =>	50,
      "51+d.1" =>	52,
   52 =>        "#R-break\natcursor_break_link(1, 'R');",
      "52-d.1" =>	51,
      "52+d.1" =>	53,
   53 =>        "#U-break\natcursor_break_link(1, 'U');",
      "53-d.1" =>	52,
      "53+d.1" =>	54,
   54 =>        "#D-break\natcursor_break_link(1, 'D');",
      "54-d.1" =>	53,
      "54+d.1" =>	55,
   55 =>        "#I-break\natcursor_break_link(1, 'I');",
      "55-d.1" =>	54,
      "55+d.1" =>	56,
   56 =>        "#O-break\natcursor_break_link(1, 'O');",
      "56-d.1" =>	55,
   60 =>        "#Select\natcursor_select(1);",
      "60-d.2" =>	50,
      "60+d.2" =>	70,
      "60+d.1" =>       61,
   61 =>        "#Rot.Selection\nrotate_selection();",
      "61-d.1" =>       60,
      "61+d.1" =>       62,
   62 =>	"#Push Selection\npush_selection();",
      "62-d.1" =>	61,
   70 =>        "#L-Hop\natcursor_hop(1, 'L');",
      "70+d.1" =>	71,
      "70-d.2" =>	60,
      "70+d.2" =>	80,
   71 =>        "#R-Hop\natcursor_hop(1, 'R');",
      "71-d.1" =>	70,
      "71+d.1" =>	72,
   72 =>        "#U-Hop\natcursor_hop(1, 'U');",
      "72-d.1" =>	71,
      "72+d.1" =>	73,
   73 =>        "#D-Hop\natcursor_hop(1, 'D');",
      "73-d.1" =>	72,
      "73+d.1" =>	74,
   74 =>        "#I-Hop\natcursor_hop(1, 'I');",
      "74-d.1" =>	73,
      "74+d.1" =>	75,
   75 =>        "#O-Hop\natcursor_hop(1, 'O');",
      "75-d.1" =>	74,
   80 =>        "#Shear -^\natcursor_shear(1, 'D', 'L')",
      "80-d.2" =>	70,
      "80+d.2" =>	85,
      "80+d.1" =>       81,
   81 =>        "#Shear -v\natcursor_shear(1, 'U', 'L')",
      "81-d.1" =>       80,
      "81+d.1" =>       82,
   82 =>        "#Shear ^+\natcursor_shear(1, 'D', 'R')",
      "82-d.1" =>       81,
      "82+d.1" =>       83,
   83 =>        "#Shear v+\natcursor_shear(1, 'U', 'R')",
      "83-d.1" =>       82,
   85 =>        "#Chug",
      "85-d.2" =>	80,
      "85+d.2" =>	90,
   90 =>        "#A-View toggle\nview_raster_toggle(0);",
      "90+d.1" =>	91,
      "90-d.2" =>	85,
      "90+d.2" =>	93,
   91 =>        "#D-View toggle\nview_raster_toggle(1);",
      "91-d.1" =>	90,
      "91+d.1" =>	92,
   92 =>	"#Quad view toggle\nview_quadrant_toggle(1);",
      "92-d.1" =>	91,
   93 =>	"#X-rotate view\nview_rotate(1, 'X');",
      "93+d.1" =>	94,
      "93-d.2" =>	90,
      "93+d.2" =>	96,
   94 =>	"#Y-rotate view\nview_rotate(1, 'Y');",
      "94-d.1" =>	93,
      "94+d.1" =>	95,
   95 =>	"#Z-rotate view\nview_rotate(1, 'Z');",
      "95-d.1" =>	94,
   96 =>	"#X-flip view\nview_flip(1, 'X');",
      "96+d.1" =>	97,
      "96-d.2" =>	93,
   97 =>	"#Y-flip view\nview_flip(1, 'Y');",
      "97-d.1" =>	96,
      "97+d.1" =>	98,
   98 =>	"#Z-flip view\nview_flip(1, 'Z');",
      "98-d.1" =>	97,
   99 =>        "Recycle pile",
      "99-d.1" =>	1,
      "99+d.1" =>	0,
   "n" =>        100
   );
}

sub db_open(;$)
{
  # If there's a parameter, use it as the filename
  my $Filename = shift || $FILENAME;
  if (-e $Filename)
  {
    # we have an existing datafile - back it up!
    move($Filename, $Filename . $BACKUP_FILE_SUFFIX)
      || die "Can't rename data file \"$Filename\": $!\n";
    copy($Filename . $BACKUP_FILE_SUFFIX, $Filename)
      || die "Can't copy data file \"$Filename\": $!\n";
    $DB_Ref = tie %ZZ, 'DB_File', $Filename, O_RDWR
      || die "Can't open data file \"$Filename\": $!\n";
  }
  else
  {
    # no initial data file,  resort to initial geometry
    $DB_Ref = tie %ZZ, 'DB_File', $Filename, O_RDWR | O_CREAT
      || die "Can't create data file \"$Filename\": $!\n";
    %ZZ = initial_geometry();
  }
}

sub db_close()
{
  undef $DB_Ref;	# So untie doesn't complain
  untie %ZZ;
}

sub db_sync()
{
  $DB_Ref->sync();
}


#
# Some helper functions
#

sub reverse_sign($)
# Reverse the sign of the given cursor/dimension
{
  return ((substr($_[0], 0, 1) eq "+") ? "-" : "+") . substr($_[0], 1);
}

sub wordbreak($$)
# Returns a string up to the first line break or the end of the last word
# that finishes before the given character position
{
  $_ = substr($_[0], 0, $_[1]);
  if (/^(.*)\n/)
  { $_ = "$1 "; }
  elsif ((length eq $_[1]) && /^(.+)\s+\S*$/)
  { $_ = $1; }
  return $_;
}

#
# Testing cell type
# Named is_*
#
sub is_cursor($)
{
  my $cell = shift;
  return (defined($ZZ{"$cell-d.cursor"}) || defined($ZZ{"$cell+d.cursor"}));
}

sub is_clone($)
{
  my $cell = shift;
  return (defined($ZZ{"$cell-d.clone"}) || defined($ZZ{"$cell+d.clone"}));
}

sub is_selected($)
{
  my $cell = shift;
  my $headcell = get_lastcell($cell, '-d.mark');
  return $headcell != $cell
    && defined get_distance($headcell, "+d.2", $SELECT_HOME);
}

sub is_active_selected($)
{
  my $cell = shift;
  my $headcell = get_lastcell($cell, '-d.mark');
  return $headcell == $SELECT_HOME && $headcell != $cell;
}


#
# People aren't allowed to delete essential dimensions!
#
sub dimension_is_essential($)
{
  my $dim = shift;
  return ($dim =~ m/^[+-]?d\.(cursor|clone|1|2|3|inside|contents|mark)$/);
}

sub dimension_exists($)
{
  my $dim = shift;
  # XXX todo
  return $TRUE;
}


#
# Retrieving Information
# Named get_*
#

sub get_accursed($)
# Get the cell that is accursed in the specified window
# or by the specified cursor
{
  my $n = shift;
  get_lastcell(get_cursor($n), "-d.cursor");
}

sub get_active_selection()
{
  get_selection(0);
}

sub get_selection($)
# Get the $nth selection and return a list of cells
{
  my ($n) = @_;
  my $sel;
  for ($sel = $SELECT_HOME; $n && defined($sel); $n--)
  { $sel = $ZZ{"$sel+d.2"}; }

  cells_row($ZZ{"$sel+d.mark"}, "+d.mark");
}

sub get_which_selection($) 
# Given a cell, get the headcell of the selection it is in, or undef
# if it is not part of a selection
{
  my $cell = shift;
  return undef unless defined $ZZ{"$cell-d.mark"};
  get_lastcell($cell, "-d.mark");
}

sub get_lastcell($$)
# Find the last cell along a given dimension
{
  my ($cell, $dim) = @_;
  die "No cell $cell" unless defined($ZZ{"$cell"});
  die "Invalid direction $dim" unless ($dim =~ /^[+-]/);

  # Follow links to the end or until we return to where we started
  $cell = $_ while defined($_ = $ZZ{"$cell$dim"}) && ($_ != $_[0]);
  return $cell;
}

sub get_distance($$$)
# Given cell A a direction, and cell B,
# find out how far B is from A in the specified direction.
# return undef if B cannot be reached from A in that direction
{
  my ($start, $dir, $end) = @_;
  my $cell;

  return 0 if $start == $end;

  my $dist = 1;
  for ($cell = $ZZ{"$start$dir"};
       defined $cell && $cell != $end && $cell != $start;
       $cell = $ZZ{"$cell$dir"}
      )
  { $dist++; }
  return undef if !defined($cell) || $cell == $start;
  return $dist;
}

sub get_outline_parent($)
# Find the "outline parent" (first cell -d.1 along -d.2) of a cell
{
  my $cell = $_[0];
  die "No cell $cell" unless defined($ZZ{"$cell"});

  # Move -d.2 until we find a -d.1 link or return to where we started
  $cell = $_ while (!defined($ZZ{"$cell-d.1"}) &&
		    defined($_ = $ZZ{"$cell-d.2"}) && ($_ != $_[0]));
  $cell = $_ if defined($_ = $ZZ{"$cell-d.1"});
  return $cell;
}

sub get_cell_contents($)
# Return the contents of a cell
{
  my $cell = $_[0];
  die "No cell $cell" unless defined($ZZ{"$cell"});
  my $contents = $ZZ{get_lastcell($cell, "-d.clone")};

  if ($ZZMAIL_SUPPORT && $contents =~ /^\[(\d+)\+(\d+)\]/)
  # Note 1: This should handle pointer lists, but currently only handles
  #         the first pointer.
  # Note 2: This performs extremely badly for large primedia.  It should
  #         make requests to an OSMIC server instead.
  {
    my $pos = $1;
    my $len = $2;
    my $PRIMEDIA = $ZZ{get_outline_parent($cell)};
    if (open(PRIMEDIA, "<$PRIMEDIA"))
    {
      my $error = $FALSE;
      seek(PRIMEDIA, $pos, SEEK_SET) || ($error = "seeking");
      read(PRIMEDIA, $contents, $len) == $len || ($error = "reading");
      close PRIMEDIA;
      die "Error $error $PRIMEDIA" if $error;
    }
  }

  return $contents;
}

sub get_cursor($)
# Return the given cursor
{
  my $number = $_[0];
  my $cell = $CURSOR_HOME;

  # Count to the numbered cursor
  for ($_ = 0; defined($cell) && ($_ <= $number); $_++)
  { $cell = $ZZ{"$cell+d.2"}; }
  die "No cursor $number" unless defined($cell);
  return $cell;
}

sub get_dimension($$)
# Get the dimension for a given cursor and direction
# Requires that each cursor have the current screen X, Y and Z axis
# dimension mappings linked +d.1 from the cursor cell
{
  my ($curs, $dir) = @_;
  die "Invalid direction $dir" unless ($dir =~ /^[LRUDIO]$/);

  $curs = $ZZ{"$curs+d.1"};
  if ($dir eq "L")
  { return reverse_sign($ZZ{$curs}); }
  if ($dir eq "R")
  { return $ZZ{$curs}; }
  $curs = $ZZ{"$curs+d.1"};
  if ($dir eq "U")
  { return reverse_sign($ZZ{$curs}); }
  if ($dir eq "D")
  { return $ZZ{$curs}; }
  $curs = $ZZ{"$curs+d.1"};
  if ($dir eq "I")
  { return reverse_sign($ZZ{$curs}); }
  if ($dir eq "O")
  { return $ZZ{$curs}; }
}

sub get_contained($)
# Return list of cells "contained" within a cell
# Performs a depth-first descend-only treewalk with loops broken
# +d.inside is depth, +d.contents is width.
# Sadly, this is broken because d.inside and d.contents
# aren't actually meant to have the same semantics!
{
  my %gen;
  my @stack;
  my $cell = $_[0];
  my $gen = 0;
  my ($index, $next, $start);

  $start = get_lastcell($cell, "-d.contents");
  # If d.contents is not linked or is a loop, just use $cell
  $start = $cell if !defined($start) || defined($ZZ{"$start-d.contents"});

  # Mark the first generation
  $index = $start;
  do
  {
    $gen{$index} = 0;
    $index = $ZZ{"$index+d.contents"};
  }
  until (!defined($index) || ($index eq $start));

  undef @_;
  while (defined($cell))
  {
    push @_, $cell;

    if (($next = $ZZ{"$cell+d.inside"}) && 
        (!defined($gen{$next}) || ($gen{$next} > $gen)))
    {
      push @stack, $cell, $start;

      $start = get_lastcell($next, "-d.contents");
      # If d.contents is not linked or is a loop, just use $next
      $start = $next if !defined($start) || defined($ZZ{"$start-d.contents"});

      # Mark the new generation
      $gen++;
      $index = $start;
      do
      {
        $gen{$index} = $gen;
        $index = $ZZ{"$index+d.contents"};
      }
      until (!defined($index) || ($index eq $start));

      $cell = $start;
    }
    else # Can't go +d.inside, so find somewhere to go +d.contents
    {
      while (defined($cell) &&
             ((!defined($cell = $ZZ{"$cell+d.contents"})) ||
              ($cell eq $start)))
      {
        $start = pop @stack;
        $cell = pop @stack;
      }
      $gen = $gen{$cell} if defined($cell);
    }
  }
  return @_;
}

sub get_links_to($)
# Returns a list of all the links back to the specified cell
{
  my $cell = $_[0];
  my $index = $ZZ{"$CURSOR_HOME+d.1"}; # Dimension list is +d.1 from Cursor home
  my @result;

  do
  {
    my $dim = $ZZ{$index};
    push @result, $ZZ{"$cell-$dim"} . "+$dim" if defined $ZZ{"$cell-$dim"};
    push @result, $ZZ{"$cell+$dim"} . "-$dim" if defined $ZZ{"$cell+$dim"};
    $index = $ZZ{"$index+d.2"};
    die "Dimension list broken" unless defined $index;
  } until $index = $ZZ{"CURSOR_HOME+d.1"};
  return @result;
}

#
# Multiple-cell operations
# Named do_*
#
sub do_shear($$$;$$) 
# Given a row of cells starting at $first_cell,
# move them all $n cells in the $dir direction.
# Cells that were linked in the $link direction
# have their links broken and relinked to new cells.
#
# Before: do_shear(A1, d.1, d.2, 1);
# 
# ---> d.1
# V d.2
#
# A1 --- B1 --- C1 --- D1 --- E1
# |      |             |      |
# A2 --- B2 --- C2 --- D2 --- E2
#
# After:
#
#        A1 --- B1 --- C1 --- D1 --- E1
#        |      |             |
# A2 --- B2 --- C2 --- D2 --- E2
#
# Optional fourth argument $n defaults to 1.
# Optional fifth argument $hang says whether the cell on the end
# should be linked back at the beginning or whether it should just
# be left hanging.  $hang = false: Back at beginning.  
# $hang = true: Leave hanging.  Default: false.
{
  my ($first_cell, $dir, $link, $n, $hang) = @_;
  $n = 1 unless defined $n;
  $hang = $FALSE unless defined $hang;

  my $cell;
  my ($prev_cell, $prev_linked);
  my $first_linked = $ZZ{"$first_cell$link"};

  my @shear_cells = cells_row($first_cell, $dir);
  my @linked_cells = map {$ZZ{"$_$link"}} @shear_cells;

  my @new_link = @linked_cells;
  # Move some of these from the beginning
  my @x = splice(@new_link, 0, $n);
  # And put them back at the end.
  push @new_link, @x;

  my $i;
  my $linkno = 0;
  my $last_linked;
  # Break all the links
  for ($i=0; $i < @shear_cells; $i++)
  {
    my $old_link = $linked_cells[$i];
    next unless defined $old_link;
    my $shear_cell = $shear_cells[$i];
    link_break($shear_cell, $old_link, $link);
  }

  $linkno = 0;
  for ($i=0; $i < @shear_cells; $i++)
  {
    my $new_link = $new_link[$i];
    next unless defined $new_link;
    next if $i == $#shear_cells && $hang;
    my $shear_cell = $shear_cells[$i];
    link_make($shear_cell,  $new_link, $link);
  }

  display_dirty();
}

#
# Functions that operate on links between cells
# Named link_*
#
sub link_break($$;$)
# Break a link between two cells in a given dimension.
# This should be the only way links are ever broken to ensure consistency.
# Second argument is optional.  If present, it must be linked from cell 1
# in the approprate dimension.
{
  my ($cell1, $cell2, $dim);
  if (@_ == 3)
  { ($cell1, $cell2, $dim) = @_; }
  else
  { ($cell1, $dim) = @_; }
  my ($linked_cell) = $ZZ{"$cell1$dim"};
  if (defined $cell2)
  {
    die "$cell1 is not linked to $cell2 in dimension $dim"
      unless $cell2 == $linked_cell;
  }
  else
  {
    $cell2 = $linked_cell; # Infer second argument
  }

  die "No cell $cell1" unless defined $ZZ{"$cell1"};
  die "No cell $cell2" unless defined $ZZ{"$cell2"};
  die "Invalid direction $dim" unless ($dim =~ /^[+-]/);

  delete($ZZ{"$cell1$dim"});
  delete($ZZ{$cell2 . reverse_sign($dim)});
}

sub link_make($$$)
# Make a link between two cells in a given dimension.
# This should be the only way links are ever made to ensure consistency.
{
  my ($cell1, $cell2, $dim) = @_;
  die "No cell $cell1" unless defined($ZZ{"$cell1"});
  die "No cell $cell2" unless defined($ZZ{"$cell2"});
  die "Invalid direction $dim" unless ($dim =~ /^[+-]/);
  my $back = reverse_sign($dim);
  die "$cell1 already linked" if defined($ZZ{"$cell1$dim"});
  die "$cell2 already linked" if defined($ZZ{"$cell2$back"});

  $ZZ{"$cell1$dim"} = $cell2;
  $ZZ{"$cell2$back"} = $cell1;
}


#
# Functions that operate on individual cells
# Named cell_*
#
sub cell_create($)
# Create a new cell and optionally edit it
{
  my $edit = $_[0];
  my ($curs, $dir) = input_get_direction();
  if ($curs)
  {
    atcursor_insert($curs, $dir);
    cursor_move_direction($curs, $dir);
    atcursor_edit($curs) if $edit;
  }
}

sub cell_insert($$$)
# Insert a cell next to another cell along a given dimension
#
#           Original state                             New state
#           --------------                           -------------
#           $cell1---next
#           $cell2---$cell3                $cell2---$cell1---($cell3 or next)
{
  my ($cell1, $cell2, $dim) = @_;
  die "No cell $cell1" unless defined($ZZ{"$cell1"});
  die "No cell $cell2" unless defined($ZZ{"$cell2"});
  die "Invalid direction $dim" unless ($dim =~ /^[+-]/);
  my $cell3 = $ZZ{"$cell2$dim"};

  # Can't insert if $cell1 has inappropriate neighbours
  if (defined($ZZ{$cell1 . reverse_sign($dim)}) ||
      ((defined($ZZ{"$cell1$dim"}) && defined($cell3))))
  { 
     user_error(2, "$cell1 $dim $cell2"); 
  }
  else
  {
    if (defined($cell3))
    {
       link_break($cell2, $cell3, $dim);
       link_make($cell1, $cell3, $dim);
    }
    link_make($cell2, $cell1, $dim);
  }
}

sub cell_excise($$)
# Remove a cell from a given dimension
{
  my ($cell, $dim) = @_;
  die "No cell $cell" unless defined $ZZ{"$cell"};
  my $prev = $ZZ{"$cell-$dim"};
  my $next = $ZZ{"$cell+$dim"};

  link_break($cell, $prev, "-$dim") if defined($prev);
  link_break($cell, $next, "+$dim") if defined($next);
  link_make($prev, $next, "+$dim") if defined($prev) && defined($next);
}

#
# Functions that operate on the cursor cell
# Named cursor_*
#
sub cursor_move_dimension($$)
# Move cursor along a given dimension
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
  my ($curs, $dim) = @_;
  die "Invalid direction $dim" unless ($dim =~ /^[+-]/);
  my $cell = get_lastcell($curs, "-d.cursor");

  # Don't bother if there's nowhere to go
  return if (!defined($_ = $ZZ{"$cell$dim"}) ||
             ($_ == $cell) || defined $ZZ{"$_-d.cursor"});

  # Now move the cursor
  $cell = get_lastcell($_, "+d.cursor");
  cell_excise($curs, "d.cursor");
  cell_insert($curs, $cell, "+d.cursor");

  display_dirty();
}

sub cursor_jump($$)
# Jump cursor to specified destination
{
  my ($curs, $dest) = @_;

  # Must jump to a valid non-cursor cell
  if (!defined $ZZ{$dest} || defined $ZZ{"$dest-d.cursor"})
  { user_error(3, $dest); }
  else
  {
    # Move the cursor
    cell_excise($curs, "d.cursor");
    cell_insert($curs, get_lastcell($dest, "+d.cursor"), "+d.cursor");

    display_dirty();
  }
}

sub cursor_move_direction($$)
# Move given cursor in a given direction
{
  my $curs = get_cursor($_[0]);

  cursor_move_dimension($curs, get_dimension($curs, $_[1]));
}

#
# Functions that operate on the cell under a cursor
# Named atcursor_*
#
sub atcursor_execute($)
# Execute the contents of a progcell under a given cursor
{
  my $cell;
  foreach $cell (get_contained(get_lastcell(get_cursor($_[0]), "-d.cursor")))
  {
#    $_ = $ZZ{get_lastcell($cell, "-d.clone")};
    $_ = get_cell_contents($cell);
    $@ = "Cell does not start with #";	# Error in case eval isn't done
    if (/^#/)
    {
      db_sync();
      $Command_Count = 0;   # Write cached data to file
      eval;
    }
    last if $@;
  }
  chomp $@;
  user_error(4, $@) if ($@);
}

sub atcursor_clone($;$)
# Clone all the cells in the current selection
# If the current selection is empty, clone just the accursed cell.
# Move the given cursor to the first of the new clones.
# Optional second argument specifies which of several clone-ish operations
# to perform.  Presently supported:  
#  clone: as before
#  copy: copy cells instead of cloning, and copy links also.
{
  my $curs = get_cursor($_[0]);
  my $op = $_[1] || 'clone';
  my $last_new_cell;

  my @selection = get_active_selection;
  if (@selection == 0)
  { @selection = (get_lastcell($curs, "-d.cursor")); }

  my $cell;
  my %new;
  my %selected;
  foreach $cell (@selection)
  {
    my $new = $ZZ{"n"}++;
    $selected{$cell} = 'yup';
    $new{$cell} = $new;
    if ($op eq 'clone')
    {
      $ZZ{$new} = "Clone of $cell";
      cell_insert($new, $cell, "+d.clone");
    }
    elsif ($op eq 'copy')
    {
      $ZZ{$new} = "Copy of " . $ZZ{$cell};
    }
    $last_new_cell = $new;
  }

  # duplicate exactly those links that are from one selected cell to another.
  # FIXME: Needs to be rewritten to use get_links_to() and link_make()
#  my @cell_links = get_links_from(@selection);
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
#      if ($selected{$ZZ{"$old$dim"}})
#      {
#	$ZZ{"$new$dim"} = $new{$ZZ{"$old$dim"}};
#	# Warning:  Doesn't use `link_make'.
#      }
#    }
#  }

  cursor_jump($curs, $last_new_cell);

  display_dirty();
}

sub atcursor_copy($)
# Convenience routine: See atcursor_clone
{
  atcursor_clone($_[0], 'copy');
}

sub atcursor_select($)
# select or unselect the current cell
{
  my $curs = get_cursor($_[0]);
  my $cell = get_lastcell($curs, "-d.cursor");
  my $already_selected = is_selected($cell);
  my $which_selection =  get_which_selection($cell) if $already_selected;

  cell_excise($cell, "d.mark");

  # If it wasn't already selected in the active selection, deselect it.
  # (The excise did this already, so we need only print a message.)
  # Otherwise add it to the active selection and deliver a message.
  if ($already_selected && $which_selection == $SELECT_HOME)
  {
    display_status_draw("Deselected cell $cell");      
  }
  else
  {    
    cell_insert($cell, $SELECT_HOME, "+d.mark");
    display_status_draw("Selected cell $cell");
  }
  #cursor_move_dimension($curs, "+d.mark");

  display_dirty();
}

sub rotate_selection () 
# Exchange the current selection with one of the saved selections.  If
# there's an input buffer, it holds the number of the desired
# selection, so shear all the selections +d.2ward by that many.
# (Selection #0 is currently active.)  Otherwise, just shear by 1.
{
  my $shear_count = (defined($Input_Buffer) ? $Input_Buffer : 1);
#  my $num_selections = cells_row($SELECT_HOME, "+d.2");
  
  do_shear($SELECT_HOME, '-d.2', '+d.mark', $shear_count);
  undef $Input_Buffer;
}

sub push_selection()
# Push the current selection onto the selection stack.
# All saved selections move +d.2ward one step.
# The current selection is now empty.
{  
  my $new_sel = $ZZ{"n"}++;
  my $num_selections = cells_row($SELECT_HOME, "+d.2");
  $ZZ{$new_sel} = "Selection #$num_selections";
  cell_insert($new_sel, $SELECT_HOME, "+d.2");
  do_shear($SELECT_HOME, "+d.2", "+d.mark", 1);
}


sub atcursor_insert($$)
# Insert a new cell at a given cursor in a given direction
{
  my $curs = get_cursor($_[0]);
  my $dim = get_dimension($curs, $_[1]);

  # Can't insert if it's the cursor or clone dimension
  if ($dim =~ /^[+-]d\.(clone|cursor)$/)
  {
     user_error(9, $dim);
  }
  else
  {
    my $new = $ZZ{"n"}++;
    $ZZ{$new} = "$new";		# Initial contents will be cell number
    cell_insert($new, get_lastcell($curs, "-d.cursor"), $dim);

    display_dirty();
  }
}

sub atcursor_delete($)
# Delete the cell under a given cursor
{
  my $curs = get_cursor($_[0]);
  my $cell = get_lastcell($curs, "-d.cursor");
  my $index = $ZZ{"$CURSOR_HOME+d.1"}; # Dimension list is +d.1 from Cursor home
  my $neighbour;

  # Pass the torch if this cell has clone(s)
  if (!defined $ZZ{"$cell-d.clone"} && ($_ = $ZZ{"$cell+d.clone"}))
  { $ZZ{$_} = $ZZ{$cell}; }

  do
  {
    my $dim = $ZZ{$index};
    # Try and find any valid non-cursor neighbour
    $neighbour = $_ unless defined $neighbour
      || ((!defined($_ = $ZZ{"$cell-$dim"})
          || ($_ eq $cell)
          || defined $ZZ{"$_-d.cursor"})
        && (!defined($_ = $ZZ{"$cell+$dim"})
          || ($_ eq $cell)
          || defined $ZZ{"$_-d.cursor"}));

    # Excise $cell from dimension $dim
    cell_excise($cell, $dim);

    # Proceed to the next dimension
    $index = $ZZ{"$index+d.2"};
    die "Dimension list broken" unless defined $index;
  } until ($index == $ZZ{"$CURSOR_HOME+d.1"});
  $neighbour = 0 unless defined $neighbour;

  # Move $cell to the deleted stack
  cell_insert($cell, $DELETE_HOME, "+d.2");

  # Move the cursor to any $neighbour or home if none
  $cell = get_lastcell($neighbour, "+d.cursor");
  cell_insert($curs, $cell, "+d.cursor");

  display_dirty();
}

sub atcursor_hop(@)
# Hop a cell at a given cursor in a given direction
#
#           Original state                             New state
#           --------------                           -------------
# $prev---$cell---$neighbour---$next        $prev---$neighbour---$cell---$next
{
  my $curs = get_cursor($_[0]);
  my $dim = get_dimension($curs, $_[1]);

  # Not in the Cursor dimension!
  return if $dim eq "d.cursor";

  my $cell = get_lastcell($curs, "-d.cursor");
  my $neighbour = $ZZ{"$cell$dim"};
  if (!defined $neighbour)
  { 
     user_error(5, "$cell$dim"); 
  }
  else
  {
    my $prev = $ZZ{$cell . reverse_sign($dim)};
    my $next = $ZZ{"$neighbour$dim"};

    link_break($cell, $neighbour, $dim);
    if (defined $prev)
    {
      link_break($prev, $cell, $dim);
      link_make($prev, $neighbour, $dim);
    }
    if (defined $next)
    {
      link_break($neighbour, $next, $dim);
      link_make($cell, $next, $dim);
    }
    link_make($neighbour, $cell, $dim);
    
    display_dirty();
  }
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

  do_shear($headcell, $shear_dim, $link_dim, 1);
}

sub atcursor_make_link($$)
# Link two cells along a given dimension
{
  my $curs = get_cursor($_[0]);
  my $dim = get_dimension($curs, $_[1]);

  # Not in the Cursor dimension!
  return if $dim eq "d.cursor";

  # If no cell number selected, just move the cursor instead
  if (!defined $Input_Buffer)
  {
     cursor_move_dimension($curs, $dim);
  }
  elsif (!defined $ZZ{$Input_Buffer})
  {
     user_error(6, $Input_Buffer);
  }
  else
  {
    cell_insert($Input_Buffer, get_lastcell($curs, "-d.cursor"), $dim);
    undef $Input_Buffer;

    display_dirty();
  }
}

sub atcursor_break_link(@)
# Break a link in a given dimension
{
  my $curs = get_cursor($_[0]);
  my $dim = get_dimension($curs, $_[1]);
  my $cell = get_lastcell($curs, "-d.cursor");

  # Not in the Cursor dimension!
  return if $dim eq "d.cursor";

  # First check that there is an existing link
  if (!defined($_ = $ZZ{"$cell$dim"}))
  {
     user_error(7, "$cell$dim");
  }
  else
  {
    link_break($cell, $_, $dim);

    display_dirty();
  }
}

#
# Functions that operate on groups of cells in a given dimension
# Named: cells_*
# (bad name?)
#
sub cells_row($$) 
# Find all the cells in the row starting from $cell
# in the $dir dimension.  Return a list or a count
# depending on calling context.
{
  my ($cell1, $dir) = @_;

  return if (!defined $cell1);

  my $cell;
  my @result = ($cell1);
  for ($cell = $ZZ{"$cell1$dir"}; 
       defined($cell) && $cell != $cell1; 
       $cell = $ZZ{"$cell$dir"}
      )
  { push @result, $cell; }
  @result;
}

# Functions that lay out cells in a window
# Named: layout_*
#
sub layout_cells_horizontal($$$$$)
# Layout cells horizontally at row starting at cell
{
  my ($lref, $cell, $row, $dim, $sign) = @_;

  # Layout at most half a screen of cells
  for (my $i = 1; defined $cell && ($i <= int($Hcells / 2)); $i++)
  {
    # Find the next cell, if any
    if (defined ($cell = $ZZ{"$cell$dim"}))
    {
      my $col = $sign * $i;
      $$lref{"$col,$row"} = $cell;
      $$lref{"$col-$row"} = $TRUE;
    }
  }
}

sub layout_cells_vertical($$$$$)
# Layout cells vertically at col starting at cell
{
  my ($lref, $cell, $col, $dim, $sign) = @_;

  # Layout at most half a screen of cells
  for (my $i = 1; defined $cell && ($i <= int($Vcells / 2)); $i++)
  {
    # Find the next cell, if any
    if (defined ($cell = $ZZ{"$cell$dim"}))
    {
      my $row = $sign * $i;
      $$lref{"$col,$row"} = $cell;
      $$lref{"$col|$row"} = $TRUE;
    }
  }
}

sub layout_preview($$$$)
# Layout a preview of the window starting at cell
{
  my ($lref, $cell, $right, $down) = @_;

  $$lref{"0,0"} = $cell;
  layout_cells_horizontal($lref, $cell, 0, reverse_sign($right), -1);
  layout_cells_vertical($lref, $cell, 0, reverse_sign($down), -1);
  layout_cells_horizontal($lref, $cell, 0, $right, 1);
  layout_cells_vertical($lref, $cell, 0, $down, 1);
}

sub layout_Iraster($$$$)
# Horizontal ("I raster") window layout starting at cell
{
  my ($lref, $cell, $right, $down) = @_;
  my $left = reverse_sign($right);
  my $up = reverse_sign($down);
  my ($y, $i);

  $$lref{"0,0"} = $cell;
  layout_cells_horizontal($lref, $cell, 0, $left, -1);
  layout_cells_horizontal($lref, $cell, 0, $right, 1);

  for ($y = 1, $i = $cell; defined $i && ($y <= int($Vcells / 2)); $y++)
  {
    # Find the next cell above, if any
    if (defined $i && defined ($i = $ZZ{"$i$up"}))
    {
      $$lref{"0,-$y"} = $i;
      $$lref{"0|-$y"} = $TRUE;
      layout_cells_horizontal($lref, $i, -$y, $left, -1);
      layout_cells_horizontal($lref, $i, -$y, $right, 1);
    }
  }
  
  for ($y = 1, $i = $cell; defined $i && ($y <= int($Vcells / 2)); $y++)
  {
    # Find the next cell below, if any
    if (defined $i && defined ($i = $ZZ{"$i$down"}))
    {
      $$lref{"0,$y"} = $i;
      $$lref{"0|$y"} = $TRUE;
      layout_cells_horizontal($lref, $i, $y, $left, -1);
      layout_cells_horizontal($lref, $i, $y, $right, 1);
    }
  }
}

sub layout_Hraster($$$$)
# Vertical ("H raster") window layout starting at cell
{
  my ($lref, $cell, $right, $down) = @_;
  my $left = reverse_sign($right);
  my $up = reverse_sign($down);
  my ($x, $i);

  $$lref{"0,0"} = $cell;
  layout_cells_vertical($lref, $cell, 0, $up, -1);
  layout_cells_vertical($lref, $cell, 0, $down, 1);

  for ($x = 1, $i = $cell; defined $i && ($x <= int($Hcells / 2)); $x++)
  {
    # Find the next cell to the left, if any
    if (defined $i && defined ($i = $ZZ{"$i$left"}))
    {
      $$lref{"-$x,0"} = $i;
      $$lref{"-$x-0"} = $TRUE;
      layout_cells_vertical($lref, $i, -$x, $up, -1);
      layout_cells_vertical($lref, $i, -$x, $down, 1);
    }
  }

  for ($x = 1, $i = $cell; defined $i && ($x <= int($Hcells / 2)); $x++)
  {
    # Find the next cell to the right, if any
    if (defined $i && defined ($i = $ZZ{"$i$right"}))
    {
      $$lref{"$x,0"} = $i;
      $$lref{"$x-0"} = $TRUE;
      layout_cells_vertical($lref, $i, $x, $up, -1);
      layout_cells_vertical($lref, $i, $x, $down, 1);
    }
  }
}


#
# View functions.  These munge options which control how the
# window_draw_* functions work.
# Named: view_*
#
sub view_quadrant_toggle($)
# Toggle quadrant display style for given window
{
  my $cell = get_cursor($_[0]);
  $cell = $ZZ{"$cell+d.1"};
  $cell = $ZZ{"$cell+d.1"};
  $cell = $ZZ{"$cell+d.1"};
  $cell = $ZZ{"$cell+d.1"};

  if ($ZZ{$cell} =~ /Q$/)
  { $ZZ{$cell} = substr($ZZ{$cell}, 0, 1); }
  else
  { $ZZ{$cell} .= "Q"; }

  display_dirty();
}

sub view_raster_toggle($)
# Toggle redraw style for given window
{
  my $cell = get_cursor($_[0]);
  $cell = $ZZ{"$cell+d.1"};
  $cell = $ZZ{"$cell+d.1"};
  $cell = $ZZ{"$cell+d.1"};
  $cell = $ZZ{"$cell+d.1"};

  # Toggle the value between "I" and "H"
  $ZZ{$cell} =~ tr/IH/HI/;

  display_dirty();
}

sub view_reset($)
# Reset dimensions of given cursor
{
  my ($number) = @_;
  my $curs = get_cursor($number);
  my $index = $ZZ{"$CURSOR_HOME+d.1"}; # Dimension list is +d.1 from Cursor home

  $ZZ{$curs = $ZZ{"$curs+d.1"}} = "+$ZZ{$index}";
  $ZZ{$curs = $ZZ{"$curs+d.1"}} = "+" . $ZZ{$index = $ZZ{"$index+d.2"}};
  $ZZ{$curs = $ZZ{"$curs+d.1"}} = "+" . $ZZ{$index = $ZZ{"$index+d.2"}};

  display_dirty();
}

sub view_rotate($$)
# Rotate dimensions of given cursor around given axis
{
  my ($number, $axis) = @_;
  my $curs = get_cursor($number);
  die "Invalid axis $axis" unless $axis =~ /^[XYZ]$/;
  $curs = $ZZ{"$curs+d.1"};
  $curs = $ZZ{"$curs+d.1"} if $axis ne "X";
  $curs = $ZZ{"$curs+d.1"} if $axis eq "Z";
  my $dim = substr($ZZ{$curs}, 1);
  my $index = $ZZ{"$CURSOR_HOME+d.1"}; # Dimension list is +d.1 from Cursor home

  # Find the current dimension
  while ($ZZ{$index} ne $dim)
  {
    $index = $ZZ{"$index+d.2"};
    die "Dimension list broken" unless defined $index;
    die "Dimension $dim not found" if ($index == $ZZ{"$CURSOR_HOME+d.1"});
  }

  $ZZ{$curs} = substr($ZZ{$curs}, 0, 1) . $ZZ{$ZZ{"$index+d.2"}};
  display_dirty();
}

sub view_flip($$)
# Invert sign of given cursor and dimension
{
  my ($number, $axis) = @_;
  my $curs = get_cursor($number);
  $curs = $ZZ{"$curs+d.1"};
  $curs = $ZZ{"$curs+d.1"} if $axis ne "X";
  $curs = $ZZ{"$curs+d.1"} if $axis eq "Z";

  $ZZ{$curs} = reverse_sign($ZZ{$curs});
  display_dirty();
}

$TRUE;
#
# End of ZZ.pl
#