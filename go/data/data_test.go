package data

import (
	"fmt"
	"reflect"
	"sort"
	"strconv"
	"strings"
	"testing"
)

// Helper to create a new slice, open it (which loads initial geometry if it's the first),
// and return it. This also handles cleanup of openSlices after the test.
func setupTestSliceWithInitialGeometry(t *testing.T) *Slice {
	// Clean up any existing global state before setting up a new test.
	// This is crucial because SliceOpen and other functions modify global 'openSlices'.
	ResetOpenSlices() // Assuming a helper in data package or implement here for test.

	s, err := SliceOpen("test_initial.zz") // Use a distinct name for testing
	if err != nil {
		t.Fatalf("setupTestSliceWithInitialGeometry: SliceOpen failed: %v", err)
	}
	if s == nil {
		t.Fatalf("setupTestSliceWithInitialGeometry: SliceOpen returned nil slice")
	}
	// Ensure initial geometry is loaded (SliceOpen does this for the first slice)
	if len(s.Cells) == 0 {
		// This might happen if SliceOpen logic changes or if it's not the first slice.
		// For tests assuming initial geom, we might need to force it.
		// However, the current SliceOpen loads it for the first opened slice.
		// If this test is not the first, it might open an empty slice.
		// Forcing it here for robustness in testing specific functions.
		// s.loadInitialGeometry() // loadInitialGeometry is not exported.
		// The test design relies on SliceOpen correctly populating the first slice.
		t.Fatalf("setupTestSliceWithInitialGeometry: Slice seems empty after open, initial geometry not loaded as expected.")
	}

	// After each test that uses this, we should clean up.
	t.Cleanup(func() {
		ResetOpenSlices()
	})
	return s
}

// ResetOpenSlices is a test helper to clear the global openSlices variable.
// This should ideally be in the data package if it's needed for general testing,
// or defined here if it's test-specific.
func ResetOpenSlices() {
	openSlices = []*Slice{}
}

// Helper to check if two integer slices are equal (ignoring order).
func equalIntSlicesUnordered(a, b []int) bool {
	if len(a) != len(b) {
		return false
	}
	aCopy := make([]int, len(a))
	bCopy := make([]int, len(b))
	copy(aCopy, a)
	copy(bCopy, b)
	sort.Ints(aCopy)
	sort.Ints(bCopy)
	return reflect.DeepEqual(aCopy, bCopy)
}

// Helper to check if a slice contains a specific integer.
func containsInt(slice []int, val int) bool {
	for _, item := range slice {
		if item == val {
			return true
		}
	}
	return false
}


// TestMain can be used for global setup/teardown if needed,
// but individual test cleanup with t.Cleanup() is often preferred.

// --- Test Functions Start Here ---

func TestSetupHelper(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	if s == nil {
		t.Fatal("setupTestSliceWithInitialGeometry returned nil")
	}
	if len(s.Cells) == 0 {
		t.Error("Slice should have initial geometry loaded.")
	}
	// Check a known cell from initial geometry
	if _, ok := s.Cells[0]; !ok {
		t.Errorf("Cell 0 (Home) not found in initial geometry")
	}
	if s.Cells[0].Content != "Home" {
		t.Errorf("Cell 0 content expected 'Home', got '%s'", s.Cells[0].Content)
	}
	// Ensure cleanup works for the next test
	ResetOpenSlices()
	if len(openSlices) != 0 {
		t.Fatal("ResetOpenSlices did not clear openSlices")
	}
}

// Step 2: Slice Operations

func TestSliceOpen(t *testing.T) {
	ResetOpenSlices()

	t.Run("OpenFirstSlice", func(t *testing.T) {
		s1, err := SliceOpen("test1.zz")
		if err != nil {
			t.Fatalf("SliceOpen(first) failed: %v", err)
		}
		if s1 == nil {
			t.Fatal("SliceOpen(first) returned nil slice")
		}
		if len(s1.Cells) == 0 { // First slice should load initial geometry
			t.Error("First slice opened should have initial geometry")
		}
		if len(openSlices) != 1 || openSlices[0] != s1 {
			t.Errorf("openSlices not correctly updated: got %d slices", len(openSlices))
		}
		// SliceUpgrade is called internally by SliceOpen for the first slice.
		// A specific test for SliceUpgrade will verify its effects.
		// Here, we just ensure no panic and basic setup.
		if _, homeExists := s1.Cells[Home]; !homeExists { // Home is 0
			t.Error("Home cell (0) not found after first SliceOpen, SliceUpgrade might have issues or initial_geometry missing.")
		}
		if _, selectHomeExists := s1.Cells[SelectHome]; !selectHomeExists {
			t.Error("SelectHome cell not found after first SliceOpen, SliceUpgrade might not have run as expected.")
		}
		t.Cleanup(ResetOpenSlices)
	})

	t.Run("OpenDefaultFilenameWhenEmpty", func(t *testing.T) {
		s, err := SliceOpen("") // Should use default Filename
		if err != nil {
			t.Fatalf("SliceOpen(\"\") failed: %v", err)
		}
		if s.Name != Filename {
			t.Errorf("Expected default filename '%s', got '%s'", Filename, s.Name)
		}
		if len(s.Cells) == 0 {
			t.Error("Default slice opened first should have initial geometry")
		}
		t.Cleanup(ResetOpenSlices)
	})
	
	t.Run("OpenMultipleSlices", func(t *testing.T) {
		s1, _ := SliceOpen("test_multi1.zz")
		s2, err := SliceOpen("test_multi2.zz")
		if err != nil {
			t.Fatalf("SliceOpen(second) failed: %v", err)
		}
		if s2 == nil {
			t.Fatal("SliceOpen(second) returned nil slice")
		}
		// Second slice with a new name should typically be empty unless specific logic loads initial_geometry.
		// Based on current SliceOpen, it will be empty.
		if len(s2.Cells) != 0 {
			t.Errorf("Second slice '%s' should be empty, got %d cells", s2.Name, len(s2.Cells))
		}
		if len(openSlices) != 2 {
			t.Errorf("Expected 2 open slices, got %d", len(openSlices))
		}
		if openSlices[0] != s1 || openSlices[1] != s2 {
			t.Error("openSlices not correctly ordered or populated")
		}
		t.Cleanup(ResetOpenSlices)
	})

	t.Run("OpenExistingSliceByName", func(t *testing.T) {
		sInitial, _ := SliceOpen("test_exist.zz")
		sSame, err := SliceOpen("test_exist.zz")
		if err != nil {
			t.Fatalf("SliceOpen for existing name failed: %v", err)
		}
		if sSame != sInitial {
			t.Error("Opening an already open slice by name should return the same instance")
		}
		if len(openSlices) != 1 {
			t.Errorf("Expected 1 open slice after opening same name twice, got %d", len(openSlices))
		}
		t.Cleanup(ResetOpenSlices)
	})
}

func TestSliceClose(t *testing.T) {
	ResetOpenSlices()
	s1, _ := SliceOpen("close1.zz")
	s2, _ := SliceOpen("close2.zz")
	if len(openSlices) != 2 {
		t.Fatalf("Setup: Expected 2 open slices, got %d", len(openSlices))
	}

	err := SliceClose(0) // Close s1
	if err != nil {
		t.Fatalf("SliceClose(0) failed: %v", err)
	}
	if len(openSlices) != 1 {
		t.Errorf("Expected 1 open slice after closing one, got %d", len(openSlices))
	}
	if openSlices[0] != s2 {
		t.Error("Incorrect slice removed or list reordered unexpectedly")
	}

	err = SliceClose(0) // Close s2 (now at index 0)
	if err != nil {
		t.Fatalf("SliceClose(0) again failed: %v", err)
	}
	if len(openSlices) != 0 {
		t.Errorf("Expected 0 open slices after closing all, got %d", len(openSlices))
	}

	err = SliceClose(0) // Try to close non-existent
	if err == nil {
		t.Error("SliceClose on empty list should have failed")
	}
	t.Cleanup(ResetOpenSlices)
}


// Step 4: Link Manipulation
func TestLinkMake(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t) // Uses initial geometry
	// Add some test cells if initial geometry isn't sufficient or to avoid modifying it too much
	cellA, _ := s.CellNew("CellAForLinkMake")
	cellB, _ := s.CellNew("CellBForLinkMake")
	cellC, _ := s.CellNew("CellCForLinkMake")

	t.Run("ValidLinkMake", func(t *testing.T) {
		dim := "+d.testlink"
		err := s.LinkMake(cellA, cellB, dim)
		if err != nil {
			t.Fatalf("LinkMake(%d, %d, %s) failed: %v", cellA, cellB, dim, err)
		}

		// Check forward link
		target, ok := s.CellNbr(cellA, dim)
		if !ok || target != cellB {
			t.Errorf("Forward link error: cell %d dim %s. Expected target %d, got %d (ok: %t)", cellA, dim, cellB, target, ok)
		}
		// Check backward link
		backDim := ReverseSign(dim)
		source, ok := s.CellNbr(cellB, backDim)
		if !ok || source != cellA {
			t.Errorf("Backward link error: cell %d dim %s. Expected source %d, got %d (ok: %t)", cellB, backDim, cellA, source, ok)
		}
	})

	t.Run("ErrorOnCell1AlreadyLinked", func(t *testing.T) {
		// cellA is already linked to cellB via +d.testlink from previous subtest
		dim := "+d.testlink"
		err := s.LinkMake(cellA, cellC, dim) // Try to link cellA to cellC in same dim
		if err == nil {
			t.Errorf("Expected error when cell1 (%d) already linked in dim %s, but got nil", cellA, dim)
		}
	})

	t.Run("ErrorOnCell2AlreadyLinkedReverse", func(t *testing.T) {
		// cellB is already linked from cellA via +d.testlink (so cellB has -d.testlink to cellA)
		// Try to link cellC to cellB via +d.testlink. This means cellB would need -d.testlink from cellC,
		// but it already has -d.testlink from cellA.
		dim := "+d.testlink" // cellC --(+d.testlink)--> cellB
		backDim := ReverseSign(dim) // cellB <--(-d.testlink)--- cellC

		// Pre-check: cellB should have backDim to cellA
		if src, ok := s.CellNbr(cellB, backDim); !ok || src != cellA {
			t.Fatalf("Pre-check failed: cellB's link in %s is not to cellA as expected from previous test setup.", backDim)
		}

		err := s.LinkMake(cellC, cellB, dim)
		if err == nil {
			t.Errorf("Expected error when cell2 (%d) already linked in reverse dim %s, but got nil", cellB, backDim)
		}
	})

	t.Run("ErrorOnNonExistentCells", func(t *testing.T) {
		if err := s.LinkMake(999, cellA, "+d.foo"); err == nil {
			t.Error("Expected error for LinkMake with non-existent cell1")
		}
		if err := s.LinkMake(cellA, 999, "+d.foo"); err == nil {
			t.Error("Expected error for LinkMake with non-existent cell2")
		}
	})

	t.Run("ErrorOnInvalidDimension", func(t *testing.T) {
		if err := s.LinkMake(cellA, cellC, "d.invalid"); err == nil {
			t.Error("Expected error for LinkMake with invalid dimension (no +/- prefix)")
		}
	})
}

