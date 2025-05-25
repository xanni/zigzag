package cursor

import (
	"fmt"

	"../data" // Adjusted import path
)

// MoveCursorInDimension moves a cursor cell (cursorID) along a specified dimension (dim).
// The actual cell being conceptually "moved" to determine the target is the one accursed by cursorID.
// The cursorID itself is then re-linked in the "d.cursor" dimension relative to the new target.
func MoveCursorInDimension(s *data.Slice, cursorID int, dim string) error {
	if _, cursorExists := s.Cells[cursorID]; !cursorExists {
		return fmt.Errorf("MoveCursorInDimension: cursor cell %d does not exist in slice %s", cursorID, s.Name)
	}

	// The cell that determines the target spot by moving along 'dim'.
	// This is the cell "accursed" by the cursor, found at the end of its -d.cursor chain.
	// If cursorID is the only cell in its -d.cursor chain, cellToAssessMovement will be cursorID.
	cellToAssessMovement, ok := s.GetLastCell(cursorID, "-d.cursor")
	if !ok {
		// This case implies GetLastCell had an issue, though if cursorID exists,
		// GetLastCell should at least return (cursorID, true).
		return fmt.Errorf("MoveCursorInDimension: failed to determine cell to assess movement for cursor %d in slice %s", cursorID, s.Name)
	}

	// Find the target cell by trying to move cellToAssessMovement along the given dimension 'dim'.
	targetCellID, targetExists := s.CellNbr(cellToAssessMovement, dim)
	if !targetExists {
		return fmt.Errorf("MoveCursorInDimension: no cell found from cell %d along dimension %s in slice %s (nowhere to move cursor %d)", cellToAssessMovement, dim, s.Name, cursorID)
	}

	if targetCellID == cellToAssessMovement {
		return fmt.Errorf("MoveCursorInDimension: target cell %d is the same as current accursed cell %d for cursor %d in slice %s (no actual movement)", targetCellID, cellToAssessMovement, cursorID, s.Name)
	}

	// Check if the targetCellID itself is part of a cursor structure (specifically, if it accurses another cell).
	// In Perl: defined cell_nbr($_, "-d.cursor")) where $_ is targetCellID.
	// This means the target cell should not itself be a head of another cursor's -d.cursor chain.
	if _, isTargetAlreadyAccursing := s.CellNbr(targetCellID, "-d.cursor"); isTargetAlreadyAccursing {
		// This is a simplified check. The original Perl `defined cell_nbr($_, "-d.cursor")`
		// checks if the target cell *has* a -d.cursor link, implying it's a cursor.
		// A more direct translation of the Perl's condition:
		// return if (!defined($_ = cell_nbr($cell, $dir)) || ($_ == $cell) || defined cell_nbr($_, "-d.cursor"));
		// So, if targetCellID has a -d.cursor link, it's not a valid place to move.
		return fmt.Errorf("MoveCursorInDimension: target cell %d is itself a cursor or part of a cursor structure in slice %s (cannot move cursor %d there)", targetCellID, s.Name, cursorID)
	}
	
	// Determine the insertion point for the cursorID in the "d.cursor" dimension.
	// Ted's preference: cursor is inserted after the last cell in the +d.cursor chain of the target.
	insertionPointCellID, ok := s.GetLastCell(targetCellID, "+d.cursor")
	if !ok {
		// This implies targetCellID is invalid for GetLastCell, which shouldn't happen if it exists.
		// Or, GetLastCell could not determine an end (e.g. broken structure, though targetCellID itself should be an end if no +d.cursor link).
		// If targetCellID has no +d.cursor links, GetLastCell should return (targetCellID, true).
		// We use targetCellID itself as the insertion point if GetLastCell fails unexpectedly,
		// assuming targetCellID is where the cursor chain should begin.
		// However, the Perl code implies `get_lastcell($_, "+d.cursor")` where $_ is targetCellID.
		// This means `insertionPointCellID` should be `targetCellID` if `targetCellID` has no `+d.cursor` link.
		// Let's ensure `insertionPointCellID` is valid. If `GetLastCell` returns `(targetCellID, true)` this is fine.
		return fmt.Errorf("MoveCursorInDimension: could not determine insertion point for cursor %d at target %d in slice %s", cursorID, targetCellID, s.Name)
	}


	// Now, move the actual cursorID cell.
	// 1. Excise cursorID from its current position in the "d.cursor" dimension.
	err := s.CellExcise(cursorID, "d.cursor") // "d.cursor" is the base dimension name
	if err != nil {
		return fmt.Errorf("MoveCursorInDimension: failed to excise cursor %d from 'd.cursor' dimension in slice %s: %w", cursorID, s.Name, err)
	}

	// 2. Insert cursorID at the new position, relative to insertionPointCellID, along "+d.cursor".
	err = s.CellInsert(cursorID, insertionPointCellID, "+d.cursor")
	if err != nil {
		return fmt.Errorf("MoveCursorInDimension: failed to insert cursor %d relative to cell %d in '+d.cursor' dimension in slice %s: %w", cursorID, insertionPointCellID, s.Name, err)
	}

	// display_dirty() would be called here in Perl.
	return nil
}

