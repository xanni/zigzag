# Xanadu(R) Zigzag(tm) Hyperstructure Kit, $Revision: 0.71 $
#
# Designed by Ted Nelson
# Programmed by Andrew Pam ("xanni") and Bek Oberin ("gossamer")
# Copyright (c) 1997-2025 Project Xanadu
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
# This file "Zigzag.pm" contains the implementation of the Zigzag data
# structures and operations.  User interfaces for interactive manipulation of
# the Zigzag data structures can be created using the operations defined in
# this file.  Example interfaces include "zigzag" (a text-based interface using
# Curses) and "zizl" (a web-based interface using HTML and HTTP).
#
# ===================== Change Log
#
# Inital Zigzag implementation
# $Id: Zigzag.pm,v 0.71 2025/05/30 01:07:00 xanni Exp $
#
# $Log: Zigzag.pm,v $
# Revision 0.71  2025/05/30 01:07:00  xanni
# * Added unit tests and fixed bugs in is_clone(), dimension_rename()
#   and cell_new()
#
# Revision 0.70  1999/05/14 13:43:21  xanni
# * Imported atcursor_edit from front end
# * Implemented dimension_home()
# * Minor fix to add_contents()
# * Replaced $DB_Ref and %ZZ globals with @Filename, @DB_Ref and @Hash_Ref
# * Implemented cell_slice()
# * Replaced direct access to %ZZ with cell_get(), cell_set() and cell_nbr()
# * Replaced db_open(), db_close() and db_sync() with
#   slice_open(), slice_close(), slice_close_all() and slice_sync_all()
# * Renamed db_upgrade() to slice_upgrade()
#
# Revision 0.69  1999/05/09 12:19:53  xanni
# Fixed view_rotate() to handle hidden dimensions, rewrote get_contained()
#
# Revision 0.68  1999/03/13 13:05:04  xanni
# Implemented is_essential(), cell_find() and dimension_rename()
# Implemented dimension_find() to replace dimension_exists()
# atcursor_delete() now checks for essential cells and dimensions
# Improved db_upgrade(), miscellaneous minor cleanup
#
# Revision 0.67  1999/03/13 05:01:31  xanni
# Minor naming fixes, moved cell_create() to front-end
# Made recycle pile a circular queue, reused oldest cell first
# Implemented db_upgrade(), dimension_exists() and cell_new()
#
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