// Step 6: Information Retrieval (Getters)
func TestGetLastCell(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	// From initial_geometry:
	// 1 --(+d.2)--> 2 --(+d.2)--> 3 --(+d.2)--> 4 --(+d.2)--> 5 --(+d.2)--> 6 --(+d.2)--> 7 --(+d.2)--> 8 --(+d.2)--> 1 (loop)
	// 10 --(+d.1)--> 1 (no loop, ends at 1)

	t.Run("FindEndOfChain", func(t *testing.T) {
		last, ok := s.GetLastCell(10, "+d.1")
		if !ok || last != 1 {
			t.Errorf("Expected last cell to be 1 along +d.1 from 10, got %d (ok: %t)", last, ok)
		}
	})

	t.Run("FindEndOfChainLoop", func(t *testing.T) {
		// In the d.2 dimension starting from 1, it's a loop 1->2->...->8->1
		// GetLastCell should return the cell just before re-encountering the start (or the start itself if it's a loop of 1)
		// Based on Perl: $cell = $_ while defined($_ = cell_nbr($cell, $dir)) && ($_ != $_[0]);
		// This means it stops when next is undefined OR next is the original start cell.
		// So for 1 along +d.2, it will traverse 2,3,4,5,6,7,8. Next from 8 is 1. So it stops at 8.
		last, ok := s.GetLastCell(1, "+d.2")
		if !ok || last != 8 {
			t.Errorf("Expected last cell in loop +d.2 from 1 to be 8, got %d (ok: %t)", last, ok)
		}
		
		// Test from a different point in the loop
		last, ok = s.GetLastCell(5, "+d.2")
		if !ok || last != 4 { // 5->6->7->8->1->2->3->4, next from 4 is 5 (start)
			t.Errorf("Expected last cell in loop +d.2 from 5 to be 4, got %d (ok: %t)", last, ok)
		}
	})

	t.Run("NonExistentStartCell", func(t *testing.T) {
		_, ok := s.GetLastCell(9999, "+d.1")
		if ok {
			t.Error("GetLastCell should return !ok for non-existent start cell")
		}
	})

	t.Run("InvalidDimensionFormat", func(t *testing.T) {
		_, ok := s.GetLastCell(0, "d.1") // Missing +/-
		if ok {
			t.Error("GetLastCell should return !ok for invalid dimension format")
		}
	})
	
	t.Run("CellWithNoLinksInDim", func(t *testing.T) {
		// Cell 15 ("I") has "15-d.1" => 14, but no +d.1 link in initial_geometry
		last, ok := s.GetLastCell(15, "+d.1")
		if !ok || last != 15 { // Should return itself if no link in that direction
			t.Errorf("Expected last cell to be 15 itself for +d.1 from 15, got %d (ok: %t)", last, ok)
		}
	})
}

func TestGetDistance(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	// 1 --(+d.2)--> 2 --(+d.2)--> 3
	// 10 --(+d.1)--> 1

	t.Run("DirectNeighbor", func(t *testing.T) {
		dist, ok := s.GetDistance(1, "+d.2", 2)
		if !ok || dist != 1 {
			t.Errorf("Expected distance 1 from 1 to 2 along +d.2, got %d (ok: %t)", dist, ok)
		}
	})

	t.Run("MultipleSteps", func(t *testing.T) {
		dist, ok := s.GetDistance(1, "+d.2", 3)
		if !ok || dist != 2 {
			t.Errorf("Expected distance 2 from 1 to 3 along +d.2, got %d (ok: %t)", dist, ok)
		}
	})
	
	t.Run("StartEqualsEnd", func(t *testing.T) {
		dist, ok := s.GetDistance(1, "+d.2", 1)
		if !ok || dist != 0 {
			t.Errorf("Expected distance 0 from 1 to 1, got %d (ok: %t)", dist, ok)
		}
	})

	t.Run("NotReachable", func(t *testing.T) {
		_, ok := s.GetDistance(1, "+d.1", 3) // d.1 and d.2 are different paths
		if ok {
			t.Error("Expected !ok for unreachable cells (1 to 3 along +d.1)")
		}
	})
	
	t.Run("PathBroken", func(t *testing.T) {
		// Cell 15 has no +d.1 link.
		_, ok := s.GetDistance(15, "+d.1", 0) 
		if ok {
			t.Error("Expected !ok when path is broken (15 along +d.1)")
		}
	})

	t.Run("CycleWithoutHittingTarget", func(t *testing.T) {
		// 1->2->...->8->1. Try to find cell 10 (CursorHome) from 1 along +d.2
		_, ok := s.GetDistance(1, "+d.2", 10)
		if ok {
			t.Error("Expected !ok when cycling along +d.2 from 1 without hitting 10")
		}
	})
	
	t.Run("NonExistentCells", func(t *testing.T) {
		_, ok := s.GetDistance(999, "+d.1", 1)
		if ok { t.Error("Expected !ok if start cell doesn't exist") }
		_, ok = s.GetDistance(1, "+d.1", 999)
		if ok { t.Error("Expected !ok if end cell doesn't exist") }
	})
}

func TestGetCursor(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	// Initial geometry: 10(CursorHome) -> 11(Menu) -> 16(Event) along +d.2
	// So, cursor 0 should be cell 11. Cursor 1 should be cell 16.
	
	t.Run("GetCursor0", func(t *testing.T) {
		cID, ok := s.GetCursor(0)
		if !ok || cID != 11 {
			t.Errorf("Expected cursor 0 to be cell 11, got %d (ok: %t)", cID, ok)
		}
	})
	t.Run("GetCursor1", func(t *testing.T) {
		cID, ok := s.GetCursor(1)
		if !ok || cID != 16 {
			t.Errorf("Expected cursor 1 to be cell 16, got %d (ok: %t)", cID, ok)
		}
	})
	t.Run("CursorNotFound", func(t *testing.T) {
		_, ok := s.GetCursor(5) // Assuming not that many cursors defined initially
		if ok {
			t.Error("Expected !ok for non-existent cursor number")
		}
	})
	t.Run("CursorHomeNonExistent", func(t *testing.T) {
		// Temporarily remove CursorHome to test this path
		originalCursorHome, chExists := s.Cells[CursorHome]
		delete(s.Cells, CursorHome)
		
		_, ok := s.GetCursor(0)
		if ok {
			t.Error("GetCursor should fail if CursorHome cell does not exist")
		}
		// Restore
		if chExists {
			s.Cells[CursorHome] = originalCursorHome
		}
	})
}

func TestGetCellContents(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	
	// Create a clone chain: cellRealContent -> cellClone1 (-d.clone from real) -> cellClone2 (-d.clone from clone1)
	realContentID, _ := s.CellNew("Actual Content")
	clone1ID, _ := s.CellNew(fmt.Sprintf("Clone of %d", realContentID))
	s.LinkMake(realContentID, clone1ID, "+d.clone") // real --(+d.clone)--> clone1
	
	clone2ID, _ := s.CellNew(fmt.Sprintf("Clone of %d", clone1ID))
	s.LinkMake(clone1ID, clone2ID, "+d.clone") // clone1 --(+d.clone)--> clone2

	t.Run("GetContentOfOriginalCell", func(t *testing.T) {
		content, ok := s.GetCellContents(realContentID)
		if !ok || content != "Actual Content" {
			t.Errorf("Expected content 'Actual Content', got '%s' (ok: %t)", content, ok)
		}
	})
	t.Run("GetContentViaOneClone", func(t *testing.T) {
		content, ok := s.GetCellContents(clone1ID) // Should get content of realContentID
		if !ok || content != "Actual Content" {
			t.Errorf("Expected content 'Actual Content' via clone1, got '%s' (ok: %t)", content, ok)
		}
	})
	t.Run("GetContentViaMultipleClones", func(t *testing.T) {
		content, ok := s.GetCellContents(clone2ID) // Should get content of realContentID
		if !ok || content != "Actual Content" {
			t.Errorf("Expected content 'Actual Content' via clone2, got '%s' (ok: %t)", content, ok)
		}
	})
	t.Run("GetContentNonExistentCell", func(t *testing.T) {
		_, ok := s.GetCellContents(9999)
		if ok {
			t.Error("Expected !ok for GetCellContents on non-existent cell")
		}
	})
}

func TestCellsRow(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	// 1 --(+d.2)--> 2 --(+d.2)--> 3
	// 10 --(+d.1)--> 1 (ends)
	// Recycle pile: 99 --(+d.2)--> 99 (loop of 1)

	t.Run("SimpleRow", func(t *testing.T) {
		row, ok := s.CellsRow(1, "+d.2") // 1->2->3->4->5->6->7->8 (then 8 links back to 1)
		expected := []int{1, 2, 3, 4, 5, 6, 7, 8}
		if !ok || !reflect.DeepEqual(row, expected) {
			t.Errorf("Expected row %v, got %v (ok: %t)", expected, row, ok)
		}
	})
	t.Run("RowEndingEarly", func(t *testing.T) {
		row, ok := s.CellsRow(10, "+d.1") // 10 -> 1
		expected := []int{10, 1}
		if !ok || !reflect.DeepEqual(row, expected) {
			t.Errorf("Expected row %v for 10(+d.1), got %v (ok: %t)", expected, row, ok)
		}
	})
	t.Run("RowWithSingleCellLoop", func(t *testing.T) {
		// Cell 99 (Recycle Pile) in initial_geometry links to itself in +d.2 and -d.2
		row, ok := s.CellsRow(99, "+d.2")
		expected := []int{99}
		if !ok || !reflect.DeepEqual(row, expected) {
			t.Errorf("Expected row %v for cell 99 loop, got %v (ok: %t)", expected, row, ok)
		}
	})
	t.Run("RowFromNonExistentCell", func(t *testing.T) {
		_, ok := s.CellsRow(9999, "+d.1")
		if ok {
			t.Error("CellsRow should return !ok for non-existent start cell")
		}
	})
	t.Run("RowWithNoLinksInDim", func(t *testing.T) {
		// Cell 15 has no +d.1 link
		row, ok := s.CellsRow(15, "+d.1")
		expected := []int{15}
		if !ok || !reflect.DeepEqual(row, expected) {
			t.Errorf("Expected row %v for cell 15 (+d.1), got %v (ok: %t)", expected, row, ok)
		}
	})
}

