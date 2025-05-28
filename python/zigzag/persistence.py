import json
import os
from typing import Dict, Any, Optional
from ..zigzag.core import Cell, ZigzagSpace

# Module-level constants
BACKUP_FILE_SUFFIX: str = ".bak"
DEFAULT_ZIGZAG_FILENAME: str = "zigzag.zz"

INITIAL_GEOMETRY: dict[int | str, str | int] = {
    0: "Home",
    "0-d.1": 99,
    "0+d.2": 30,
    "0+d.cursor": 11,
    1: "d.1",
    "1-d.1": 10,
    "1+d.1": 99,
    "1-d.2": 8,
    "1+d.2": 2,
    2: "d.2",
    "2-d.2": 1,
    "2+d.2": 3,
    3: "d.3",
    "3-d.2": 2,
    "3+d.2": 4,
    4: "d.inside",
    "4-d.2": 3,
    "4+d.2": 5,
    5: "d.contents",
    "5-d.2": 4,
    "5+d.2": 6,
    6: "d.mark",
    "6-d.2": 5,
    "6+d.2": 7,
    7: "d.clone",
    "7-d.2": 6,
    "7+d.2": 8,
    8: "d.cursor",
    "8-d.2": 7,
    "8+d.2": 1,
    10: "Cursor home",
    "10+d.1": 1,
    "10+d.2": 11,
    "10-d.1": 21,
    11: "Menu",
    "11+d.1": 12,
    "11-d.2": 10,
    "11+d.2": 16,
    "11-d.cursor": 0,
    "11+d.cursor": 16,
    12: "+d.1",
    "12-d.1": 11,
    "12+d.1": 13,
    13: "+d.2",
    "13-d.1": 12,
    "13+d.1": 14,
    14: "+d.3",
    "14-d.1": 13,
    "14+d.1": 15,
    15: "I",
    "15-d.1": 14,
    16: "Event",
    "16+d.1": 17,
    "16-d.2": 11,
    "16-d.cursor": 11,
    17: "+d.1",
    "17-d.1": 16,
    "17+d.1": 18,
    18: "+d.2",
    "18-d.1": 17,
    "18+d.1": 19,
    19: "+d.3",
    "19-d.1": 18,
    "19+d.1": 20,
    20: "I",
    "20-d.1": 19,
    21: "Selection",
    "21+d.1": 10,
    "21+d.2": 21,
    "21-d.2": 21,
    30: "#Edit\natcursor_edit(1);",
    "30+d.1": 35,
    "30-d.2": 0,
    "30+d.2": 40,
    35: "#Clone\natcursor_clone(1);",
    "35-d.1": 30,
    40: "#L-ins\natcursor_insert(1, 'L');",
    "40+d.1": 41,
    "40-d.2": 30,
    "40+d.2": 50,
    41: "#R-ins\natcursor_insert(1, 'R');",
    "41-d.1": 40,
    "41+d.1": 42,
    42: "#U-ins\natcursor_insert(1, 'U');",
    "42-d.1": 41,
    "42+d.1": 43,
    43: "#D-ins\natcursor_insert(1, 'D');",
    "43-d.1": 42,
    "43+d.1": 44,
    44: "#I-ins\natcursor_insert(1, 'I');",
    "44-d.1": 43,
    "44+d.1": 45,
    45: "#O-ins\natcursor_insert(1, 'O');",
    "45-d.1": 44,
    50: "#Delete\natcursor_delete(1);",
    "50+d.1": 51,
    "50-d.2": 40,
    "50+d.2": 60,
    51: "#L-break\natcursor_break_link(1, 'L');",
    "51-d.1": 50,
    "51+d.1": 52,
    52: "#R-break\natcursor_break_link(1, 'R');",
    "52-d.1": 51,
    "52+d.1": 53,
    53: "#U-break\natcursor_break_link(1, 'U');",
    "53-d.1": 52,
    "53+d.1": 54,
    54: "#D-break\natcursor_break_link(1, 'D');",
    "54-d.1": 53,
    "54+d.1": 55,
    55: "#I-break\natcursor_break_link(1, 'I');",
    "55-d.1": 54,
    "55+d.1": 56,
    56: "#O-break\natcursor_break_link(1, 'O');",
    "56-d.1": 55,
    60: "#Select\natcursor_select(1);",
    "60-d.2": 50,
    "60+d.2": 70,
    "60+d.1": 61,
    61: "#Rot.Selection\nrotate_selection();",
    "61-d.1": 60,
    "61+d.1": 62,
    62: "#Push Selection\npush_selection();",
    "62-d.1": 61,
    70: "#L-Hop\natcursor_hop(1, 'L');",
    "70+d.1": 71,
    "70-d.2": 60,
    "70+d.2": 80,
    71: "#R-Hop\natcursor_hop(1, 'R');",
    "71-d.1": 70,
    "71+d.1": 72,
    72: "#U-Hop\natcursor_hop(1, 'U');",
    "72-d.1": 71,
    "72+d.1": 73,
    73: "#D-Hop\natcursor_hop(1, 'D');",
    "73-d.1": 72,
    "73+d.1": 74,
    74: "#I-Hop\natcursor_hop(1, 'I');",
    "74-d.1": 73,
    "74+d.1": 75,
    75: "#O-Hop\natcursor_hop(1, 'O');",
    "75-d.1": 74,
    80: "#Shear -^\natcursor_shear(1, 'D', 'L')",
    "80-d.2": 70,
    "80+d.2": 85,
    "80+d.1": 81,
    81: "#Shear -v\natcursor_shear(1, 'U', 'L')",
    "81-d.1": 80,
    "81+d.1": 82,
    82: "#Shear ^+\natcursor_shear(1, 'D', 'R')",
    "82-d.1": 81,
    "82+d.1": 83,
    83: "#Shear v+\natcursor_shear(1, 'U', 'R')",
    "83-d.1": 82,
    85: "#Chug",
    "85-d.2": 80,
    "85+d.2": 90,
    90: "#A-View toggle\nview_raster_toggle(0);",
    "90+d.1": 91,
    "90-d.2": 85,
    "90+d.2": 93,
    91: "#D-View toggle\nview_raster_toggle(1);",
    "91-d.1": 90,
    "91+d.1": 92,
    92: "#Quad view toggle\nview_quadrant_toggle(1);",
    "92-d.1": 91,
    93: "#X-rotate view\nview_rotate(1, 'X');",
    "93+d.1": 94,
    "93-d.2": 90,
    "93+d.2": 96,
    94: "#Y-rotate view\nview_rotate(1, 'Y');",
    "94-d.1": 93,
    "94+d.1": 95,
    95: "#Z-rotate view\nview_rotate(1, 'Z');",
    "95-d.1": 94,
    96: "#X-flip view\nview_flip(1, 'X');",
    "96+d.1": 97,
    "96-d.2": 93,
    97: "#Y-flip view\nview_flip(1, 'Y');",
    "97-d.1": 96,
    "97+d.1": 98,
    98: "#Z-flip view\nview_flip(1, 'Z');",
    "98-d.1": 97,
    99: "Recycle pile",
    "99-d.1": 1,
    "99+d.1": 0,
    "99-d.2": 99,
    "99+d.2": 99,
    "n": 100
}