// InputBuffer simulates the global $Input_Buffer in Perl.
// It holds an optional integer, typically a cell ID, for commands like AtCursorMakeLink.
// A nil value means no input is currently buffered.
var InputBuffer *int

// ClearInputBuffer sets the InputBuffer to nil.
func ClearInputBuffer() {
	InputBuffer = nil
}

// SetInputBuffer sets the InputBuffer to the given integer value.
func SetInputBuffer(value int) {
	InputBuffer = &value
}

// AtCursorClone clones cells. If a selection is active, it clones the selected cells.
// Otherwise, it clones the cell accursed by cursorNum.
// 'op' can be "clone" (creates clone links) or "copy" (copies content and selected links).
// After cloning/copying, the cursor jumps to the last new cell created.
func AtCursorClone(s *data.Slice, cursorNum int, op string) error {
	if op != "clone" && op != "copy" {
		return fmt.Errorf("AtCursorClone: invalid operation '%s', must be 'clone' or 'copy'", op)
	}

	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorClone: cursor %d not found", cursorNum)
	}

	selection, selectionExists := s.GetActiveSelection()
	if !selectionExists || len(selection) == 0 { // If GetActiveSelection returns false or empty slice
		accursedCellID, accursedOk := s.GetAccursed(cursorNum)
		if !accursedOk {
			return fmt.Errorf("AtCursorClone: could not get accursed cell for cursor %d", cursorNum)
		}
		selection = []int{accursedCellID}
	}
	if len(selection) == 0 {
		return fmt.Errorf("AtCursorClone: no cells to clone/copy for cursor %d", cursorNum)
	}

	newCellIDs := make(map[int]int) // Maps old cell ID to new cell ID
	isCellSelected := make(map[int]bool)
	var lastNewCellID int

	for _, cellID := range selection {
		isCellSelected[cellID] = true // Mark all cells in the initial selection list
	}

	for _, oldCellID := range selection {
		var newCellContent string
		if op == "copy" {
			content, contentOk := s.GetCellContents(oldCellID) // Get true content for copying
			if !contentOk {
				return fmt.Errorf("AtCursorClone: could not get content for cell %d during copy", oldCellID)
			}
			newCellContent = "Copy of " + content
		} else { // "clone"
			newCellContent = fmt.Sprintf("Clone of %d", oldCellID)
		}

		newID, err := s.CellNew(newCellContent)
		if err != nil {
			return fmt.Errorf("AtCursorClone: failed to create new cell: %w", err)
		}
		newCellIDs[oldCellID] = newID
		lastNewCellID = newID

		if op == "clone" {
			err := s.CellInsert(newID, oldCellID, "+d.clone")
			if err != nil {
				// Attempt to clean up by deleting the new cell if linking fails
				// s.CellDelete(newID) // This would require a CellDelete function. For now, log and error.
				return fmt.Errorf("AtCursorClone: failed to insert clone link for new cell %d from old cell %d: %w", newID, oldCellID, err)
			}
		}
	}

	// For "copy" operation, duplicate links between selected cells.
	if op == "copy" {
		for _, oldCellID := range selection {
			newSourceID := newCellIDs[oldCellID]
			// Iterate over all dimensions to find links originating from oldCellID
			// This is a simplified version of Perl's "FIXME" section.
			// A more robust GetLinksFrom(cellID) would be better.
			if cell, exists := s.Cells[oldCellID]; exists {
				for dim, targetOldID := range cell.Links {
					// If the target of the link was also part of the selection
					if isCellSelected[targetOldID] {
						newTargetID := newCellIDs[targetOldID]
						// Make the link between the new cells
						err := s.LinkMake(newSourceID, newTargetID, dim)
						if err != nil {
							// Log or handle error: failed to copy link
							fmt.Printf("Warning: AtCursorClone (copy): failed to make link from new cell %d to new cell %d along %s: %v\n", newSourceID, newTargetID, dim, err)
						}
					}
				}
			}
		}
	}

	if lastNewCellID != 0 { // Ensure a new cell was actually created
		err := JumpCursor(s, cursorID, lastNewCellID)
		if err != nil {
			return fmt.Errorf("AtCursorClone: failed to jump cursor %d to new cell %d: %w", cursorNum, lastNewCellID, err)
		}
	}
	// display_dirty()
	return nil
}