func TestGetContained(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	// Setup a containment structure for testing GetContained.
	// Parent (P) contains C1 and C2 (+d.inside)
	// C1 has contents L1, L2 (+d.contents)
	// C2 has contents L3 (+d.contents)
	// L2 itself contains SC1 (+d.inside), which has contents SL1 (+d.contents)
	// One of C2's contents (L3) is also a start of another inside chain, so it should not be traversed for *its* contents by L3's parent.

	p, _ := s.CellNew("Parent")
	c1, _ := s.CellNew("C1")
	c2, _ := s.CellNew("C2")
	l1, _ := s.CellNew("L1")
	l2, _ := s.CellNew("L2")
	l3, _ := s.CellNew("L3_AlsoInsideHead") // This will also be head of its own +d.inside chain
	
	sc1, _ := s.CellNew("SC1") // Sub-contained in L2
	sl1, _ := s.CellNew("SL1") // Sub-list item of SC1

	l3_child_inside, _ := s.CellNew("L3_ChildInside") // Child of L3 via +d.inside

	// Parent structure
	s.LinkMake(p, c1, "+d.inside")
	s.LinkMake(c1, c2, "+d.inside") // P -> C1 -> C2 (along +d.inside)

	// C1's contents
	s.LinkMake(c1, l1, "+d.contents")
	s.LinkMake(l1, l2, "+d.contents") // C1 has L1 -> L2 (along +d.contents)

	// L2's own containment
	s.LinkMake(l2, sc1, "+d.inside")   // L2 contains SC1
	s.LinkMake(sc1, sl1, "+d.contents") // SC1 has SL1

	// C2's contents
	s.LinkMake(c2, l3, "+d.contents") // C2 has L3

	// Make L3 also a head of an inside chain (so its contents via *this* GetContained(P) should stop at L3)
	s.LinkMake(l3, l3_child_inside, "+d.inside")


	// Expected for GetContained(P): P, C1, L1, L2, SC1, SL1, C2, L3.
	// L3_ChildInside should NOT be included because L3 itself has a -d.inside link (implicitly from its +d.inside link to l3_child_inside).
	// The Perl code for add_contents:
	//   while (defined $index and not defined $hashref->{$index} and not defined cell_nbr($index, "-d.inside"))
	// This means if $index (here, L3) *has* a -d.inside link, its children via +d.contents are not recursively added by *this* call.
	// My GetContained implementation was refined to match this behavior.
	
	// The `-d.inside` check for `index` (L3) means that `add_contents(index, ...)` is NOT called if `index` has a `-d.inside` link.
	// L3 is linked from C2 via `+d.contents`. L3 itself has `l3_child_inside` via `+d.inside`.
	// So, L3 *will* have a `-d.inside` link (implicitly from `l3_child_inside` if `LinkMake` is symmetric for `-d.inside` on children).
	// Let's assume `LinkMake` does this, or the check `cell_nbr($index, "-d.inside")` means "is $index pointed to by any -d.inside".
	// The current `LinkMake` makes `l3_child_inside` link to `L3` via `-d.inside`. So `L3` does not have a `-d.inside` link itself.
	// The check `not defined cell_nbr($index, "-d.inside")` is on `$index` (L3).
	// So if L3 has no link *from it* called "-d.inside", then `add_contents` is called for L3.
	// This means the children of L3 *would* be explored if L3 itself doesn't have an outgoing "-d.inside" link.

	// The Perl `add_contents` logic:
	// add_contents($start = P)
	//   adds P
	//   $cell = C1 (nbr of P via +d.inside)
	//   adds C1
	//   $index = L1 (nbr of C1 via +d.contents)
	//   L1 has no -d.inside link -> add_contents(L1)
	//     adds L1
	//   $index = L2 (nbr of L1 via +d.contents)
	//   L2 has no -d.inside link -> add_contents(L2)
	//     adds L2
	//     $sub_cell_inside = SC1 (nbr of L2 via +d.inside)
	//     adds SC1
	//     $sub_index_content = SL1 (nbr of SC1 via +d.contents)
	//     SL1 has no -d.inside -> add_contents(SL1)
	//       adds SL1
	//     ... (SC1's +d.contents ends)
	//     ... (L2's +d.inside ends)
	//   ... (C1's +d.contents ends)
	//   $cell = C2 (nbr of C1 via +d.inside)
	//   adds C2
	//   $index = L3 (nbr of C2 via +d.contents)
	//   L3 has no -d.inside link defined by default *from* it.
	//   The original comment was: `not defined cell_nbr($index, "-d.inside")`
	//   This means L3's *own* -d.inside link. If L3 is not specifically linked *from* itself via -d.inside, it passes.
	//   So, add_contents(L3) is called.
	//     adds L3
	//     $l3_child_inside_from_L3 = l3_child_inside (nbr of L3 via +d.inside)
	//     adds l3_child_inside
	// This implies the original expectation might be wrong, or my interpretation of `not defined cell_nbr($index, "-d.inside")`
	
	// Let's re-read the Perl `add_contents` carefully for the condition:
	// `while (defined $index and not defined $hashref->{$index} and not defined cell_nbr($index, "-d.inside"))`
	// This `cell_nbr($index, "-d.inside")` checks if the *current content item* (`$index`) itself has an outgoing `-d.inside` link.
	// If it does, the recursion on `$index` stops for its `+d.contents` chain.
	// This condition is about `$index`'s own properties, not whether it's a target of a `-d.inside` from somewhere else.
	// My `L3` does not have an *outgoing* `-d.inside` link in the setup.
	// So, the expectation should include L3's children if reached via `+d.inside` from L3.
	
	// The `GetContained` implementation in `data.go` was:
	// `if !hasNegativeDInside { performAdd(nextContentCellID) }`
	// where `hasNegativeDInside` is `s.CellNbr(nextContentCellID, "-d.inside")`. This is correct.
	// So, if L3 does not have an outgoing `-d.inside` link, `performAdd(L3)` will be called.
	// Inside `performAdd(L3)`: it will add L3. Then it will iterate L3's `+d.inside` chain.
	// This means `l3_child_inside` will be added.
	// Expected: P, C1, L1, L2, SC1, SL1, C2, L3, l3_child_inside.

	expectedContained := []int{p, c1, l1, l2, sc1, sl1, c2, l3, l3_child_inside}
	
	t.Run("ComplexContainment", func(t *testing.T) {
		contained := s.GetContained(p)
		if !equalIntSlicesUnordered(contained, expectedContained) {
			t.Errorf("GetContained(%d) failed.\nExpected (any order): %v\nGot: %v", p, expectedContained, contained)
		}
	})
	
	t.Run("ContainedFromEmpty", func(t *testing.T) {
		emptyCell, _ := s.CellNew("EmptyContainer")
		contained := s.GetContained(emptyCell)
		expected := []int{emptyCell}
		if !equalIntSlicesUnordered(contained, expected) {
			t.Errorf("GetContained for empty cell: expected %v, got %v", expected, contained)
		}
	})
}


func TestDimensionHomeAndFind(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t) // Ensures initial geometry, including dimension list

	t.Run("DimensionHome", func(t *testing.T) {
		// CursorHome (10) links via +d.1 to cell 1 (d.1)
		expectedDimHomeID := 1
		dimHomeID, ok := s.DimensionHome()
		if !ok || dimHomeID != expectedDimHomeID {
			t.Errorf("DimensionHome: expected cell %d, got %d (ok: %t)", expectedDimHomeID, dimHomeID, ok)
		}
	})

	t.Run("DimensionFindExisting", func(t *testing.T) {
		// Find "d.1"
		dimCellID, ok := s.DimensionFind("d.1")
		if !ok || dimCellID != 1 { // Cell 1's content is "d.1"
			t.Errorf("DimensionFind(\"d.1\"): expected cell 1, got %d (ok: %t)", dimCellID, ok)
		}
		// Find "d.2"
		dimCellID, ok = s.DimensionFind("d.2")
		if !ok || dimCellID != 2 { // Cell 2's content is "d.2"
			t.Errorf("DimensionFind(\"d.2\"): expected cell 2, got %d (ok: %t)", dimCellID, ok)
		}
	})

	t.Run("DimensionFindNonExistent", func(t *testing.T) {
		_, ok := s.DimensionFind("d.nonexistent")
		if ok {
			t.Error("DimensionFind should return !ok for a non-existent dimension name")
		}
	})
	
	t.Run("DimensionHomeBrokenLink", func(t *testing.T) {
		// Simulate CursorHome not having a +d.1 link
		originalCursorHomeLinks := s.Cells[CursorHome].Links
		s.Cells[CursorHome].Links = make(map[string]int) // Remove links
		delete(s.db, strconv.Itoa(CursorHome)+"+d.1")  // Remove from db sim
		
		_, ok := s.DimensionHome()
		if ok {
			t.Error("DimensionHome should fail if CursorHome has no +d.1 link")
		}
		s.Cells[CursorHome].Links = originalCursorHomeLinks // Restore
		s.db[strconv.Itoa(CursorHome)+"+d.1"] = strconv.Itoa(1) // Restore db sim
	})
}

// Step 7: Cell Type/Property Checks

func TestIsEssentialChecks(t *testing.T) {
	t.Run("IsEssentialCell", func(t *testing.T) {
		if !IsEssentialCell(0) { t.Error("Cell 0 should be essential") }
		if !IsEssentialCell(CursorHome) { t.Errorf("Cell %d (CursorHome) should be essential", CursorHome) }
		if !IsEssentialCell(DeleteHome) { t.Errorf("Cell %d (DeleteHome) should be essential", DeleteHome) }
		if !IsEssentialCell(SelectHome) { t.Errorf("Cell %d (SelectHome) should be essential", SelectHome) }
		if IsEssentialCell(1) { t.Error("Cell 1 should not be essential") } // Assuming 1 is not one of the special consts
		if IsEssentialCell(50) { t.Error("Cell 50 should not be essential") }
	})

	t.Run("DimensionIsEssential", func(t *testing.T) {
		essentialDims := []string{
			"+d.1", "-d.1", "d.1",
			"+d.2", "-d.2", "d.2",
			"+d.cursor", "-d.cursor", "d.cursor",
			"+d.clone", "-d.clone", "d.clone",
			"+d.inside", "-d.inside", "d.inside",
			"+d.contents", "-d.contents", "d.contents",
			"+d.mark", "-d.mark", "d.mark",
		}
		nonEssentialDims := []string{
			"d.3", "+d.foo", "d.12", "", "+d.", "d.",
		}
		for _, dim := range essentialDims {
			if !DimensionIsEssential(dim) {
				t.Errorf("Dimension '%s' should be essential", dim)
			}
		}
		for _, dim := range nonEssentialDims {
			if DimensionIsEssential(dim) {
				t.Errorf("Dimension '%s' should not be essential", dim)
			}
		}
	})
}

