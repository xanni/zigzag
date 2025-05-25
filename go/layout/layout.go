package layout

import (
	"fmt"
	"strconv"

	"../data" // Adjust import path as necessary
)

// Hcells represents the number of horizontal cells per window (default: 80).
var Hcells = 80

// Vcells represents the number of vertical cells per window (default: 24).
var Vcells = 24

// formatCoord creates a string key "col,row" for maps.
func formatCoord(col, row int) string {
	return strconv.Itoa(col) + "," + strconv.Itoa(row)
}

// formatHLinkCoord creates a string key "col-row" for horizontal links.
func formatHLinkCoord(col, row int) string {
	return strconv.Itoa(col) + "-" + strconv.Itoa(row)
}

// formatVLinkCoord creates a string key "col|row" for vertical links.
func formatVLinkCoord(col, row int) string {
	return strconv.Itoa(col) + "|" + strconv.Itoa(row)
}

// LayoutCellsHorizontal lays out cells horizontally from a starting cell.
// It populates the 'layoutMap' with cell IDs at coordinates and 'hLinksDrawn' for horizontal links.
func LayoutCellsHorizontal(s *data.Slice, layoutMap map[string]int, hLinksDrawn map[string]bool, startCellID int, row int, dim string, sign int) {
	currentCellID := startCellID
	// Layout at most half a screen of cells
	for i := 1; ; i++ {
		if Hcells > 0 && i > (Hcells/2) { // Check Hcells to prevent infinite loop if Hcells is 0 or negative
			break
		}
		if Hcells <= 0 && i > 40 { // Default limit if Hcells is not positive
		    break;
		}


		nextCellID, exists := s.CellNbr(currentCellID, dim)
		if !exists {
			break
		}
		if _, cellExistsInSlice := s.Cells[nextCellID]; !cellExistsInSlice {
			// fmt.Printf("LayoutCellsHorizontal: Link from cell %d along %s points to non-existent cell %d\n", currentCellID, dim, nextCellID)
			break // Broken link
		}


		col := sign * i
		layoutMap[formatCoord(col, row)] = nextCellID
		hLinksDrawn[formatHLinkCoord(col, row)] = true // In Perl, it's "$col-$row", suggesting a link from (col-sign*1,row) to (col,row)

		currentCellID = nextCellID
		if currentCellID == startCellID { // Cycled back
			break
		}
	}
}

// LayoutCellsVertical lays out cells vertically from a starting cell.
// It populates 'layoutMap' with cell IDs and 'vLinksDrawn' for vertical links.
func LayoutCellsVertical(s *data.Slice, layoutMap map[string]int, vLinksDrawn map[string]bool, startCellID int, col int, dim string, sign int) {
	currentCellID := startCellID
	// Layout at most half a screen of cells
	for i := 1; ; i++ {
		if Vcells > 0 && i > (Vcells/2) {
			break
		}
		if Vcells <= 0 && i > 12 { // Default limit
		    break;
		}


		nextCellID, exists := s.CellNbr(currentCellID, dim)
		if !exists {
			break
		}
		if _, cellExistsInSlice := s.Cells[nextCellID]; !cellExistsInSlice {
			// fmt.Printf("LayoutCellsVertical: Link from cell %d along %s points to non-existent cell %d\n", currentCellID, dim, nextCellID)
			break // Broken link
		}

		row := sign * i
		layoutMap[formatCoord(col, row)] = nextCellID
		vLinksDrawn[formatVLinkCoord(col, row)] = true // In Perl, it's "$col|$row"

		currentCellID = nextCellID
		if currentCellID == startCellID { // Cycled back
			break
		}
	}
}

// LayoutPreview generates a basic cross-shaped preview layout.
// Returns:
// - layoutMap: map["col,row"]cellID
// - hLinksDrawn: map["col-row"]true (horizontal links)
// - vLinksDrawn: map["col|row"]true (vertical links)
func LayoutPreview(s *data.Slice, cellID int, rightDim, downDim string) (map[string]int, map[string]bool, map[string]bool) {
	layoutMap := make(map[string]int)
	hLinksDrawn := make(map[string]bool)
	vLinksDrawn := make(map[string]bool)

	if _, cellExists := s.Cells[cellID]; !cellExists {
		// fmt.Printf("LayoutPreview: Start cell %d does not exist\n", cellID)
		return layoutMap, hLinksDrawn, vLinksDrawn
	}

	layoutMap[formatCoord(0, 0)] = cellID

	leftDim := data.ReverseSign(rightDim)
	upDim := data.ReverseSign(downDim)

	LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, cellID, 0, leftDim, -1)  // Left
	LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, cellID, 0, rightDim, 1) // Right
	LayoutCellsVertical(s, layoutMap, vLinksDrawn, cellID, 0, upDim, -1)    // Up
	LayoutCellsVertical(s, layoutMap, vLinksDrawn, cellID, 0, downDim, 1)   // Down

	return layoutMap, hLinksDrawn, vLinksDrawn
}

