import unittest
from zigzag.core import ZigzagSpace, Cell
# Assuming module level constants are accessible if needed, e.g. from zigzag.core
# from zigzag.core import CURSOR_HOME_ID 

class TestCoreBasic(unittest.TestCase):

    def setUp(self):
        self.zz = ZigzagSpace()
        # You might want to load initial geometry for some tests if they rely on it
        # from zigzag.persistence import slice_open
        # slice_open(self.zz, "dummy_for_test_core.db") 

    def test_01_cell_creation_and_content(self):
        c1_id = self.zz.cell_new("Hello")
        self.assertIsNotNone(self.zz.cells.get(c1_id))
        self.assertEqual(self.zz.cell_get(c1_id), "Hello")
        
        c2_id = self.zz.cell_new() # Default content is cell_id
        self.assertEqual(self.zz.cell_get(c2_id), c2_id)
        
        self.zz.cell_set(c1_id, "World")
        self.assertEqual(self.zz.cell_get(c1_id), "World")
        
        self.assertIsNone(self.zz.cell_get("nonexistent_id"))
        # Test setting content for non-existent cell (should print error, not raise for now)
        self.zz.cell_set("nonexistent_id", "test")


    def test_02_linking_and_navigation(self):
        c1_id = self.zz.cell_new("Cell1")
        c2_id = self.zz.cell_new("Cell2")
        c3_id = self.zz.cell_new("Cell3")

        # Test link_make
        self.zz.link_make(c1_id, c2_id, "+d.1")
        self.assertEqual(self.zz.cell_nbr(c1_id, "+d.1"), c2_id)
        self.assertEqual(self.zz.cell_nbr(c2_id, "-d.1"), c1_id)
        self.assertIn("d.1", self.zz.dimensions)

        # Test linking to already linked cell (should fail)
        # Assuming link_make prints error and doesn't overwrite for now
        # No direct assert for printed error, but check link not made
        current_c1_plus_d1 = self.zz.cell_nbr(c1_id, "+d.1")
        self.zz.link_make(c1_id, c3_id, "+d.1") # Attempt to overwrite
        self.assertEqual(self.zz.cell_nbr(c1_id, "+d.1"), current_c1_plus_d1, "Link should not have been overwritten")


        # Test link_break
        self.zz.link_break(c1_id, c2_id, "+d.1")
        self.assertIsNone(self.zz.cell_nbr(c1_id, "+d.1"))
        self.assertIsNone(self.zz.cell_nbr(c2_id, "-d.1"))
        
        # Test break non-existent link
        self.zz.link_break(c1_id, c3_id, "+d.test") # Should print error

    def test_03_dimension_helpers(self):
        self.assertEqual(self.zz._reverse_dimension_sign("+d.test"), "-d.test")
        self.assertEqual(self.zz._reverse_dimension_sign("-d.test"), "+d.test")
        self.assertEqual(self.zz._reverse_dimension_sign("d.test"), "d.test") # No sign

        self.assertEqual(self.zz._get_base_dimension("+d.test"), "d.test")
        self.assertEqual(self.zz._get_base_dimension("-d.test"), "d.test")
        self.assertEqual(self.zz._get_base_dimension("d.test"), "d.test")
        
    def test_04_cell_insert(self):
        c1 = self.zz.cell_new("C1")
        c2 = self.zz.cell_new("C2")
        c3 = self.zz.cell_new("C3")
        
        # C2 --(+d.1)--> C3
        self.zz.link_make(c2, c3, "+d.1")
        # Insert C1 between C2 and C3: C2 --(+d.1)--> C1 --(+d.1)--> C3
        self.zz.cell_insert(c1, c2, "+d.1")
        
        self.assertEqual(self.zz.cell_nbr(c2, "+d.1"), c1)
        self.assertEqual(self.zz.cell_nbr(c1, "-d.1"), c2)
        self.assertEqual(self.zz.cell_nbr(c1, "+d.1"), c3)
        self.assertEqual(self.zz.cell_nbr(c3, "-d.1"), c1)
        self.assertIn("d.1", self.zz.dimensions)

    def test_05_cell_excise(self):
        c1 = self.zz.cell_new("C1")
        c2 = self.zz.cell_new("C2")
        c3 = self.zz.cell_new("C3")
        # C1 --(+d.1)--> C2 --(+d.1)--> C3
        self.zz.link_make(c1,c2,"+d.1")
        self.zz.link_make(c2,c3,"+d.1")
        
        self.zz.cell_excise(c2, "d.1")
        
        self.assertIsNone(self.zz.cell_nbr(c2, "+d.1"))
        self.assertIsNone(self.zz.cell_nbr(c2, "-d.1"))
        self.assertEqual(self.zz.cell_nbr(c1, "+d.1"), c3) # C1 should now link to C3
        self.assertEqual(self.zz.cell_nbr(c3, "-d.1"), c1) # C3 should now link to C1
        
    def test_06_cell_find(self):
        c1 = self.zz.cell_new("Target")
        c2 = self.zz.cell_new("Intermediate")
        c3 = self.zz.cell_new("Target") # Same content
        c4 = self.zz.cell_new("End")
        
        # c2 -> c1 -> c4 (along +d.find)
        self.zz.link_make(c2,c1,"+d.find")
        self.zz.link_make(c1,c4,"+d.find")
        # c2 -> c3 (along +d.other)
        self.zz.link_make(c2,c3,"+d.other")

        found_c1 = self.zz.cell_find(c2, "+d.find", "Target")
        self.assertEqual(found_c1, c1)
        
        found_nothing = self.zz.cell_find(c2, "+d.find", "NonExistent")
        self.assertIsNone(found_nothing)

        # Test find in a different dimension
        found_c3 = self.zz.cell_find(c2, "+d.other", "Target")
        self.assertEqual(found_c3, c3)

        # Test find from start_cell which has the content
        self.assertEqual(self.zz.cell_find(c1, "+d.find", "Target"), c1)


if __name__ == '__main__':
    unittest.main()