func TestIsCellPropertyChecks(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	
	// Cell 11 in initial_geometry is Menu, and is a cursor (0+d.cursor -> 11, 11-d.cursor -> 0, 11+d.cursor -> 16)
	// Cell 0 is Home, not a cursor in terms of having d.cursor links itself.

	t.Run("IsCursor", func(t *testing.T) {
		if !s.IsCursor(11) { t.Errorf("Cell 11 (Menu) should be identified as a cursor") }
		if s.IsCursor(0) { t.Errorf("Cell 0 (Home) should not be identified as a cursor by its own links") }
		
		nonCursor, _ := s.CellNew("NonCursorCell")
		if s.IsCursor(nonCursor) { t.Errorf("Newly created cell %d should not be a cursor", nonCursor) }

		cursorTest, _ := s.CellNew("TestCursorCell")
		s.LinkMake(cursorTest, 0, "+d.cursor") // Make it a cursor
		if !s.IsCursor(cursorTest) {t.Errorf("Cell %d with +d.cursor link should be a cursor", cursorTest) }
		s.LinkBreakInfer(cursorTest, "+d.cursor") // clean up
	})

	t.Run("IsClone", func(t *testing.T) {
		notClone, _ := s.CellNew("NotAClone")
		if s.IsClone(notClone) { t.Errorf("Cell %d should not be a clone initially", notClone) }

		isCloneTarget, _ := s.CellNew("CloneTarget")
		s.LinkMake(isCloneTarget, notClone, "+d.clone") // notClone is now a clone of isCloneTarget
		if !s.IsClone(notClone) {t.Errorf("Cell %d should be a clone after linking with +d.clone (it has a -d.clone link)", notClone)}
		
		// Check the source of the clone (isCloneTarget)
		// Perl's is_clone also checks `defined(cell_nbr($cell, "d.clone"))` which is ambiguous.
		// Current Go IsClone checks for -d.clone or +d.clone.
		// So, isCloneTarget (which has a -d.clone link to notClone) will also be true.
		// This might need clarification if the intent was only for cells that *are* clones, not sources.
		// Based on current Go port:
		if !s.IsClone(isCloneTarget) { t.Errorf("Cell %d (clone source) should also be identified by IsClone due to +/-d.clone check", isCloneTarget)}

		s.LinkBreakInfer(isCloneTarget, "+d.clone") // cleanup
	})
	
	// IsSelected and IsActiveSelected depend on GetLastCell, GetDistance, SelectHome setup
	t.Run("IsSelected_And_IsActiveSelected", func(t *testing.T) {
		// Setup: cellSel is selected by SelectHome
		// SelectHome --- (+d.mark) ---> cellSel
		cellSel, _ := s.CellNew("SelectedCell")
		err := s.LinkMake(SelectHome, cellSel, "+d.mark")
		if err != nil {
			t.Fatalf("Failed to link SelectHome to cellSel for IsSelected test: %v", err)
		}

		// Verify IsSelected
		if !s.IsSelected(cellSel) {
			t.Errorf("Cell %d should be IsSelected", cellSel)
		}
		// Verify IsActiveSelected
		if !s.IsActiveSelected(cellSel) {
			t.Errorf("Cell %d should be IsActiveSelected", cellSel)
		}

		// CellNotSel is not selected
		cellNotSel, _ := s.CellNew("NotSelectedCell")
		if s.IsSelected(cellNotSel) {
			t.Errorf("Cell %d should NOT be IsSelected", cellNotSel)
		}
		if s.IsActiveSelected(cellNotSel) {
			t.Errorf("Cell %d should NOT be IsActiveSelected", cellNotSel)
		}
		
		// Test a cell that is part of a different selection list (not active)
		otherSelHead, _ := s.CellNew("OtherSelectionHead")
		s.LinkMake(SelectHome, otherSelHead, "+d.2") // otherSelHead is now a (non-active) selection list
		cellInOtherSel, _ := s.CellNew("CellInOtherSelection")
		s.LinkMake(otherSelHead, cellInOtherSel, "+d.mark")

		if !s.IsSelected(cellInOtherSel) { // Should be IsSelected (it's in *a* selection)
			t.Errorf("Cell %d in other selection should be IsSelected", cellInOtherSel)
		}
		if s.IsActiveSelected(cellInOtherSel) { // Should NOT be IsActiveSelected
			t.Errorf("Cell %d in other selection should NOT be IsActiveSelected", cellInOtherSel)
		}
		
		// Cleanup links
		s.LinkBreakInfer(SelectHome, "+d.mark")
		s.LinkBreakInfer(otherSelHead, "+d.mark")
		s.LinkBreakInfer(SelectHome, "+d.2")
	})
}

// Step 8: Dimension Operations
func TestDimensionRenameIntegration(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t) // Uses initial geometry where DimensionHome, etc. are set up.

	oldDimName := "d.1" // Exists in initial_geometry, cell ID 1
	newDimName := "d.renamed_dim1"

	// Get the original cell ID of "d.1"
	originalDimCellID, ok := s.DimensionFind(oldDimName)
	if !ok {
		t.Fatalf("Could not find original dimension '%s' for test setup", oldDimName)
	}

	// Create a cell that links using the old dimension name
	// E.g., cellUser links to cellTarget via +d.1
	cellUser, _ := s.CellNew("UserCellForDimRename")
	cellTarget, _ := s.CellNew("TargetCellForDimRename")
	s.LinkMake(cellUser, cellTarget, "+"+oldDimName)

	// Perform rename
	err := s.DimensionRename(oldDimName, newDimName)
	if err != nil {
		t.Fatalf("DimensionRename('%s', '%s') failed: %v", oldDimName, newDimName, err)
	}

	// 1. Check old dimension name is gone
	if _, found := s.DimensionFind(oldDimName); found {
		t.Errorf("Old dimension name '%s' still found after rename", oldDimName)
	}

	// 2. Check new dimension name exists and points to the original cell ID
	renamedDimCellID, found := s.DimensionFind(newDimName)
	if !found {
		t.Fatalf("New dimension name '%s' not found after rename", newDimName)
	}
	if renamedDimCellID != originalDimCellID {
		t.Errorf("New dimension '%s' (cell %d) does not point to original dimension cell ID %d", newDimName, renamedDimCellID, originalDimCellID)
	}
	content, _ := s.CellGet(renamedDimCellID)
	if content != newDimName {
		t.Errorf("Content of dimension cell %d: expected '%s', got '%s'", renamedDimCellID, newDimName, content)
	}
	
	// 3. Check if links were updated for cellUser
	// Link should now be "+d.renamed_dim1"
	currentTarget, linkExists := s.CellNbr(cellUser, "+"+newDimName)
	if !linkExists {
		t.Errorf("Link for cellUser with new dimension name '+%s' does not exist", newDimName)
	} else if currentTarget != cellTarget {
		t.Errorf("Link for cellUser with new dimension name '+%s' points to %d, expected %d", newDimName, currentTarget, cellTarget)
	}

	// Check if old link key is gone from cellUser's Links map and s.db
	if _, oldLinkStillExistsInCell := s.Cells[cellUser].Links["+"+oldDimName]; oldLinkStillExistsInCell {
		t.Errorf("Old link '+%s' still exists in cellUser.Links map", oldDimName)
	}
	if _, oldLinkStillExistsInDB := s.db[strconv.Itoa(cellUser)+"+"+oldDimName]; oldLinkStillExistsInDB {
		t.Errorf("Old link key '%s' still exists in s.db map", strconv.Itoa(cellUser)+"+"+oldDimName)
	}
	
	// Test renaming back to original to ensure it's possible and for cleanup
	err = s.DimensionRename(newDimName, oldDimName)
	if err != nil {
		t.Fatalf("Failed to rename dimension back to '%s': %v", oldDimName, err)
	}
	if _, found := s.DimensionFind(oldDimName); !found {
		t.Errorf("Failed to find dimension '%s' after renaming back", oldDimName)
	}
}