def _populate_from_initial_geometry(zz_space: ZigzagSpace) -> None:
    """Populates the ZigzagSpace from the INITIAL_GEOMETRY."""
    
    # First pass: Create cells with content
    for key, value in INITIAL_GEOMETRY.items():
        if isinstance(key, int): # Cell content, e.g., 0: "Home"
            cell_id_str = str(key)
            zz_space.cells[cell_id_str] = Cell(cell_id=cell_id_str, content=value)
        elif key == 'n': # Next cell ID
            zz_space.next_cell_id = int(value)

    # Second pass: Establish connections and dimensions
    for key, value in INITIAL_GEOMETRY.items():
        if isinstance(key, str) and ('-' in key or '+' in key): # Connection, e.g., "0-d.1": 99
            # Ensure we don't process keys like "+d.1" if they are cell content by mistake
            if key in zz_space.cells: # If a key like "+d.1" is already a cell_id, skip
                continue

            parts = key.split('-', 1)
            sign = "-"
            if len(parts) == 2:
                cell_id_str, dimension_name_part = parts
            else:
                parts = key.split('+', 1)
                sign = "+"
                if len(parts) == 2:
                    cell_id_str, dimension_name_part = parts
                else:
                    # This condition should ideally not be met if keys are cell IDs or 'n' or valid connections
                    # print(f"Warning: Could not parse connection key: {key}")
                    continue 

            # Check if cell_id_str is a valid cell identifier (exists in zz_space.cells)
            # This is crucial because INITIAL_GEOMETRY might have keys like "0+d.cursor"
            # where "0" is the cell_id_str.
            if cell_id_str not in zz_space.cells:
                # This could happen if a connection refers to a cell_id that wasn't defined as an integer key
                # Or if the key format is not "cell_id<sign>dimension_name"
                # print(f"Warning: Source cell ID '{cell_id_str}' from connection key '{key}' not found.")
                continue

            dimension_name_with_sign = sign + dimension_name_part
            target_cell_id_str = str(value)
            
            # Ensure target cell for connection will exist (it should be created in the first pass if it's an int key)
            # If target_cell_id_str is not in zz_space.cells yet, it implies it might be defined later
            # or is missing. For INITIAL_GEOMETRY, all referenced cells should be definable.
            # We assume that all connections point to cells that are defined by integer keys in INITIAL_GEOMETRY

            zz_space.cells[cell_id_str].connections[dimension_name_with_sign] = target_cell_id_str
            base_dimension = dimension_name_part 
            zz_space.dimensions.add(base_dimension)


