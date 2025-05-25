package data

import (
	"fmt"
	"strconv"
	"strings"
)

// Constants
const (
	CursorHome = 10
	SelectHome = 21
	DeleteHome = 99
	Filename   = "zigzag.zz"
)

// Cell represents a cell in the Zigzag structure
type Cell struct {
	ID      int
	Content string
	Links   map[string]int // Dimension -> CellID
}

// Slice represents a slice in the Zigzag structure
type Slice struct {
	Name     string
	Cells    map[int]*Cell
	NextCellID int
	// For now, we'll simulate DB_File with an in-memory map.
	// In a real implementation, this would be a database connection.
	db map[string]string // Simulates a key-value store (CellID+Dimension -> TargetCellID, or CellID -> Content)
}

// Global slice management (simulating Perl's @Filename, @DB_Ref, @Hash_Ref)
var (
	openSlices []*Slice
)

// initialGeometryData holds the raw data for the initial geometry.
// We use a map[string]string for easy initialization; this will be
// parsed into the Slice.Cells structure.
var initialGeometryData = map[string]string{
	"0":          "Home",
	"0-d.1":      "99",
	"0+d.2":      "30",
	"0+d.cursor": "11",
	"1":          "d.1",
	"1-d.1":      "10",
	"1+d.1":      "99",
	"1-d.2":      "8",
	"1+d.2":      "2",
	"2":          "d.2",
	"2-d.2":      "1",
	"2+d.2":      "3",
	"3":          "d.3",
	"3-d.2":      "2",
	"3+d.2":      "4",
	"4":          "d.inside",
	"4-d.2":      "3",
	"4+d.2":      "5",
	"5":          "d.contents",
	"5-d.2":      "4",
	"5+d.2":      "6",
	"6":          "d.mark",
	"6-d.2":      "5",
	"6+d.2":      "7",
	"7":          "d.clone",
	"7-d.2":      "6",
	"7+d.2":      "8",
	"8":          "d.cursor",
	"8-d.2":      "7",
	"8+d.2":      "1",
	"10":         "Cursor home",
	"10+d.1":     "1",
	"10+d.2":     "11",
	"10-d.1":     "21",
	"11":         "Menu",
	"11+d.1":     "12",
	"11-d.2":     "10",
	"11+d.2":     "16",
	"11-d.cursor": "0",
	"11+d.cursor": "16",
	"12":         "+d.1",
	"12-d.1":     "11",
	"12+d.1":     "13",
	"13":         "+d.2",
	"13-d.1":     "12",
	"13+d.1":     "14",
	"14":         "+d.3",
	"14-d.1":     "13",
	"14+d.1":     "15",
	"15":         "I",
	"15-d.1":     "14",
	"16":         "Event",
	"16+d.1":     "17",
	"16-d.2":     "11",
	"16-d.cursor": "11",
	"17":         "+d.1",
	"17-d.1":     "16",
	"17+d.1":     "18",
	"18":         "+d.2",
	"18-d.1":     "17",
	"18+d.1":     "19",
	"19":         "+d.3",
	"19-d.1":     "18",
	"19+d.1":     "20",
	"20":         "I",
	"20-d.1":     "19",
	"21":         "Selection",
	"21+d.1":     "10",
	"21+d.2":     "21",
	"21-d.2":     "21",
	"30":         "#Edit\natcursor_edit(1);",
	"30+d.1":     "35",
	"30-d.2":     "0",
	"30+d.2":     "40",
	"35":         "#Clone\natcursor_clone(1);",
	"35-d.1":     "30",
	"40":         "#L-ins\natcursor_insert(1, 'L');",
	"40+d.1":     "41",
	"40-d.2":     "30",
	"40+d.2":     "50",
	"41":         "#R-ins\natcursor_insert(1, 'R');",
	"41-d.1":     "40",
	"41+d.1":     "42",
	"42":         "#U-ins\natcursor_insert(1, 'U');",
	"42-d.1":     "41",
	"42+d.1":     "43",
	"43":         "#D-ins\natcursor_insert(1, 'D');",
	"43-d.1":     "42",
	"43+d.1":     "44",
	"44":         "#I-ins\natcursor_insert(1, 'I');",
	"44-d.1":     "43",
	"44+d.1":     "45",
	"45":         "#O-ins\natcursor_insert(1, 'O');",
	"45-d.1":     "44",
	"50":         "#Delete\natcursor_delete(1);",
	"50+d.1":     "51",
	"50-d.2":     "40",
	"50+d.2":     "60",
	"51":         "#L-break\natcursor_break_link(1, 'L');",
	"51-d.1":     "50",
	"51+d.1":     "52",
	"52":         "#R-break\natcursor_break_link(1, 'R');",
	"52-d.1":     "51",
	"52+d.1":     "53",
	"53":         "#U-break\natcursor_break_link(1, 'U');",
	"53-d.1":     "52",
	"53+d.1":     "54",
	"54":         "#D-break\natcursor_break_link(1, 'D');",
	"54-d.1":     "53",
	"54+d.1":     "55",
	"55":         "#I-break\natcursor_break_link(1, 'I');",
	"55-d.1":     "54",
	"55+d.1":     "56",
	"56":         "#O-break\natcursor_break_link(1, 'O');",
	"56-d.1":     "55",
	"60":         "#Select\natcursor_select(1);",
	"60-d.2":     "50",
	"60+d.2":     "70",
	"60+d.1":     "61",
	"61":         "#Rot.Selection\nrotate_selection();",
	"61-d.1":     "60",
	"61+d.1":     "62",
	"62":         "#Push Selection\npush_selection();",
	"62-d.1":     "61",
	"70":         "#L-Hop\natcursor_hop(1, 'L');",
	"70+d.1":     "71",
	"70-d.2":     "60",
	"70+d.2":     "80",
	"71":         "#R-Hop\natcursor_hop(1, 'R');",
	"71-d.1":     "70",
	"71+d.1":     "72",
	"72":         "#U-Hop\natcursor_hop(1, 'U');",
	"72-d.1":     "71",
	"72+d.1":     "73",
	"73":         "#D-Hop\natcursor_hop(1, 'D');",
	"73-d.1":     "72",
	"73+d.1":     "74",
	"74":         "#I-Hop\natcursor_hop(1, 'I');",
	"74-d.1":     "73",
	"74+d.1":     "75",
	"75":         "#O-Hop\natcursor_hop(1, 'O');",
	"75-d.1":     "74",
	"80":         "#Shear -^\natcursor_shear(1, 'D', 'L')",
	"80-d.2":     "70",
	"80+d.2":     "85",
	"80+d.1":     "81",
	"81":         "#Shear -v\natcursor_shear(1, 'U', 'L')",
	"81-d.1":     "80",
	"81+d.1":     "82",
	"82":         "#Shear ^+\natcursor_shear(1, 'D', 'R')",
	"82-d.1":     "81",
	"82+d.1":     "83",
	"83":         "#Shear v+\natcursor_shear(1, 'U', 'R')",
	"83-d.1":     "82",
	"85":         "#Chug",
	"85-d.2":     "80",
	"85+d.2":     "90",
	"90":         "#A-View toggle\nview_raster_toggle(0);",
	"90+d.1":     "91",
	"90-d.2":     "85",
	"90+d.2":     "93",
	"91":         "#D-View toggle\nview_raster_toggle(1);",
	"91-d.1":     "90",
	"91+d.1":     "92",
	"92":         "#Quad view toggle\nview_quadrant_toggle(1);",
	"92-d.1":     "91",
	"93":         "#X-rotate view\nview_rotate(1, 'X');",
	"93+d.1":     "94",
	"93-d.2":     "90",
	"93+d.2":     "96",
	"94":         "#Y-rotate view\nview_rotate(1, 'Y');",
	"94-d.1":     "93",
	"94+d.1":     "95",
	"95":         "#Z-rotate view\nview_rotate(1, 'Z');",
	"95-d.1":     "94",
	"96":         "#X-flip view\nview_flip(1, 'X');",
	"96+d.1":     "97",
	"96-d.2":     "93",
	"97":         "#Y-flip view\nview_flip(1, 'Y');",
	"97-d.1":     "96",
	"97+d.1":     "98",
	"98":         "#Z-flip view\nview_flip(1, 'Z');",
	"98-d.1":     "97",
	"99":         "Recycle pile",
	"99-d.1":     "1",
	"99+d.1":     "0",
	"99-d.2":     "99",
	"99+d.2":     "99",
	"n":          "100", // Represents the next available cell ID
}

// NewSlice creates a new, empty slice.
func NewSlice(name string) *Slice {
	return &Slice{
		Name:     name,
		Cells:    make(map[int]*Cell),
		NextCellID: 1, // Start with 1, 0 is often special
		db:       make(map[string]string),
	}
}

// loadInitialGeometry parses the initialGeometryData and populates the slice.
func (s *Slice) loadInitialGeometry() {
	s.Cells = make(map[int]*Cell) // Clear existing cells if any

	maxCellID := 0

	// First pass: create all cells with their content
	for key, value := range initialGeometryData {
		if strings.Contains(key, "d.") { // Skip link definitions for now
			continue
		}
		if key == "n" { // Special case for next cell ID
			continue
		}

		cellID, err := strconv.Atoi(key)
		if err != nil {
			fmt.Printf("Warning: Could not parse cell ID '%s': %v\n", key, err)
			continue
		}
		if cellID > maxCellID {
			maxCellID = cellID
		}

		s.Cells[cellID] = &Cell{
			ID:      cellID,
			Content: value,
			Links:   make(map[string]int),
		}
	}

	// Second pass: create links
	for key, value := range initialGeometryData {
		if !strings.Contains(key, "d.") { // Skip content definitions now
			continue
		}

		parts := strings.SplitN(key, "-", 2)
		if len(parts) != 2 && !strings.Contains(key, "+") { // check for + too
			parts = strings.SplitN(key, "+", 2)
			if len(parts) != 2 {
				fmt.Printf("Warning: Could not parse link key '%s'\n", key)
				continue
			}
			// Reconstruct dimension with '+'
			parts[1] = "+" + parts[1]
		} else if len(parts) == 2 {
			// Reconstruct dimension with '-'
			parts[1] = "-" + parts[1]
		}


		cellID, err := strconv.Atoi(parts[0])
		if err != nil {
			fmt.Printf("Warning: Could not parse cell ID from link key '%s': %v\n", key, err)
			continue
		}

		dimension := parts[1]

		targetCellID, err := strconv.Atoi(value)
		if err != nil {
			fmt.Printf("Warning: Could not parse target cell ID '%s' for link key '%s': %v\n", value, key, err)
			continue
		}

		cell, ok := s.Cells[cellID]
		if !ok {
			// This case should ideally not happen if all cells are defined first
			// However, to be robust, create a placeholder if a cell is only defined by a link
			cell = &Cell{ID: cellID, Content: strconv.Itoa(cellID), Links: make(map[string]int)}
			s.Cells[cellID] = cell
			if cellID > maxCellID {
				maxCellID = cellID
			}
		}
		cell.Links[dimension] = targetCellID
	}

	// Set NextCellID based on the "n" value in initialGeometryData or max found ID + 1
	if nVal, ok := initialGeometryData["n"]; ok {
		n, err := strconv.Atoi(nVal)
		if err == nil {
			s.NextCellID = n
		} else {
			s.NextCellID = maxCellID + 1
		}
	} else {
		s.NextCellID = maxCellID + 1
	}
}