// AtCursorCopy is a convenience function for AtCursorClone with "copy" operation.
func AtCursorCopy(s *data.Slice, cursorNum int) error {
	return AtCursorClone(s, cursorNum, "copy")
}

// AtCursorSelect toggles the selection status of the cell accursed by cursorNum.
// Returns a status message.
func AtCursorSelect(s *data.Slice, cursorNum int) (string, error) {
	accursedCellID, ok := s.GetAccursed(cursorNum)
	if !ok {
		return "", fmt.Errorf("AtCursorSelect: could not get accursed cell for cursor %d", cursorNum)
	}

	alreadySelected := s.IsSelected(accursedCellID)
	var whichSelectionHeadID int
	var whichSelectionHeadExists bool

	if alreadySelected {
		whichSelectionHeadID, whichSelectionHeadExists = s.GetWhichSelection(accursedCellID)
	}

	// Always excise from "d.mark" first.
	// If it's not part of any mark chain, CellExcise should handle this gracefully or error.
	// Assuming CellExcise won't error if links don't exist, but will do nothing.
	// For robustness, one might check if it's in a d.mark chain first.
	if _, hasMarkLinks := s.CellNbr(accursedCellID, "+d.mark"); hasMarkLinks || s.IsClone(accursedCellID) { // Check if it has any d.mark links
		err := s.CellExcise(accursedCellID, "d.mark")
		if err != nil {
			// This error might mean it wasn't part of a d.mark chain in a way CellExcise expected.
			// Or a more serious issue.
			// fmt.Printf("Warning: AtCursorSelect: CellExcise from d.mark for cell %d failed (might be ok if not in chain): %v\n", accursedCellID, err)
		}
	}


	var statusMsg string
	if alreadySelected && whichSelectionHeadExists && whichSelectionHeadID == data.SelectHome {
		statusMsg = fmt.Sprintf("Deselected cell %d", accursedCellID)
		// display_status_draw(statusMsg)
	} else {
		// Add to the active selection (headed by data.SelectHome)
		err := s.CellInsert(accursedCellID, data.SelectHome, "+d.mark")
		if err != nil {
			return "", fmt.Errorf("AtCursorSelect: failed to insert cell %d into active selection (+d.mark from %d): %w", accursedCellID, data.SelectHome, err)
		}
		statusMsg = fmt.Sprintf("Selected cell %d", accursedCellID)
		// display_status_draw(statusMsg)
	}
	// display_dirty()
	return statusMsg, nil
}

// RotateSelection exchanges the current selection with a saved selection.
// If shearCountOptional is provided, it uses that; otherwise, it uses InputBuffer or defaults to 1.
func RotateSelection(s *data.Slice, shearCountOptional ...int) error {
	shearCount := 1 // Default
	if len(shearCountOptional) > 0 {
		shearCount = shearCountOptional[0]
	} else if InputBuffer != nil {
		shearCount = *InputBuffer
		ClearInputBuffer() // Consume input buffer
	}

	if shearCount == 0 { return nil } // No rotation

	// The Perl code `do_shear($SELECT_HOME, '-d.2', '+d.mark', $shear_count);`
	// Shears the selection heads themselves along '-d.2'.
	// The items being sheared are the selection head cells (e.g. SelectHome, and cells linked to it via +/-d.2).
	// The links being affected are their respective '+d.mark' links.
	err := s.DoShear(data.SelectHome, "-d.2", "+d.mark", shearCount, false) // hang = false
	if err != nil {
		return fmt.Errorf("RotateSelection: DoShear failed: %w", err)
	}
	// display_dirty()
	return nil
}