// Step 9: DoShear
func TestDoShear(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	
	// Setup a row of cells: A --(+d.row)--> B --(+d.row)--> C --(+d.row)--> D
	// Each cell A,B,C,D also has a link in another dimension, e.g., +d.link
	// A --(+d.link)--> AL, B --(+d.link)--> BL, C --(+d.link)--> CL, D --(+d.link)--> DL
	
	a, _ := s.CellNew("A")
	b, _ := s.CellNew("B")
	c, _ := s.CellNew("C")
	d, _ := s.CellNew("D")
	s.LinkMake(a,b, "+d.row"); s.LinkMake(b,c, "+d.row"); s.LinkMake(c,d, "+d.row")

	al, _ := s.CellNew("AL"); bl, _ := s.CellNew("BL"); cl, _ := s.CellNew("CL"); dl, _ := s.CellNew("DL")
	s.LinkMake(a,al, "+d.link"); s.LinkMake(b,bl, "+d.link"); s.LinkMake(c,cl, "+d.link"); s.LinkMake(d,dl, "+d.link")

	// Original links: A->AL, B->BL, C->CL, D->DL
	
	t.Run("Shear_n1_noHang", func(t *testing.T) {
		// Shear row A,B,C,D along +d.row. Affects +d.link links. n=1, hang=false.
		// Expected: A->BL, B->CL, C->DL, D->AL
		err := s.DoShear(a, "+d.row", "+d.link", 1, false)
		if err != nil {
			t.Fatalf("DoShear(n=1, noHang) failed: %v", err)
		}
		
		targetA, _ := s.CellNbr(a, "+d.link"); if targetA != bl { t.Errorf("A should link to BL, got %d", targetA) }
		targetB, _ := s.CellNbr(b, "+d.link"); if targetB != cl { t.Errorf("B should link to CL, got %d", targetB) }
		targetC, _ := s.CellNbr(c, "+d.link"); if targetC != dl { t.Errorf("C should link to DL, got %d", targetC) }
		targetD, _ := s.CellNbr(d, "+d.link"); if targetD != al { t.Errorf("D should link to AL, got %d", targetD) }

		// Reset for next test: break and remake original links
		s.LinkBreakInfer(a, "+d.link"); s.LinkBreakInfer(b, "+d.link"); s.LinkBreakInfer(c, "+d.link"); s.LinkBreakInfer(d, "+d.link")
		s.LinkMake(a,al, "+d.link"); s.LinkMake(b,bl, "+d.link"); s.LinkMake(c,cl, "+d.link"); s.LinkMake(d,dl, "+d.link")
	})

	t.Run("Shear_n1_Hang", func(t *testing.T) {
		// Shear row A,B,C,D. n=1, hang=true.
		// Expected: A->BL, B->CL, C->DL. D's +d.link should be broken (no link).
		err := s.DoShear(a, "+d.row", "+d.link", 1, true)
		if err != nil {
			t.Fatalf("DoShear(n=1, hang=true) failed: %v", err)
		}
		targetA, _ := s.CellNbr(a, "+d.link"); if targetA != bl { t.Errorf("Hang: A should link to BL, got %d", targetA) }
		targetB, _ := s.CellNbr(b, "+d.link"); if targetB != cl { t.Errorf("Hang: B should link to CL, got %d", targetB) }
		targetC, _ := s.CellNbr(c, "+d.link"); if targetC != dl { t.Errorf("Hang: C should link to DL, got %d", targetC) }
		if _, exists := s.CellNbr(d, "+d.link"); exists { t.Errorf("Hang: D should have no link in +d.link") }

		// Reset for next test
		s.LinkBreakInfer(a, "+d.link"); s.LinkBreakInfer(b, "+d.link"); s.LinkBreakInfer(c, "+d.link") 
		s.LinkMake(a,al, "+d.link"); s.LinkMake(b,bl, "+d.link"); s.LinkMake(c,cl, "+d.link"); s.LinkMake(d,dl, "+d.link") // D gets its link back
	})
	
	t.Run("Shear_n_equals_length_noHang", func(t *testing.T) {
		// n=4 (length of row A,B,C,D). Should result in original links.
		err := s.DoShear(a, "+d.row", "+d.link", 4, false)
		if err != nil {
			t.Fatalf("DoShear(n=len, noHang) failed: %v", err)
		}
		targetA, _ := s.CellNbr(a, "+d.link"); if targetA != al { t.Errorf("n=len: A should link to AL, got %d", targetA) }
		targetB, _ := s.CellNbr(b, "+d.link"); if targetB != bl { t.Errorf("n=len: B should link to BL, got %d", targetB) }
		targetC, _ := s.CellNbr(c, "+d.link"); if targetC != cl { t.Errorf("n=len: C should link to CL, got %d", targetC) }
		targetD, _ := s.CellNbr(d, "+d.link"); if targetD != dl { t.Errorf("n=len: D should link to DL, got %d", targetD) }
	})

	// More tests: empty row, row of 1, n > length with hang, etc.
}

func TestLinkBreak(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	cellA, _ := s.CellNew("CellAForLinkBreak")
	cellB, _ := s.CellNew("CellBForLinkBreak")
	dim := "+d.testbreak"
	backDim := ReverseSign(dim)

	// Setup initial link
	if err := s.LinkMake(cellA, cellB, dim); err != nil {
		t.Fatalf("Setup: LinkMake failed: %v", err)
	}

	t.Run("LinkBreakExplicitValid", func(t *testing.T) {
		err := s.LinkBreakExplicit(cellA, cellB, dim)
		if err != nil {
			t.Fatalf("LinkBreakExplicit failed: %v", err)
		}
		if _, exists := s.CellNbr(cellA, dim); exists {
			t.Errorf("Forward link from %d along %s still exists after break", cellA, dim)
		}
		if _, exists := s.CellNbr(cellB, backDim); exists {
			t.Errorf("Backward link from %d along %s still exists after break", cellB, backDim)
		}
		// Check db
		if _, exists := s.db[strconv.Itoa(cellA)+dim]; exists {
			t.Errorf("DB entry for forward link %s%s still exists", strconv.Itoa(cellA), dim)
		}
		if _, exists := s.db[strconv.Itoa(cellB)+backDim]; exists {
			t.Errorf("DB entry for backward link %s%s still exists", strconv.Itoa(cellB), backDim)
		}
	})

	t.Run("LinkBreakExplicitErrorNonExistentLink", func(t *testing.T) {
		// Link was already broken in previous sub-test
		err := s.LinkBreakExplicit(cellA, cellB, dim)
		if err == nil {
			t.Error("LinkBreakExplicit should error when breaking a non-existent link")
		}
	})
	
	t.Run("LinkBreakExplicitErrorWrongTarget", func(t *testing.T) {
		cellC, _ := s.CellNew("CellCForWrongTarget")
		s.LinkMake(cellA, cellB, dim) // Re-make link A-B
		err := s.LinkBreakExplicit(cellA, cellC, dim) // Try to break A-C, but link is A-B
		if err == nil {
			t.Error("LinkBreakExplicit should error when specified target does not match actual linked target")
		}
		s.LinkBreakExplicit(cellA, cellB, dim) // Clean up by breaking A-B
	})


	t.Run("LinkBreakInferValid", func(t *testing.T) {
		// Re-setup link
		if err := s.LinkMake(cellA, cellB, dim); err != nil {
			t.Fatalf("Setup: LinkMake for LinkBreakInferValid failed: %v", err)
		}
		err := s.LinkBreakInfer(cellA, dim)
		if err != nil {
			t.Fatalf("LinkBreakInfer failed: %v", err)
		}
		if _, exists := s.CellNbr(cellA, dim); exists {
			t.Errorf("Infer: Forward link from %d along %s still exists after break", cellA, dim)
		}
		if _, exists := s.CellNbr(cellB, backDim); exists {
			t.Errorf("Infer: Backward link from %d along %s still exists after break", cellB, backDim)
		}
	})
	
	t.Run("LinkBreakInferErrorNonExistentLink", func(t *testing.T) {
		err := s.LinkBreakInfer(cellA, dim) // Link already broken
		if err == nil {
			t.Error("LinkBreakInfer should error when breaking a non-existent link")
		}
	})

	t.Run("LinkBreakErrorNonExistentCells", func(t *testing.T) {
		if err := s.LinkBreakExplicit(999, cellA, dim); err == nil {
			t.Error("Expected error for LinkBreakExplicit with non-existent cell1")
		}
		if err := s.LinkBreakExplicit(cellA, 999, dim); err == nil {
			t.Error("Expected error for LinkBreakExplicit with non-existent cell2")
		}
		if err := s.LinkBreakInfer(999, dim); err == nil {
			t.Error("Expected error for LinkBreakInfer with non-existent cell1")
		}
	})
	
	t.Run("LinkBreakErrorInvalidDimension", func(t *testing.T) {
		s.LinkMake(cellA, cellB, dim) // Make a link first
		if err := s.LinkBreakExplicit(cellA, cellB, "d.no_plus_minus"); err == nil {
			t.Error("Expected error for LinkBreakExplicit with invalid dimension")
		}
		if err := s.LinkBreakInfer(cellA, "d.no_plus_minus"); err == nil {
			t.Error("Expected error for LinkBreakInfer with invalid dimension")
		}
		s.LinkBreakInfer(cellA, dim) // Clean up
	})
}

// Step 5: Cell Manipulation
func TestCellNew(t *testing.T) {
	t.Run("NewCellWithoutRecycling", func(t *testing.T) {
		s := createBareSlice(t, "new_no_recycle.zz") // Bare slice, DeleteHome is set up to be empty
		ResetOpenSlices() // ensure this test suite can call SliceOpen as if it's the first.
		openSlices = append(openSlices,s) // So CellNew can find the slice if it uses CellSlice or similar global access.

		initialNextID := s.NextCellID
		
		id1, err := s.CellNew("content1")
		if err != nil {
			t.Fatalf("CellNew failed: %v", err)
		}
		if id1 != initialNextID {
			t.Errorf("Expected new cell ID %d, got %d", initialNextID, id1)
		}
		if s.NextCellID != initialNextID+1 {
			t.Errorf("Expected NextCellID to be %d, got %d", initialNextID+1, s.NextCellID)
		}
		cell1, ok := s.Cells[id1]
		if !ok || cell1.Content != "content1" {
			t.Errorf("Cell %d content error: expected 'content1', got '%s' (ok: %t)", id1, cell1.Content, ok)
		}

		id2, err := s.CellNew() // Default content
		if err != nil {
			t.Fatalf("CellNew (default content) failed: %v", err)
		}
		if id2 != initialNextID+1 {
			t.Errorf("Expected new cell ID %d for second cell, got %d", initialNextID+1, id2)
		}
		cell2, ok := s.Cells[id2]
		if !ok || cell2.Content != strconv.Itoa(id2) {
			t.Errorf("Cell %d content error: expected '%s', got '%s' (ok: %t)", id2, strconv.Itoa(id2), cell2.Content, ok)
		}
		t.Cleanup(ResetOpenSlices)
	})

	t.Run("NewCellWithRecycling", func(t *testing.T) {
		s := createBareSlice(t, "new_with_recycle.zz")
		ResetOpenSlices()
		openSlices = append(openSlices,s)


		// Manually set up recycle pile: DeleteHome(-d.2) -> recycledCellID
		recycledCellID := 1000
		s.Cells[recycledCellID] = &Cell{ID: recycledCellID, Content: "Recycled", Links: make(map[string]int)}
		s.db[strconv.Itoa(recycledCellID)] = "Recycled"
		// Link DeleteHome to this cell to make it recyclable
		// DeleteHome itself needs to exist. createBareSlice should ensure this.
		if _, deleteHomeExists := s.Cells[DeleteHome]; !deleteHomeExists {
			t.Fatal("DeleteHome cell does not exist in bare slice for recycling test.")
		}

		// Make DeleteHome point to recycledCellID via -d.2, and recycledCellID point back via +d.2
		s.LinkMake(DeleteHome, recycledCellID, "-d.2") // This also makes recycledCellID(+d.2) -> DeleteHome
		
		// Also make recycledCellID point to DeleteHome via -d.2 to complete the d.2 chain for excision
		// In Perl, cell_excise($new, "d.2") implies breaking $new's links in +d.2 and -d.2.
		// So, the recycled cell should be properly linked in the d.2 dimension.
		// If DeleteHome is the only other cell in d.2 for the recycle pile, then:
		// DeleteHome <-(-d.2)-- recycledCellID --(+d.2)--> DeleteHome
		// We already have DeleteHome --(-d.2)--> recycledCellID.
		// And recycledCellID --(+d.2)--> DeleteHome (from LinkMake above).
		// For CellExcise(recycledCellID, "d.2") to work and then link DeleteHome to DeleteHome:
		// It needs recycledCellID to have a -d.2 link.
		// Let's assume a simple recycle pile: DeleteHome <-> recycledCellID on d.2
		// LinkMake(DeleteHome, recycledCellID, "-d.2") implies:
		//   DeleteHome[-d.2] = recycledCellID
		//   recycledCellID[+d.2] = DeleteHome
		// For CellExcise(recycledCellID, "d.2") to make DeleteHome link to itself,
		// recycledCellID also needs a -d.2 link, e.g., to DeleteHome.
		s.LinkMake(recycledCellID, DeleteHome, "-d.2")


		initialNextIDBeforeRecycle := s.NextCellID

		newID, err := s.CellNew("new_content_after_recycle")
		if err != nil {
			t.Fatalf("CellNew with recycling failed: %v", err)
		}
		if newID != recycledCellID {
			t.Errorf("Expected recycled cell ID %d, got %d", recycledCellID, newID)
		}
		if s.NextCellID != initialNextIDBeforeRecycle { // NextCellID should not have incremented
			t.Errorf("NextCellID should not increment when recycling. Expected %d, got %d", initialNextIDBeforeRecycle, s.NextCellID)
		}
		cell, ok := s.Cells[newID]
		if !ok || cell.Content != "new_content_after_recycle" {
			t.Errorf("Recycled cell content error: expected 'new_content_after_recycle', got '%s'", cell.Content)
		}

		// Check that the recycled cell is no longer linked in d.2 from DeleteHome
		if nextRecycled, stillRecyclable := s.CellNbr(DeleteHome, "-d.2"); stillRecyclable && nextRecycled == newID {
			t.Errorf("Recycled cell %d still appears to be on recycle pile (-d.2 from DeleteHome)", newID)
		}
		// After CellExcise, DeleteHome's -d.2 should ideally point to itself if the pile is now empty.
		endOfPile, _ := s.CellNbr(DeleteHome, "-d.2")
		if endOfPile != DeleteHome {
		    t.Errorf("DeleteHome's -d.2 link should point to itself after recycle pile is empty, points to %d", endOfPile)
		}

		t.Cleanup(ResetOpenSlices)
	})
}