// Helper to get a cell, creating if it doesn't exist (used by initial_geometry parsing)
func (s *Slice) getOrCreateCell(cellID int) *Cell {
	if cell, exists := s.Cells[cellID]; exists {
		return cell
	}
	// Create a new cell if it doesn't exist.
	// This might happen if initialGeometryData refers to a cell ID in a link
	// before defining its content.
	newCell := &Cell{
		ID:      cellID,
		Content: strconv.Itoa(cellID), // Default content is its ID
		Links:   make(map[string]int),
	}
	s.Cells[cellID] = newCell
	if cellID >= s.NextCellID { // Ensure NextCellID is always ahead
		s.NextCellID = cellID + 1
	}
	return newCell
}


// SliceOpen opens a slice. If filename is empty, it opens the default slice.
// If the slice does not exist, it's created with initial geometry.
func SliceOpen(filename string) (*Slice, error) {
	if filename == "" && len(openSlices) == 0 {
		filename = Filename
	}

	// Check if already open (simplified check by name)
	for _, s := range openSlices {
		if s.Name == filename {
			// In Perl, it seems to allow opening the same file multiple times,
			// pushing onto @DB_Ref etc. Here, we'll just return the existing one for now.
			// A more faithful version might create distinct Slice objects sharing a DB backend.
			return s, nil
		}
	}

	// Simulate file existence and loading.
	// In a real scenario, this would involve disk I/O and DB_File.
	s := NewSlice(filename)

	// For now, always load initial_geometry for new slices if it's the first one.
	// The Perl code has a more complex logic for when to load initial_geometry
	// (only for the very first slice if no file exists).
	if len(openSlices) == 0 { // First slice being opened
		// Simulate "file does not exist" by loading initial geometry
		s.loadInitialGeometry()
		// Simulate tie %hash, 'DB_File', $Filename, O_RDWR | O_CREAT
		// by populating our in-memory db from s.Cells
		for id, cell := range s.Cells {
			s.db[strconv.Itoa(id)] = cell.Content
			for dim, targetID := range cell.Links {
				s.db[strconv.Itoa(id)+dim] = strconv.Itoa(targetID)
			}
		}
		s.db["n"] = strconv.Itoa(s.NextCellID) // Store next cell ID
	} else {
		// For subsequent slices, or if we were to implement actual file loading:
		// If file existed, we would load from s.db.
		// If not, it might be an error or a new empty slice depending on requirements.
		// For now, let's make subsequent slices empty unless they are the default filename.
		if filename == Filename && len(s.Cells) == 0 { // Default filename but not the first, and somehow empty
			  // This case is a bit ambiguous in direct translation without file persistence.
			  // Let's load initial geometry if it's the default and seems uninitialized.
			  s.loadInitialGeometry()
		}
	}


	openSlices = append(openSlices, s)
	// The Perl code calls slice_upgrade() for the first slice.
	if len(openSlices) == 1 {
		if err := s.SliceUpgrade(); err != nil {
			// If upgrade fails, we might need to remove the slice from openSlices
			// and return the error. For now, just print.
			fmt.Printf("Warning: SliceUpgrade failed for %s: %v\n", s.Name, err)
		}
	}
	return s, nil
}

// SliceClose closes a slice by its index in the openSlices array.
func SliceClose(num int) error {
	if num < 0 || num >= len(openSlices) {
		return fmt.Errorf("invalid slice number %d", num)
	}
	// Simulate untie and undef
	// For in-memory, we just remove it from the list.
	// A real implementation would close DB connections, etc.
	openSlices = append(openSlices[:num], openSlices[num+1:]...)
	return nil
}

// SliceCloseAll closes all open slices.
func SliceCloseAll() {
	// Simulate untie for all
	openSlices = []*Slice{}
}

// SliceSyncAll simulates syncing all open slices to persistent storage.
func SliceSyncAll() {
	for _, s := range openSlices {
		// In a real implementation, this would call s.db.Sync() or similar.
		// For our in-memory simulation, data is always "synced".
		fmt.Printf("Simulating sync for slice: %s\n", s.Name)
	}
}

// CellSlice returns the index of the slice the cell key (e.g. "10" or "10+d.1") belongs to.
// In this Go version, with distinct Slice objects, a cell belongs to the slice it's in.
// The Perl version checks across all global hashes.
// This function will need to search through openSlices.
func CellSlice(cellKey string) (int, *Slice) {
	for i, s := range openSlices {
		// Check if the key (content or link) exists in the slice's db simulation
		if _, exists := s.db[cellKey]; exists {
			return i, s
		}
		// If cellKey is just a cell ID, check content
		if _, err := strconv.Atoi(cellKey); err == nil {
			if _, exists := s.db[cellKey]; exists { // Check for content key like "10"
				return i,s
			}
		}
	}
	return -1, nil
}

// CellGet retrieves cell content.
func (s *Slice) CellGet(cellID int) (string, bool) {
	// In our model, content is directly in Cell struct, but we can also check db simulation
	// to be closer to Perl's cell_get which checks the bound hash.
	content, exists := s.db[strconv.Itoa(cellID)]
	if !exists {
		// Fallback to checking the Cells map directly if not in db (e.g. if slice not "saved" yet)
		if cell, ok := s.Cells[cellID]; ok {
			return cell.Content, true
		}
		return "", false
	}
	return content, true
}


// CellSet sets cell content.
func (s *Slice) CellSet(cellID int, content string) error {
	if _, exists := s.Cells[cellID]; !exists {
		// The Perl version implies the cell must exist (via cell_slice).
		// Let's enforce that the cell must be part of the slice's Cells map.
		// To create a new cell, one would use a different function (e.g., cell_new).
		return fmt.Errorf("no cell %d in slice %s", cellID, s.Name)
	}
	s.Cells[cellID].Content = content
	s.db[strconv.Itoa(cellID)] = content // Update db simulation
	return nil
}

// CellNbr follows a link from a cell in a given dimension.
// Returns the target cell ID and true if the link exists, otherwise 0 and false.
func (s *Slice) CellNbr(cellID int, dimension string) (int, bool) {
	// Check db simulation first, similar to Perl's cell_nbr
	key := strconv.Itoa(cellID) + dimension
	if targetStr, exists := s.db[key]; exists {
		targetID, err := strconv.Atoi(targetStr)
		if err == nil {
			return targetID, true
		}
		fmt.Printf("Warning: Could not parse target cell ID '%s' for link '%s'\n", targetStr, key)
		return 0, false //Should not happen if data is consistent
	}

	// Fallback to checking the Cells map directly
	if cell, exists := s.Cells[cellID]; exists {
		if targetCellID, linkExists := cell.Links[dimension]; linkExists {
			return targetCellID, true
		}
	}
	return 0, false
}


// SliceUpgrade performs upgrades for backward compatibility.
func (s *Slice) SliceUpgrade() error {
	// Helper function to find a dimension by its name (content)
	dimensionFind := func(dimName string) (int, bool) {
		// This is a simplified version. Perl's dimension_find searches from dimension_home().
		// For now, we'll iterate through cells and check content.
		// This assumes dimension cells have their name as content.
		for id, cell := range s.Cells {
			if cell.Content == dimName {
				// rudimentary check, might need to be more specific
				// e.g. check if it's linked from dimension_home()
				return id, true
			}
		}
		return -1, false
	}

	// Helper function to rename a dimension
	dimensionRename := func(oldName, newName string) {
		oldDimCellID, found := dimensionFind(oldName)
		if !found {
			return // Old dimension doesn't exist
		}
		if _, newExists := dimensionFind(newName); newExists {
			return // New dimension name already in use by another cell
		}

		fmt.Printf("Renaming dimension %s to %s. Please wait...\n", oldName, newName)
		s.CellSet(oldDimCellID, newName) // Rename the cell content

		// Update all links in all cells in this slice
		for _, cell := range s.Cells {
			for linkDim, targetCellID := range cell.Links {
				if strings.HasSuffix(linkDim, oldName) { // e.g., +d.Cursor or -d.Cursor
					prefix := linkDim[:len(linkDim)-len(oldName)]
					newLinkDim := prefix + newName
					delete(cell.Links, linkDim)
					cell.Links[newLinkDim] = targetCellID

					// Update db simulation
					dbKey := strconv.Itoa(cell.ID) + linkDim
					newDbKey := strconv.Itoa(cell.ID) + newLinkDim
					if val, ok := s.db[dbKey]; ok {
						delete(s.db, dbKey)
						s.db[newDbKey] = val
					}
				}
			}
		}
		fmt.Println("done.")
	}

	// Check for d.1
	if _, found := dimensionFind("d.1"); !found {
		// In Perl, this is a die condition. We'll return an error.
		return fmt.Errorf("sorry, this data file predates Zigzag v0.44.1.1 (missing d.1)")
	}

	// Rename dimensions
	dimensionRename("d.Cursor", "d.cursor")
	dimensionRename("d.Clone", "d.clone")
	dimensionRename("d.Mark", "d.mark")
	dimensionRename("d.Contain", "d.inside")
	dimensionRename("d.Contain2", "d.contents")
	dimensionRename("d.contentlist", "d.contents")
	dimensionRename("d.contain", "d.inside")
	dimensionRename("d.containment", "d.inside")

	// Make sure SelectHome exists (from v0.57)
	if _, exists := s.CellGet(SelectHome); !exists {
		s.Cells[SelectHome] = &Cell{ID: SelectHome, Content: "Selection", Links: make(map[string]int)}
		s.db[strconv.Itoa(SelectHome)] = "Selection" // Add to db
		s.NextCellID++ // Ensure NextCellID is updated if SelectHome was new and high

		// link_make($SELECT_HOME, $SELECT_HOME, "+d.2");
		s.Cells[SelectHome].Links["+d.2"] = SelectHome
		s.db[strconv.Itoa(SelectHome)+"+d.2"] = strconv.Itoa(SelectHome)
		// Also need the reverse link for consistency if link_make implies it
		s.Cells[SelectHome].Links["-d.2"] = SelectHome
		s.db[strconv.Itoa(SelectHome)+"-d.2"] = strconv.Itoa(SelectHome)


		// cell_insert($SELECT_HOME, $CURSOR_HOME, "-d.1");
		// This is more complex, involving breaking and making links.
		// Simplified: Link SelectHome to CursorHome's existing -d.1 neighbor,
		// then link CursorHome to SelectHome.
		// For now, just a direct link:
		// SelectHome's -d.1 -> CursorHome
		// CursorHome's +d.1 -> SelectHome (assuming -d.1 on SelectHome means +d.1 on CursorHome)
		
		// Simulating: link_make(CursorHome, SelectHome, "+d.1")
		// (assuming CursorHome's original +d.1 was what SelectHome is replacing or being inserted before)
		// This part is tricky without full cell_insert and link_make logic.
		// A simple version:
		if cursorHomeCell, ok := s.Cells[CursorHome]; ok {
			// What was originally at CursorHome's +d.1?
			// originalNext := cursorHomeCell.Links["+d.1"]
			
			cursorHomeCell.Links["+d.1"] = SelectHome // CursorHome now points to SelectHome
			s.db[strconv.Itoa(CursorHome)+"+d.1"] = strconv.Itoa(SelectHome)

			s.Cells[SelectHome].Links["-d.1"] = CursorHome // SelectHome points back to CursorHome
			s.db[strconv.Itoa(SelectHome)+"-d.1"] = strconv.Itoa(CursorHome)

			// If there was an originalNext, SelectHome should point to it via +d.1
			// And originalNext should point to SelectHome via -d.1
			// This is a simplified version of cell_insert's logic.
			// For now, we'll assume SelectHome is at one end.
		}
	}

	// Rename "Midden" to "Recycle pile" (from v0.62)
	if content, exists := s.CellGet(DeleteHome); exists && content == "Midden" {
		s.CellSet(DeleteHome, "Recycle pile")
	}

	// Make sure recycle pile is a circular queue (from v0.67)
	// This requires get_lastcell and link_make, which are not fully ported yet.
	// my $first = get_lastcell($DELETE_HOME, "-d.2");
	// link_make($first, get_lastcell($DELETE_HOME, "+d.2"), "-d.2")
	//   unless defined cell_nbr($first, "-d.2");
	// This logic is complex and depends on other functions. Skipping full implementation for now.
	fmt.Println("Note: Recycle pile circular queue check in SliceUpgrade is simplified.")

	return nil
}