// PushSelection pushes the current active selection onto the selection stack
// and makes the active selection empty.
func PushSelection(s *data.Slice) error {
	// Count existing selections to name the new one (optional, for content)
	selectionHeads, ok := s.CellsRow(data.SelectHome, "+d.2")
	if !ok {
		// This implies SelectHome doesn't exist or CellsRow failed.
		return fmt.Errorf("PushSelection: could not get current selection heads")
	}
	numSelections := len(selectionHeads) // Includes SelectHome itself

	newSelHeadContent := fmt.Sprintf("Selection #%d", numSelections)
	newSelHeadID, err := s.CellNew(newSelHeadContent)
	if err != nil {
		return fmt.Errorf("PushSelection: failed to create new cell for selection head: %w", err)
	}

	// Insert the new selection head into the list of selection heads (after SelectHome)
	err = s.CellInsert(newSelHeadID, data.SelectHome, "+d.2")
	if err != nil {
		return fmt.Errorf("PushSelection: failed to insert new selection head %d after %d: %w", newSelHeadID, data.SelectHome, err)
	}

	// Shear all selections +d.2ward by 1, effectively moving the old active selection's
	// +d.mark links to the newly created (now empty) selection head, and
	// making the original SelectHome's +d.mark empty.
	// The Perl code is: do_shear($SELECT_HOME, "+d.2", "+d.mark", 1);
	// This means the row of selection heads (starting from SelectHome, along +d.2)
	// has their +d.mark links shifted by 1.
	err = s.DoShear(data.SelectHome, "+d.2", "+d.mark", 1, false) // hang = false
	if err != nil {
		return fmt.Errorf("PushSelection: DoShear failed: %w", err)
	}
	// display_dirty()
	return nil
}


// AtCursorInsert inserts a new cell relative to the cell accursed by cursorNum,
// in the direction specified by directionKey.
func AtCursorInsert(s *data.Slice, cursorNum int, directionKey string) error {
	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorInsert: cursor %d not found", cursorNum)
	}
	accursedCellID, ok := s.GetAccursed(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorInsert: could not get accursed cell for cursor %d", cursorNum)
	}

	actualDim, ok := s.GetDimension(cursorID, directionKey)
	if !ok {
		return fmt.Errorf("AtCursorInsert: could not get dimension for cursor %d, key '%s': %w", cursorNum, directionKey, fmt.Errorf("dimension not found"))
	}

	// Perl: if ($dim =~ /^[+-]d\.(clone|cursor)$/) { user_error(9, $dim); }
	if actualDim == "+d.clone" || actualDim == "-d.clone" || actualDim == "d.clone" ||
		actualDim == "+d.cursor" || actualDim == "-d.cursor" || actualDim == "d.cursor" {
		return fmt.Errorf("AtCursorInsert: cannot insert along protected dimension '%s'", actualDim) // user_error(9)
	}

	newCellID, err := s.CellNew() // Default content (cell ID as string)
	if err != nil {
		return fmt.Errorf("AtCursorInsert: failed to create new cell: %w", err)
	}

	err = s.CellInsert(newCellID, accursedCellID, actualDim)
	if err != nil {
		// s.CellDelete(newCellID) // Attempt to clean up if insert fails.
		return fmt.Errorf("AtCursorInsert: failed to insert new cell %d relative to cell %d in dim %s: %w", newCellID, accursedCellID, actualDim, err)
	}
	// display_dirty()
	return nil
}