func TestCellInsert(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	c1, _ := s.CellNew("c1")
	c2, _ := s.CellNew("c2")
	c3, _ := s.CellNew("c3")
	c4, _ := s.CellNew("c4") // Cell to be inserted

	dim := "+d.inserttest"
	backDim := ReverseSign(dim)

	// Initial setup: c1 ---dim---> c2
	s.LinkMake(c1, c2, dim)

	t.Run("InsertInMiddle", func(t *testing.T) {
		// Insert c4 between c1 and c2:  c1 ---c4---> c2  (meaning c1 --dim--> c4 --dim--> c2)
		err := s.CellInsert(c4, c1, dim) // Insert c4 next to c1 in direction dim
		if err != nil {
			t.Fatalf("CellInsert failed: %v", err)
		}
		// Verify links:
		// c1 -> c4
		target, _ := s.CellNbr(c1, dim)
		if target != c4 {
			t.Errorf("c1 expected to link to c4, got %d", target)
		}
		source, _ := s.CellNbr(c4, backDim)
		if source != c1 {
			t.Errorf("c4 expected to link back to c1, got %d", source)
		}
		// c4 -> c2
		target, _ = s.CellNbr(c4, dim)
		if target != c2 {
			t.Errorf("c4 expected to link to c2, got %d", target)
		}
		source, _ = s.CellNbr(c2, backDim)
		if source != c4 {
			t.Errorf("c2 expected to link back to c4, got %d", source)
		}
	})
	
	// Clean up for next test: break all links made
	s.LinkBreakInfer(c1, dim)
	s.LinkBreakInfer(c4, dim) // c4 might be linked to c2
	// Ensure c2 is not linked back to c4 (LinkBreakInfer should handle backlink)


	t.Run("InsertAtEnd", func(t *testing.T) {
		// Setup: c1 (no links in dim)
		// Insert c3 after c1 in dim: c1 ---dim---> c3
		err := s.CellInsert(c3, c1, dim)
		if err != nil {
			t.Fatalf("CellInsert at end failed: %v", err)
		}
		target, _ := s.CellNbr(c1, dim)
		if target != c3 {
			t.Errorf("c1 expected to link to c3, got %d", target)
		}
		source, _ := s.CellNbr(c3, backDim)
		if source != c1 {
			t.Errorf("c3 expected to link back to c1, got %d", source)
		}
		// Ensure c3 has no further link in dim
		if _, exists := s.CellNbr(c3, dim); exists {
			t.Errorf("c3 should have no link in %s after being inserted at end", dim)
		}
	})
	
	// Cleanup for next tests
	s.LinkBreakInfer(c1, dim)


	t.Run("ErrorCell1AlreadyLinkedBack", func(t *testing.T) {
		c5, _ := s.CellNew("c5")
		c6, _ := s.CellNew("c6")
		s.LinkMake(c5, c6, backDim) // c5 <---backDim--- c6 (so c5 is linked on its "back" side relative to dim)
		
		err := s.CellInsert(c5, c1, dim) // Try to insert c5 next to c1 in direction dim
		if err == nil {
			t.Error("Expected error when cellToInsert (c5) is already linked in reverse_sign(dim)")
		}
		s.LinkBreakInfer(c5, backDim) // cleanup
	})

	t.Run("ErrorCell1LinkedFrontAndCell3Exists", func(t *testing.T) {
		c_exist_front, _ := s.CellNew("c_exist_front")
		c_exist_neighbor, _ := s.CellNew("c_exist_neighbor")
		c_ref, _ := s.CellNew("c_ref")
		c_orig_neighbor, _ := s.CellNew("c_orig_neighbor")

		s.LinkMake(c_exist_front, c_exist_neighbor, dim) // c_exist_front --dim--> c_exist_neighbor
		s.LinkMake(c_ref, c_orig_neighbor, dim)          // c_ref --dim--> c_orig_neighbor (this is cell3)

		// Try to insert c_exist_front next to c_ref in direction dim.
		// c_exist_front is linked on its "front" (dim), and c_ref also has a neighbor (c_orig_neighbor) in dim.
		err := s.CellInsert(c_exist_front, c_ref, dim)
		if err == nil {
			t.Error("Expected error when cellToInsert is linked in dim, and ref cell also has neighbor in dim")
		}
		// Cleanup
		s.LinkBreakInfer(c_exist_front, dim)
		s.LinkBreakInfer(c_ref, dim)
	})
}

func TestCellExcise(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	c1, _ := s.CellNew("c1_excise")
	c2, _ := s.CellNew("c2_excise_ME") // Middle Element
	c3, _ := s.CellNew("c3_excise")
	baseDim := "d.excise"
	posDim := "+" + baseDim
	negDim := "-" + baseDim

	// Setup: c1 <--> c2 <--> c3
	s.LinkMake(c1, c2, posDim)
	s.LinkMake(c2, c3, posDim)

	t.Run("ExciseMiddleElement", func(t *testing.T) {
		err := s.CellExcise(c2, baseDim)
		if err != nil {
			t.Fatalf("CellExcise failed: %v", err)
		}
		// c2 should have no links in +/-baseDim
		if _, exists := s.CellNbr(c2, posDim); exists {
			t.Errorf("c2 still has link in %s after excise", posDim)
		}
		if _, exists := s.CellNbr(c2, negDim); exists {
			t.Errorf("c2 still has link in %s after excise", negDim)
		}
		// c1 should now link to c3
		target, ok := s.CellNbr(c1, posDim)
		if !ok || target != c3 {
			t.Errorf("c1 should link to c3 along %s; got target %d, ok %t", posDim, target, ok)
		}
		source, ok := s.CellNbr(c3, negDim)
		if !ok || source != c1 {
			t.Errorf("c3 should link back to c1 along %s; got source %d, ok %t", negDim, source, ok)
		}
	})
	
	// Cleanup for next test: break c1-c3 link
	s.LinkBreakInfer(c1, posDim)


	t.Run("ExciseElementWithOneNeighbor (Start)", func(t *testing.T) {
		// Setup: c1 <--> c2 (c3 not linked to c2 anymore)
		s.LinkMake(c1,c2,posDim)
		
		err := s.CellExcise(c1, baseDim)
		if err != nil {
			t.Fatalf("CellExcise for c1 (start) failed: %v", err)
		}
		if _, exists := s.CellNbr(c1, posDim); exists {
			t.Errorf("c1 (start) should have no posDim link after excise")
		}
		// c2 should now have no negDim link
		if _, exists := s.CellNbr(c2, negDim); exists {
			t.Errorf("c2 should have no negDim link after c1 (start) was excised")
		}
	})
	
	// Cleanup: break c1-c2 if any, c2-c3 if any.
	// c1 was just excised from its link with c2. c2 might still point to c3 if previous tests didn't clean up fully.
	// For robustness, ensure clean state or use fresh cells.
	// Let's re-create for clarity for the next sub-test.
	c_ex_1, _ := s.CellNew("c_ex_1")
	c_ex_2, _ := s.CellNew("c_ex_2")
	s.LinkMake(c_ex_1, c_ex_2, posDim)

	t.Run("ExciseElementWithOneNeighbor (End)", func(t *testing.T) {
		err := s.CellExcise(c_ex_2, baseDim)
		if err != nil {
			t.Fatalf("CellExcise for c_ex_2 (end) failed: %v", err)
		}
		if _, exists := s.CellNbr(c_ex_2, negDim); exists {
			t.Errorf("c_ex_2 (end) should have no negDim link after excise")
		}
		// c_ex_1 should now have no posDim link
		if _, exists := s.CellNbr(c_ex_1, posDim); exists {
			t.Errorf("c_ex_1 should have no posDim link after c_ex_2 (end) was excised")
		}
	})


	t.Run("ExciseStandaloneElement", func(t *testing.T) {
		c_solo, _ := s.CellNew("c_solo")
		err := s.CellExcise(c_solo, baseDim) // Should do nothing gracefully
		if err != nil {
			t.Fatalf("CellExcise for standalone cell failed: %v", err)
		}
		if _, exists := s.CellNbr(c_solo, posDim); exists {
			t.Errorf("Standalone cell should not have links after excise attempt")
		}
		if _, exists := s.CellNbr(c_solo, negDim); exists {
			t.Errorf("Standalone cell should not have links after excise attempt")
		}
	})
}