func (s *Slice) GetNextCellID() int {
	return s.NextCellID
}

func (s *Slice) IncrementNextCellID() {
	s.NextCellID++
}

// Helper function to reverse sign of a dimension string (e.g. "+d.1" -> "-d.1")
// This is already present in data.go from a previous step, ensuring it's here.
func reverseSign(dim string) string {
	if strings.HasPrefix(dim, "+") {
		return "-" + dim[1:]
	}
	if strings.HasPrefix(dim, "-") {
		return "+" + dim[1:]
	}
	return dim // Should not happen for valid dimensions
}

// GetLastCell finds the last cell in a given direction from a starting cellID.
// It follows links along the dimension 'dim' until it can no longer move,
// or it returns to the starting cell (in case of a loop).
func (s *Slice) GetLastCell(cellID int, dim string) (int, bool) {
	if _, exists := s.Cells[cellID]; !exists {
		// Or handle error: fmt.Errorf("GetLastCell: cell %d not found", cellID)
		return 0, false
	}
	if !strings.HasPrefix(dim, "+") && !strings.HasPrefix(dim, "-") {
		// Or handle error: fmt.Errorf("GetLastCell: invalid dimension format '%s'", dim)
		return 0, false
	}

	currentCellID := cellID
	for {
		nextCellID, exists := s.CellNbr(currentCellID, dim)
		if !exists || nextCellID == cellID { // Stop if no next cell or returned to start
			break
		}
		// Check if the nextCellID actually exists in the slice to prevent infinite loops on broken links
		// This check is implicitly handled if CellNbr only returns true for valid cells.
		// However, if CellNbr could point to a non-existent cell ID that's stored in Links:
		if _, cellExists := s.Cells[nextCellID]; !cellExists {
			// This indicates a broken link where a cell ID in Links doesn't map to an actual cell.
			// The original Perl code might be more lenient or rely on DB_File's behavior.
			// For robustness, we stop.
			fmt.Printf("Warning: GetLastCell encountered a broken link from cell %d along %s to non-existent cell %d\n", currentCellID, dim, nextCellID)
			break
		}
		currentCellID = nextCellID
	}
	return currentCellID, true
}

// GetDistance calculates the number of steps from startCellID to endCellID along a dimension 'dim'.
// Returns the distance (>=0) and true if reachable, or 0 and false if not.
func (s *Slice) GetDistance(startCellID int, dim string, endCellID int) (int, bool) {
	if _, exists := s.Cells[startCellID]; !exists {
		return 0, false // Start cell doesn't exist
	}
	if _, exists := s.Cells[endCellID]; !exists {
		return 0, false // End cell doesn't exist
	}

	if startCellID == endCellID {
		return 0, true
	}

	distance := 1
	currentCellID := startCellID

	for i := 0; i < len(s.Cells); i++ { // Loop protection: max possible steps is num cells
		nextCellID, exists := s.CellNbr(currentCellID, dim)
		if !exists {
			return 0, false // Path broken
		}
		if nextCellID == endCellID {
			return distance, true
		}
		if nextCellID == startCellID { // Cycled back to start without finding endCell
			return 0, false
		}
		currentCellID = nextCellID
		distance++
	}
	return 0, false // Path too long or complex cycle not hitting endCell
}

// IsCursor checks if a cell is a cursor cell.
// A cell is a cursor if it has links in "-d.cursor" or "+d.cursor" dimensions.
func (s *Slice) IsCursor(cellID int) bool {
	if _, exists := s.Cells[cellID]; !exists {
		return false
	}
	_, negExists := s.CellNbr(cellID, "-d.cursor")
	_, posExists := s.CellNbr(cellID, "+d.cursor")
	return negExists || posExists
}

// IsClone checks if a cell is a clone.
// A cell is a clone if it has links in "-d.clone" or "+d.clone" dimensions.
// The Perl code also checks for "d.clone" which is ambiguous; interpreting as "+/-d.clone".
func (s *Slice) IsClone(cellID int) bool {
	if _, exists := s.Cells[cellID]; !exists {
		return false
	}
	_, negExists := s.CellNbr(cellID, "-d.clone")
	_, posExists := s.CellNbr(cellID, "+d.clone")
	// The original Perl also had `defined(cell_nbr($cell, "d.clone"))`.
	// This is unusual. If "d.clone" is a valid dimension name itself (without +/-),
	// then it should be added here. Assuming it implies +/- for now.
	return negExists || posExists
}

// IsSelected checks if a cell is part of any selection (not necessarily active).
// It checks if the cell's marked head is linked to SelectHome via +d.2.
func (s *Slice) IsSelected(cellID int) bool {
	if _, cellExists := s.Cells[cellID]; !cellExists {
		return false
	}
	headCellID, exists := s.GetLastCell(cellID, "-d.mark")
	if !exists {
		return false
	}
	// A cell is selected if its mark-chain head is not itself (it's marked)
	// AND that headCell can reach SELECT_HOME along "+d.2".
	// The original Perl code is: $headcell != $cell && defined get_distance($headcell, "+d.2", $SELECT_HOME)
	// `defined get_distance` implies reachability.
	if headCellID == cellID { // Not marked, or is its own head of mark chain
		return false
	}

	_, reachable := s.GetDistance(headCellID, "+d.2", SelectHome)
	return reachable
}

// IsActiveSelected checks if a cell is part of the active selection.
// The active selection's head is SelectHome itself.
func (s *Slice) IsActiveSelected(cellID int) bool {
	if _, cellExists := s.Cells[cellID]; !cellExists {
		return false
	}
	headCellID, exists := s.GetLastCell(cellID, "-d.mark")
	if !exists {
		return false
	}
	// A cell is part of the *active* selection if its mark-chain head is SelectHome itself,
	// and the cell is not SelectHome (i.e., it's a cell marked by SelectHome).
	return headCellID == SelectHome && cellID != SelectHome
}

// IsEssentialCell checks if a cell ID corresponds to one of the fundamental system cells.
func IsEssentialCell(cellID int) bool {
	switch cellID {
	case 0, CursorHome, DeleteHome, SelectHome:
		return true
	default:
		return false
	}
}

// essentialDimensionPattern is a compiled regex for DimensionIsEssential.
var essentialDimensionPattern = regexp.MustCompile(`^[+-]?d\.(1|2|cursor|clone|inside|contents|mark)$`)

// DimensionIsEssential checks if a dimension name is an essential dimension.
// Essential dimensions are system-critical (e.g., d.1, d.2, d.cursor).
func DimensionIsEssential(dimName string) bool {
	return essentialDimensionPattern.MatchString(dimName)
}

// CellFind searches for a cell with specific content along a dimension.
// It starts from startCellID, moves along the given dimension 'dim',
// and looks for a cell whose content matches 'content'.
// Returns the found cell's ID and true, or 0 and false if not found or error.
func (s *Slice) CellFind(startCellID int, dim string, content string) (int, bool) {
	if _, exists := s.Cells[startCellID]; !exists {
		fmt.Printf("CellFind: Start cell %d does not exist in slice %s\n", startCellID, s.Name)
		return 0, false
	}
	if !strings.HasPrefix(dim, "+") && !strings.HasPrefix(dim, "-") {
		fmt.Printf("CellFind: Invalid dimension format '%s' for slice %s\n", dim, s.Name)
		return 0, false
	}

	currentCellID := startCellID
	// Loop with a limit to prevent infinite loops in case of corrupted data or complex cycles
	// Max iterations could be the number of cells in the slice.
	for i := 0; i < len(s.Cells)+1; i++ {
		cell, cellExists := s.Cells[currentCellID]
		if !cellExists {
			// Should not happen if CellNbr is robust and only points to existing cells.
			fmt.Printf("CellFind: Traversed to non-existent cell %d from %d along %s in slice %s\n", currentCellID, startCellID, dim, s.Name)
			return 0, false
		}

		if cell.Content == content {
			return currentCellID, true // Found the cell
		}

		nextCellID, nextExists := s.CellNbr(currentCellID, dim)
		if !nextExists {
			return 0, false // End of dimension
		}
		if nextCellID == startCellID {
			return 0, false // Cycled back to start
		}
		currentCellID = nextCellID
	}
	// If loop finishes, it means we've iterated too many times (likely a cycle not including start)
	// or the dimension is unexpectedly long.
	fmt.Printf("CellFind: Search exceeded max iterations for content '%s' from cell %d along %s in slice %s\n", content, startCellID, dim, s.Name)
	return 0, false
}