// AtCursorDelete deletes the cell accursed by cursorNum.
// Handles essential cells, clone promotion, and moving the deleted cell to the recycle pile.
// The cursor then jumps to a suitable neighbor or to cell 0.
func (s *data.Slice) AtCursorDelete(cursorNum int) error {
	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorDelete: cursor %d not found", cursorNum)
	}
	cellToDeleteID, ok := s.GetAccursed(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorDelete: could not get accursed cell for cursor %d", cursorNum)
	}

	if data.IsEssentialCell(cellToDeleteID) {
		return fmt.Errorf("AtCursorDelete: cell %d is essential and cannot be deleted", cellToDeleteID) // user_error(10)
	}

	dimHomeCellID, dimHomeOk := s.DimensionHome()
	if dimHomeOk { // Only perform this check if DimensionHome is found
		cellContent, _ := s.CellGet(cellToDeleteID)
		// Perl: (cell_find($cell, "-d.2", cell_get($dhome)) == $dhome)
		// This checks if the cellToDeleteID is part of the main dimension list itself (connected to dimHome via -d.2 chain)
		// And if its content (which is a dimension name) is essential.
		// This is a complex check. For now, a simplified check:
		if data.DimensionIsEssential(cellContent) {
			// A more accurate check would verify it's truly a dimension defining cell in the dimension list.
			// For now, if its content matches an essential dim name, and it's not one of the essential cells, it's an issue.
			// The original check `cell_find($cell, "-d.2", cell_get($dhome)) == $dhome` implies cell is in the dimension list.
			// We'll assume if content is an essential dim, it's critical.
			// A full CellFind from cellToDeleteID along -d.2 to find dimHome's content might be too much here.
			// This simplified check might be too restrictive or not restrictive enough.
			// Let's assume for now that if its content is an essential dimension name, it's an error.
			// This is likely what the original intended for cells that define essential dimensions.
			// A proper check: is cellToDeleteID reachable from dimHomeCellID via +d.2 and is its content an essential dim name?
			isDimDefCell, _ := s.CellFind(dimHomeCellID, "+d.2", cellContent)
			if isDimDefCell == cellToDeleteID { // cellToDelete is a dimension definition cell for an essential dim
				 return fmt.Errorf("AtCursorDelete: cell %d defines an essential dimension '%s' and cannot be deleted", cellToDeleteID, cellContent) // user_error(11)
			}
		}
	}


	// Clone promotion: if cellToDelete has a +d.clone link (it's a clone source)
	// and no -d.clone link (it's not a clone itself), promote its content.
	if cloneTargetID, isCloneSource := s.CellNbr(cellToDeleteID, "+d.clone"); isCloneSource {
		if _, isItselfClone := s.CellNbr(cellToDeleteID, "-d.clone"); !isItselfClone {
			originalContent, contentOk := s.CellGet(cellToDeleteID)
			if contentOk {
				err := s.CellSet(cloneTargetID, originalContent)
				if err != nil {
					// Log or handle error during clone promotion content setting
					fmt.Printf("Warning: AtCursorDelete: failed to set content on promoted clone %d: %v\n", cloneTargetID, err)
				}
			}
		}
	}

	var bestNeighborID = 0 // Default to cell 0 (Home)
	var neighborFound = false

	// Iterate all dimensions to excise the cell and find a suitable neighbor for the cursor to jump to.
	if dimHomeOk { // Proceed only if dimension list is accessible
		currentDimListCell := dimHomeCellID
		processedDimListCells := make(map[int]bool)

		for i := 0; i < len(s.Cells)+1; i++ { // Loop protection
			if _, currentDimListCellExists := s.Cells[currentDimListCell]; !currentDimListCellExists { break }
			if processedDimListCells[currentDimListCell] { break } // Cycled
			processedDimListCells[currentDimListCell] = true
			
			baseDimName, nameOk := s.CellGet(currentDimListCell)
			if nameOk && baseDimName != "" {
				// Try to find a neighbor along this dimension before excising
				if !neighborFound {
					if negNbr, negExists := s.CellNbr(cellToDeleteID, "-"+baseDimName); negExists && !s.IsCursor(negNbr) {
						bestNeighborID = negNbr
						neighborFound = true
					} else if posNbr, posExists := s.CellNbr(cellToDeleteID, "+"+baseDimName); posExists && !s.IsCursor(posNbr) {
						bestNeighborID = posNbr
						neighborFound = true
					}
				}
				s.CellExcise(cellToDeleteID, baseDimName) // Ignoring error for now, as some dimensions might not have the cell
			}
			
			prevDimListCell := currentDimListCell
			currentDimListCell, ok = s.CellNbr(currentDimListCell, "+d.2")
			if !ok || currentDimListCell == prevDimListCell || currentDimListCell == dimHomeCellID && i >0 {
				break
			}
		}
	} else { // Fallback if dimension list isn't available: try excising from known essential dimensions
		essentialDimsToTry := []string{"d.1", "d.2", "d.cursor", "d.clone", "d.inside", "d.contents", "d.mark"}
		for _, baseDimName := range essentialDimsToTry {
			s.CellExcise(cellToDeleteID, baseDimName) // Ignoring errors
		}
	}


	// Move cellToDeleteID to the recycle pile (insert into d.2 of DeleteHome)
	if _, deleteHomeCellExists := s.Cells[data.DeleteHome]; deleteHomeCellExists {
		err := s.CellInsert(cellToDeleteID, data.DeleteHome, "+d.2")
		if err != nil {
			return fmt.Errorf("AtCursorDelete: failed to move cell %d to recycle pile: %w", cellToDeleteID, err)
		}
	} else {
		fmt.Printf("Warning: AtCursorDelete: DeleteHome cell %d does not exist. Cannot move cell %d to recycle pile.\n", data.DeleteHome, cellToDeleteID)
		// Cell is effectively deleted from dimensions but not placed on a formal recycle pile.
	}

	// Move the cursor to the best found neighbor or cell 0.
	// The cursor itself is `cursorID`.
	err := JumpCursor(s, cursorID, bestNeighborID)
	if err != nil {
		// If jump fails (e.g. bestNeighborID is also problematic), try jumping to cell 0 as a last resort.
		if bestNeighborID != 0 {
			fmt.Printf("Warning: AtCursorDelete: failed to jump cursor %d to neighbor %d (%v). Attempting jump to cell 0.\n", cursorNum, bestNeighborID, err)
			return JumpCursor(s, cursorID, 0)
		}
		return fmt.Errorf("AtCursorDelete: failed to jump cursor %d to best neighbor %d: %w", cursorNum, bestNeighborID, err)
	}

	// display_dirty()
	return nil
}