// LayoutIRaster generates a horizontal ("I-raster") layout.
// Returns maps for cell layout, horizontal links, and vertical links.
func LayoutIRaster(s *data.Slice, cellID int, rightDim, downDim string) (map[string]int, map[string]bool, map[string]bool) {
	layoutMap := make(map[string]int)
	hLinksDrawn := make(map[string]bool)
	vLinksDrawn := make(map[string]bool)

	if _, cellExists := s.Cells[cellID]; !cellExists {
		// fmt.Printf("LayoutIRaster: Start cell %d does not exist\n", cellID)
		return layoutMap, hLinksDrawn, vLinksDrawn
	}

	layoutMap[formatCoord(0, 0)] = cellID
	leftDim := data.ReverseSign(rightDim)
	upDim := data.ReverseSign(downDim)

	// Layout the central row
	LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, cellID, 0, leftDim, -1)
	LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, cellID, 0, rightDim, 1)

	// Layout rows above
	currentRowCellID := cellID
	for y := 1; ; y++ {
		if Vcells > 0 && y > (Vcells/2) { break }
		if Vcells <= 0 && y > 12 { break } // Default limit

		nextRowStartCellID, exists := s.CellNbr(currentRowCellID, upDim)
		if !exists { break }
		if _, cellExistsInSlice := s.Cells[nextRowStartCellID]; !cellExistsInSlice { break }


		layoutMap[formatCoord(0, -y)] = nextRowStartCellID
		vLinksDrawn[formatVLinkCoord(0, -y)] = true // Link from cell (0, -(y-1)) to (0, -y)

		LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, nextRowStartCellID, -y, leftDim, -1)
		LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, nextRowStartCellID, -y, rightDim, 1)
		
		if nextRowStartCellID == cellID { break } // Cycled back to the main row's start cell
		currentRowCellID = nextRowStartCellID
	}

	// Layout rows below
	currentRowCellID = cellID
	for y := 1; ; y++ {
		if Vcells > 0 && y > (Vcells/2) { break }
		if Vcells <= 0 && y > 12 { break } // Default limit

		nextRowStartCellID, exists := s.CellNbr(currentRowCellID, downDim)
		if !exists { break }
		if _, cellExistsInSlice := s.Cells[nextRowStartCellID]; !cellExistsInSlice { break }

		layoutMap[formatCoord(0, y)] = nextRowStartCellID
		vLinksDrawn[formatVLinkCoord(0, y)] = true // Link from cell (0, y-1) to (0, y)

		LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, nextRowStartCellID, y, leftDim, -1)
		LayoutCellsHorizontal(s, layoutMap, hLinksDrawn, nextRowStartCellID, y, rightDim, 1)

		if nextRowStartCellID == cellID { break } // Cycled back
		currentRowCellID = nextRowStartCellID
	}

	return layoutMap, hLinksDrawn, vLinksDrawn
}

// LayoutHRaster generates a vertical ("H-raster") layout.
// Returns maps for cell layout, horizontal links, and vertical links.
func LayoutHRaster(s *data.Slice, cellID int, rightDim, downDim string) (map[string]int, map[string]bool, map[string]bool) {
	layoutMap := make(map[string]int)
	hLinksDrawn := make(map[string]bool)
	vLinksDrawn := make(map[string]bool)

	if _, cellExists := s.Cells[cellID]; !cellExists {
		// fmt.Printf("LayoutHRaster: Start cell %d does not exist\n", cellID)
		return layoutMap, hLinksDrawn, vLinksDrawn
	}

	layoutMap[formatCoord(0, 0)] = cellID
	leftDim := data.ReverseSign(rightDim)
	upDim := data.ReverseSign(downDim)

	// Layout the central column
	LayoutCellsVertical(s, layoutMap, vLinksDrawn, cellID, 0, upDim, -1)
	LayoutCellsVertical(s, layoutMap, vLinksDrawn, cellID, 0, downDim, 1)

	// Layout columns to the left
	currentColStartCellID := cellID
	for x := 1; ; x++ {
		if Hcells > 0 && x > (Hcells/2) { break }
		if Hcells <= 0 && x > 40 { break } // Default limit

		nextColStartCellID, exists := s.CellNbr(currentColStartCellID, leftDim)
		if !exists { break }
		if _, cellExistsInSlice := s.Cells[nextColStartCellID]; !cellExistsInSlice { break }

		layoutMap[formatCoord(-x, 0)] = nextColStartCellID
		hLinksDrawn[formatHLinkCoord(-x,0)] = true // Link from cell (-(x-1), 0) to (-x, 0)

		LayoutCellsVertical(s, layoutMap, vLinksDrawn, nextColStartCellID, -x, upDim, -1)
		LayoutCellsVertical(s, layoutMap, vLinksDrawn, nextColStartCellID, -x, downDim, 1)
		
		if nextColStartCellID == cellID { break } // Cycled back
		currentColStartCellID = nextColStartCellID
	}

	// Layout columns to the right
	currentColStartCellID = cellID
	for x := 1; ; x++ {
		if Hcells > 0 && x > (Hcells/2) { break }
		if Hcells <= 0 && x > 40 { break } // Default limit

		nextColStartCellID, exists := s.CellNbr(currentColStartCellID, rightDim)
		if !exists { break }
		if _, cellExistsInSlice := s.Cells[nextColStartCellID]; !cellExistsInSlice { break }

		layoutMap[formatCoord(x, 0)] = nextColStartCellID
		hLinksDrawn[formatHLinkCoord(x,0)] = true // Link from cell (x-1, 0) to (x, 0)

		LayoutCellsVertical(s, layoutMap, vLinksDrawn, nextColStartCellID, x, upDim, -1)
		LayoutCellsVertical(s, layoutMap, vLinksDrawn, nextColStartCellID, x, downDim, 1)

		if nextColStartCellID == cellID { break } // Cycled back
		currentColStartCellID = nextColStartCellID
	}
	return layoutMap, hLinksDrawn, vLinksDrawn
}