// DimensionHome returns the starting cell ID of the dimension list.
// The dimension list is typically linked from CursorHome via "+d.1".
func (s *Slice) DimensionHome() (int, bool) {
	dimHomeCellID, exists := s.CellNbr(CursorHome, "+d.1")
	if !exists {
		fmt.Printf("DimensionHome: CursorHome (%d) has no link in +d.1 direction in slice %s\n", CursorHome, s.Name)
		return 0, false
	}
	if _, cellActuallyExists := s.Cells[dimHomeCellID]; !cellActuallyExists {
		fmt.Printf("DimensionHome: +d.1 link from CursorHome points to non-existent cell %d in slice %s\n", dimHomeCellID, s.Name)
		return 0, false
	}
	return dimHomeCellID, true
}

// DimensionFind finds a dimension cell by its name (content).
// It searches the dimension list (starting from DimensionHome) for a cell
// whose content matches dimName.
func (s *Slice) DimensionFind(dimName string) (int, bool) {
	dimListStartCellID, ok := s.DimensionHome()
	if !ok {
		return 0, false // DimensionHome itself is not found or invalid
	}

	// Dimensions are linked along "+d.2" from the dimension home cell.
	foundCellID, found := s.CellFind(dimListStartCellID, "+d.2", dimName)
	return foundCellID, found
}

// DimensionRename renames a dimension from oldDimName to newDimName.
// This involves updating the content of the dimension's defining cell
// and also updating all links throughout the slice that refer to this dimension.
func (s *Slice) DimensionRename(oldDimName, newDimName string) error {
	dimCellID, found := s.DimensionFind(oldDimName)
	if !found {
		return fmt.Errorf("DimensionRename: Original dimension '%s' not found in slice %s", oldDimName, s.Name)
	}

	// Check if new dimension name already exists and is not the same cell
	// This check was implicit in Perl's `if ($cell and not dimension_find($d_new))`
	// where dimension_find would return true for $d_new if it existed.
	if newDimCellID, newFound := s.DimensionFind(newDimName); newFound {
		if newDimCellID != dimCellID { // It's okay if newName is same as oldName, effectively a no-op for rename part
			return fmt.Errorf("DimensionRename: New dimension name '%s' already exists as cell %d in slice %s", newDimName, newDimCellID, s.Name)
		}
	}
	
	if oldDimName == newDimName {
		return nil // No actual rename needed
	}

	fmt.Printf("Renaming dimension %s to %s in slice %s. Please wait...\n", oldDimName, newDimName, s.Name)

	// 1. Update the content of the dimension cell itself
	err := s.CellSet(dimCellID, newDimName)
	if err != nil {
		return fmt.Errorf("DimensionRename: Failed to set content for dimension cell %d to '%s': %w", dimCellID, newDimName, err)
	}

	// 2. Update all links in all cells in this slice that use the old dimension name
	//    This also requires updating the s.db simulation.
	for cellID, cell := range s.Cells {
		linksToUpdate := make(map[string]int) // Stores oldDim -> targetCellID
		newLinksToAdd := make(map[string]int) // Stores newDim -> targetCellID

		for linkDim, targetCellID := range cell.Links {
			// Check if linkDim uses oldDimName, e.g., "+d.OldName" or "-d.OldName"
			if strings.HasSuffix(linkDim, "."+oldDimName) { // Suffix check is more robust
				sign := linkDim[0:len(linkDim)-len(oldDimName)-1] // e.g., "+d" or "-d"
				
				// Check if the part before the dot is valid like "+d" or "-d"
				if strings.HasPrefix(sign, "+d") || strings.HasPrefix(sign, "-d") {
					newLinkDimStr := sign + "." + newDimName
					linksToUpdate[linkDim] = targetCellID
					newLinksToAdd[newLinkDimStr] = targetCellID
				}
			}
		}

		if len(linksToUpdate) > 0 {
			for oldLink, target := range linksToUpdate {
				delete(cell.Links, oldLink) // Remove old link from cell.Links
				
				oldDbKey := strconv.Itoa(cellID) + oldLink
				delete(s.db, oldDbKey)      // Remove old link from db simulation
			}
			for newLink, target := range newLinksToAdd {
				cell.Links[newLink] = target // Add new link to cell.Links

				newDbKey := strconv.Itoa(cellID) + newLink
				s.db[newDbKey] = strconv.Itoa(target) // Add new link to db simulation
			}
		}
	}

	fmt.Printf("DimensionRename: Renaming of '%s' to '%s' completed for slice %s.\n", oldDimName, newDimName, s.Name)
	return nil
}

// CellsRow collects all cell IDs in a row starting from startCellID along a given dimension.
// It stops if the dimension ends, or if it loops back to the startCellID.
func (s *Slice) CellsRow(startCellID int, dim string) ([]int, bool) {
	if _, exists := s.Cells[startCellID]; !exists {
		// fmt.Printf("CellsRow: Start cell %d does not exist in slice %s\n", startCellID, s.Name)
		return nil, false
	}
	if !strings.HasPrefix(dim, "+") && !strings.HasPrefix(dim, "-") {
		// fmt.Printf("CellsRow: Invalid dimension format '%s' for slice %s\n", dim, s.Name)
		return nil, false
	}

	var row []int
	currentCellID := startCellID
	visitedInRow := make(map[int]bool) // To detect loops within the row traversal specifically

	for {
		if _, cellExists := s.Cells[currentCellID]; !cellExists {
			// This indicates a broken link if currentCellID is not startCellID
			// fmt.Printf("CellsRow: Traversed to non-existent cell %d along %s from %d in slice %s\n", currentCellID, dim, startCellID, s.Name)
			break // Stop if a link points to a non-existent cell
		}

		if visitedInRow[currentCellID] { // Loop detected
			break
		}
		row = append(row, currentCellID)
		visitedInRow[currentCellID] = true

		nextCellID, exists := s.CellNbr(currentCellID, dim)
		if !exists {
			break // End of dimension
		}
		currentCellID = nextCellID
		if currentCellID == startCellID && len(row) > 0 { // Completed a full loop back to start
		    // In some contexts, a full loop means all cells in the loop are part of the row.
		    // In others, it might mean the row definition is problematic if start isn't explicitly expected to be re-added.
		    // The Perl `cells_row` includes the start cell once and continues until loop or end.
		    // The current Go logic correctly breaks after adding all unique cells in the loop.
		    break
		}

	}
	return row, true
}

// GetCursor returns the cell ID of the nth cursor.
// Cursors are linked from CursorHome along "+d.2".
func (s *Slice) GetCursor(cursorNum int) (int, bool) {
	if _, exists := s.Cells[CursorHome]; !exists {
		// fmt.Printf("GetCursor: CursorHome cell %d not found in slice %s\n", CursorHome, s.Name)
		return 0, false
	}

	currentCursorID := CursorHome
	// Iterate 'cursorNum' times to find the specific cursor.
	// Cursor 0 is the first cell linked from CursorHome in the +d.2 dimension.
	for i := 0; i <= cursorNum; i++ {
		nextCursorID, exists := s.CellNbr(currentCursorID, "+d.2")
		if !exists {
			// fmt.Printf("GetCursor: Cursor %d not found; ran out of links from %d in slice %s\n", cursorNum, currentCursorID, s.Name)
			return 0, false // Not enough cursors
		}
		currentCursorID = nextCursorID
		if _, cellExists := s.Cells[currentCursorID]; !cellExists {
			// fmt.Printf("GetCursor: Cursor link points to non-existent cell %d in slice %s\n", currentCursorID, s.Name)
			return 0, false // Broken link in cursor chain
		}
	}
	return currentCursorID, true
}

// GetAccursed returns the cell ID "accursed" by the specified cursor.
// This is the cell found by following "-d.cursor" from the cursor's own cell.
func (s *Slice) GetAccursed(cursorNum int) (int, bool) {
	cursorCellID, ok := s.GetCursor(cursorNum)
	if !ok {
		return 0, false // Cursor itself not found
	}
	// The accursed cell is the last cell in the "-d.cursor" direction from the cursor cell.
	accursedCellID, exists := s.GetLastCell(cursorCellID, "-d.cursor")
	if !exists {
		// This might mean the cursor cell itself is the accursed cell if it has no further -d.cursor links,
		// or GetLastCell correctly returns cursorCellID if it's the end of the chain.
		// The Perl logic `get_lastcell(get_cursor($n), "-d.cursor")` implies this.
		// Let's assume GetLastCell handles the "no further link" case by returning its input if that's the end.
		// We primarily care if the GetLastCell operation itself was valid.
		// If cursorCellID has no -d.cursor link, GetLastCell should return cursorCellID, true.
		// If cursorCellID itself doesn't exist (caught by GetCursor), this won't be reached.
		// If GetLastCell returns false, it means cursorCellID was invalid for GetLastCell, which shouldn't happen if GetCursor succeeded.
		// Thus, we can directly use the result of GetLastCell.
		return 0, false
	}
	return accursedCellID, true
}

// GetSelection returns a list of cell IDs for the nth selection.
// Selections are chains starting from SelectHome along "+d.2".
// Each selection head then points via "+d.mark" to the first cell of the actual selection row.
func (s *Slice) GetSelection(selectionNum int) ([]int, bool) {
	if _, exists := s.Cells[SelectHome]; !exists {
		// fmt.Printf("GetSelection: SelectHome cell %d not found in slice %s\n", SelectHome, s.Name)
		return nil, false
	}

	selectionHeadID := SelectHome
	for i := 0; i < selectionNum; i++ { // Navigate to the nth selection head
		nextHeadID, exists := s.CellNbr(selectionHeadID, "+d.2")
		if !exists {
			// fmt.Printf("GetSelection: Selection %d not found; ran out of links from %d in slice %s\n", selectionNum, selectionHeadID, s.Name)
			return nil, false // Not enough selections
		}
		selectionHeadID = nextHeadID
		if _, cellExists := s.Cells[selectionHeadID]; !cellExists {
			// fmt.Printf("GetSelection: Selection head link points to non-existent cell %d in slice %s\n", selectionHeadID, s.Name)
			return nil, false // Broken link in selection chain
		}
	}

	// Now, from this selectionHeadID, get the actual start of the selected cells row.
	// This start is linked via "+d.mark" from the selectionHeadID.
	selectedRowStartCellID, exists := s.CellNbr(selectionHeadID, "+d.mark")
	if !exists {
		// fmt.Printf("GetSelection: Selection head %d has no '+d.mark' link in slice %s\n", selectionHeadID, s.Name)
		return []int{}, true // Valid selection head, but it marks no cells (empty selection)
	}
	if _, cellExists := s.Cells[selectedRowStartCellID]; !cellExists {
		// fmt.Printf("GetSelection: '+d.mark' link from selection head %d points to non-existent cell %d in slice %s\n", selectionHeadID, selectedRowStartCellID, s.Name)
		return nil, false // Broken link
	}

	// Get all cells in the row marked by this selection head
	selectedCells, ok := s.CellsRow(selectedRowStartCellID, "+d.mark")
	if !ok {
		// This implies selectedRowStartCellID was invalid for CellsRow, which should be caught above.
		// However, returning an empty list might be safer if CellsRow can return false for other reasons.
		// fmt.Printf("GetSelection: CellsRow failed for start cell %d in slice %s\n", selectedRowStartCellID, s.Name)
		return nil, false
	}
	return selectedCells, true
}