// AtCursorHop swaps the cell accursed by cursorNum with its neighbor in the specified directionKey's dimension.
func AtCursorHop(s *data.Slice, cursorNum int, directionKey string) error {
	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorHop: cursor %d not found", cursorNum)
	}
	cellToHop, ok := s.GetAccursed(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorHop: could not get accursed cell for cursor %d", cursorNum)
	}

	dim, ok := s.GetDimension(cursorID, directionKey)
	if !ok {
		return fmt.Errorf("AtCursorHop: could not get dimension for key '%s'", directionKey)
	}
	if dim == "d.cursor" || dim == "+d.cursor" || dim == "-d.cursor" { // Cannot hop in cursor dimension
		return fmt.Errorf("AtCursorHop: cannot hop in 'd.cursor' dimension")
	}

	neighborID, neighborExists := s.CellNbr(cellToHop, dim)
	if !neighborExists {
		return fmt.Errorf("AtCursorHop: cell %d has no neighbor in dimension %s to hop with", cellToHop, dim) // user_error(5)
	}
	if _, neighborCellReallyExists := s.Cells[neighborID]; !neighborCellReallyExists {
	    return fmt.Errorf("AtCursorHop: neighbor cell %d (of cell %d in dim %s) does not exist in slice %s", neighborID, cellToHop, dim, s.Name)
	}


	prevID, prevExists := s.CellNbr(cellToHop, data.ReverseSign(dim))
	nextID, nextExists := s.CellNbr(neighborID, dim)

	// Break all relevant links first
	// cellToHop <-> neighborID
	s.LinkBreakExplicit(cellToHop, neighborID, dim) // Error handling omitted for brevity, assume it works if link exists

	if prevExists {
		s.LinkBreakExplicit(prevID, cellToHop, dim)
	}
	if nextExists {
		s.LinkBreakExplicit(neighborID, nextID, dim)
	}

	// Make new links to swap cellToHop and neighborID
	// prevID <-> neighborID <-> cellToHop <-> nextID
	if prevExists {
		if err := s.LinkMake(prevID, neighborID, dim); err != nil { return fmt.Errorf("AtCursorHop: LinkMake(prev,neighbor) failed: %w", err)}
	}
	if err := s.LinkMake(neighborID, cellToHop, dim); err != nil { return fmt.Errorf("AtCursorHop: LinkMake(neighbor,cellToHop) failed: %w", err)}
	if nextExists {
		if err := s.LinkMake(cellToHop, nextID, dim); err != nil { return fmt.Errorf("AtCursorHop: LinkMake(cellToHop,next) failed: %w", err)}
	}
	
	// display_dirty()
	return nil
}

// AtCursorShear performs a shear operation on the row of cells starting from the accursed cell.
func AtCursorShear(s *data.Slice, cursorNum int, shearDirKey string, linkDirKey string) error {
	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorShear: cursor %d not found", cursorNum)
	}
	headCellID, ok := s.GetAccursed(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorShear: could not get accursed cell for cursor %d", cursorNum)
	}

	shearDim, ok := s.GetDimension(cursorID, shearDirKey)
	if !ok {
		return fmt.Errorf("AtCursorShear: could not get shear dimension for key '%s'", shearDirKey)
	}
	linkDim, ok := s.GetDimension(cursorID, linkDirKey)
	if !ok {
		return fmt.Errorf("AtCursorShear: could not get link dimension for key '%s'", linkDirKey)
	}

	// Call DoShear with n=1 and hang=false (default behavior of original atcursor_shear)
	err := s.DoShear(headCellID, shearDim, linkDim, 1, false)
	if err != nil {
		return fmt.Errorf("AtCursorShear: DoShear operation failed: %w", err)
	}
	// display_dirty()
	return nil
}

