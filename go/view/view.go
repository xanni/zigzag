package view

import (
	"fmt"
	"strings"

	"../data" // Adjust import path as necessary
)

// Helper function to get the Nth cell linked from a start cell along a dimension.
// Returns cellID and true if found, 0 and false otherwise.
func getNthLinkedCell(s *data.Slice, startCellID int, dim string, n int) (int, bool) {
	currentCellID := startCellID
	var ok bool
	for i := 0; i < n; i++ {
		currentCellID, ok = s.CellNbr(currentCellID, dim)
		if !ok {
			return 0, false
		}
		if _, cellExists := s.Cells[currentCellID]; !cellExists {
			return 0, false // Link points to non-existent cell
		}
	}
	return currentCellID, true
}

// QuadrantToggle toggles the quadrant display style for the given cursor's view.
// It appends or removes "Q" from the content of the 4th cell linked via "+d.1" from the cursor.
func QuadrantToggle(s *data.Slice, cursorNum int) error {
	cursorCellID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("QuadrantToggle: cursor %d not found", cursorNum)
	}

	// In Perl: $cell = cell_nbr($cell, "+d.1"); $cell = cell_nbr($cell, "+d.1");
	// $cell = cell_nbr($cell, "+d.1"); $cell = cell_nbr($cell, "+d.1");
	// This is the cell for Raster/Quadrant style (4th +d.1 from cursor cell)
	styleCellID, ok := getNthLinkedCell(s, cursorCellID, "+d.1", 4)
	if !ok {
		return fmt.Errorf("QuadrantToggle: could not find style cell (4th +d.1) for cursor %d (cell %d)", cursorNum, cursorCellID)
	}

	currentContent, contentOk := s.CellGet(styleCellID)
	if !contentOk {
		return fmt.Errorf("QuadrantToggle: could not get content of style cell %d", styleCellID)
	}

	var newContent string
	if strings.HasSuffix(currentContent, "Q") {
		newContent = strings.TrimSuffix(currentContent, "Q")
	} else {
		newContent = currentContent + "Q"
	}

	err := s.CellSet(styleCellID, newContent)
	if err != nil {
		return fmt.Errorf("QuadrantToggle: failed to set content for style cell %d: %w", styleCellID, err)
	}
	// display_dirty() in Perl
	return nil
}

// RasterToggle toggles the raster display style for the given cursor's view.
// It changes the content of the 4th cell linked via "+d.1" from the cursor between "I" and "H".
func RasterToggle(s *data.Slice, cursorNum int) error {
	cursorCellID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("RasterToggle: cursor %d not found", cursorNum)
	}

	styleCellID, ok := getNthLinkedCell(s, cursorCellID, "+d.1", 4)
	if !ok {
		return fmt.Errorf("RasterToggle: could not find style cell (4th +d.1) for cursor %d (cell %d)", cursorNum, cursorCellID)
	}

	currentContent, contentOk := s.CellGet(styleCellID)
	if !contentOk {
		return fmt.Errorf("RasterToggle: could not get content of style cell %d", styleCellID)
	}

	var newContent string
	// Perl: tr/IH/HI/; - This swaps I and H, keeping Q if present.
	if strings.HasPrefix(currentContent, "I") {
		newContent = "H" + strings.TrimPrefix(currentContent, "I")
	} else if strings.HasPrefix(currentContent, "H") {
		newContent = "I" + strings.TrimPrefix(currentContent, "H")
	} else {
		// Default or unknown state, set to "I" perhaps, or error.
		// For now, let's assume it's one of I or H, possibly with Q.
		// If it's just "Q", or empty, this logic might need refinement based on expected states.
		// The Perl code `tr/IH/HI/` would leave "Q" as "Q", "" as "".
		// So, if neither I nor H is the prefix, content remains unchanged by this part.
		newContent = currentContent // No change if no I/H prefix
	}
	
	// Check if content was actually I or H to toggle
	// The tr/IH/HI/ in perl will only change I to H or H to I. Other chars remain.
	// Example: "IQ" -> "HQ", "H" -> "I", "Q" -> "Q"
	// My logic above: "IQ" -> "HQ", "H" -> "I"
	// If currentContent = "Q", currentContent = "Q"
	// If currentContent = "X", currentContent = "X"
	// This seems fine.

	if newContent != currentContent {
		err := s.CellSet(styleCellID, newContent)
		if err != nil {
			return fmt.Errorf("RasterToggle: failed to set content for style cell %d: %w", styleCellID, err)
		}
	}
	// display_dirty() in Perl
	return nil
}