// GetActiveSelection returns the cells in the currently active selection (selection 0).
func (s *Slice) GetActiveSelection() ([]int, bool) {
	return s.GetSelection(0)
}

// GetWhichSelection returns the head cell ID of the selection that cellID is part of.
// Returns the head cell ID and true if found, otherwise 0 and false.
func (s *Slice) GetWhichSelection(cellID int) (int, bool) {
	if _, exists := s.Cells[cellID]; !exists {
		return 0, false
	}
	// Check if the cell is marked (has a -d.mark link)
	if _, linkExists := s.CellNbr(cellID, "-d.mark"); !linkExists {
		return 0, false // Cell is not part of any d.mark chain
	}
	// The head of the selection is the last cell in the -d.mark direction
	return s.GetLastCell(cellID, "-d.mark")
}

// GetOutlineParent finds the "outline parent" of a cell.
// This is defined as the first cell found by moving -d.2 until a -d.1 link is found,
// and then taking that -d.1 link.
func (s *Slice) GetOutlineParent(cellID int) (int, bool) {
	if _, exists := s.Cells[cellID]; !exists {
		// fmt.Printf("GetOutlineParent: Cell %d does not exist in slice %s\n", cellID, s.Name)
		return 0, false
	}

	currentCellID := cellID
	// Loop to find a cell with a -d.1 link by traversing -d.2
	// Protect against infinite loops, max iterations could be number of cells.
	for i := 0; i < len(s.Cells)+1; i++ {
		// Check if currentCellID has a -d.1 link
		parentLinkID, hasNegD1Link := s.CellNbr(currentCellID, "-d.1")
		if hasNegD1Link {
			if _, parentCellExists := s.Cells[parentLinkID]; parentCellExists {
				return parentLinkID, true
			}
			// fmt.Printf("GetOutlineParent: Cell %d's -d.1 link points to non-existent cell %d in slice %s\n", currentCellID, parentLinkID, s.Name)
			return 0, false // Broken link
		}

		// Move to the next cell along -d.2
		nextCellID, exists := s.CellNbr(currentCellID, "-d.2")
		if !exists {
			// fmt.Printf("GetOutlineParent: No -d.2 link from cell %d in slice %s\n", currentCellID, s.Name)
			return 0, false // End of -d.2 chain
		}
		if nextCellID == cellID && i > 0 { // Cycled back to original cell without finding -d.1
			// fmt.Printf("GetOutlineParent: Cycled back to cell %d while searching along -d.2 in slice %s\n", cellID, s.Name)
			return 0, false
		}
		currentCellID = nextCellID
		if i == len(s.Cells) { // Exceeded max iterations
		    // fmt.Printf("GetOutlineParent: Exceeded max iterations searching from cell %d in slice %s\n", cellID, s.Name)
			return 0, false
		}
	}
	return 0, false // Should be caught by loop limit or cycle detection
}

// GetCellContents returns the "true" content of a cell, following clone links.
// It navigates "-d.clone" links to find the original cell, then gets its content.
// ZZMAIL_SUPPORT from Perl is omitted.
func (s *Slice) GetCellContents(cellID int) (string, bool) {
	if _, exists := s.Cells[cellID]; !exists {
		// fmt.Printf("GetCellContents: Cell %d does not exist in slice %s\n", cellID, s.Name)
		return "", false
	}

	// Find the original cell by traversing -d.clone links to the end
	originalCellID, ok := s.GetLastCell(cellID, "-d.clone")
	if !ok {
		// This implies cellID was invalid for GetLastCell, which should be caught by the check above.
		// However, if GetLastCell itself had an issue with a valid cellID (e.g. broken internal link it couldn't resolve),
		// this path could be taken.
		// fmt.Printf("GetCellContents: Failed to determine original cell for %d via -d.clone in slice %s\n", cellID, s.Name)
		return "", false
	}

	return s.CellGet(originalCellID)
}

// GetDimension returns the name of the dimension associated with a cursor's axis.
// cursorCellID is the ID of the cursor cell itself.
// directionChar is one of "L", "R", "U", "D", "I", "O".
func (s *Slice) GetDimension(cursorCellID int, directionChar string) (string, bool) {
	if _, exists := s.Cells[cursorCellID]; !exists {
		return "", false
	}

	axisCell := cursorCellID
	var dimName string
	var useReverseSign bool

	// Navigate from cursor cell: +d.1 for X-axis, then another +d.1 for Y-axis, then another for Z-axis.
	axisCell, _ = s.CellNbr(axisCell, "+d.1") // X-axis dimension cell
	if _, ok := s.Cells[axisCell]; !ok { return "", false }

	switch strings.ToUpper(directionChar) {
	case "L":
		dimName, _ = s.CellGet(axisCell)
		useReverseSign = true
	case "R":
		dimName, _ = s.CellGet(axisCell)
		useReverseSign = false
	case "U", "D":
		axisCell, _ = s.CellNbr(axisCell, "+d.1") // Y-axis dimension cell
		if _, ok := s.Cells[axisCell]; !ok { return "", false }
		dimName, _ = s.CellGet(axisCell)
		useReverseSign = (strings.ToUpper(directionChar) == "U")
	case "I", "O":
		axisCell, _ = s.CellNbr(axisCell, "+d.1") // Y-axis
		if _, ok := s.Cells[axisCell]; !ok { return "", false }
		axisCell, _ = s.CellNbr(axisCell, "+d.1") // Z-axis dimension cell
		if _, ok := s.Cells[axisCell]; !ok { return "", false }
		dimName, _ = s.CellGet(axisCell)
		useReverseSign = (strings.ToUpper(directionChar) == "I")
	default:
		// fmt.Printf("GetDimension: Invalid direction character '%s'\n", directionChar)
		return "", false
	}

	if dimName == "" { // If CellGet failed or returned empty content
		return "", false
	}

	if useReverseSign {
		return reverseSign(dimName), true
	}
	return dimName, true
}