// AtCursorMakeLink links the cell accursed by cursorNum to another cell.
// If targetCellIDFromInput (representing global InputBuffer) is nil, it moves the cursor.
// Otherwise, it links the accursed cell to *targetCellIDFromInput.
func AtCursorMakeLink(s *data.Slice, cursorNum int, directionKey string, targetCellIDFromInput *int) error {
	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorMakeLink: cursor %d not found", cursorNum)
	}
	accursedCellID, ok := s.GetAccursed(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorMakeLink: could not get accursed cell for cursor %d", cursorNum)
	}

	dim, ok := s.GetDimension(cursorID, directionKey)
	if !ok {
		return fmt.Errorf("AtCursorMakeLink: could not get dimension for key '%s'", directionKey)
	}

	if dim == "d.cursor" || dim == "+d.cursor" || dim == "-d.cursor" {
		return fmt.Errorf("AtCursorMakeLink: cannot make links in 'd.cursor' dimension")
	}

	if targetCellIDFromInput == nil { // No cell number selected from input buffer
		return MoveCursorInDimension(s, cursorID, dim)
	}

	targetCellID := *targetCellIDFromInput
	ClearInputBuffer() // Consume buffer

	if _, targetExists := s.Cells[targetCellID]; !targetExists {
		return fmt.Errorf("AtCursorMakeLink: target cell %d from input buffer does not exist", targetCellID) // user_error(6)
	}

	// Insert targetCellID next to accursedCellID in the specified dimension 'dim'.
	// This means accursedCellID will point to targetCellID via 'dim'.
	err := s.CellInsert(targetCellID, accursedCellID, dim)
	if err != nil {
		return fmt.Errorf("AtCursorMakeLink: failed to insert/link cell %d to accursed cell %d along %s: %w", targetCellID, accursedCellID, dim, err)
	}
	// display_dirty()
	return nil
}

// AtCursorBreakLink breaks a link from the cell accursed by cursorNum in a given dimension.
func AtCursorBreakLink(s *data.Slice, cursorNum int, directionKey string) error {
	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorBreakLink: cursor %d not found", cursorNum)
	}
	accursedCellID, ok := s.GetAccursed(cursorNum)
	if !ok {
		return fmt.Errorf("AtCursorBreakLink: could not get accursed cell for cursor %d", cursorNum)
	}

	dim, ok := s.GetDimension(cursorID, directionKey)
	if !ok {
		return fmt.Errorf("AtCursorBreakLink: could not get dimension for key '%s'", directionKey)
	}

	if dim == "d.cursor" || dim == "+d.cursor" || dim == "-d.cursor" {
		return fmt.Errorf("AtCursorBreakLink: cannot break links in 'd.cursor' dimension")
	}

	// Check if there is an existing link to break
	targetCellID, linkExists := s.CellNbr(accursedCellID, dim)
	if !linkExists {
		return fmt.Errorf("AtCursorBreakLink: no link exists from accursed cell %d along dimension %s to break", accursedCellID, dim) // user_error(7)
	}
	
	// Ensure target cell exists before trying to break the link from its side.
	// LinkBreakExplicit will handle this check too.
	if _, targetActuallyExists := s.Cells[targetCellID]; !targetActuallyExists {
	    // Link points to a non-existent cell. We can only remove the forward link.
	    if cell, cellExists := s.Cells[accursedCellID]; cellExists && cell.Links != nil {
	        delete(cell.Links, dim)
	        delete(s.db, strconv.Itoa(accursedCellID)+dim)
	        // display_dirty()
	        return nil
	    }
	    return fmt.Errorf("AtCursorBreakLink: accursed cell %d link to non-existent cell %d along %s", accursedCellID, targetCellID, dim)
	}


	err := s.LinkBreakExplicit(accursedCellID, targetCellID, dim)
	if err != nil {
		return fmt.Errorf("AtCursorBreakLink: failed to break link from accursed cell %d to %d along %s: %w", accursedCellID, targetCellID, dim, err)
	}
	// display_dirty()
	return nil
}