def slice_open(zz_space: ZigzagSpace, filename: Optional[str] = None, storage_type: str = 'json') -> None:
    """
    Opens a Zigzag data slice.
    If the file exists and is JSON, it loads from the file.
    Otherwise, it populates the space with initial geometry.
    """
    if filename is None:
        filename = DEFAULT_ZIGZAG_FILENAME
    
    # Ensure filename is now a string for os.path.exists and other operations
    # (it will be if it was None or provided as a string)

    if storage_type == 'json' and os.path.exists(filename):
        try:
            with open(filename, 'r') as f:
                data = json.load(f)
            
            zz_space.cells.clear() # Clear any existing cells
            loaded_cells_data = data.get('cells', {})
            for cell_id_str, cell_data in loaded_cells_data.items():
                # Cell IDs from JSON are strings, ensure consistency
                zz_space.cells[cell_id_str] = Cell(
                    cell_id=cell_id_str, 
                    content=cell_data.get('content')
                )
                # Connections in JSON should have target_cell_id as string
                zz_space.cells[cell_id_str].connections = cell_data.get('connections', {})

            zz_space.dimensions = set(data.get('dimensions', [])) # Ensure dimensions is a set
            zz_space.next_cell_id = int(data.get('next_cell_id', 0))
            print(f"Successfully loaded data from {filename}")

        except json.JSONDecodeError:
            print(f"Error: Could not decode JSON from {filename}. Using initial geometry.")
            _populate_from_initial_geometry(zz_space)
        except Exception as e: # Catch other potential errors during loading
            print(f"An unexpected error occurred while loading {filename}: {e}. Using initial geometry.")
            _populate_from_initial_geometry(zz_space)
    else:
        if storage_type == 'json' and not os.path.exists(filename):
            print(f"Info: File {filename} not found. Using initial geometry.")
        _populate_from_initial_geometry(zz_space)
        
    zz_space.filename = filename


def slice_sync_all(zz_space: ZigzagSpace, filename: Optional[str] = None, storage_type: str = 'json') -> None:
    """
    Saves the current state of the ZigzagSpace to a file.
    """
    target_filename = filename if filename is not None else zz_space.filename

    if target_filename is None:
        print("Error: No filename specified for saving the Zigzag space.")
        return

    if storage_type == 'json':
        data_to_save: Dict[str, Any] = {}
        data_to_save['next_cell_id'] = zz_space.next_cell_id
        data_to_save['dimensions'] = sorted(list(zz_space.dimensions)) # Sort for consistent output
        
        cells_data: Dict[str, Dict[str, Any]] = {}
        for cell_id, cell_obj in zz_space.cells.items():
            cells_data[cell_id] = {
                'content': cell_obj.content,
                'connections': cell_obj.connections # Assuming connections keys and target_ids are already strings
            }
        data_to_save['cells'] = cells_data

        try:
            with open(target_filename, 'w') as f:
                json.dump(data_to_save, f, indent=4, sort_keys=True) # sort_keys for consistent output
            print(f"Zigzag space successfully saved to {target_filename}")
        except IOError as e:
            print(f"Error: Could not write to file {target_filename}. {e}")
        except Exception as e:
            print(f"An unexpected error occurred while saving to {target_filename}: {e}")
    else:
        print(f"Error: Storage type '{storage_type}' is not supported for saving.")


def slice_close(zz_space: ZigzagSpace, filename: Optional[str] = None, storage_type: str = 'json') -> None:
    """
    Saves the Zigzag space and (optionally in the future) cleans up.
    """
    slice_sync_all(zz_space, filename, storage_type)
    # Future: Add logic here to clear or reset zz_space if necessary, e.g.:
    # zz_space.cells.clear()
    # zz_space.dimensions.clear()
    # zz_space.next_cell_id = 0
    # zz_space.filename = None
    # print("Zigzag space closed.")