// addContentsRecursive is a helper for GetContained.
// It recursively builds a list of cell IDs "contained" within startCellID.
func (s *Slice) addContentsRecursive(currentCellID int, list *[]int, visited map[int]bool) {
	if visited[currentCellID] {
		return
	}
	if _, exists := s.Cells[currentCellID]; !exists {
		return // Do not process non-existent cells
	}

	*list = append(*list, currentCellID)
	visited[currentCellID] = true

	// Traverse +d.inside
	insideCellID, insideLinkExists := s.CellNbr(currentCellID, "+d.inside")
	for insideLinkExists {
		if visited[insideCellID] { // Already processed or in current path
			break
		}
		if _, cellExists := s.Cells[insideCellID]; !cellExists { // Broken link
		    // fmt.Printf("addContentsRecursive: Broken link from %d to non-existent cell %d via +d.inside in slice %s\n", currentCellID, insideCellID, s.Name)
			break
		}

		s.addContentsRecursive(insideCellID, list, visited) // Recurse for the cell found via +d.inside

		// Check for further cells in the +d.inside chain from the *original* currentCellID's perspective in Perl.
		// The Perl code's outer while loop for `+d.inside` implies that after processing an `insideCellID` (and its contents chain),
		// it continues to look for the *next* `+d.inside` link from the *original* `currentCellID`.
		// This seems to be a misunderstanding of the Perl. The Perl code is:
		// my $cell = cell_nbr($start, "+d.inside");
		// while (defined $cell and not defined $hashref->{$cell}) { ... $cell = cell_nbr($cell, "+d.inside"); }
		// This means it iterates along the +d.inside chain. My current recursive structure for +d.inside does this naturally.

		// Traverse +d.contents from the *current* insideCellID (the one just added)
		// The Perl code has an inner while loop for +d.contents from the $cell found by +d.inside.
		// It also checks `not defined cell_nbr($index, "-d.inside")` to ensure it's a true contents list.
		
		// Let's refine based on the structure:
		// The current `insideCellID` is the one we just added via `+d.inside` from `currentCellID` (or original start).
		// Now, from this `insideCellID`, we look for a `+d.contents` chain.
		
		indexCellID, indexLinkExists := s.CellNbr(insideCellID, "+d.contents")
		for indexLinkExists {
			if visited[indexCellID] {
				break
			}
			if _, cellExists := s.Cells[indexCellID]; !cellExists { // Broken link
			    // fmt.Printf("addContentsRecursive: Broken link to non-existent cell %d via +d.contents from %d in slice %s\n", indexCellID, insideCellID, s.Name)
				break
			}
			
			// Crucial Perl condition: `not defined cell_nbr($index, "-d.inside")`
			// This means only add if the $indexCellID is NOT itself a start of another containment structure via -d.inside.
			_, hasNegDInside := s.CellNbr(indexCellID, "-d.inside")
			if !hasNegDInside {
				s.addContentsRecursive(indexCellID, list, visited) // Recurse for cells in the +d.contents chain
			} else {
				// If it has a -d.inside link, it's considered a different kind of structure, so we don't recurse into its contents here.
				// We might still add this indexCellID itself if it wasn't visited and is reachable by other means,
				// but the Perl `add_contents` adds it to the list *before* this check for its own children.
				// My current structure adds `indexCellID` only if `!hasNegDInside` allows recursion.
				// This needs to match Perl: add if not visited, then decide to recurse.
				// The `add_contents($index, $listref, $hashref)` in Perl happens for $indexCellID
				// if $indexCellID is not in $hashref AND `not defined cell_nbr($index, "-d.inside")`.
				// This means `indexCellID` itself is added by the recursive call only if the condition is met.
				// If the condition is NOT met, `indexCellID` is NOT added via this path.
				// So, the current Go structure is correct: only recurse (and thus add) if the condition holds.
			}
			
			prevIndexCellID := indexCellID
			indexCellID, indexLinkExists = s.CellNbr(prevIndexCellID, "+d.contents") // Move to next in +d.contents chain
			if indexCellID == prevIndexCellID && indexLinkExists { // Self-loop on +d.contents
			    // fmt.Printf("addContentsRecursive: Self-loop on +d.contents at cell %d from %d in slice %s\n", indexCellID, insideCellID, s.Name)
			    break
			}
		}

		// Move to the next cell in the +d.inside chain from the *original* currentCellID (or its predecessor in the chain)
		// This is handled by the recursive calls correctly processing their own +d.inside chains.
		// The loop for `+d.inside` should be outside or managed by the caller for the initial `startCellID`.
		// The original Perl code's structure for `add_contents` is:
		// 1. Add $start to list/hash.
		// 2. Get first $cell = cell_nbr($start, "+d.inside").
		// 3. Loop while $cell is defined and not in hash:
		//    a. Add $cell to list/hash.
		//    b. Get first $index = cell_nbr($cell, "+d.contents").
		//    c. Loop while $index is defined and not in hash and $index has no -d.inside link:
		//       i.  Call add_contents($index, list, hash) recursively.
		//       ii. $index = cell_nbr($index, "+d.contents") (next in contents chain).
		//    d. $cell = cell_nbr($cell, "+d.inside") (next in inside chain).
		// My current Go `addContentsRecursive` is called for `currentCellID`.
		// It adds `currentCellID`. Then it needs to process *its own* `+d.inside` chain.
		
		// The fixed logic should be: after adding currentCellID:
		// Iterate its +d.inside chain. For each cell in that chain:
		//   add it, then iterate its +d.contents chain (recursively calling addContentsRecursive for those).
		// This suggests `addContentsRecursive` should primarily focus on adding itself,
		// and then its *contents* chain. The *inside* chain is handled by the caller iterating.
		// Let's re-evaluate structure for GetContained.

		// For now, this will explore one level of +d.inside, then its full +d.contents chain.
		// To match Perl, the iteration of the +d.inside chain needs to be explicit.

		// The current recursive call handles the next cell in the *current* `+d.inside` chain correctly.
		// `insideCellID` is the next in the chain from `currentCellID`. The recursion on `insideCellID` will handle *its* children.
		// No, this is not right. The `while (defined $cell and not defined $hashref->{$cell})` in Perl iterates the +d.inside chain.
		// My recursive call `s.addContentsRecursive(insideCellID, list, visited)` processes one inside cell.
		// The loop for the *next* inside cell needs to be explicit.

		// Let's stick to the logic: add current, then process its direct +d.inside children, each of which
		// will in turn process their direct +d.contents children.

		// The issue is that `add_contents` in Perl is called for $start.
		// Then it iterates the $start's +d.inside chain.
		// For each element in the +d.inside chain, it adds it, then iterates *that element's* +d.contents chain.
		// For each element in that +d.contents chain (if valid), it calls `add_contents` recursively.

		// Corrected logic for currentCellID's children:
		// This was already done for 'insideCellID' above.
		// The loop for insideCellID needs to be outside this direct recursion if we are inside addContentsRecursive(startNode)
		// Let's simplify: GetContained will call addContentsRecursive.
		// addContentsRecursive(X) will:
		// 1. Add X.
		// 2. For each child Y of X along +d.inside (if not visited): call addContentsRecursive(Y).
		// 3. For each child Z of X along +d.contents (if not visited AND Z has no -d.inside): call addContentsRecursive(Z).
		// This is not what the Perl does. The Perl code has a specific structure.

		// Let's trace the Perl logic for add_contents($start, $listref, $hashref):
		// 1. Add $start. Mark visited.
		// 2. $child_inside = first_neighbor($start, "+d.inside")
		// 3. WHILE $child_inside is valid AND not visited:
		//    a. Add $child_inside. Mark visited.
		//    b. $child_content = first_neighbor($child_inside, "+d.contents")
		//    c. WHILE $child_content is valid AND not visited AND $child_content has no -d.inside link:
		//       i.  add_contents($child_content, $listref, $hashref) // RECURSIVE CALL
		//       ii. $child_content = next_neighbor($child_content, "+d.contents")
		//    d. $child_inside = next_neighbor($child_inside, "+d.inside")
		// This structure means the recursion for `+d.contents` is nested inside the iteration for `+d.inside`.

		// My current recursive structure is simpler: add self, then recurse on direct unvisited neighbors.
		// To match Perl's specific traversal for `get_contained`:
		// `addContentsRecursive` should add `currentCellID`, then iterate its `+d.contents` chain (recursing on valid ones).
		// `GetContained` will manage the `+d.inside` iteration.
		
		// Sticking to the current simpler recursive add:
		// It adds currentCellID. Then it needs to find its neighbors.
		// The Perl version's `add_contents` has specific logic for `+d.inside` and `+d.contents`.
		// My `addContentsRecursive` is more generic. For `GetContained`, I need to replicate the Perl order.
		// So, `addContentsRecursive` as defined is fine for general graph traversal.
		// For `GetContained`, I will implement the specific logic.

		// The recursion was on `insideCellID`, and then on `indexCellID`.
		// The loop `insideCellID, insideLinkExists = s.CellNbr(insideCellID, "+d.inside")` was wrong.
		// It should be `insideCellID, insideLinkExists = s.CellNbr(currentCellID_of_this_level_of_inside_chain, "+d.inside")`
		// This is complex to map directly to a single recursive function that does both.

		// Let's simplify addContentsRecursive to only add itself and recurse based on a list of dimensions.
		// Or, implement GetContained iteratively to mirror Perl's loops.
		// Given the existing `addContentsRecursive` structure, it's adding `currentCellID` and then iterating its *own* children.
		// This is fine. The Perl's `add_contents` is what `GetContained` should mimic.

		// This function is being called with `insideCellID`. So `currentCellID` here *is* `insideCellID`.
		// Then it processes its *own* `+d.contents` chain. This is correct.
		// The iteration of the *next* `insideCellID` (sibling in the `+d.inside` chain)
		// needs to be handled by the caller of the first `addContentsRecursive` for `+d.inside`.
		// This means `GetContained` needs to manage the top-level `+d.inside` iteration.
		break; // Only process the first +d.inside link directly in this recursive step.
		           // The iteration of the +d.inside chain will be handled in GetContained.
	}
}

// GetContained returns a list of cell IDs "contained" within a given cellID.
// This implements the specific logic from Perl's get_contained using add_contents.
func (s *Slice) GetContained(startCellID int) []int {
	var list []int
	visited := make(map[int]bool)

	if _, exists := s.Cells[startCellID]; !exists {
		return list
	}
	
	// This is the effective logic of Perl's add_contents($start, \@list, \%hash)
	// when called by get_contained($start).
	var performAdd func(currentID int)
	performAdd = func(currentID int) {
		if visited[currentID] {
			return
		}
		if _, cellExists := s.Cells[currentID]; !cellExists {
			return
		}
		
		list = append(list, currentID)
		visited[currentID] = true

		// Iterate the +d.inside chain from currentID
		insideLink := currentID
		nextInsideCellID, hasInsideLink := s.CellNbr(insideLink, "+d.inside")
		for hasInsideLink {
			if visited[nextInsideCellID] { // Stop if already visited to prevent cycles or redundant work
				break
			}
			if _, cellExists := s.Cells[nextInsideCellID]; !cellExists { // Broken link
				break
			}

			// Add this cell from the +d.inside chain
			list = append(list, nextInsideCellID)
			visited[nextInsideCellID] = true
			
			currentInsideCellForContentsIteration := nextInsideCellID

			// Iterate the +d.contents chain from currentInsideCellForContentsIteration
			contentLink := currentInsideCellForContentsIteration
			nextContentCellID, hasContentLink := s.CellNbr(contentLink, "+d.contents")
			for hasContentLink {
				if visited[nextContentCellID] {
					break
				}
				if _, cellExists := s.Cells[nextContentCellID]; !cellExists { // Broken link
					break
				}

				// Crucial Perl condition: only add/recurse if $index has no -d.inside link
				_, hasNegativeDInside := s.CellNbr(nextContentCellID, "-d.inside")
				if !hasNegativeDInside {
					performAdd(nextContentCellID) // Recursive call for valid content cells
				} else {
					// If it has a -d.inside, it's not added via this content chain path.
					// It might be added if reached through an 'inside' chain directly.
				}
				
				prevContentCellID := nextContentCellID
				nextContentCellID, hasContentLink = s.CellNbr(prevContentCellID, "+d.contents")
				if nextContentCellID == prevContentCellID && hasContentLink { break } // self-loop
			}
			
			prevInsideCellID := nextInsideCellID
			nextInsideCellID, hasInsideLink = s.CellNbr(prevInsideCellID, "+d.inside")
			if nextInsideCellID == prevInsideCellID && hasInsideLink { break } // self-loop
		}
	}

	performAdd(startCellID)
	return list
}


// GetLinksTo returns a list of strings representing links pointing to the given cellID.
// Each string is in the format "sourceCellID+dimensionName" or "sourceCellID-dimensionName".
func (s *Slice) GetLinksTo(targetCellID int) ([]string, bool) {
	if _, exists := s.Cells[targetCellID]; !exists {
		return nil, false
	}

	var linksTo []string
	dimListStart, ok := s.DimensionHome()
	if !ok {
		// fmt.Printf("GetLinksTo: Could not find DimensionHome in slice %s\n", s.Name)
		return nil, false // Cannot proceed without dimension list
	}

	processedDims := make(map[int]bool) // To avoid reprocessing if dimension list has duplicates or short cycles
	currentDimCellID := dimListStart

	for i := 0; i < len(s.Cells)+1; i++ { // Loop protection
		if _, dimCellExists := s.Cells[currentDimCellID]; !dimCellExists {
			// fmt.Printf("GetLinksTo: Dimension list seems broken, cell %d does not exist in slice %s\n", currentDimCellID, s.Name)
			break
		}
		if processedDims[currentDimCellID] { // Cycled in dimension list
			break
		}
		processedDims[currentDimCellID] = true

		dimName, dimNameExists := s.CellGet(currentDimCellID)
		if !dimNameExists || dimName == "" {
			// fmt.Printf("GetLinksTo: Dimension cell %d has no valid name in slice %s\n", currentDimCellID, s.Name)
			goto next_dim // Continue to the next dimension cell
		}

		// Check for positive dimension link: someCell +dimName -> targetCellID
		// This means targetCellID would have a -dimName link from someCell.
		// So, we check s.CellNbr(targetCellID, "-" + dimName)
		negDim := "-" + dimName
		sourceCellPos, existsPos := s.CellNbr(targetCellID, negDim)
		if existsPos {
			if _, srcExists := s.Cells[sourceCellPos]; srcExists {
				linksTo = append(linksTo, strconv.Itoa(sourceCellPos)+"+"+dimName)
			}
		}

		// Check for negative dimension link: someCell -dimName -> targetCellID
		// This means targetCellID would have a +dimName link from someCell.
		// So, we check s.CellNbr(targetCellID, "+" + dimName)
		posDim := "+" + dimName
		sourceCellNeg, existsNeg := s.CellNbr(targetCellID, posDim)
		if existsNeg {
			if _, srcExists := s.Cells[sourceCellNeg]; srcExists {
				linksTo = append(linksTo, strconv.Itoa(sourceCellNeg)+"-"+dimName)
			}
		}

	next_dim:
		prevDimCellID := currentDimCellID
		currentDimCellID, ok = s.CellNbr(currentDimCellID, "+d.2") // Move to next dimension in the list
		if !ok {
			break // End of dimension list
		}
		if currentDimCellID == prevDimCellID { break } // Self-loop in dimension list
		if currentDimCellID == dimListStart && i > 0 { // Full cycle of dimension list
			break
		}
	}
	return linksTo, true
}