package Zigzag;
use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw
  (
    $Command_Count $Hcells $Vcells $Input_Buffer
    slice_open
    slice_close
    slice_close_all
    slice_sync_all
    reverse_sign
    wordbreak
    is_cursor
    is_clone
    is_selected
    is_active_selected
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
    cell_get
    cell_set
    cell_nbr
    cell_insert
    cell_new
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
@EXPORT_OK = qw(link_make link_break is_essential cell_excise cell_find
		dimension_find dimension_home dimension_is_essential);

use integer;
use strict;
use POSIX;
use DB_File;
#use Fcntl;
use File::Copy;

# Import functions
*atcursor_edit = *::atcursor_edit;
*display_dirty = *::display_dirty;
*display_status_draw = *::display_status_draw;
*user_error = *::user_error;

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
$VERSION = do { my @r = (q$Revision: 0.71 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker
my $FALSE = 0;
my $TRUE = !$FALSE;
my $CURSOR_HOME = 10;           # NOTE!  This assumes it stays fixed!
my $SELECT_HOME = 21;           # NOTE!  This assumes it stays fixed!
my $DELETE_HOME = 99;           # NOTE!  This assumes it stays fixed!
my $FILENAME = "zigzag.zz";     # Default filename for initial slice
my $ZZMAIL_SUPPORT = $FALSE;	# Enable preliminary ZZmail support
#my $COMMAND_SYNC_COUNT = 20;    # Sync the DB after this many commands
my $BACKUP_FILE_SUFFIX = ".bak";

# Declare globals
use vars qw($Command_Count $Hcells $Vcells $Input_Buffer);

#my $Input_Buffer;               # Cell number entered from the keyboard
#my $Command_Count;              # Counts commands between DB syncs
our @Filename;			# Array of filenames
our @DB_Ref;			# Array of database references
our @Hash_Ref;			# Array of hash references
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
   11 =>        "Menu",
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
   16 =>        "Event",
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
      "99-d.2" =>	99,
      "99+d.2" =>	99,
   "n" =>        100
   );
}

sub slice_upgrade()
# Perform any upgrades necessary to maintain backward compatibility
# with old home slices
{
  # Earlier than v0.44.1.1 not presently supported due to
  # massive dimension renaming
  die "Sorry, this data file predates Zigzag v0.44.1.1.\n"
    unless dimension_find("d.1");

  # Change to current dimension names (from v0.50)
  dimension_rename("d.Cursor", "d.cursor");
  dimension_rename("d.Clone", "d.clone");
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
  # There's a default filename for the first (home) slice
  $Filename = $FILENAME if (not defined $Filename) and ($#Filename < 0);
  if (-e $Filename)
  {
    # we have an existing datafile - back it up!
    move($Filename, $Filename . $BACKUP_FILE_SUFFIX)
      || die "Can't rename data file \"$Filename\": $!\n";
    copy($Filename . $BACKUP_FILE_SUFFIX, $Filename)
      || die "Can't copy data file \"$Filename\": $!\n";
    $DB_Ref = tie %hash, 'DB_File', $Filename, O_RDWR
      || die "Can't open data file \"$Filename\": $!\n";
    push @Hash_Ref, \%hash;
    slice_upgrade() if $#DB_Ref < 0;
  }
  else
  {
    # no initial data file
    $DB_Ref = tie %hash, 'DB_File', $Filename, O_RDWR | O_CREAT
      || die "Can't create data file \"$Filename\": $!\n";
    # resort to initial geometry for first (home) slice
    %hash = initial_geometry() if $#Hash_Ref < 0;
    push @Hash_Ref, \%hash;
  }
  push @Filename, $Filename;
  push @DB_Ref, $DB_Ref;
}

sub slice_close($)
{
  my $num = shift;
  undef $DB_Ref[$num];
  untie %{$Hash_Ref[$num]};
  splice @Filename, $num, 1;
  splice @DB_Ref, $num, 1;
  splice @Hash_Ref, $num, 1;
}

sub slice_close_all()
{
  my $DB_Ref;
  while (defined ($DB_Ref = pop @DB_Ref))
  {
    pop @Filename;
    undef $DB_Ref;
    untie %{pop @Hash_Ref};
  }
}

sub slice_sync_all()
{
  foreach (@DB_Ref)
  { $_->sync(); }
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
  return (defined(cell_nbr($cell, "-d.cursor")) ||
	  defined(cell_nbr($cell, "+d.cursor")));
}

sub is_clone($)
{
  my $cell = shift;
  return (defined(cell_nbr($cell, "-d.clone")) ||
	  defined(cell_nbr($cell, "+d.clone")));
}

sub is_selected($)
{
  my $cell = shift;
  my $headcell = get_lastcell($cell, "-d.mark");
  return $headcell != $cell
    && defined get_distance($headcell, "+d.2", $SELECT_HOME);
}

sub is_active_selected($)
{
  my $cell = shift;
  my $headcell = get_lastcell($cell, "-d.mark");
  return $headcell == $SELECT_HOME && $headcell != $cell;
}

sub is_essential($)
{
  my $cell = shift;
  return (($cell == 0) or ($cell == $CURSOR_HOME) or
    ($cell == $DELETE_HOME) or ($cell == $SELECT_HOME));
}


sub dimension_is_essential($)
{
  return $_[0] =~ /^[+-]?d\.(1|2|cursor|clone|inside|contents|mark)$/;
}

sub dimension_home()
{
  # Dimension list is +d.1 from Cursor home
  return cell_nbr($CURSOR_HOME, "+d.1");
}

sub dimension_find($)
{
  return cell_find(dimension_home(), "+d.2", $_[0]);
}

sub dimension_rename($$)
# Rename an entire dimension.  Warning - traverses all cells!
{
  my ($d_orig, $d_new) = @_;
  my $cell = dimension_find($d_orig);

  if ($cell and not dimension_find($d_new))
  {
    print STDERR "Renaming dimension $d_orig to $d_new.  Please wait...";
    cell_set($cell, $d_new);

    foreach my $slice_hash_ref (@Hash_Ref) {
      my @keys_to_rename = grep { /\Q$d_orig\E$/ } keys %$slice_hash_ref;
            
      foreach my $old_key (@keys_to_rename) {
          (my $new_key = $old_key) =~ s/\Q$d_orig\E$/$d_new/;
          $slice_hash_ref->{$new_key} = delete $slice_hash_ref->{$old_key};
      }
    }
    print STDERR "done.\n";
  }
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
  { $sel = cell_nbr($sel, "+d.2"); }

  cells_row(cell_nbr($sel, "+d.mark"), "+d.mark");
}

sub get_which_selection($) 
# Given a cell, get the headcell of the selection it is in, or undef
# if it is not part of a selection
{
  my $cell = shift;
  return undef unless defined cell_nbr($cell, "-d.mark");
  get_lastcell($cell, "-d.mark");
}

sub get_lastcell($$)
# Find the last cell in a given direction
{
  my ($cell, $dir) = @_;
  die "No cell $cell" unless defined(cell_get($cell));
  die "Invalid direction $dir" unless ($dir =~ /^[+-]/);

  # Follow links to the end or until we return to where we started
  $cell = $_ while defined($_ = cell_nbr($cell, $dir)) && ($_ != $_[0]);
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
  for ($cell = cell_nbr($start, $dir);
       defined $cell && $cell != $end && $cell != $start;
       $cell = cell_nbr($cell, $dir)
      )
  { $dist++; }
  return undef if !defined($cell) || $cell == $start;
  return $dist;
}

sub get_outline_parent($)
# Find the "outline parent" (first cell -d.1 along -d.2) of a cell
{
  my $cell = $_[0];
  die "No cell $cell" unless defined(cell_get($cell));

  # Move -d.2 until we find a -d.1 link or return to where we started
  $cell = $_ while (!defined(cell_nbr($cell, "-d.1")) &&
		    defined($_ = cell_nbr($cell, "-d.2")) && ($_ != $_[0]));
  $cell = $_ if defined($_ = cell_nbr($cell, "-d.1"));
  return $cell;
}

sub get_cell_contents($)
# Return the contents of a cell
{
  my $cell = $_[0];
  die "No cell $cell" unless defined(cell_get($cell));
  my $contents = cell_get(get_lastcell($cell, "-d.clone"));

  if ($ZZMAIL_SUPPORT && $contents =~ /^\[(\d+)\+(\d+)\]/)
  # Note 1: This should handle pointer lists, but currently only handles
  #         the first pointer.
  # Note 2: This performs extremely badly for large primedia.  It should
  #         make requests to an OSMIC server instead.
  {
    my $pos = $1;
    my $len = $2;
    my $PRIMEDIA = cell_get(get_outline_parent($cell));
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
  { $cell = cell_nbr($cell, "+d.2"); }
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

  $curs = cell_nbr($curs, "+d.1");
  if ($dir eq "L")
  { return reverse_sign(cell_get($curs)); }
  if ($dir eq "R")
  { return cell_get($curs); }
  $curs = cell_nbr($curs, "+d.1");
  if ($dir eq "U")
  { return reverse_sign(cell_get($curs)); }
  if ($dir eq "D")
  { return cell_get($curs); }
  $curs = cell_nbr($curs, "+d.1");
  if ($dir eq "I")
  { return reverse_sign(cell_get($curs)); }
  if ($dir eq "O")
  { return cell_get($curs); }
}

sub add_contents($$$)
# Add list of cells "contained" within a cell to a referenced list and hash
{
  my ($start, $listref, $hashref) = @_;
  push @$listref, $start;
  $hashref->{$start} = $TRUE;

  my $cell = cell_nbr($start, "+d.inside");
  while (defined $cell and not defined $hashref->{$cell})
  {
    push @$listref, $cell;
    $hashref->{$cell} = $TRUE;

    my $index = cell_nbr($cell, "+d.contents");
    while (defined $index and
	   not defined $hashref->{$index} and
	   not defined cell_nbr($index, "-d.inside"))
    {
      add_contents($index, $listref, $hashref);
      $index = cell_nbr($index, "+d.contents");
    }

    $cell = cell_nbr($cell, "+d.inside");
  }
}

sub get_contained($)
# Return list of cells "contained" within a cell
{
  my @list;
  my %hash;
  add_contents($_[0], \@list, \%hash);
  return @list;
}

sub get_links_to($)
# Returns a list of all the links back to the specified cell
{
  my $cell = $_[0];
  my $index = dimension_home();
  my @result;

  do
  {
    my $dim = cell_get($index);
    push @result, cell_nbr($cell, "-$dim") . "+$dim"
      if defined cell_nbr($cell, "-$dim");
    push @result, cell_nbr($cell, "+$dim") . "-$dim"
      if defined cell_nbr($cell, "+$dim");
    $index = cell_nbr($index, "+d.2");
    die "Dimension list broken" unless defined $index;
  } until $index == dimension_home();
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
  my $first_linked = cell_nbr($first_cell, $link);

  my @shear_cells = cells_row($first_cell, $dir);
  my @linked_cells = map {cell_nbr($_, $link)} @shear_cells;

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
# Break a link between two cells in a given direction.
# To ensure consistency, this should be the only way links are ever broken
# Second argument is optional.  If present, it must be linked from cell 1
# in the approprate dimension.
{
  my ($cell1, $cell2, $dir, $slice);

  if (@_ == 3)
  {
    ($cell1, $cell2, $dir) = @_;
    die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
    $slice = cell_slice("$cell1$dir");
    die "$cell1 has no link in direction $dir" unless defined $slice;
    die "$cell1 is not linked to $cell2 in direction $dir"
      unless $cell2 == $Hash_Ref[$slice]{"$cell1$dir"};
  }
  else
  {
    ($cell1, $dir) = @_;
    die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
    $slice = cell_slice("$cell1$dir");
    die "$cell1 has no link in direction $dir" unless defined $slice;
    $cell2 = $Hash_Ref[$slice]{"$cell1$dir"}; # Infer second argument
  }

  die "No cell $cell1" unless defined cell_get($cell1);
  die "No cell $cell2" unless defined cell_get($cell2);

  delete $Hash_Ref[$slice]{"$cell1$dir"};
  $dir = reverse_sign($dir);
  delete $Hash_Ref[cell_slice("$cell2$dir")]{"$cell2$dir"};
}

sub link_make($$$)
# Make a link between two cells in a given direction.
# To ensure consistency, this should be the only way links are ever made
{
  my ($cell1, $cell2, $dir) = @_;
  die "No cell $cell1" unless defined cell_get($cell1);
  die "No cell $cell2" unless defined cell_get($cell2);
  die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
  my $back = reverse_sign($dir);
  die "$cell1 already linked" if defined cell_nbr($cell1, $dir);
  die "$cell2 already linked" if defined cell_nbr($cell2, $back);

  $Hash_Ref[cell_slice($cell1)]{"$cell1$dir"} = $cell2;
  $Hash_Ref[cell_slice($cell2)]{"$cell2$back"} = $cell1;
}


#
# Functions that operate on individual cells
# Named cell_*
#
sub cell_slice($)
# Returns the slice in which a cell resides
{
  my $slice = 0;
  my $found;
  do
  { $found = defined $Hash_Ref[$slice++]{$_[0]}; }
  until ($found or $slice > $#Hash_Ref);
  return $found ? $slice - 1 : undef;
}

sub cell_get($)
# Retrieve cell contents
{
  my $slice = cell_slice($_[0]);
  return (defined $slice) ? $Hash_Ref[$slice]{$_[0]} : undef;
}

sub cell_set($$)
# Set cell contents
{
  my $slice = cell_slice($_[0]);
  die "No cell $_[0]" unless defined $slice;
  $Hash_Ref[$slice]{$_[0]} = $_[1];
}

sub cell_nbr($$)
# Follow link from cell
{
  my $slice = cell_slice("$_[0]$_[1]");
  return (defined $slice) ? $Hash_Ref[$slice]{"$_[0]$_[1]"} : undef;
}

sub cell_insert($$$)
# Insert a cell next to another cell in a given direction
#
#           Original state                             New state
#           --------------                           -------------
#           $cell1---next
#           $cell2---$cell3                $cell2---$cell1---($cell3 or next)
{
  my ($cell1, $cell2, $dir) = @_;
  die "No cell $cell1" unless defined(cell_get($cell1));
  die "No cell $cell2" unless defined(cell_get($cell2));
  die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
  my $cell3 = cell_nbr($cell2, $dir);

  # Can't insert if $cell1 has inappropriate neighbours
  if (defined(cell_nbr($cell1, reverse_sign($dir))) ||
      ((defined(cell_nbr($cell1, $dir)) && defined($cell3))))
  { user_error(2, "$cell1 $dir $cell2"); }
  else
  {
    if (defined($cell3))
    {
      link_break($cell2, $cell3, $dir);
      link_make($cell1, $cell3, $dir);
    }
    link_make($cell2, $cell1, $dir);
  }
}

sub cell_find($$$)
# From a starting cell, travel a given direction to find given cell contents
{
  my ($start, $dir, $contents) = @_;
  die "Invalid direction $dir" unless ($dir =~ /^[+-]/);
  my $cell = $start;
  my $found = $FALSE;

  # Follow links until we find a match or return to where we started
  do
  {
    $found = $cell if (defined $cell) and (cell_get($cell) eq $contents);
    $cell = cell_nbr($cell, $dir);
  } until $found or (not defined $cell) or ($cell == $start);
  return $found;
}

sub cell_excise($$)
# Remove a cell from a given dimension
{
  my ($cell, $dim) = @_;
  die "No cell $cell" unless defined cell_get($cell);
  my $prev = cell_nbr($cell, "-$dim");
  my $next = cell_nbr($cell, "+$dim");

  link_break($cell, $prev, "-$dim") if defined($prev);
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

  # Assign contents of cell (defaults to the cell number)
  $Hash_Ref[0]{$new} = (defined $_[0]) ? $_[0] : $new;

  return $new;
}

#
# Functions that operate on the cursor cell
# Named cursor_*
#
sub cursor_move_dimension($$)
# Move cursor in a given direction
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

  # Don't bother if there's nowhere to go
  return if (!defined($_ = cell_nbr($cell, $dir)) ||
             ($_ == $cell) || defined cell_nbr($_, "-d.cursor"));

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
  if (!defined cell_get($dest) || defined cell_nbr($dest, "-d.cursor"))
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
#    $_ = cell_get(get_lastcell($cell, "-d.clone"));
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
    my $new = cell_new();
    $new{$cell} = $new;
    $selected{$cell} = 'yup';
    if ($op eq 'clone')
    {
      cell_set($new, "Clone of $cell");
      cell_insert($new, $cell, "+d.clone");
    }
    elsif ($op eq 'copy')
    {
      cell_set($new, "Copy of " . cell_get($cell));
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
#      if ($selected{cell_nbr($old, $dim)})
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
  my $num_selections = cells_row($SELECT_HOME, "+d.2");
  my $new_sel = cell_new("Selection #$num_selections");
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

  if (is_essential($cell))
  {
    user_error(10);
  }
  elsif ((cell_find($cell, "-d.2", cell_get($dhome)) == $dhome) and
    dimension_is_essential(cell_get($cell)))
  {
    user_error(11, cell_get($cell))
  }
  else
  {
    # Pass the torch if this cell has clone(s)
    if (!defined cell_nbr($cell, "-d.clone") &&
	($_ = cell_nbr($cell, "+d.clone")))
    { cell_set($_, cell_get($cell)); }
  
    do
    {
      my $dim = cell_get($index);
      # Try and find any valid non-cursor neighbour
      $neighbour = $_ unless defined $neighbour
        || ((!defined($_ = cell_nbr($cell, "-$dim"))
            || ($_ == $cell)
            || defined cell_nbr($_, "-d.cursor"))
          && (!defined($_ = cell_nbr($cell, "+$dim"))
            || ($_ == $cell)
            || defined cell_nbr($_, "-d.cursor")));
  
      # Excise $cell from dimension $dim
      cell_excise($cell, $dim);
  
      # Proceed to the next dimension
      $index = cell_nbr($index, "+d.2");
      die "Dimension list broken" unless defined $index;
    } until ($index == $dhome);
    $neighbour = 0 unless defined $neighbour;
  
    # Move $cell to the recycle pile
    cell_insert($cell, $DELETE_HOME, "+d.2");
  
    # Move the cursor to any $neighbour or home if none
    $cell = get_lastcell($neighbour, "+d.cursor");
    cell_insert($curs, $cell, "+d.cursor");

    display_dirty();
  }
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
  my $neighbour = cell_nbr($cell, $dim);
  if (!defined $neighbour)
  { 
     user_error(5, "$cell$dim"); 
  }
  else
  {
    my $prev = cell_nbr($cell, reverse_sign($dim));
    my $next = cell_nbr($neighbour, $dim);

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
  elsif (!defined cell_get($Input_Buffer))
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
  if (!defined($_ = cell_nbr($cell, $dim)))
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
  for ($cell = cell_nbr($cell1, $dir); 
       defined($cell) && $cell != $cell1; 
       $cell = cell_nbr($cell, $dir)
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
    if (defined ($cell = cell_nbr($cell, $dim)))
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
    if (defined ($cell = cell_nbr($cell, $dim)))
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
    if (defined $i && defined ($i = cell_nbr($i, $up)))
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
    if (defined $i && defined ($i = cell_nbr($i, $down)))
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
    if (defined $i && defined ($i = cell_nbr($i, $left)))
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
    if (defined $i && defined ($i = cell_nbr($i, $right)))
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
  $cell = cell_nbr($cell, "+d.1");
  $cell = cell_nbr($cell, "+d.1");
  $cell = cell_nbr($cell, "+d.1");
  $cell = cell_nbr($cell, "+d.1");

  if (cell_get($cell) =~ /Q$/)
  { cell_set($cell, substr(cell_get($cell), 0, 1)); }
  else
  { cell_set($cell, cell_get($cell) . "Q"); }

  display_dirty();
}

sub view_raster_toggle($)
# Toggle redraw style for given window
{
  my $cell = get_cursor($_[0]);
  $cell = cell_nbr($cell, "+d.1");
  $cell = cell_nbr($cell, "+d.1");
  $cell = cell_nbr($cell, "+d.1");
  $cell = cell_nbr($cell, "+d.1");

  # Toggle the value between "I" and "H"
  $_ = cell_get($cell);
  tr/IH/HI/;
  cell_set($cell, $_);

  display_dirty();
}

sub view_reset($)
# Reset dimensions of given cursor
{
  my ($number) = @_;
  my $curs = get_cursor($number);
  my $index = dimension_home();

  cell_set($curs = cell_nbr($curs, "+d.1"), "+" . cell_get($index));
  cell_set($curs = cell_nbr($curs, "+d.1"),
	   "+" . cell_get($index = cell_nbr($index, "+d.2")));
  cell_set($curs = cell_nbr($curs, "+d.1"),
	   "+" . cell_get($index = cell_nbr($index, "+d.2")));

  display_dirty();
}

sub view_rotate($$)
# Rotate dimensions of given cursor around given axis
{
  my ($number, $axis) = @_;
  my $curs = get_cursor($number);
  die "Invalid axis $axis" unless $axis =~ /^[XYZ]$/;
  $curs = cell_nbr($curs, "+d.1");
  $curs = cell_nbr($curs, "+d.1") if $axis ne "X";
  $curs = cell_nbr($curs, "+d.1") if $axis eq "Z";
  my $dim = substr(cell_get($curs), 1);
  my $dhome = dimension_home();
  my $index = cell_find($dhome, "+d.2", $dim);

  if ($index)
  { $index = cell_nbr($index, "+d.2"); }
  else
  { $index = $dhome; }
  cell_set($curs, substr(cell_get($curs), 0, 1) . cell_get($index));
  display_dirty();
}

sub view_flip($$)
# Invert sign of given cursor and dimension
{
  my ($number, $axis) = @_;
  my $curs = get_cursor($number);
  $curs = cell_nbr($curs, "+d.1");
  $curs = cell_nbr($curs, "+d.1") if $axis ne "X";
  $curs = cell_nbr($curs, "+d.1") if $axis eq "Z";

  cell_set($curs, reverse_sign(cell_get($curs)));
  display_dirty();
}

$TRUE;
#
# End of Zigzag.pm
#
