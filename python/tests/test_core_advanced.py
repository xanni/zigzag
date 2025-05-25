import unittest
from zigzag.core import ZigzagSpace
from zigzag.persistence import slice_open, INITIAL_GEOMETRY
# Import constants like CURSOR_HOME_ID, SELECT_HOME_ID, etc.
from zigzag.core import CURSOR_HOME_ID, SELECT_HOME_ID, DELETE_HOME_ID, ROOT_CELL_ID, ESSENTIAL_DIMENSIONS

# Helper to initialize a space with geometry for tests
def setup_zz_space_with_geometry():
    zz = ZigzagSpace()
    # Use a dummy filename, persistence tests handle file IO
    slice_open(zz, "dummy_for_adv_tests.db")
    return zz

class TestCoreAdvanced(unittest.TestCase):

    def setUp(self):
        self.zz = setup_zz_space_with_geometry()

    def test_01_dimension_management(self):
        # dimension_home
        self.assertEqual(self.zz.dimension_home(), CURSOR_HOME_ID)

        # is_essential & dimension_is_essential
        self.assertTrue(self.zz.is_essential(CURSOR_HOME_ID))
        self.assertFalse(self.zz.is_essential(self.zz.cell_new("NonEssential")))
        self.assertTrue(self.zz.dimension_is_essential("d.1"))
        self.assertTrue(self.zz.dimension_is_essential("+d.cursor"))
        self.assertFalse(self.zz.dimension_is_essential("d.custom"))

        # dimension_find
        self.assertEqual(self.zz.dimension_find("d.1"), "1") # From INITIAL_GEOMETRY
        self.assertIsNotNone(self.zz.dimension_find("d.cursor"))
        self.assertIsNone(self.zz.dimension_find("d.nonexistent"))

        # dimension_rename
        # First, ensure d.3 exists and find its original cell ID
        original_d3_id = self.zz.dimension_find("d.3")
        self.assertIsNotNone(original_d3_id, "Dimension d.3 should exist for rename test")
        
        # Link a test cell using +d.3
        c_test = self.zz.cell_new("Test for d.3 rename")
        self.zz.link_make(CURSOR_HOME_ID, c_test, "+d.3")
        self.assertEqual(self.zz.cell_nbr(CURSOR_HOME_ID, "+d.3"), c_test)

        self.zz.dimension_rename("d.3", "d.renamed_dim")
        self.assertIsNone(self.zz.dimension_find("d.3"))
        renamed_d3_id = self.zz.dimension_find("d.renamed_dim")
        self.assertIsNotNone(renamed_d3_id)
        self.assertEqual(original_d3_id, renamed_d3_id) # ID should be same, content changed
        self.assertEqual(self.zz.cell_get(renamed_d3_id), "d.renamed_dim")
        self.assertIn("d.renamed_dim", self.zz.dimensions)
        self.assertNotIn("d.3", self.zz.dimensions)
        
        # Check if the link was updated
        self.assertIsNone(self.zz.cell_nbr(CURSOR_HOME_ID, "+d.3"))
        self.assertEqual(self.zz.cell_nbr(CURSOR_HOME_ID, "+d.renamed_dim"), c_test)
        
        # Clean up by renaming back, if cell_set is robust enough or if we re-init for other tests
        self.zz.dimension_rename("d.renamed_dim", "d.3")


    def test_02_getters_basic(self):
        # get_last_cell
        self.assertEqual(self.zz.get_last_cell("0", "+d.1"), "99") # 0 -> ... -> 99 in d.1 from INITIAL_GEOMETRY
        # get_cell_contents (clone handling)
        original_id = self.zz.cell_new("Original Content")
        clone1_id = self.zz.cell_new(f"Clone of {original_id}")
        self.zz.link_make(original_id, clone1_id, "+d.clone")
        self.assertEqual(self.zz.get_cell_contents(clone1_id), "Original Content")
        self.assertEqual(self.zz.get_cell_contents(original_id), "Original Content")

        # get_cursor & get_accursed
        cursor0_id = self.zz.get_cursor(0)
        self.assertIsNotNone(cursor0_id) 
        # CURSOR_HOME_ID (10) -> +d.2 -> 11 (Menu cell, also 0th cursor)
        self.assertEqual(cursor0_id, INITIAL_GEOMETRY.get("10+d.2")) # Should be "11"
        
        accursed_by_c0 = self.zz.get_accursed(0) # Cursor 0 ("11") accurses "0"
        self.assertEqual(accursed_by_c0, "0")


    def test_03_getters_navigation_rows(self):
        # get_dimension (assumes cursor 0 - cell "11" - view is default)
        # Default view for cursor "11" (0th cursor): X=+d.1, Y=+d.2, Z=+d.3 (from view_reset logic)
        # Need to setup view for cursor 0 if not default or if reset is not run.
        # For now, assume default setup by INITIAL_GEOMETRY matches view_reset expectation
        # Cell "11" has "+d.1" -> "12", "+d.1" -> "13", "+d.1" -> "14" which contain "+d.1", "+d.2", "+d.3"
        # The cell "11" itself is the 0th cursor
        # Its +d.1 link is to "12" (content "+d.1")
        # Its +d.1 -> +d.1 link is to "13" (content "+d.2")
        # Its +d.1 -> +d.1 -> +d.1 link is to "14" (content "+d.3")
        
        # To make get_dimension test robust, let's explicitly set a cursor's view dimensions
        c0_id = self.zz.get_cursor(0) # Should be "11"
        self.assertIsNotNone(c0_id)
        
        # Manually set view for cursor 0 to known values if not already by INITIAL_GEOMETRY
        # This part is tricky as INITIAL_GEOMETRY sets up the structure,
        # but get_dimension relies on the *content* of these view cells.
        # Content of cell "12" is "+d.1", "13" is "+d.2", "14" is "+d.3".
        # These are the dimension names themselves.
        
        self.assertEqual(self.zz.get_dimension(c0_id, 'R'), "+d.1") # X-axis right
        self.assertEqual(self.zz.get_dimension(c0_id, 'L'), "-d.1") # X-axis left
        self.assertEqual(self.zz.get_dimension(c0_id, 'D'), "+d.2") # Y-axis down
        self.assertEqual(self.zz.get_dimension(c0_id, 'U'), "-d.2") # Y-axis up
        self.assertEqual(self.zz.get_dimension(c0_id, 'O'), "+d.3") # Z-axis out
        self.assertEqual(self.zz.get_dimension(c0_id, 'I'), "-d.3") # Z-axis in

        # get_distance
        # In INITIAL_GEOMETRY: 0 --(+d.2)--> 30
        self.assertEqual(self.zz.get_distance("0", "+d.2", "30"), 1)
        self.assertIsNone(self.zz.get_distance("0", "+d.1", "30")) # No direct path

        # cells_row
        # d.1 dimension: 10 --(+d.2)--> 11 --(+d.2)--> 16 ... (part of menu/event structure)
        # Let's use a simpler one from INITIAL_GEOMETRY: 1 --(+d.2)--> 2 --(+d.2)--> 3 --(+d.2)--> 4 ...
        row_d2_from_1 = self.zz.cells_row("1", "+d.2") 
        expected_row = ["1", "2", "3", "4", "5", "6", "7", "8"] # then 8 links back to 1
        self.assertEqual(row_d2_from_1, expected_row)
        
    def test_04_selection_getters_and_predicates(self):
        c1 = self.zz.cell_new("s1")
        c2 = self.zz.cell_new("s2")
        
        # is_selected / is_active_selected (before selection)
        self.assertFalse(self.zz.is_selected(c1))
        self.assertFalse(self.zz.is_active_selected(c1))

        # Add to active selection (d.mark from SELECT_HOME_ID)
        self.zz.cell_insert(c1, SELECT_HOME_ID, "+d.mark")
        self.assertTrue(self.zz.is_selected(c1))
        # The is_active_selected logic from prompt is: head_cell = self.get_last_cell(cell_id, "-d.mark"); return head_cell == SELECT_HOME_ID and cell_id != SELECT_HOME_ID
        # If c1 is first in selection, get_last_cell(c1, "-d.mark") is c1. So head_cell (c1) != SELECT_HOME_ID.
        # This test will fail based on that specific logic.
        # However, if is_active_selected means "is part of the chain whose ultimate -d.mark parent is SELECT_HOME_ID", it should be true.
        # Let's adjust the test to reflect the provided is_active_selected interpretation.
        # With c1 inserted into SELECT_HOME_ID's +d.mark chain, get_last_cell(c1, "-d.mark") will be c1.
        # Its -d.mark parent is SELECT_HOME_ID.
        # self.assertTrue(self.zz.is_active_selected(c1)) # This will fail if head_cell must *be* SELECT_HOME_ID for is_active_selected.
        # The `is_active_selected` condition `head_cell == SELECT_HOME_ID` implies `SELECT_HOME_ID` itself is the start of the mark chain.

        # Let's test according to the implementation of is_active_selected:
        # is_active_selected: head_cell = get_last_cell(c1, "-d.mark") which is c1.
        # Is c1 == SELECT_HOME_ID? No. So is_active_selected(c1) is False.
        # This means the test needs to be written for a cell *after* the first one if that's the logic.
        # OR, the logic for is_active_selected needs to be: self.cell_nbr(head_cell, "-d.mark") == SELECT_HOME_ID
        # For now, I will assume is_active_selected as implemented will pass for c1 if it's the *only* cell.
        # The original Perl for is_active_selected $self->{selecthome} == $headcell && $headcell ne $cellid
        # This implies $headcell is $SELECT_HOME. For c1 in selection, get_last_cell(c1,"-d.mark") is $SELECT_HOME.
        # So if c1 is in selection, is_active_selected(c1) should be true.
        
        # Let's re-verify is_active_selected: head_cell = get_last_cell(cell_id, "-d.mark")
        # return head_cell == SELECT_HOME_ID and cell_id != SELECT_HOME_ID
        # If SELECT_HOME_ID --+d.mark--> c1. get_last_cell(c1, "-d.mark") is SELECT_HOME_ID.
        # So head_cell IS SELECT_HOME_ID. And cell_id (c1) != SELECT_HOME_ID. This should be TRUE.
        self.assertTrue(self.zz.is_active_selected(c1), "c1 should be active selected")

        self.assertEqual(self.zz.get_which_selection(c1), SELECT_HOME_ID)
        
        active_sel = self.zz.get_active_selection()
        self.assertIn(c1, active_sel)
        
        self.zz.cell_insert(c2, c1, "+d.mark") # c2 after c1 in active selection
        active_sel_2 = self.zz.get_active_selection()
        self.assertEqual(active_sel_2, [c1, c2])
        self.assertTrue(self.zz.is_active_selected(c2))


        # is_cursor, is_clone
        self.assertTrue(self.zz.is_cursor(CURSOR_HOME_ID)) # "10"
        self.assertTrue(self.zz.is_cursor(self.zz.get_cursor(0))) # "11"
        
        clone_orig = self.zz.cell_new("clone_orig")
        clone_copy = self.zz.cell_new("clone_copy")
        self.zz.link_make(clone_orig, clone_copy, "+d.clone")
        self.assertTrue(self.zz.is_clone(clone_copy))
        self.assertFalse(self.zz.is_clone(clone_orig)) # Original is not the clone

    def test_05_cursor_operations(self):
        cursor0_id = self.zz.get_cursor(0) # Cell "11"
        self.assertIsNotNone(cursor0_id)
        initial_accursed = self.zz.get_accursed(0) # Should be "0"
        self.assertEqual(initial_accursed, "0")

        # cursor_move_dimension
        # Move cursor 0 (cell "11") from "0" along "+d.2" to "30"
        self.zz.cursor_move_dimension(cursor0_id, "+d.2")
        self.assertEqual(self.zz.get_accursed(0), "30")

        # cursor_jump
        # Jump cursor 0 to cell "1" (d.1)
        self.zz.cursor_jump(cursor0_id, "1")
        self.assertEqual(self.zz.get_accursed(0), "1")
        
        # cursor_move_direction
        # Cursor 0 is on "1". Its R direction is "+d.1".
        # Cell "1" +d.1 is "99". So cursor should move to "99".
        self.zz.cursor_move_direction(0, 'R') # Move Right
        self.assertEqual(self.zz.get_accursed(0), "99")

    def test_06_atcursor_operations(self):
        # Setup: cursor 0 ("11") pointing to "0" (Home)
        self.zz.cursor_jump(self.zz.get_cursor(0), "0")
        self.assertEqual(self.zz.get_accursed(0), "0")

        # atcursor_insert
        # Insert new cell to the Right of "0" (Home). Cursor 0's R is +d.1.
        # So, 0 --(+d.1)--> new_cell
        self.zz.atcursor_insert(0, 'R')
        new_cell_r_of_0 = self.zz.cell_nbr("0", "+d.1")
        self.assertIsNotNone(new_cell_r_of_0)
        self.assertNotEqual(new_cell_r_of_0, "99") # Original +d.1 of "0" was "99"

        # atcursor_select
        self.assertFalse(self.zz.is_active_selected("0"))
        self.zz.atcursor_select(0) # Selects cell "0"
        self.assertTrue(self.zz.is_active_selected("0"))
        self.zz.atcursor_select(0) # Deselects cell "0"
        self.assertFalse(self.zz.is_active_selected("0"))
        
        # atcursor_hop
        # Home("0") --(+d.2)--> Cell("30") --(+d.2)--> Cell("40") ...
        # Hop Home("0") over Cell("30") along "+d.2" (D from cursor 0's perspective)
        # State before: ... -> 0 -> 30 -> 40 -> ...
        # State after:  ... -> 30 -> 0 -> 40 -> ...
        # Original "+d.2" neighbor of "0" is "30".
        # Original "+d.2" neighbor of "30" is "40".
        # We need to ensure "0" is pointing to "30" first.
        self.zz.cursor_jump(self.zz.get_cursor(0), "0") # Ensure cursor is on 0
        self.zz.link_make("0", "30", "+d.2") # Ensure link 0-(+d.2)->30
        self.zz.link_make("30", "40", "+d.2")# Ensure link 30-(+d.2)->40

        self.assertEqual(self.zz.cell_nbr("0", "+d.2"), "30")
        self.zz.atcursor_hop(0, 'D') # Hop "0" over its Down (+d.2) neighbor "30"
        self.assertEqual(self.zz.cell_nbr("30", "+d.2"), "0") # 30 should now point to 0
        self.assertEqual(self.zz.cell_nbr("0", "+d.2"), "40") # 0 should now point to 40 (original neighbor of 30)

        # atcursor_delete (delete cell "0" which is now after "30")
        # Cursor 0 is still pointing at "0".
        self.zz.atcursor_delete(0)
        self.assertIsNone(self.zz.cells.get("0")) # Cell "0" should be gone (or on recycle)
        # Check if cursor moved to a neighbor, e.g. "30" or "40" or ROOT_CELL_ID if those were also gone
        self.assertNotEqual(self.zz.get_accursed(0), "0")
        # Check if "0" is on recycle pile: DELETE_HOME_ID ("99") --(+d.2)--> "0"
        self.assertEqual(self.zz.cell_nbr(DELETE_HOME_ID, "+d.2"), "0")


if __name__ == '__main__':
    unittest.main()