// Reset resets the view dimensions (X, Y, Z axes) for the given cursor to defaults.
// Defaults are typically +d.1, +d.2, +d.3 taken from the main dimension list.
func Reset(s *data.Slice, cursorNum int) error {
	cursorCellID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("ViewReset: cursor %d not found", cursorNum)
	}

	dimListStartCellID, dimListOk := s.DimensionHome()
	if !dimListOk {
		return fmt.Errorf("ViewReset: DimensionHome not found in slice %s", s.Name)
	}

	currentDimCellID := dimListStartCellID

	for i := 1; i <= 3; i++ { // For X, Y, Z axes (1st, 2nd, 3rd +d.1 from cursor)
		axisViewCellID, axisCellOk := getNthLinkedCell(s, cursorCellID, "+d.1", i)
		if !axisCellOk {
			return fmt.Errorf("ViewReset: could not find %d-th axis view cell for cursor %d (cell %d)", i, cursorNum, cursorCellID)
		}

		dimName, nameOk := s.CellGet(currentDimCellID)
		if !nameOk {
			return fmt.Errorf("ViewReset: could not get dimension name from cell %d (dim list)", currentDimCellID)
		}

		err := s.CellSet(axisViewCellID, "+"+dimName)
		if err != nil {
			return fmt.Errorf("ViewReset: failed to set view for axis %d (cell %d) to '+%s': %w", i, axisViewCellID, dimName, err)
		}

		if i < 3 { // Move to next dimension in the list for Y and Z
			nextDimCell, nextDimOk := s.CellNbr(currentDimCellID, "+d.2")
			if !nextDimOk {
				return fmt.Errorf("ViewReset: dimension list too short; cannot find dimension for axis %d", i+1)
			}
			if _, nextDimCellActuallyExists := s.Cells[nextDimCell]; !nextDimCellActuallyExists {
			    return fmt.Errorf("ViewReset: dimension list link broken at cell %d to non-existent cell %d", currentDimCellID, nextDimCell)
			}
			currentDimCellID = nextDimCell
		}
	}
	// display_dirty() in Perl
	return nil
}