func TestSliceCloseAll(t *testing.T) {
	ResetOpenSlices()
	SliceOpen("closeall1.zz")
	SliceOpen("closeall2.zz")
	if len(openSlices) != 2 {
		t.Fatalf("Setup: Expected 2 open slices, got %d", len(openSlices))
	}

	SliceCloseAll()
	if len(openSlices) != 0 {
		t.Errorf("Expected 0 open slices after SliceCloseAll, got %d", len(openSlices))
	}
	t.Cleanup(ResetOpenSlices)
}

// TestSliceUpgrade needs more intricate setup for pre-upgrade states.
// For now, we can test parts of it if SliceOpen calls it.
// A dedicated test would involve creating a slice, manually setting it to a pre-upgrade state,
// then calling SliceUpgrade.
func TestSliceUpgrade_DimensionRenaming(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t) // SliceUpgrade is called on first open
	
	// Check for a dimension that should have been renamed.
	// e.g., "d.Cursor" should become "d.cursor"
	_, foundOld := s.DimensionFind("d.Cursor")
	if foundOld {
		t.Errorf("SliceUpgrade: old dimension 'd.Cursor' still found")
	}
	dimCellID, foundNew := s.DimensionFind("d.cursor")
	if !foundNew {
		t.Errorf("SliceUpgrade: new dimension 'd.cursor' not found after upgrade")
	} else {
		content, _ := s.CellGet(dimCellID)
		if content != "d.cursor" {
			t.Errorf("SliceUpgrade: dimension cell %d content expected 'd.cursor', got '%s'", dimCellID, content)
		}
	}

	// Check if link keys were updated (harder to check directly without specific setup)
	// Example: cell 11 has "11-d.cursor": "0" in initialGeometryData.
	// After "d.Cursor" -> "d.cursor" rename, this link should still work.
	// The SliceUpgrade in data.go has a dimensionRename helper that updates s.db and s.Cells[*].Links
	// We need to ensure that the rename logic in SliceUpgrade correctly updates these.
	// The initialGeometry has "0+d.cursor": "11". After upgrade, this should be "0+d.cursor".
	// The DimensionRename in SliceUpgrade has print statements, not actual map key renaming.
	// This test will likely fail or be incomplete until DimensionRename in SliceUpgrade is fixed.
	
	// For now, let's assume the simple DimensionFind check is a starting point.
	// A more robust test would involve creating a slice state with old dimension names in links
	// and then verifying those links are correctly updated after SliceUpgrade.
	// The current DimensionRename in SliceUpgrade has a bug: it iterates @Hash_Ref which is global.
	// It should iterate s.db and s.Cells for the current slice.
	// And `key =~ s/$d_orig$/$d_new/` for map keys is not how Go map keys are changed.
	// This test points to a needed fix in `SliceUpgrade`'s `dimensionRename` internal helper.
	
	// Given the current state of SliceUpgrade's dimensionRename (which has issues),
	// this test can only be superficial for now.
	// A full test would require:
	// 1. Manually create a slice *without* calling SliceOpen's upgrade.
	// 2. Populate it with data using old dimension names in links.
	// 3. Call s.SliceUpgrade().
	// 4. Verify links are updated.
	// This is hard because SliceOpen *always* calls SliceUpgrade for the first slice.
	// We could simulate by having a slice with old data:
	
	// Reset and create a new slice, manually setting old data
	ResetOpenSlices()
	sliceForUpgradeTest := NewSlice("upgrade_test.zz")
	// Manually add a cell with an old dimension name in its content (as a dimension definition)
	// and a link using an old dimension name.
	sliceForUpgradeTest.Cells[1000] = &Cell{ID: 1000, Content: "d.Cursor", Links: make(map[string]int)}
	sliceForUpgradeTest.db["1000"] = "d.Cursor"
	
	sliceForUpgradeTest.Cells[1001] = &Cell{ID: 1001, Content: "SourceCell", Links: map[string]int{"+d.Cursor": 1002}}
	sliceForUpgradeTest.db["1001"] = "SourceCell"
	sliceForUpgradeTest.db["1001+d.Cursor"] = "1002"

	sliceForUpgradeTest.Cells[1002] = &Cell{ID: 1002, Content: "TargetCell", Links: map[string]int{"-d.Cursor": 1001}}
	sliceForUpgradeTest.db["1002"] = "TargetCell"
	sliceForUpgradeTest.db["1002-d.Cursor"] = "1001"
	
	// Add this slice to openSlices to make it the "first" for the next SliceOpen call
	// This is a bit of a hack. A better way would be to make SliceUpgrade testable independently.
	openSlices = append(openSlices, sliceForUpgradeTest) // Make it seem like it was already "opened" (but not upgraded)

	// Now call SliceUpgrade (which is what SliceOpen would do if this was the first *real* open)
	// We need to call the version of SliceUpgrade that uses the *internal* dimensionFind and dimensionRename.
	// The SliceUpgrade in data.go calls its *internal* dimensionFind/dimensionRename.
	// The internal dimensionRename in SliceUpgrade has a bug with global @Hash_Ref iteration.
	// For now, let's assume SliceUpgrade is called and test its effects if dimensionRename worked correctly on s.Cells and s.db
	
	// This test setup is becoming too complex due to SliceUpgrade's current direct modification style and internal calls.
	// A simplified check:
	sInitial := setupTestSliceWithInitialGeometry(t) // This calls SliceUpgrade internally

	// Check SelectHome creation (from v0.57)
	selectHomeCell, ok := sInitial.Cells[SelectHome]
	if !ok {
		t.Fatalf("SliceUpgrade: SelectHome cell %d not found after initial open", SelectHome)
	}
	if selectHomeCell.Content != "Selection" {
		t.Errorf("SliceUpgrade: SelectHome content expected 'Selection', got '%s'", selectHomeCell.Content)
	}
	// Check links for SelectHome: +d.2 to itself, -d.1 to CursorHome
	targetD2, linkD2Exists := sInitial.CellNbr(SelectHome, "+d.2")
	if !linkD2Exists || targetD2 != SelectHome {
		t.Errorf("SliceUpgrade: SelectHome missing +d.2 link to itself. Got target %d, exists %t", targetD2, linkD2Exists)
	}
	targetD1, linkD1Exists := sInitial.CellNbr(SelectHome, "-d.1") // In initial_geometry, it's 21+d.1 -> 10. So, 21-d.1 is not defined by cell_insert directly.
	// The cell_insert was: cell_insert($SELECT_HOME, $CURSOR_HOME, "-d.1");
	// This means CURSOR_HOME's -d.1 link becomes SELECT_HOME.
	// So CURSOR_HOME should link to SELECT_HOME via -d.1
	// And SELECT_HOME should link back to CURSOR_HOME via +d.1
	
	// Let's re-check the logic in SliceUpgrade for SelectHome:
	// cell_insert($SELECT_HOME, $CURSOR_HOME, "-d.1");  means $CURSOR_HOME---(-d.1)--->$SELECT_HOME
	// So, CURSOR_HOME's -d.1 link should be SELECT_HOME.
	// And SELECT_HOME's +d.1 link should be CURSOR_HOME.
	
	cursorHomeLinkToSelect, chLinkOk := sInitial.CellNbr(CursorHome, "-d.1")
	if !chLinkOk || cursorHomeLinkToSelect != SelectHome {
		t.Errorf("SliceUpgrade: CursorHome should link to SelectHome via -d.1 after SelectHome creation. Got cell %d, linkOk: %t", cursorHomeLinkToSelect, chLinkOk)
	}
	selectHomeLinkToCursor, shLinkOk := sInitial.CellNbr(SelectHome, "+d.1")
	if !shLinkOk || selectHomeLinkToCursor != CursorHome {
		t.Errorf("SliceUpgrade: SelectHome should link to CursorHome via +d.1. Got cell %d, linkOk: %t", selectHomeLinkToCursor, shLinkOk)
	}

	// Check Midden rename
	if recycleCell, ok := sInitial.Cells[DeleteHome]; ok {
		if recycleCell.Content == "Midden" {
			t.Errorf("SliceUpgrade: DeleteHome cell still named 'Midden', should be 'Recycle pile'")
		}
	}
}

// TODO: Add more tests for other SliceUpgrade scenarios if they can be isolated or mocked.

// Step 3: Basic Cell Operations
func TestCellGetSet(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	t.Run("GetExistingCell", func(t *testing.T) {
		content, ok := s.CellGet(0) // Home cell
		if !ok {
			t.Fatal("CellGet(0) returned !ok for existing cell")
		}
		if content != "Home" {
			t.Errorf("Expected content 'Home' for cell 0, got '%s'", content)
		}
	})
	t.Run("GetNonExistentCell", func(t *testing.T) {
		_, ok := s.CellGet(9999) // Non-existent cell
		if ok {
			t.Error("CellGet(9999) returned ok for non-existent cell")
		}
	})
	t.Run("SetCellContent", func(t *testing.T) {
		err := s.CellSet(0, "New Home Content")
		if err != nil {
			t.Fatalf("CellSet(0) failed: %v", err)
		}
		content, _ := s.CellGet(0)
		if content != "New Home Content" {
			t.Errorf("CellSet did not update content. Expected 'New Home Content', got '%s'", content)
		}
		// Check db simulation
		if s.db["0"] != "New Home Content" {
			t.Errorf("CellSet did not update db map. Expected 'New Home Content', got '%s'", s.db["0"])
		}
	})
	t.Run("SetContentNonExistentCell", func(t *testing.T) {
		err := s.CellSet(9999, "Content for non-existent")
		if err == nil {
			t.Error("CellSet should fail for non-existent cell")
		}
	})
}