// JumpCursor moves a cursor cell (cursorID) to "accurse" a new destinationCellID.
// The cursorID is relinked in the "d.cursor" dimension.
func JumpCursor(s *data.Slice, cursorID int, destinationCellID int) error {
	if _, cursorExists := s.Cells[cursorID]; !cursorExists {
		return fmt.Errorf("JumpCursor: cursor cell %d does not exist in slice %s", cursorID, s.Name)
	}
	if _, destExists := s.Cells[destinationCellID]; !destExists {
		return fmt.Errorf("JumpCursor: destination cell %d does not exist in slice %s", destinationCellID, s.Name)
	}

	// Perl's condition: if (!defined cell_get($dest) || defined cell_nbr($dest, "-d.cursor"))
	// This means destinationCellID must exist (checked above) AND it must not itself be a cursor
	// (i.e., it should not have a -d.cursor link pointing from it).
	if _, destIsCursor := s.CellNbr(destinationCellID, "-d.cursor"); destIsCursor {
		return fmt.Errorf("JumpCursor: destination cell %d is itself a cursor in slice %s (cannot jump cursor %d there)", destinationCellID, s.Name, cursorID)
	}
	// The original IsCursor also checks +d.cursor. The Perl code is specific to -d.cursor for this check.
	// if s.IsCursor(destinationCellID) {
	// 	return fmt.Errorf("JumpCursor: destination cell %d is itself a cursor in slice %s (cannot jump cursor %d there)", destinationCellID, s.Name, cursorID)
	// }


	// Determine the insertion point for the cursorID in the "d.cursor" dimension.
	// The cursor is inserted after the last cell in the +d.cursor chain starting from/at destinationCellID.
	insertionPointCellID, ok := s.GetLastCell(destinationCellID, "+d.cursor")
	if !ok {
		// Similar to MoveCursorInDimension, this implies an issue with GetLastCell or destinationCellID.
		// If destinationCellID is valid and has no +d.cursor links, GetLastCell should return (destinationCellID, true).
		return fmt.Errorf("JumpCursor: could not determine insertion point for cursor %d at destination %d in slice %s", cursorID, destinationCellID, s.Name)
	}
	
	// 1. Excise cursorID from its current position in the "d.cursor" dimension.
	err := s.CellExcise(cursorID, "d.cursor") // "d.cursor" is the base dimension name
	if err != nil {
		return fmt.Errorf("JumpCursor: failed to excise cursor %d from 'd.cursor' dimension in slice %s: %w", cursorID, s.Name, err)
	}

	// 2. Insert cursorID at the new position, relative to insertionPointCellID, along "+d.cursor".
	err = s.CellInsert(cursorID, insertionPointCellID, "+d.cursor")
	if err != nil {
		return fmt.Errorf("JumpCursor: failed to insert cursor %d relative to cell %d in '+d.cursor' dimension in slice %s: %w", cursorID, insertionPointCellID, s.Name, err)
	}

	// display_dirty() would be called here in Perl.
	return nil
}

// MoveCursorUsingDirectionKey moves a specified cursor (by its number) in a given symbolic direction.
// Directions: "L" (left), "R" (right), "U" (up), "D" (down), "I" (in), "O" (out).
func MoveCursorUsingDirectionKey(s *data.Slice, cursorNum int, directionKey string) error {
	cursorID, ok := s.GetCursor(cursorNum)
	if !ok {
		return fmt.Errorf("MoveCursorUsingDirectionKey: failed to get cursor cell for cursor number %d in slice %s: %w", cursorNum, s.Name, fmt.Errorf("cursor not found"))
	}

	// Get the actual dimension name (e.g., "+d.1", "-d.2") corresponding to the symbolic directionKey for this cursor.
	actualDim, ok := s.GetDimension(cursorID, directionKey)
	if !ok {
		return fmt.Errorf("MoveCursorUsingDirectionKey: failed to get dimension for cursor %d (cell %d) with direction key '%s' in slice %s: %w", cursorNum, cursorID, directionKey, s.Name, fmt.Errorf("dimension not found for key"))
	}
	if actualDim == "" { // Should be caught by !ok from GetDimension, but as an extra check.
		return fmt.Errorf("MoveCursorUsingDirectionKey: GetDimension returned empty for cursor %d, key '%s' in slice %s", cursorNum, directionKey, s.Name)
	}


	// Now, move the cursor (cursorID) in this actualDim.
	// Note: MoveCursorInDimension expects cursorID (the cursor's own cell ID), not the cell it accurses.
	err := MoveCursorInDimension(s, cursorID, actualDim)
	if err != nil {
		return fmt.Errorf("MoveCursorUsingDirectionKey: failed to move cursor %d (cell %d) in dimension %s (from key '%s') in slice %s: %w", cursorNum, cursorID, actualDim, directionKey, s.Name, err)
	}

	return nil
}