// Rotate rotates the view dimensions for a given cursor around a specified axis ('X', 'Y', or 'Z').
func Rotate(s *data.Slice, cursorNum int, axis rune) error {
	cursorCellID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("ViewRotate: cursor %d not found", cursorNum)
	}

	var axisViewCellID int // The cell holding the dimension for the specified axis
	var axisCellOk bool

	switch strings.ToUpper(string(axis)) {
	case "X":
		axisViewCellID, axisCellOk = getNthLinkedCell(s, cursorCellID, "+d.1", 1)
	case "Y":
		axisViewCellID, axisCellOk = getNthLinkedCell(s, cursorCellID, "+d.1", 2)
	case "Z":
		axisViewCellID, axisCellOk = getNthLinkedCell(s, cursorCellID, "+d.1", 3)
	default:
		return fmt.Errorf("ViewRotate: invalid axis '%c'", axis)
	}

	if !axisCellOk {
		return fmt.Errorf("ViewRotate: could not find axis view cell for axis '%c', cursor %d (cell %d)", axis, cursorNum, cursorCellID)
	}

	currentViewDimFullName, contentOk := s.CellGet(axisViewCellID)
	if !contentOk {
		return fmt.Errorf("ViewRotate: could not get current view dimension for axis '%c' from cell %d", axis, axisViewCellID)
	}

	currentSign := ""
	currentDimName := currentViewDimFullName
	if strings.HasPrefix(currentViewDimFullName, "+") || strings.HasPrefix(currentViewDimFullName, "-") {
		currentSign = string(currentViewDimFullName[0])
		currentDimName = currentViewDimFullName[1:]
	} else {
		// If no sign, assume positive, though spec implies they are stored with signs.
		// This case should ideally not happen if view_reset sets them with signs.
		currentSign = "+" 
	}


	dimListStartCellID, dimListOk := s.DimensionHome()
	if !dimListOk {
		return fmt.Errorf("ViewRotate: DimensionHome not found in slice %s", s.Name)
	}

	// Find currentDimName in the main dimension list
	currentDimDefCellID, dimFound := s.CellFind(dimListStartCellID, "+d.2", currentDimName)
	if !dimFound {
		// If current dimension name not in list, rotate to the start of the list (dimHome)
		currentDimDefCellID = dimListStartCellID 
	}

	// Get the next dimension in the list (+d.2 chain)
	nextDimDefCellID, nextDimOk := s.CellNbr(currentDimDefCellID, "+d.2")
	if !nextDimOk { // Reached end of list, loop back to the start
		nextDimDefCellID = dimListStartCellID
	}
	if _, nextDimDefCellActuallyExists := s.Cells[nextDimDefCellID]; !nextDimDefCellActuallyExists {
	    return fmt.Errorf("ViewRotate: dimension list link broken at cell %d to non-existent cell %d", currentDimDefCellID, nextDimDefCellID)
	}


	newDimName, nameOk := s.CellGet(nextDimDefCellID)
	if !nameOk {
		return fmt.Errorf("ViewRotate: could not get name for new dimension cell %d", nextDimDefCellID)
	}

	err := s.CellSet(axisViewCellID, currentSign+newDimName)
	if err != nil {
		return fmt.Errorf("ViewRotate: failed to set new view dimension '%s%s' for axis '%c' in cell %d: %w", currentSign, newDimName, axis, axisViewCellID, err)
	}
	// display_dirty() in Perl
	return nil
}

// Flip inverts the sign (+/-) of the view dimension for a given cursor and axis.
func Flip(s *data.Slice, cursorNum int, axis rune) error {
	cursorCellID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("ViewFlip: cursor %d not found", cursorNum)
	}

	var axisViewCellID int
	var axisCellOk bool

	switch strings.ToUpper(string(axis)) {
	case "X":
		axisViewCellID, axisCellOk = getNthLinkedCell(s, cursorCellID, "+d.1", 1)
	case "Y":
		axisViewCellID, axisCellOk = getNthLinkedCell(s, cursorCellID, "+d.1", 2)
	case "Z":
		axisViewCellID, axisCellOk = getNthLinkedCell(s, cursorCellID, "+d.1", 3)
	default:
		return fmt.Errorf("ViewFlip: invalid axis '%c'", axis)
	}

	if !axisCellOk {
		return fmt.Errorf("ViewFlip: could not find axis view cell for axis '%c', cursor %d (cell %d)", axis, cursorNum, cursorCellID)
	}

	currentContent, contentOk := s.CellGet(axisViewCellID)
	if !contentOk {
		return fmt.Errorf("ViewFlip: could not get content of axis view cell %d", axisViewCellID)
	}

	newContent := data.ReverseSign(currentContent) // Use ReverseSign from data package

	err := s.CellSet(axisViewCellID, newContent)
	if err != nil {
		return fmt.Errorf("ViewFlip: failed to set flipped content for axis view cell %d: %w", axisViewCellID, err)
	}
	// display_dirty() in Perl
	return nil
}