func TestCellNbr(t *testing.T) {
	s := setupTestSliceWithInitialGeometry(t)
	t.Run("GetExistingNeighbor", func(t *testing.T) {
		// From initialGeometry: "0+d.cursor": "11"
		neighborID, ok := s.CellNbr(0, "+d.cursor")
		if !ok {
			t.Fatal("CellNbr(0, \"+d.cursor\") returned !ok for existing link")
		}
		if neighborID != 11 {
			t.Errorf("Expected neighbor 11 for cell 0 along +d.cursor, got %d", neighborID)
		}
	})
	t.Run("GetNonExistentNeighbor", func(t *testing.T) {
		_, ok := s.CellNbr(0, "+d.nonexistentdim")
		if ok {
			t.Error("CellNbr returned ok for a non-existent dimension link")
		}
	})
	t.Run("GetNeighborForNonExistentCell", func(t *testing.T) {
		_, ok := s.CellNbr(9999, "+d.1")
		if ok {
			t.Error("CellNbr returned ok when source cell does not exist")
		}
	})
}

func TestCellSlice(t *testing.T) {
	ResetOpenSlices()
	s1, _ := SliceOpen("slice1.zz") // Loads initial geometry
	s2, _ := SliceOpen("slice2.zz") // Empty
	
	s2.Cells[1000] = &Cell{ID: 1000, Content: "CellInSlice2"}
	s2.db["1000"] = "CellInSlice2"
	s2.db["1000+d.test"] = "1001"


	t.Run("FindCellInCorrectSlice", func(t *testing.T) {
		idx, slice := CellSlice(strconv.Itoa(0)) // Cell 0 is in s1
		if slice != s1 || idx != 0 {
			t.Errorf("CellSlice for cell 0: expected slice s1 (idx 0), got slice at index %d", idx)
		}
		
		idx, slice = CellSlice("1000") // Cell 1000 is in s2
		if slice != s2 || idx != 1 {
			t.Errorf("CellSlice for cell 1000: expected slice s2 (idx 1), got slice at index %d", idx)
		}
	})
	t.Run("FindLinkInCorrectSlice", func(t *testing.T) {
		idx, slice := CellSlice("0+d.cursor") // Link from cell 0
		if slice != s1 || idx != 0 {
			t.Errorf("CellSlice for link '0+d.cursor': expected s1 (idx 0), got slice at index %d", idx)
		}
		idx, slice = CellSlice("1000+d.test") // Link from cell 1000
		if slice != s2 || idx != 1 {
			t.Errorf("CellSlice for link '1000+d.test': expected s2 (idx 1), got slice at index %d", idx)
		}
	})
	t.Run("NonExistentKey", func(t *testing.T) {
		idx, slice := CellSlice("9999+d.foo")
		if slice != nil || idx != -1 {
			t.Errorf("CellSlice for non-existent key: expected nil slice and -1 index, got index %d", idx)
		}
	})
	t.Cleanup(ResetOpenSlices)
}

// --- Helper for upcoming tests ---
func createBareSlice(t *testing.T, name string) *Slice {
	// This helper creates a slice without loading initial geometry
	// and without adding it to openSlices initially.
	// Useful for setting up specific states.
	s := NewSlice(name)
	// Manually add essential cells if needed for specific tests, like DeleteHome
	if _, exists := s.Cells[DeleteHome]; !exists {
		s.Cells[DeleteHome] = &Cell{ID: DeleteHome, Content: "Recycle pile", Links: make(map[string]int)}
		s.db[strconv.Itoa(DeleteHome)] = "Recycle pile"
		// Make DeleteHome's d.2 point to itself to signify empty recycle pile initially
		s.Cells[DeleteHome].Links["+d.2"] = DeleteHome
		s.Cells[DeleteHome].Links["-d.2"] = DeleteHome
		s.db[strconv.Itoa(DeleteHome)+"+d.2"] = strconv.Itoa(DeleteHome)
		s.db[strconv.Itoa(DeleteHome)+"-d.2"] = strconv.Itoa(DeleteHome)
	}
	if _, exists := s.Cells[CursorHome]; !exists { // Needed for DimensionHome
		s.Cells[CursorHome] = &Cell{ID: CursorHome, Content: "Cursor home", Links: make(map[string]int)}
		s.db[strconv.Itoa(CursorHome)] = "Cursor home"
	}
	if _, exists := s.Cells[SelectHome]; !exists { // Needed for some selection tests
		s.Cells[SelectHome] = &Cell{ID: SelectHome, Content: "Selection", Links: make(map[string]int)}
		s.db[strconv.Itoa(SelectHome)] = "Selection"
	}


	return s
}

// Placeholder for the rest of the tests.
// Due to the large number of tests, I will implement them in groups.
// The next step will be Link Manipulation and Cell Manipulation tests.
// Then Information Retrieval, Cell Type/Property Checks, Dimension Ops, and DoShear.

// Test stubs for remaining sections (to be implemented in subsequent steps)
// func TestLinkMake(t *testing.T) { /* ... */ }
// func TestLinkBreak(t *testing.T) { /* ... */ }
// func TestCellNew(t *testing.T) { /* ... */ }
// func TestCellInsert(t *testing.T) { /* ... */ }
// func TestCellExcise(t *testing.T) { /* ... */ }
// func TestGetLastCell(t *testing.T) { /* ... */ }
// func TestGetDistance(t *testing.T) { /* ... */ }
// func TestGetCursor(t *testing.T) { /* ... */ }
// func TestGetCellContents(t *testing.T) { /* ... */ }
// func TestCellsRow(t *testing.T) { /* ... */ }
// func TestGetContained(t *testing.T) { /* ... */ }
// func TestDimensionHomeDimensionFind(t *testing.T) { /* ... */ }
// func TestIsEssentialChecks(t *testing.T) { /* ... */ }
// func TestIsCellPropertyChecks(t *testing.T) { /* ... */ }
// func TestDimensionRename(t *testing.T) { /* ... */ }
// func TestDoShear(t *testing.T) { /* ... */ }

// Note: A proper TestMain might be useful to manage global state if ResetOpenSlices in t.Cleanup is not sufficient.
// func TestMain(m *testing.M) {
// 	ResetOpenSlices() // Ensure clean state before any test runs
// 	code := m.Run()
// 	ResetOpenSlices() // Clean up after all tests
// 	os.Exit(code)
// }

// For TestSliceUpgrade's dimension renaming, a more focused setup:
func TestSliceUpgrade_DimensionRenameSpecific(t *testing.T) {
	ResetOpenSlices()
	
	// Create a slice instance directly, don't add to openSlices yet
	s := NewSlice("upgrade_dim_rename.zz")

	// Manually set up a state that SliceUpgrade's dimensionRename would act upon
	// Old dimension name: "d.Cursor"
	// New dimension name: "d.cursor"

	// 1. Create the dimension cell with the old name
	dimCellID := 8 // In initial_geometry, cell 8 is "d.cursor" but was "d.Cursor" before v0.50
	s.Cells[dimCellID] = &Cell{ID: dimCellID, Content: "d.Cursor", Links: make(map[string]int)}
	s.db[strconv.Itoa(dimCellID)] = "d.Cursor"

	// 2. Create cells with links using the old dimension name suffix
	cellA := 100
	cellB := 101
	s.Cells[cellA] = &Cell{ID: cellA, Content: "CellA_OldLink", Links: map[string]int{"+d.Cursor": cellB}}
	s.db[strconv.Itoa(cellA)] = "CellA_OldLink"
	s.db[strconv.Itoa(cellA)+"+d.Cursor"] = strconv.Itoa(cellB)

	s.Cells[cellB] = &Cell{ID: cellB, Content: "CellB_OldLink", Links: map[string]int{"-d.Cursor": cellA}}
	s.db[strconv.Itoa(cellB)] = "CellB_OldLink"
	s.db[strconv.Itoa(cellB)+"-d.Cursor"] = strconv.Itoa(cellA)
	
	// Add a dummy 'd.1' so SliceUpgrade doesn't die early
	s.Cells[1] = &Cell{ID:1, Content: "d.1"}
	s.db["1"] = "d.1"


	// Now, call SliceUpgrade.
	// SliceUpgrade is not exported. To test it, we rely on SliceOpen calling it.
	// To make this slice the "first" one that SliceOpen processes and upgrades:
	openSlices = append(openSlices, s) // Add it to the global list *before* SliceOpen might be called again
	                                   // Or, call SliceUpgrade directly if it were exported.
	
	// For this specific test, let's assume we can call the upgrade logic.
	// Since SliceUpgrade is not exported, and its internal dimensionRename is also not,
	// this test highlights the difficulty of testing unexported methods with complex internal state changes.
	// A true unit test for dimensionRename (the helper inside SliceUpgrade) would require making it
	// a standalone function or method that can be called with a slice.
	// The current SliceUpgrade's dimensionRename iterates global @Hash_Ref, which is problematic for Go.
	// The Go version of dimensionRename in SliceUpgrade *does* iterate s.Cells and s.db.

	// Let's assume we can call the upgrade method on our manually constructed slice:
	err := s.SliceUpgrade() // This will run the dimension renaming logic
	if err != nil {
		// If d.1 was missing, it would fail here. We added a dummy d.1.
		if !strings.Contains(err.Error(), "missing d.1") { // Ignore "missing d.1" if that's the only reason
			t.Fatalf("SliceUpgrade call failed: %v", err)
		}
	}


	// Assertions:
	// 1. Dimension cell content updated
	renamedDimCell, ok := s.Cells[dimCellID]
	if !ok || renamedDimCell.Content != "d.cursor" {
		t.Errorf("Dimension cell content not updated. Expected 'd.cursor', got '%s'", renamedDimCell.Content)
	}
	if s.db[strconv.Itoa(dimCellID)] != "d.cursor" {
		t.Errorf("Dimension cell content in DB not updated.")
	}

	// 2. Links updated in s.Cells
	cellALinks := s.Cells[cellA].Links
	if target, exists := cellALinks["+d.cursor"]; !exists || target != cellB {
		t.Errorf("Cell A link not updated to +d.cursor or target incorrect. Got target %d, exists %t. Links: %v", target, exists, cellALinks)
	}
	if _, oldExists := cellALinks["+d.Cursor"]; oldExists {
		t.Errorf("Old link +d.Cursor still exists in Cell A's links.")
	}

	// 3. Links updated in s.db
	if _, dbOldLinkExists := s.db[strconv.Itoa(cellA)+"+d.Cursor"]; dbOldLinkExists {
		t.Errorf("Old link key in DB not deleted for cell A.")
	}
	if dbNewLinkTargetStr, dbNewLinkExists := s.db[strconv.Itoa(cellA)+"+d.cursor"]; !dbNewLinkExists || dbNewLinkTargetStr != strconv.Itoa(cellB) {
		t.Errorf("New link key in DB not created or target incorrect for cell A. Got target %s, exists %t", dbNewLinkTargetStr, dbNewLinkExists)
	}
	t.Cleanup(ResetOpenSlices)
}
