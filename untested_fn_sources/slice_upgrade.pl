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