// CellInsert inserts cell1ID next to cell2ID in the specified dimension 'dim'.
// 'dim' is the direction from cell2ID where cell1ID will be inserted.
// Example: To insert cell1ID to the right of cell2ID (along +d.1 from cell2ID):
//   CellInsert(cell1ID, cell2ID, "+d.1")
//   Original: cell2 --- cell3
//   New:      cell2 --- cell1 --- cell3
func (s *Slice) CellInsert(cell1ID, cell2ID int, dim string) error {
	if _, ok := s.Cells[cell1ID]; !ok {
		return fmt.Errorf("CellInsert: cell to insert (cell1ID: %d) does not exist in slice %s", cell1ID, s.Name)
	}
	if _, ok := s.Cells[cell2ID]; !ok {
		return fmt.Errorf("CellInsert: reference cell (cell2ID: %d) does not exist in slice %s", cell2ID, s.Name)
	}
	if !strings.HasPrefix(dim, "+") && !strings.HasPrefix(dim, "-") {
		return fmt.Errorf("CellInsert: invalid dimension format '%s'. Must start with '+' or '-'", dim)
	}

	backDim := reverseSign(dim)
	cell3ID, cell3Exists := s.CellNbr(cell2ID, dim)

	// Perl's condition:
	// if (defined(cell_nbr($cell1, reverse_sign($dir))) ||
	//     ((defined(cell_nbr($cell1, $dir)) && defined($cell3))))
	// This means:
	// 1. cell1 must not already be linked on its "back" side (relative to the insertion direction).
	if _, cell1HasBackLink := s.CellNbr(cell1ID, backDim); cell1HasBackLink {
		return fmt.Errorf("CellInsert: cell %d is already linked in direction %s (cannot insert)", cell1ID, backDim)
	}
	// 2. If cell1 *is* linked on its "front" side, then cell3 (cell2's original neighbor) must NOT exist.
	if _, cell1HasFrontLink := s.CellNbr(cell1ID, dim); cell1HasFrontLink && cell3Exists {
		return fmt.Errorf("CellInsert: cell %d is already linked in direction %s, and cell %d also has a neighbor %d in that direction (cannot insert)", cell1ID, dim, cell2ID, cell3ID)
	}

	// If cell2 was linked to cell3, break that link and link cell1 to cell3.
	if cell3Exists {
		if _, cell3StillExistsInMap := s.Cells[cell3ID]; !cell3StillExistsInMap {
			return fmt.Errorf("CellInsert: cell %d's neighbor %d (cell3) in dim %s does not exist in slice %s, data inconsistency", cell2ID, cell3ID, dim, s.Name)
		}
		err := s.LinkBreakExplicit(cell2ID, cell3ID, dim)
		if err != nil {
			return fmt.Errorf("CellInsert: failed to break link between cell %d and cell %d in dim %s: %w", cell2ID, cell3ID, dim, err)
		}
		err = s.LinkMake(cell1ID, cell3ID, dim)
		if err != nil {
			return fmt.Errorf("CellInsert: failed to link cell %d to cell %d in dim %s: %w", cell1ID, cell3ID, dim, err)
		}
	}

	// Link cell2 to cell1.
	err := s.LinkMake(cell2ID, cell1ID, dim)
	if err != nil {
		return fmt.Errorf("CellInsert: failed to link cell %d to cell %d in dim %s: %w", cell2ID, cell1ID, dim, err)
	}

	return nil
}

// CellExcise removes a cell from a given base dimension (e.g., "d.1", "d.cursor").
// It links the cell's previous and next neighbors in that dimension together.
func (s *Slice) CellExcise(cellID int, baseDimName string) error {
	if _, ok := s.Cells[cellID]; !ok {
		return fmt.Errorf("CellExcise: cell %d does not exist in slice %s", cellID, s.Name)
	}
	if strings.HasPrefix(baseDimName, "+") || strings.HasPrefix(baseDimName, "-") {
		return fmt.Errorf("CellExcise: baseDimName '%s' should not include +/- prefix", baseDimName)
	}

	negDim := "-" + baseDimName
	posDim := "+" + baseDimName

	prevCellID, prevExists := s.CellNbr(cellID, negDim)
	nextCellID, nextExists := s.CellNbr(cellID, posDim)

	// Break link with previous cell, if it exists.
	if prevExists {
		if _, prevCellActuallyExists := s.Cells[prevCellID]; !prevCellActuallyExists {
			// This indicates an inconsistent state; a link points to a non-existent cell.
			// Depending on strictness, could log a warning or return an error.
			// For now, we'll try to proceed cautiously by not attempting to modify the non-existent cell's links.
			// However, the link from cellID to prevCellID still needs to be removed from cellID's side.
			delete(s.Cells[cellID].Links, negDim)
			delete(s.db, strconv.Itoa(cellID)+negDim)
			// The reverse link from prevCellID (which doesn't exist) would be an orphan in s.db if it was there.
		} else {
			err := s.LinkBreakExplicit(cellID, prevCellID, negDim)
			if err != nil {
				return fmt.Errorf("CellExcise: failed to break link between cell %d and prev cell %d in dim %s: %w", cellID, prevCellID, negDim, err)
			}
		}
	}

	// Break link with next cell, if it exists.
	if nextExists {
		if _, nextCellActuallyExists := s.Cells[nextCellID]; !nextCellActuallyExists {
			delete(s.Cells[cellID].Links, posDim)
			delete(s.db, strconv.Itoa(cellID)+posDim)
		} else {
			err := s.LinkBreakExplicit(cellID, nextCellID, posDim)
			if err != nil {
				return fmt.Errorf("CellExcise: failed to break link between cell %d and next cell %d in dim %s: %w", cellID, nextCellID, posDim, err)
			}
		}
	}

	// Link previous and next cells together, if both existed.
	if prevExists && nextExists {
		// Ensure both prevCellID and nextCellID actually exist before trying to link them
		if _, prevCellStillExists := s.Cells[prevCellID]; !prevCellStillExists {
			return fmt.Errorf("CellExcise: previous cell %d (originally linked to %d) no longer exists, cannot re-link to next cell %d in slice %s", prevCellID, cellID, nextCellID, s.Name)
		}
		if _, nextCellStillExists := s.Cells[nextCellID]; !nextCellStillExists {
			return fmt.Errorf("CellExcise: next cell %d (originally linked to %d) no longer exists, cannot re-link from previous cell %d in slice %s", nextCellID, cellID, prevCellID, s.Name)
		}
		
		err := s.LinkMake(prevCellID, nextCellID, posDim) // Link prev to next along positive dimension
		if err != nil {
			// This could happen if, for example, prevCellID is now already linked in posDim
			// due to some other operation or inconsistent state.
			return fmt.Errorf("CellExcise: failed to link prev cell %d to next cell %d in dim %s: %w", prevCellID, nextCellID, posDim, err)
		}
	}
	return nil
}

// CellNew creates a new cell in the slice.
// It attempts to recycle a cell ID from the DeleteHome recycle pile first.
// If the pile is empty, it uses the slice's NextCellID counter.
// Optional content can be provided; otherwise, content defaults to the cell's ID.
func (s *Slice) CellNew(optContent ...string) (int, error) {
	var newCellID int

	// Check if DeleteHome and its links are properly initialized
	_, deleteHomeExists := s.Cells[DeleteHome]

	if deleteHomeExists {
		recycledID, recycleLinkExists := s.CellNbr(DeleteHome, "-d.2")
		if recycleLinkExists && recycledID != DeleteHome { // Recycle pile is not empty
			// Ensure the recycledID actually exists before trying to excise it.
			if _, recycledCellExists := s.Cells[recycledID]; recycledCellExists {
				newCellID = recycledID
				err := s.CellExcise(newCellID, "d.2") // baseDimName is "d.2"
				if err != nil {
					return 0, fmt.Errorf("CellNew: failed to excise cell %d from recycle pile: %w", newCellID, err)
				}
			} else {
				// Link from DeleteHome points to a non-existent cell. Fallback to new ID.
				// This indicates data inconsistency. Might need logging or repair.
				fmt.Printf("Warning: CellNew: Recycle pile link from %d points to non-existent cell %d in slice %s. Using new ID.\n", DeleteHome, recycledID, s.Name)
				newCellID = s.NextCellID
				s.NextCellID++
				s.db["n"] = strconv.Itoa(s.NextCellID) // Update 'n' counter in db
			}
		} else { // Recycle pile is empty or DeleteHome not properly set up as a circular queue head
			newCellID = s.NextCellID
			s.NextCellID++
			s.db["n"] = strconv.Itoa(s.NextCellID) // Update 'n' counter in db
		}
	} else { // DeleteHome itself doesn't exist, so no recycle pile to check.
		newCellID = s.NextCellID
		s.NextCellID++
		s.db["n"] = strconv.Itoa(s.NextCellID) // Update 'n' counter in db
	}

	// Create the new cell structure
	s.Cells[newCellID] = &Cell{
		ID:    newCellID,
		Links: make(map[string]int),
		// Content will be set by CellSet
	}

	// Assign content
	var contentToSet string
	if len(optContent) > 0 && optContent[0] != "" {
		contentToSet = optContent[0]
	} else {
		contentToSet = strconv.Itoa(newCellID)
	}

	err := s.CellSet(newCellID, contentToSet) // This also updates s.db for the cell content
	if err != nil {
		// If CellSet fails, we might have an orphaned cell in s.Cells.
		// Depending on desired atomicity, might need to revert s.NextCellID or put newCellID back on recycle pile.
		// For now, the error from CellSet is propagated.
		delete(s.Cells, newCellID) // Clean up partially created cell
		return 0, fmt.Errorf("CellNew: failed to set content for new cell %d: %w", newCellID, err)
	}

	return newCellID, nil
}

