import unittest
import os
import json
from zigzag.core import ZigzagSpace, Cell
from zigzag.persistence import slice_open, slice_sync_all, slice_close, INITIAL_GEOMETRY

TEST_JSON_FILE = "test_zigzag_data.json"

class TestPersistence(unittest.TestCase):

    def tearDown(self):
        # Clean up the test JSON file after each test if it exists
        if os.path.exists(TEST_JSON_FILE):
            os.remove(TEST_JSON_FILE)

    def test_01_slice_open_initial_geometry(self):
        zz = ZigzagSpace()
        slice_open(zz, TEST_JSON_FILE) # File doesn't exist, should load INITIAL_GEOMETRY

        self.assertEqual(zz.cell_get("0"), "Home")
        self.assertTrue("10" in zz.cells) # CURSOR_HOME_ID from INITIAL_GEOMETRY
        self.assertEqual(zz.cell_get("10"), "Cursor home")
        # Check a known link from initial_geometry, ensuring target is string "11"
        self.assertEqual(zz.cells["0"].connections.get("+d.cursor"), "11") 
        self.assertIn("d.1", zz.dimensions)
        self.assertIn("d.cursor", zz.dimensions)
        self.assertEqual(zz.next_cell_id, INITIAL_GEOMETRY.get("n", 100)) # "n" is a string key
        self.assertEqual(zz.filename, TEST_JSON_FILE)

    def test_02_slice_sync_and_load(self):
        zz_save = ZigzagSpace()
        # Make a small modification or use initial for simplicity
        slice_open(zz_save, TEST_JSON_FILE) # Load initial
        zz_save.cell_set("0", "Modified Home")
        new_cell_id = zz_save.cell_new("Test Cell for Sync")
        zz_save.link_make("0", new_cell_id, "+d.test")
        
        slice_sync_all(zz_save, TEST_JSON_FILE)
        self.assertTrue(os.path.exists(TEST_JSON_FILE))

        zz_load = ZigzagSpace()
        slice_open(zz_load, TEST_JSON_FILE) # Load from the saved file

        self.assertEqual(zz_load.cell_get("0"), "Modified Home")
        self.assertEqual(zz_load.cell_get(new_cell_id), "Test Cell for Sync")
        self.assertEqual(zz_load.cell_nbr("0", "+d.test"), new_cell_id)
        self.assertIn("d.test", zz_load.dimensions)
        self.assertEqual(zz_load.next_cell_id, zz_save.next_cell_id)
    
    def test_03_slice_close(self):
        zz = ZigzagSpace()
        slice_open(zz, TEST_JSON_FILE)
        zz.cell_set("0", "Content Before Close")
        # slice_close should sync data
        slice_close(zz, TEST_JSON_FILE) 
        
        self.assertTrue(os.path.exists(TEST_JSON_FILE))
        
        zz_reopen = ZigzagSpace()
        slice_open(zz_reopen, TEST_JSON_FILE)
        self.assertEqual(zz_reopen.cell_get("0"), "Content Before Close")

if __name__ == '__main__':
    unittest.main()