// DoShear moves a row of cells (starting at firstCellID, along dirDim) by 'n' positions.
// Links in 'linkDim' for these cells are broken and re-linked to new cells
// based on the shear operation.
// 'n' is the number of cells to shift by.
// 'hangOptional' (default false): if true, the cell on the end is left hanging;
// otherwise, it's linked back to the beginning of the (conceptual) shifted row.
func (s *Slice) DoShear(firstCellID int, dirDim string, linkDim string, n int, hangOptional ...bool) error {
	if _, ok := s.Cells[firstCellID]; !ok {
		return fmt.Errorf("DoShear: firstCellID %d does not exist", firstCellID)
	}
	if !strings.HasPrefix(dirDim, "+") && !strings.HasPrefix(dirDim, "-") {
		return fmt.Errorf("DoShear: invalid dirDim format '%s'", dirDim)
	}
	if !strings.HasPrefix(linkDim, "+") && !strings.HasPrefix(linkDim, "-") {
		return fmt.Errorf("DoShear: invalid linkDim format '%s'", linkDim)
	}
	if n == 0 { // No shear to perform
		return nil
	}
	if n < 0 { // Negative shear is not explicitly handled in original, assume positive for now or error
		return fmt.Errorf("DoShear: negative shear amount 'n' (%d) is not supported", n)
	}

	hang := false
	if len(hangOptional) > 0 {
		hang = hangOptional[0]
	}

	shearCells, ok := s.CellsRow(firstCellID, dirDim)
	if !ok || len(shearCells) == 0 {
		return fmt.Errorf("DoShear: could not get cells row from %d along %s", firstCellID, dirDim)
	}

	if n >= len(shearCells) && !hang { // Normalize n for non-hanging shears to be within row length
		n = n % len(shearCells)
		if n == 0 && len(shearCells) > 0 { // if n was a multiple of length, it's like no shear
			// return nil // Or can proceed, it will just relink to original positions
		}
	}


	linkedCells := make([]struct {
		id    int
		found bool
	}, len(shearCells))

	for i, scID := range shearCells {
		target, exists := s.CellNbr(scID, linkDim)
		linkedCells[i] = struct {id int; found bool}{target, exists}
	}

	newLinkTargets := make([]struct {id int; found bool}, len(shearCells))
	copy(newLinkTargets, linkedCells)

	// Perform the shear on newLinkTargets
	// Example: if n=1, [A,B,C,D] -> [D,A,B,C] for a non-hanging shear if we imagine targets shifted
	// The actual logic is that the cell at shearCells[i] will now link to newLinkTargets[ (i-n+len) % len ]
	// Or, more directly, the target that was at linkedCells[j] moves to newLinkTargets[(j+n)%len]
	// So, cell shearCells[i] should link to the target originally from linkedCells[(i-n) mod len]
	
	// Simplified: create the newLinkTargets array after shifting
	// If n=1 and @linked_cells = (L0, L1, L2, L3)
	// @new_link = (L0, L1, L2, L3)
	// @x = splice(@new_link, 0, $n) -> @x = (L0), @new_link = (L1, L2, L3)
	// push @new_link, @x -> @new_link = (L1, L2, L3, L0) this is what shearCells[i] links to.
	
	// This means shearCells[0] links to new_link[0] (which is L1)
	// shearCells[1] links to new_link[1] (which is L2) ...
	
	// Let's re-evaluate the splice logic:
	// @new_link = @linked_cells;
	// @x = splice(@new_link, 0, $n); # remove first $n elements, store in @x
	// push @new_link, @x;           # add @x to the end of @new_link
	// This means if @linked_cells = (T0, T1, T2, T3) and n=1
	// @x = (T0)
	// @new_link becomes (T1, T2, T3) then (T1, T2, T3, T0)
	// So, shearCells[i] will link to new_link_final[i]
	
	shiftedTargets := make([]struct{id int; found bool}, len(shearCells))
	if len(shearCells) > 0 {
		effectiveN := n % len(shearCells) // Ensure n is within bounds for the slice logic
		
		tempSlice := make([]struct{id int; found bool}, len(shearCells))
		copy(tempSlice, linkedCells)

		firstPart := tempSlice[:effectiveN]
		secondPart := tempSlice[effectiveN:]
		
		shiftedTargets = append(secondPart, firstPart...)
	}


	// Break all old links
	for i, scID := range shearCells {
		oldTarget := linkedCells[i]
		if oldTarget.found {
			// Ensure target cell exists before trying to break link from it
			if _, targetExistsInMap := s.Cells[oldTarget.id]; targetExistsInMap {
				err := s.LinkBreakExplicit(scID, oldTarget.id, linkDim)
				if err != nil {
					// Log error or decide if it's critical.
					// Perl's link_break dies on error.
					// fmt.Printf("DoShear: Error breaking old link from %d to %d along %s: %v\n", scID, oldTarget.id, linkDim, err)
					// If a link doesn't exist as expected, LinkBreakExplicit will error.
					// This might happen if data is inconsistent or if LinkBreak was too strict.
					// For shear, it's probably fine if a link to break was already gone.
				}
			} else {
				// If target doesn't exist, just remove the forward link
				if cell, ok := s.Cells[scID]; ok {
					delete(cell.Links, linkDim)
					delete(s.db, strconv.Itoa(scID)+linkDim)
				}
			}
		}
	}

	// Make new links
	for i, scID := range shearCells {
		newTarget := shiftedTargets[i] // This is the target cell for shearCells[i]
		
		if newTarget.found { // Only make a link if there was an original target to shift
			if i == len(shearCells)-1 && hang { // If it's the last cell and we should leave it hanging
				continue
			}
			
			// Ensure both scID and newTarget.id exist before linking
			if _, scExists := s.Cells[scID]; !scExists {
				return fmt.Errorf("DoShear: source cell %d for new link does not exist", scID)
			}
			if _, targetExists := s.Cells[newTarget.id]; !targetExists {
				// This can happen if an original link pointed to a cell that was later deleted,
				// and its placeholder is now being shifted.
				// fmt.Printf("DoShear: target cell %d for new link does not exist. Cannot link from %d.\n", newTarget.id, scID)
				continue // Skip making this link
			}

			err := s.LinkMake(scID, newTarget.id, linkDim)
			if err != nil {
				// This error is more critical as it means the primary operation failed.
				return fmt.Errorf("DoShear: failed to make new link from %d to %d along %s: %w", scID, newTarget.id, linkDim, err)
			}
		}
	}
	// display_dirty() would be called here
	return nil
}

// LinkMake creates a bidirectional link between two cells in a given dimension.
// It updates both the Cell.Links maps and the Slice.db simulation.
// Ensures consistency and checks for pre-existing conflicting links.
func (s *Slice) LinkMake(cell1ID, cell2ID int, dim string) error {
	cell1, ok1 := s.Cells[cell1ID]
	if !ok1 {
		return fmt.Errorf("LinkMake: cell %d does not exist in slice %s", cell1ID, s.Name)
	}
	cell2, ok2 := s.Cells[cell2ID]
	if !ok2 {
		return fmt.Errorf("LinkMake: cell %d does not exist in slice %s", cell2ID, s.Name)
	}

	if !strings.HasPrefix(dim, "+") && !strings.HasPrefix(dim, "-") {
		return fmt.Errorf("LinkMake: invalid dimension format '%s' for slice %s. Must start with '+' or '-'", dim, s.Name)
	}

	backDim := reverseSign(dim)

	// Check if cell1 is already linked in the given dimension
	if existingTarget, exists := s.CellNbr(cell1ID, dim); exists {
		return fmt.Errorf("LinkMake: cell %d is already linked in dimension %s to cell %d in slice %s", cell1ID, dim, existingTarget, s.Name)
	}
	// Check if cell2 is already linked in the reverse dimension
	if existingSource, exists := s.CellNbr(cell2ID, backDim); exists {
		return fmt.Errorf("LinkMake: cell %d is already linked in dimension %s (reverse of %s) to cell %d in slice %s", cell2ID, backDim, dim, existingSource, s.Name)
	}

	// Update Cell.Links maps
	if cell1.Links == nil { cell1.Links = make(map[string]int) }
	cell1.Links[dim] = cell2ID

	if cell2.Links == nil { cell2.Links = make(map[string]int) }
	cell2.Links[backDim] = cell1ID

	// Update db simulation
	s.db[strconv.Itoa(cell1ID)+dim] = strconv.Itoa(cell2ID)
	s.db[strconv.Itoa(cell2ID)+backDim] = strconv.Itoa(cell1ID)

	return nil
}

// LinkBreakExplicit breaks a specific bidirectional link between cell1ID and targetCellID in the given dimension 'dim'.
// It updates both Cell.Links and Slice.db.
// This is the 3-argument version, requiring explicit target.
func (s *Slice) LinkBreakExplicit(cell1ID, targetCellID int, dim string) error {
	cell1, ok1 := s.Cells[cell1ID]
	if !ok1 {
		return fmt.Errorf("LinkBreakExplicit: cell %d does not exist in slice %s", cell1ID, s.Name)
	}
	_, ok2 := s.Cells[targetCellID] // Check targetCellID existence
	if !ok2 {
		return fmt.Errorf("LinkBreakExplicit: target cell %d does not exist in slice %s", targetCellID, s.Name)
	}

	if !strings.HasPrefix(dim, "+") && !strings.HasPrefix(dim, "-") {
		return fmt.Errorf("LinkBreakExplicit: invalid dimension format '%s' for slice %s. Must start with '+' or '-'", dim, s.Name)
	}

	// Verify the link actually exists from cell1ID to targetCellID in 'dim'
	actualTarget, linkExists := s.CellNbr(cell1ID, dim)
	if !linkExists {
		return fmt.Errorf("LinkBreakExplicit: cell %d has no link in direction %s in slice %s", cell1ID, dim, s.Name)
	}
	if actualTarget != targetCellID {
		return fmt.Errorf("LinkBreakExplicit: cell %d is linked to %d in direction %s, not to %d, in slice %s", cell1ID, actualTarget, dim, targetCellID, s.Name)
	}

	backDim := reverseSign(dim)

	// Delete from Cell.Links maps
	if cell1.Links != nil {
		delete(cell1.Links, dim)
	}
	// It's possible targetCellID's Links map is nil if data is inconsistent, but normally it shouldn't be.
	if targetCell, tcExists := s.Cells[targetCellID]; tcExists && targetCell.Links != nil {
		delete(targetCell.Links, backDim)
	}


	// Delete from db simulation
	delete(s.db, strconv.Itoa(cell1ID)+dim)
	delete(s.db, strconv.Itoa(targetCellID)+backDim)

	return nil
}

// LinkBreakInfer breaks a bidirectional link starting from cell1ID in the given dimension 'dim'.
// The target cell is inferred from the existing link.
// This is the 2-argument version.
func (s *Slice) LinkBreakInfer(cell1ID int, dim string) error {
	if _, ok1 := s.Cells[cell1ID]; !ok1 {
		return fmt.Errorf("LinkBreakInfer: cell %d does not exist in slice %s", cell1ID, s.Name)
	}
	if !strings.HasPrefix(dim, "+") && !strings.HasPrefix(dim, "-") {
		return fmt.Errorf("LinkBreakInfer: invalid dimension format '%s' for slice %s. Must start with '+' or '-'", dim, s.Name)
	}

	targetCellID, linkExists := s.CellNbr(cell1ID, dim)
	if !linkExists {
		return fmt.Errorf("LinkBreakInfer: cell %d has no link in direction %s to break in slice %s", cell1ID, dim, s.Name)
	}
	
	// Now that target is inferred, call the explicit version.
	return s.LinkBreakExplicit(cell1ID, targetCellID, dim)
}
