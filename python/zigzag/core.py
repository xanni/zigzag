from typing import Dict, Any, Optional, Set, List # Added List for type hints

# Custom Exceptions
class ZigzagError(Exception):
    """Base class for exceptions in the Zigzag library."""
    pass

class CellNotFoundError(ZigzagError):
    """Raised when a specified cell is not found."""
    def __init__(self, cell_id: str):
        super().__init__(f"Cell '{cell_id}' not found.")
        self.cell_id = cell_id

class DimensionNotFoundError(ZigzagError):
    """Raised when a specified dimension name is not found."""
    def __init__(self, dimension_name: str):
        super().__init__(f"Dimension name '{dimension_name}' not found.")
        self.dimension_name = dimension_name

class InvalidDimensionError(ZigzagError):
    """Raised when a dimension string is invalid or inappropriate for an operation."""
    def __init__(self, message: str):
        super().__init__(message)

class LinkError(ZigzagError):
    """Raised for errors during link creation or breaking."""
    pass

class OperationInvalidError(ZigzagError):
    """Raised when an operation is invalid under current conditions."""
    pass

# Module-level constants
CURSOR_HOME_ID: str = "10"
SELECT_HOME_ID: str = "21"
DELETE_HOME_ID: str = "99"
ROOT_CELL_ID: str = "0"
ESSENTIAL_DIMENSIONS: Set[str] = {"d.1", "d.2", "d.cursor", "d.clone", "d.inside", "d.contents", "d.mark"}


class Cell:
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    """
    Represents a single cell within the Zigzag space.

    Attributes:
        cell_id: A unique string identifier for the cell.
        content: The data stored within the cell.
        connections: A dictionary mapping dimension names (with sign, e.g., "+d.1")
                     to the cell_id of the connected neighbor.
    """
    def __init__(self, cell_id: str, content: Any = None):
        """
        Initializes a new Cell.

        Args:
            cell_id: The unique identifier for this cell.
            content: The initial content of the cell.
        """
        self.cell_id: str = cell_id
        self.content: Any = content
        self.connections: Dict[str, str] = {}

class ZigzagSpace:
    """
    Represents the entire Zigzag space, a multidimensional grid of cells.

    The ZigzagSpace manages cells, their content, and the connections between them
    along various dimensions. It provides methods for creating, modifying,
    navigating, and performing higher-level operations within this space.

    Attributes:
        cells: A dictionary mapping cell_id (str) to Cell objects.
        dimensions: A set of base dimension names (e.g., "d.1", "d.cursor") present in the space.
        next_cell_id: An integer counter for generating unique cell IDs.
        filename: An optional string indicating the file associated with this space.
    """
    def __init__(self, filename: Optional[str] = None):
        """
        Initializes a new ZigzagSpace.

        Args:
            filename: Optional name of the file this space is associated with.
        """
        self.cells: Dict[str, Cell] = {}
        self.dimensions: Set[str] = set() 
        self.next_cell_id: int = 0
        self.filename: Optional[str] = filename

    def _generate_cell_id(self) -> str:
        """
        Generates a new unique cell ID based on an internal counter.
        Internal method.
        
        Returns:
            A string representation of the new unique cell ID.
        """
        new_id = self.next_cell_id
        self.next_cell_id += 1
        return str(new_id)

    def cell_new(self, content: Optional[str] = None) -> str:
        """
        Creates a new cell with optional content and adds it to the space.

        If content is not provided, the cell's ID will be used as its content.
        
        Args:
            content: The optional content for the new cell.

        Returns:
            The ID of the newly created cell.
        """
        new_cell_id = self._generate_cell_id()
        if content is None:
            content = new_cell_id  # Default content is the cell_id itself
        
        cell = Cell(cell_id=new_cell_id, content=content)
        self.cells[new_cell_id] = cell
        return new_cell_id

    def cell_get(self, cell_id: str) -> Optional[str]:
        """
        Retrieves the content of a specified cell.

        Args:
            cell_id: The ID of the cell whose content is to be retrieved.

        Returns:
            The content of the cell if found, otherwise None.
        """
        cell = self.cells.get(cell_id)
        if cell:
            return cell.content
        return None

    def cell_set(self, cell_id: str, content: str) -> None:
        """
        Sets the content of an existing cell.

        Args:
            cell_id: The ID of the cell whose content is to be set.
            content: The new content for the cell.

        Raises:
            CellNotFoundError: If the cell with the given ID is not found.
        """
        if cell_id in self.cells:
            self.cells[cell_id].content = content
        else:
            raise CellNotFoundError(cell_id)

    def cell_nbr(self, cell_id: str, dimension_name_with_sign: str) -> Optional[str]:
        """
        Retrieves the ID of a neighboring cell along a given signed dimension.

        Args:
            cell_id: The ID of the starting cell.
            dimension_name_with_sign: The dimension name with sign (e.g., "+d.1", "-d.2").

        Returns:
            The ID of the neighboring cell if it exists and is linked, otherwise None.
            Returns None also if cell_id itself is not found.
        """
        cell = self.cells.get(cell_id)
        if cell:
            return cell.connections.get(dimension_name_with_sign)
        return None
        
    def _reverse_dimension_sign(self, dimension_name_with_sign: str) -> str:
        """
        Reverses the sign of a dimension string (e.g., '+d.1' to '-d.1', or 'd.foo' to 'd.foo').
        If the string is empty or does not start with '+' or '-', it's returned unchanged.
        Internal method.
        """
        if not dimension_name_with_sign:
            # Consider raising ValueError for empty string if it's truly invalid input
            return "" 
        
        sign = dimension_name_with_sign[0]
        name = dimension_name_with_sign[1:]
        if sign == '+':
            return '-' + name
        elif sign == '-':
            return '+' + name
        # If no sign, it might be an error or a base dimension.
        # For now, returning as is, consistent with original behavior.
        return dimension_name_with_sign 

    def _get_base_dimension(self, dimension_name_with_sign: str) -> str:
        """
        Extracts the base dimension name (e.g., 'd.1' from '+d.1' or '-d.1').
        If the string is empty or has no sign, it's returned as is (or empty).
        Internal method.
        """
        if not dimension_name_with_sign:
            return ""
        
        if dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-'):
            return dimension_name_with_sign[1:]
        # Assumes it's already a base dimension name if no sign
        return dimension_name_with_sign

    def link_make(self, cell1_id: str, cell2_id: str, dimension_name_with_sign: str) -> None:
        """Creates a bidirectional link between two cells along a dimension."""
        if cell1_id not in self.cells:
            print(f"Error: Cell with ID '{cell1_id}' not found. Cannot create link.")
            return
        if cell2_id not in self.cells:
            print(f"Error: Cell with ID '{cell2_id}' not found. Cannot create link.")
            return

        cell1 = self.cells[cell1_id]
        cell2 = self.cells[cell2_id]
        
        # Validate dimension_name_with_sign format (must start with + or -)
        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return

        reversed_dim = self._reverse_dimension_sign(dimension_name_with_sign)

        if cell1.connections.get(dimension_name_with_sign) is not None:
            print(f"Error: {cell1_id} already linked in direction {dimension_name_with_sign} to {cell1.connections.get(dimension_name_with_sign)}.")
            return
        if cell2.connections.get(reversed_dim) is not None:
            print(f"Error: {cell2_id} already linked in direction {reversed_dim} to {cell2.connections.get(reversed_dim)}.")
            return

        cell1.connections[dimension_name_with_sign] = cell2_id
        cell2.connections[reversed_dim] = cell1_id
        
        base_dimension = self._get_base_dimension(dimension_name_with_sign)
        if base_dimension: # Ensure base_dimension is not empty
             self.dimensions.add(base_dimension)

    def link_break(self, cell1_id: str, cell2_id: Optional[str], dimension_name_with_sign: str) -> None:
        """Breaks a bidirectional link between cells."""
        if cell1_id not in self.cells:
            print(f"Error: Cell with ID '{cell1_id}' not found. Cannot break link.")
            return
        
        cell1 = self.cells[cell1_id]

        # Validate dimension_name_with_sign format
        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return

        original_target_cell_id = cell1.connections.get(dimension_name_with_sign)

        if cell2_id is None:
            cell2_id = original_target_cell_id
            if cell2_id is None:
                print(f"Error: Link from {cell1_id} in direction {dimension_name_with_sign} does not exist or cell2_id not provided.")
                return
        
        if cell2_id not in self.cells:
            print(f"Error: Target cell with ID '{cell2_id}' (possibly inferred) not found.")
            return
            
        cell2 = self.cells[cell2_id]
        reversed_dim = self._reverse_dimension_sign(dimension_name_with_sign)

        # Verification
        if original_target_cell_id != cell2_id:
            print(f"Error: Link from {cell1_id} along {dimension_name_with_sign} (to {original_target_cell_id}) does not point to specified/inferred {cell2_id}.")
            return
        
        # Optional: Check reverse link only if it's expected to exist
        # (It might not if data is inconsistent or link was unidirectional, though our link_make makes them bidirectional)
        if cell2.connections.get(reversed_dim) != cell1_id:
             print(f"Warning: Reverse link from {cell2_id} along {reversed_dim} does not point back to {cell1_id}. Breaking forward link only.")
             # Depending on strictness, one might choose to return here or proceed to break the forward link.
             # For now, proceed to break what we can based on cell1's perspective.

        # Break links
        if dimension_name_with_sign in cell1.connections:
            del cell1.connections[dimension_name_with_sign]
        
        # Only try to delete reverse link if cell2's connection actually points back.
        # This avoids errors if the link was already partially broken or inconsistent.
        if cell2.connections.get(reversed_dim) == cell1_id:
            del cell2.connections[reversed_dim]
        else:
            if cell2.connections.get(reversed_dim) is not None: # It exists but points elsewhere
                 print(f"Warning: Reverse link from {cell2_id} along {reversed_dim} pointed to {cell2.connections.get(reversed_dim)}, not {cell1_id}. It was not removed by this operation on {cell1_id}.")
        
        # Note: Dimensions are not removed from self.dimensions, mirroring Perl behavior.

    def cell_insert(self, new_cell_id: str, existing_cell_id: str, dimension_name_with_sign: str) -> None:
        """Inserts new_cell_id into a chain of cells, next to existing_cell_id along dimension_name_with_sign."""
        if new_cell_id not in self.cells:
            print(f"Error: New cell with ID '{new_cell_id}' not found. Cannot insert.")
            return
        if existing_cell_id not in self.cells:
            print(f"Error: Existing cell with ID '{existing_cell_id}' not found. Cannot insert.")
            return

        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return

        new_cell = self.cells[new_cell_id]
        # existing_cell is self.cells[existing_cell_id], but we use existing_cell_id for link_make/break

        # Check for conflicts on new_cell
        if new_cell.connections.get(dimension_name_with_sign) is not None:
            print(f"Error: New cell '{new_cell_id}' already has a link in direction '{dimension_name_with_sign}'.")
            return
        
        reversed_dim = self._reverse_dimension_sign(dimension_name_with_sign)
        if new_cell.connections.get(reversed_dim) is not None:
            print(f"Error: New cell '{new_cell_id}' already has a link in direction '{reversed_dim}'.")
            return

        target_neighbor_id = self.cells[existing_cell_id].connections.get(dimension_name_with_sign)

        if target_neighbor_id is not None:
            # Break the link between existing_cell and its original neighbor
            self.link_break(existing_cell_id, target_neighbor_id, dimension_name_with_sign)
            # Link new_cell to that original neighbor
            self.link_make(new_cell_id, target_neighbor_id, dimension_name_with_sign)
        
        # Link existing_cell to new_cell
        self.link_make(existing_cell_id, new_cell_id, dimension_name_with_sign)
        
        base_dimension = self._get_base_dimension(dimension_name_with_sign)
        if base_dimension:
            self.dimensions.add(base_dimension)

    def cell_excise(self, cell_id_to_excise: str, dimension_name: str) -> None:
        """Removes a cell from a dimensional chain, linking its previous and next neighbors."""
        if cell_id_to_excise not in self.cells:
            print(f"Error: Cell with ID '{cell_id_to_excise}' not found. Cannot excise.")
            return

        positive_dim = "+" + dimension_name
        negative_dim = "-" + dimension_name

        prev_cell_id = self.cell_nbr(cell_id_to_excise, negative_dim)
        next_cell_id = self.cell_nbr(cell_id_to_excise, positive_dim)

        if prev_cell_id is not None:
            self.link_break(cell_id_to_excise, prev_cell_id, negative_dim)
        
        if next_cell_id is not None:
            self.link_break(cell_id_to_excise, next_cell_id, positive_dim)

        if prev_cell_id is not None and next_cell_id is not None:
            # Check if prev_cell_id and next_cell_id are the same cell,
            # which can happen if the chain was just prev <-> excise <-> next (and next == prev)
            # or if it was a loop of two cells: excise <-> prev/next <-> excise
            # If they are the same, linking them would create a self-loop on that dimension.
            # The original Perl code doesn't explicitly prevent this, but it's worth noting.
            # For now, we follow the described logic.
            self.link_make(prev_cell_id, next_cell_id, positive_dim)
        
        # This function does not delete the cell from self.cells.
        # It also doesn't remove the dimension from self.dimensions.

    def cell_find(self, start_cell_id: str, dimension_name_with_sign: str, content_to_find: str) -> Optional[str]:
        """Finds a cell by traversing along a dimension, looking for specific content."""
        if start_cell_id not in self.cells:
            print(f"Error: Start cell with ID '{start_cell_id}' not found.")
            return None

        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return None

        current_cell_id: Optional[str] = start_cell_id
        visited_cells: Set[str] = {start_cell_id}

        while current_cell_id is not None:
            current_cell = self.cells.get(current_cell_id) 
            if current_cell is None: # Should not happen if cell_nbr and internal state are correct
                print(f"Error: Cell ID '{current_cell_id}' encountered during traversal but not found in cells dict.")
                break 

            if current_cell.content == content_to_find:
                return current_cell_id

            current_cell_id = self.cell_nbr(current_cell_id, dimension_name_with_sign)

            if current_cell_id is None: # Reached end of chain
                break
            
            if current_cell_id in visited_cells: # Loop detected
                # print(f"Loop detected: cell '{current_cell_id}' already visited.") # Optional: for debugging
                break
            
            visited_cells.add(current_cell_id)
            
        return None

    def dimension_home(self) -> Optional[str]:
        """Returns the conventional starting point for dimension-related structures if it exists."""
        if CURSOR_HOME_ID in self.cells:
            return CURSOR_HOME_ID
        return None

    def is_essential(self, cell_id: str) -> bool:
        """Checks if a cell_id corresponds to one of the essential system cells."""
        return cell_id in {ROOT_CELL_ID, CURSOR_HOME_ID, DELETE_HOME_ID, SELECT_HOME_ID}

    def dimension_is_essential(self, dimension_name: str) -> bool:
        """Checks if a dimension name (with or without sign) is essential."""
        base_dimension = self._get_base_dimension(dimension_name) # Handles +/- prefixes
        return base_dimension in ESSENTIAL_DIMENSIONS

    def dimension_find(self, dimension_name_to_find: str) -> Optional[str]:
        """Finds the cell representing a dimension by its name."""
        # CURSOR_HOME_ID ("10") -> "+d.1" -> dimension_list_start_cell_id
        # From dimension_list_start_cell_id, search along "+d.2" for dimension_name_to_find
        
        if CURSOR_HOME_ID not in self.cells:
            print(f"Error: CURSOR_HOME_ID '{CURSOR_HOME_ID}' not found. Cannot start dimension find.")
            return None

        dim_list_start_cell_id = self.cell_nbr(CURSOR_HOME_ID, "+d.1")
        
        if dim_list_start_cell_id is None:
            print("Warning: Dimension list structure seems broken or not initialized from CURSOR_HOME_ID via +d.1.")
            return None
            
        if dim_list_start_cell_id not in self.cells:
            print(f"Error: Dimension list start cell ID '{dim_list_start_cell_id}' (from CURSOR_HOME_ID via +d.1) does not exist.")
            return None

        return self.cell_find(dim_list_start_cell_id, "+d.2", dimension_name_to_find)

    def dimension_rename(self, old_dimension_name: str, new_dimension_name: str) -> None:
        """Renames a dimension, updating cell connections and the dimension cell content."""
        if old_dimension_name == new_dimension_name:
            return # No change needed

        if self.dimension_is_essential(old_dimension_name):
            print(f"Error: Dimension '{old_dimension_name}' is essential and cannot be renamed.")
            return
        
        if self.dimension_is_essential(new_dimension_name):
            # This check is to prevent renaming a non-essential to an essential one by name collision,
            # though the main guard is on old_dimension_name.
            print(f"Error: New dimension name '{new_dimension_name}' collides with an essential dimension name.")
            return

        dim_cell_id = self.dimension_find(old_dimension_name)

        if dim_cell_id is None:
            print(f"Error: Dimension '{old_dimension_name}' not found. Cannot rename.")
            return

        if self.dimension_find(new_dimension_name) is not None:
            print(f"Error: Dimension '{new_dimension_name}' already exists. Cannot rename.")
            return

        # Set the content of the dimension cell
        self.cell_set(dim_cell_id, new_dimension_name)

        # Update connections in all cells
        for cell_obj in self.cells.values():
            updates_for_cell: list[tuple[str, str, str]] = [] # (old_key, new_key, target_id)
            for link_key, target_cell_id in cell_obj.connections.items():
                # link_key is like "+d.foo" or "-d.bar"
                sign = ""
                if link_key.startswith('+') or link_key.startswith('-'):
                    sign = link_key[0]
                
                base_dim = self._get_base_dimension(link_key) # e.g. "d.foo"
                
                if base_dim == old_dimension_name:
                    new_link_key = sign + new_dimension_name
                    updates_for_cell.append((link_key, new_link_key, target_cell_id))
            
            for old_key, new_key, target_id in updates_for_cell:
                del cell_obj.connections[old_key]
                cell_obj.connections[new_key] = target_id

        # Update self.dimensions set
        if old_dimension_name in self.dimensions:
            self.dimensions.remove(old_dimension_name)
        self.dimensions.add(new_dimension_name)

        print(f"Dimension '{old_dimension_name}' renamed to '{new_dimension_name}'.")

    def get_last_cell(self, start_cell_id: str, dimension_name_with_sign: str) -> Optional[str]:
        """Traverses along a dimension until the end of the chain is reached."""
        if start_cell_id not in self.cells:
            print(f"Error: Start cell with ID '{start_cell_id}' not found.")
            return None

        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return None

        current_cell_id: Optional[str] = start_cell_id
        # Keep track of visited cells to prevent infinite loops in cycles not involving start_cell_id directly
        # but still part of the chain.
        visited_cells_in_chain: Set[str] = {start_cell_id} 
        
        # Initial step
        next_cell_id = self.cell_nbr(current_cell_id, dimension_name_with_sign)

        while next_cell_id is not None:
            if next_cell_id == start_cell_id: # Loop back to the start of the entire traversal
                break 
            if next_cell_id in visited_cells_in_chain: # Loop detected within the chain
                # This implies we've found the "last" cell before re-entering a cycle in the chain.
                # Depending on interpretation, current_cell_id is the one before re-entering the cycle.
                break
            
            current_cell_id = next_cell_id
            visited_cells_in_chain.add(current_cell_id)
            next_cell_id = self.cell_nbr(current_cell_id, dimension_name_with_sign)
            
        return current_cell_id

    def get_cell_contents(self, cell_id: str) -> Optional[str]:
        """Retrieves the 'effective' content of a cell, following -d.clone links."""
        if cell_id not in self.cells:
            print(f"Error: Cell with ID '{cell_id}' not found.")
            return None

        effective_cell_id = cell_id
        visited_clones: Set[str] = {cell_id} # To prevent infinite loops in malformed clone chains
        
        cloned_from_id = self.cell_nbr(effective_cell_id, "-d.clone")

        while cloned_from_id is not None:
            if cloned_from_id == cell_id: # Original problem statement had "cloned_from_id != cell_id"
                                          # This seems to imply if it points back to the original, stop.
                                          # However, a more robust loop detection is needed.
                print(f"Warning: Clone link from '{effective_cell_id}' along '-d.clone' points back to original query cell '{cell_id}'. Stopping traversal.")
                break 
            if cloned_from_id in visited_clones:
                print(f"Warning: Loop detected in -d.clone chain at cell '{cloned_from_id}'. Stopping traversal.")
                break # Prevent infinite loop

            effective_cell_id = cloned_from_id
            visited_clones.add(effective_cell_id)
            cloned_from_id = self.cell_nbr(effective_cell_id, "-d.clone")
            
        return self.cell_get(effective_cell_id)

    def get_cursor(self, cursor_number: int) -> Optional[str]:
        """Retrieves the cell ID of the specified cursor."""
        if cursor_number < 0:
            print("Error: Cursor number must be non-negative.")
            return None

        current_cursor_cell_id: Optional[str] = CURSOR_HOME_ID
        if CURSOR_HOME_ID not in self.cells:
            print(f"Error: CURSOR_HOME_ID '{CURSOR_HOME_ID}' not found. Cannot get cursor.")
            return None

        for _ in range(cursor_number):
            if current_cursor_cell_id is None: # Should not happen if loop condition is correct
                print("Error: Internal error, current_cursor_cell_id became None unexpectedly.")
                return None
            current_cursor_cell_id = self.cell_nbr(current_cursor_cell_id, "+d.2")
            if current_cursor_cell_id is None:
                print(f"Error: Cursor number {cursor_number} is too high. Ran out of cursors in chain.")
                return None
            if current_cursor_cell_id not in self.cells: # Check if the next cell in chain exists
                print(f"Error: Cursor chain broken. Cell ID '{current_cursor_cell_id}' (for cursor level) not found.")
                return None
                
        return current_cursor_cell_id

    def get_accursed(self, cursor_number: int) -> Optional[str]:
        """Retrieves the cell pointed to by the specified cursor."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None:
            return None # Error already printed by get_cursor

        # The original Perl implies get_lastcell is used to find the *actual* cell pointed to by the cursor,
        # as the cursor itself might be a structure.
        # "-d.cursor" is the dimension from the cursor cell to the cell it "points" to.
        # If this is a chain, get_last_cell will find the end of that chain.
        # If it's a direct link, get_last_cell will return that direct link (as next_cell_id will be None).
        return self.get_last_cell(cursor_cell_id, "-d.cursor")

    def get_dimension(self, cursor_cell_id: str, direction_char: str) -> Optional[str]:
        """Gets the dimension string associated with a cursor direction."""
        valid_directions = {'L', 'R', 'U', 'D', 'I', 'O'}
        if direction_char not in valid_directions:
            print(f"Error: Invalid direction_char '{direction_char}'. Must be one of {valid_directions}.")
            return None

        if cursor_cell_id not in self.cells:
            print(f"Error: Cursor cell with ID '{cursor_cell_id}' not found.")
            return None

        current_dim_cell_id: Optional[str] = self.cell_nbr(cursor_cell_id, "+d.1") # X-axis dim cell

        if current_dim_cell_id is None:
            print(f"Warning: Cursor '{cursor_cell_id}' has no +d.1 link to X-axis dimension cell.")
            return None
        if current_dim_cell_id not in self.cells:
             print(f"Error: X-axis dimension cell ID '{current_dim_cell_id}' linked from '{cursor_cell_id}' not found.")
             return None

        if direction_char == 'L':
            content = self.cell_get(current_dim_cell_id)
            return self._reverse_dimension_sign(content) if content is not None else None
        if direction_char == 'R':
            return self.cell_get(current_dim_cell_id)

        current_dim_cell_id = self.cell_nbr(current_dim_cell_id, "+d.1") # Y-axis dim cell
        if current_dim_cell_id is None:
            print(f"Warning: X-axis dimension cell has no +d.1 link to Y-axis dimension cell.")
            return None
        if current_dim_cell_id not in self.cells:
             print(f"Error: Y-axis dimension cell ID '{current_dim_cell_id}' not found.")
             return None

        if direction_char == 'U':
            content = self.cell_get(current_dim_cell_id)
            return self._reverse_dimension_sign(content) if content is not None else None
        if direction_char == 'D':
            return self.cell_get(current_dim_cell_id)

        current_dim_cell_id = self.cell_nbr(current_dim_cell_id, "+d.1") # Z-axis dim cell
        if current_dim_cell_id is None:
            print(f"Warning: Y-axis dimension cell has no +d.1 link to Z-axis dimension cell.")
            return None
        if current_dim_cell_id not in self.cells:
             print(f"Error: Z-axis dimension cell ID '{current_dim_cell_id}' not found.")
             return None
             
        if direction_char == 'I':
            content = self.cell_get(current_dim_cell_id)
            return self._reverse_dimension_sign(content) if content is not None else None
        if direction_char == 'O':
            return self.cell_get(current_dim_cell_id)
        
        return None # Should be covered by initial direction check, but as a fallback.

    def get_distance(self, start_cell_id: str, dimension_name_with_sign: str, end_cell_id: str) -> Optional[int]:
        """Calculates the distance between two cells along a specific dimension."""
        if start_cell_id not in self.cells:
            print(f"Error: Start cell with ID '{start_cell_id}' not found.")
            return None
        if end_cell_id not in self.cells:
            print(f"Error: End cell with ID '{end_cell_id}' not found.")
            return None

        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return None

        if start_cell_id == end_cell_id:
            return 0

        distance = 1
        current_cell_id: Optional[str] = self.cell_nbr(start_cell_id, dimension_name_with_sign)
        visited_cells: Set[str] = {start_cell_id}
        max_distance = len(self.cells) + 1 # Safety break

        while current_cell_id is not None and distance <= max_distance :
            if current_cell_id == end_cell_id:
                return distance
            if current_cell_id == start_cell_id: # Full loop without finding end_cell_id
                print(f"Warning: Loop detected (back to start_cell_id) while calculating distance from '{start_cell_id}' to '{end_cell_id}'.")
                return None
            if current_cell_id in visited_cells: # Other loop detected
                print(f"Warning: Loop detected (cell '{current_cell_id}' already visited) while calculating distance.")
                return None
            
            visited_cells.add(current_cell_id)
            current_cell_id = self.cell_nbr(current_cell_id, dimension_name_with_sign)
            distance += 1
        
        if distance > max_distance:
            print(f"Warning: Exceeded max distance search ({max_distance}) from '{start_cell_id}' to '{end_cell_id}'.")

        return None # end_cell_id not found

    def get_outline_parent(self, cell_id: str) -> Optional[str]:
        """Finds the 'outline parent' of a cell by traversing -d.2 and looking for a -d.1 link."""
        if cell_id not in self.cells:
            print(f"Error: Cell with ID '{cell_id}' not found.")
            return None

        current_cell_id: str = cell_id
        original_cell_id: str = cell_id
        visited_cells: Set[str] = {current_cell_id}

        # Check current cell for -d.1 link first
        link_d1_neg = self.cell_nbr(current_cell_id, "-d.1")
        if link_d1_neg is not None:
            return link_d1_neg

        # Traverse along -d.2
        while True:
            next_cell_in_d2_neg = self.cell_nbr(current_cell_id, "-d.2")

            if next_cell_in_d2_neg is None:
                break # Reached end of -d.2 chain
            if next_cell_in_d2_neg == original_cell_id: # Looped back to the very start
                break 
            if next_cell_in_d2_neg in visited_cells: # Detected a cycle in the -d.2 chain
                break
            
            current_cell_id = next_cell_in_d2_neg
            visited_cells.add(current_cell_id)

            link_d1_neg = self.cell_nbr(current_cell_id, "-d.1")
            if link_d1_neg is not None:
                return link_d1_neg
        
        # If loop finishes, we didn't find a "-d.1" link by traversing "-d.2".
        # The Perl code implies returning the cell itself if no "-d.1" link is found on the path.
        # The final current_cell_id is where the -d.2 traversal stopped.
        # So, we return current_cell_id as per the logic: "return $cell" (which is current_cell_id here)
        return current_cell_id

    def cells_row(self, start_cell_id: str, dimension_name_with_sign: str) -> list[str]:
        """Collects all cell IDs in a row along a dimension, starting from start_cell_id."""
        if start_cell_id not in self.cells:
            print(f"Error: Start cell with ID '{start_cell_id}' not found.")
            return []

        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return []
        
        # Ensure the cell object itself exists, not just the ID in self.cells keys
        # This was an implicit check in the original prompt by checking self.cells.get(start_cell_id)
        # but since start_cell_id in self.cells already confirms it, this is fine.

        result_row: list[str] = [start_cell_id]
        current_cell_id: Optional[str] = self.cell_nbr(start_cell_id, dimension_name_with_sign)

        while current_cell_id is not None and current_cell_id != start_cell_id:
            if current_cell_id not in self.cells: # Safeguard against broken links
                print(f"Warning: Cell ID '{current_cell_id}' found in connections but not in main cells dictionary. Stopping row collection.")
                break
            result_row.append(current_cell_id)
            current_cell_id = self.cell_nbr(current_cell_id, dimension_name_with_sign)
            # Safety break for very long non-looping rows, though less critical than in get_distance
            if len(result_row) > len(self.cells) * 2 : # Arbitrary large number
                 print(f"Warning: cells_row exceeded safety limit for row length from {start_cell_id} along {dimension_name_with_sign}")
                 break

        return result_row

    def get_selection(self, selection_cursor_number: int) -> list[str]:
        """Gets the list of cell IDs in the specified selection."""
        if selection_cursor_number < 0:
            print("Error: Selection cursor number must be non-negative.")
            return []

        selection_head_cell_id: Optional[str] = SELECT_HOME_ID
        if SELECT_HOME_ID not in self.cells:
            print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot get selection.")
            return []

        for _ in range(selection_cursor_number):
            if selection_head_cell_id is None: 
                 print("Error: Internal error, selection_head_cell_id became None unexpectedly during cursor advance.")
                 return []
            current_selection_head_content = self.cells[selection_head_cell_id].content # For error reporting
            selection_head_cell_id = self.cell_nbr(selection_head_cell_id, "+d.2")
            if selection_head_cell_id is None :
                print(f"Error: Selection number {selection_cursor_number} is too high. Chain ended at cell '{current_selection_head_content}'.")
                return []
            if selection_head_cell_id not in self.cells:
                print(f"Error: Selection number {selection_cursor_number} is too high or selection structure broken. Next cell ID '{selection_head_cell_id}' not found.")
                return []
        
        if selection_head_cell_id: 
            first_selected_cell = self.cell_nbr(selection_head_cell_id, "+d.mark")
            if first_selected_cell is None:
                return [] 
            if first_selected_cell not in self.cells:
                print(f"Error: First selected cell ID '{first_selected_cell}' (from selection head '{selection_head_cell_id}') not found.")
                return []
            return self.cells_row(first_selected_cell, "+d.mark")
        
        return []

    def get_active_selection(self) -> list[str]:
        """Gets the list of cell IDs in the active selection (selection 0)."""
        return self.get_selection(0)

    def get_which_selection(self, cell_id: str) -> Optional[str]:
        """Determines which selection list a cell belongs to by finding the head of its -d.mark chain."""
        if cell_id not in self.cells:
            print(f"Error: Cell with ID '{cell_id}' not found.")
            return None
        
        # Check if the cell has an incoming -d.mark link.
        # This 'head_of_mark_chain' is actually the cell that *points to* cell_id via +d.mark,
        # or to which cell_id points via -d.mark.
        # The requirement is: head_of_mark_chain = self.cell_nbr(cell_id, "-d.mark")
        # This means we are looking for the cell that is one step "up" the -d.mark chain from cell_id.
        immediate_mark_parent = self.cell_nbr(cell_id, "-d.mark")
        
        if immediate_mark_parent is None:
            # This cell has no incoming -d.mark link, so it's the head of its own chain (or not in one).
            # It cannot be part of a selection list in the way this function defines it.
            return None
        
        # If it has an incoming -d.mark link, then find the ultimate head of this chain.
        return self.get_last_cell(cell_id, "-d.mark")

    def get_links_to(self, cell_id: str) -> list[str]:
        """Gets a list of formatted strings representing links pointing to the given cell."""
        if cell_id not in self.cells:
            print(f"Error: Cell with ID '{cell_id}' not found.")
            return []

        result_links: list[str] = []
        # Iterate over all known dimensions for consistency.
        # Using self.dimensions ensures we only check dimensions that have actually been created/used.
        sorted_dimensions = sorted(list(self.dimensions))

        for dim_name in sorted_dimensions:
            pos_dim = "+" + dim_name
            neg_dim = "-" + dim_name

            # Consider a cell X. If X --pos_dim--> cell_id, then cell_id must have cell_id --neg_dim--> X.
            # So, X = self.cell_nbr(cell_id, neg_dim).
            # The link from X to cell_id is X{pos_dim}.
            source_cell_via_its_pos_link = self.cell_nbr(cell_id, neg_dim)
            if source_cell_via_its_pos_link is not None:
                 result_links.append(f"{source_cell_via_its_pos_link}{pos_dim}")

            # Consider a cell Y. If Y --neg_dim--> cell_id, then cell_id must have cell_id --pos_dim--> Y.
            # So, Y = self.cell_nbr(cell_id, pos_dim).
            # The link from Y to cell_id is Y{neg_dim}.
            source_cell_via_its_neg_link = self.cell_nbr(cell_id, pos_dim)
            if source_cell_via_its_neg_link is not None:
                 result_links.append(f"{source_cell_via_its_neg_link}{neg_dim}")
        
        return sorted(list(set(result_links))) # Use set to remove duplicates, then sort.

    def is_cursor(self, cell_id: str) -> bool:
        """Checks if the cell is a cursor cell (has any d.cursor link)."""
        if cell_id not in self.cells:
            return False
        return (self.cell_nbr(cell_id, "-d.cursor") is not None) or \
               (self.cell_nbr(cell_id, "+d.cursor") is not None)

    def is_clone(self, cell_id: str) -> bool:
        """Checks if the cell is a clone (has an incoming +d.clone link, i.e., an outgoing -d.clone link)."""
        if cell_id not in self.cells:
            return False
        return self.cell_nbr(cell_id, "-d.clone") is not None

    def is_selected(self, cell_id: str) -> bool:
        """Checks if the cell is part of any selection list based on the Perl logic."""
        if cell_id not in self.cells: # Added check
            print(f"Error: Cell with ID '{cell_id}' not found for is_selected check.")
            return False

        head_cell = self.get_last_cell(cell_id, "-d.mark")
        
        if head_cell is None: # Should not happen if cell_id exists and get_last_cell is correct
            print(f"Warning: get_last_cell returned None for cell_id '{cell_id}' in is_selected.")
            return False
        
        if head_cell == cell_id: # Cell is head of its own mark chain or not in one.
            # According to the prompt's condition, this means it's not selected by this definition.
            return False
            
        # Check if this head_cell (the start of the -d.mark chain containing cell_id)
        # can reach SELECT_HOME_ID by traversing along "+d.2".
        distance_to_select_home = self.get_distance(head_cell, "+d.2", SELECT_HOME_ID)
        
        return distance_to_select_home is not None

    def is_active_selected(self, cell_id: str) -> bool:
        """Checks if the cell is part of the active selection list (selection 0)."""
        if cell_id not in self.cells: # Added check
            print(f"Error: Cell with ID '{cell_id}' not found for is_active_selected check.")
            return False
            
        head_cell = self.get_last_cell(cell_id, "-d.mark") 
        
        if head_cell is None: # Should not happen if cell_id exists.
            print(f"Warning: get_last_cell returned None for cell_id '{cell_id}' in is_active_selected.")
            return False
        
        # A cell is "active selected" if its -d.mark chain ultimate ancestor is SELECT_HOME_ID itself,
        # and the cell is not SELECT_HOME_ID.
        return head_cell == SELECT_HOME_ID and cell_id != SELECT_HOME_ID

    def _get_cursor_view_config_cell(self, cursor_cell_id: str, config_type: str) -> Optional[str]:
        """Helper to get the specific view-related cell for a cursor."""
        if not cursor_cell_id or cursor_cell_id not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: cursor_cell_id '{cursor_cell_id}' invalid or not found.")
            return None
        
        current_cell = self.cell_nbr(cursor_cell_id, "+d.1") # X-dim cell
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from {cursor_cell_id} -> {current_cell} (for X)")
        if config_type == "X": return current_cell
        if not current_cell or current_cell not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: X-dim cell '{current_cell}' invalid or not found.")
            return None
        
        current_cell = self.cell_nbr(current_cell, "+d.1") # Y-dim cell
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from X-dim cell -> {current_cell} (for Y)")
        if config_type == "Y": return current_cell
        if not current_cell or current_cell not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: Y-dim cell '{current_cell}' invalid or not found.")
            return None

        current_cell = self.cell_nbr(current_cell, "+d.1") # Z-dim cell
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from Y-dim cell -> {current_cell} (for Z)")
        if config_type == "Z": return current_cell
        if not current_cell or current_cell not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: Z-dim cell '{current_cell}' invalid or not found.")
            return None

        current_cell = self.cell_nbr(current_cell, "+d.1") # ViewStyle_cell (I, H, Q)
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from Z-dim cell -> {current_cell} (for Style)")
        if config_type == "Style": return current_cell
        # If looking for Style, and current_cell is None or not in cells, it will be caught by the caller.
        
        return None # Should not be reached if config_type is one of X, Y, Z, Style

    def view_quadrant_toggle(self, cursor_number: int) -> None:
        """Toggles the 'Q' (quadrant) suffix for the view style of a cursor."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        style_cell_id = self._get_cursor_view_config_cell(cursor_cell_id, "Style")
        if style_cell_id and style_cell_id in self.cells:
            current_style = self.cell_get(style_cell_id)
            if current_style is None: current_style = "I" # Default to "I" if no content

            if current_style.endswith("Q"):
                self.cell_set(style_cell_id, current_style[:-1])
            else:
                self.cell_set(style_cell_id, current_style + "Q")
            # display_dirty()
        else:
            print(f"Error: View style cell not found for cursor {cursor_number} (cell {cursor_cell_id}).")

    def view_raster_toggle(self, cursor_number: int) -> None:
        """Toggles the base view style (I/H) of a cursor, preserving Quadrant status."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        style_cell_id = self._get_cursor_view_config_cell(cursor_cell_id, "Style")
        if style_cell_id and style_cell_id in self.cells:
            current_style = self.cell_get(style_cell_id)
            if current_style is None: current_style = "I" 

            quadrant_suffix = "Q" if "Q" in current_style else ""
            base_style = current_style.replace("Q", "")

            if base_style == "I":
                self.cell_set(style_cell_id, "H" + quadrant_suffix)
            else: # Covers "H" or any other base style, defaults to "I"
                self.cell_set(style_cell_id, "I" + quadrant_suffix)
            # display_dirty()
        else:
            print(f"Error: View style cell not found for cursor {cursor_number} (cell {cursor_cell_id}).")

    def view_reset(self, cursor_number: int) -> None:
        """Resets the view dimensions (X,Y,Z) for a cursor to default d.1, d.2, d.3."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        x_dim_config_cell = self._get_cursor_view_config_cell(cursor_cell_id, "X")
        y_dim_config_cell = self._get_cursor_view_config_cell(cursor_cell_id, "Y")
        z_dim_config_cell = self._get_cursor_view_config_cell(cursor_cell_id, "Z")

        if CURSOR_HOME_ID not in self.cells: # CURSOR_HOME_ID is where the main dimension list head is attached
            print(f"Error: CURSOR_HOME_ID '{CURSOR_HOME_ID}' not found. Cannot find default dimensions.")
            return

        dim_list_head = self.cell_nbr(CURSOR_HOME_ID, "+d.1")
        if not dim_list_head or dim_list_head not in self.cells:
            print("Error: Default dimension list head (CURSOR_HOME_ID -> +d.1) not found.")
            return
        
        d1_content = self.cell_get(dim_list_head)
        if d1_content is None: d1_content = "d.1" # Fallback, though should be set

        dim_list_next = self.cell_nbr(dim_list_head, "+d.2")
        if not dim_list_next or dim_list_next not in self.cells:
            print(f"Error: Default dimension list (for d.2) broken after cell {dim_list_head}.")
            return
        d2_content = self.cell_get(dim_list_next)
        if d2_content is None: d2_content = "d.2" # Fallback

        dim_list_next_next = self.cell_nbr(dim_list_next, "+d.2")
        if not dim_list_next_next or dim_list_next_next not in self.cells:
            print(f"Error: Default dimension list (for d.3) broken after cell {dim_list_next}.")
            return
        d3_content = self.cell_get(dim_list_next_next)
        if d3_content is None: d3_content = "d.3" # Fallback
        
        # The prompt doesn't explicitly state to check if d1, d2, d3 are None from cell_get,
        # but it's good practice. However, the structure relies on these cells having content.
        # The error "Default dimensions not found" seems to refer to the structure being broken.

        if x_dim_config_cell and x_dim_config_cell in self.cells:
            self.cell_set(x_dim_config_cell, "+" + d1_content)
        if y_dim_config_cell and y_dim_config_cell in self.cells:
            self.cell_set(y_dim_config_cell, "+" + d2_content)
        if z_dim_config_cell and z_dim_config_cell in self.cells:
            self.cell_set(z_dim_config_cell, "+" + d3_content)
        # display_dirty()

    def view_rotate(self, cursor_number: int, axis_char: str) -> None:
        """Rotates the dimension used for a specific view axis (X, Y, or Z)."""
        valid_axis_chars = {'X', 'Y', 'Z'}
        if axis_char not in valid_axis_chars:
            print(f"Error: Invalid axis_char '{axis_char}'. Must be one of {valid_axis_chars}.")
            return

        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        dim_config_cell_to_rotate = self._get_cursor_view_config_cell(cursor_cell_id, axis_char)
        if not dim_config_cell_to_rotate or dim_config_cell_to_rotate not in self.cells:
            print(f"Error: Dimension config cell for axis '{axis_char}' not found for cursor {cursor_number}.")
            return

        current_dim_setting = self.cell_get(dim_config_cell_to_rotate)
        if current_dim_setting is None:
            print(f"Error: Dimension config cell '{dim_config_cell_to_rotate}' has no content.")
            return

        sign = current_dim_setting[0] if current_dim_setting and current_dim_setting[0] in ['+', '-'] else '+'
        base_dim_name = self._get_base_dimension(current_dim_setting)

        dim_list_cell = self.dimension_find(base_dim_name) # Cell whose content is base_dim_name
        if not dim_list_cell:
            print(f"Error: Base dimension '{base_dim_name}' not found in dimension list.")
            return

        next_dim_list_cell = self.cell_nbr(dim_list_cell, "+d.2")
        
        dimension_home_cell = self.dimension_home() # Typically CURSOR_HOME_ID
        if not dimension_home_cell:
             print("Error: Dimension home (CURSOR_HOME_ID) not found, cannot determine start of dimension list.")
             return

        # If next_dim_list_cell is None (end of list) or if it's the dimension_home cell itself (which is not a dim)
        if not next_dim_list_cell or next_dim_list_cell == dimension_home_cell: 
            # Loop back to the first dimension in the list (the one linked from CURSOR_HOME_ID by +d.1)
            next_dim_list_cell = self.cell_nbr(dimension_home_cell, "+d.1")
        
        if next_dim_list_cell and next_dim_list_cell in self.cells:
            new_base_dim = self.cell_get(next_dim_list_cell)
            if new_base_dim:
                self.cell_set(dim_config_cell_to_rotate, sign + new_base_dim)
                # display_dirty()
            else:
                print(f"Error: Next dimension cell '{next_dim_list_cell}' has no content.")
        else:
            print("Error: Cannot find next dimension in list for rotation.")

    def view_flip(self, cursor_number: int, axis_char: str) -> None:
        """Flips the sign of the dimension used for a specific view axis (X, Y, or Z)."""
        valid_axis_chars = {'X', 'Y', 'Z'}
        if axis_char not in valid_axis_chars:
            print(f"Error: Invalid axis_char '{axis_char}'. Must be one of {valid_axis_chars}.")
            return

        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        dim_config_cell_to_flip = self._get_cursor_view_config_cell(cursor_cell_id, axis_char)
        if not dim_config_cell_to_flip or dim_config_cell_to_flip not in self.cells:
            print(f"Error: Dimension config cell for axis '{axis_char}' not found for cursor {cursor_number}.")
            return

        current_dim_setting = self.cell_get(dim_config_cell_to_flip)
        if current_dim_setting:
            self.cell_set(dim_config_cell_to_flip, self._reverse_dimension_sign(current_dim_setting))
            # display_dirty()
        else:
            print(f"Error: Dimension config cell '{dim_config_cell_to_flip}' has no content to flip.")

    def layout_cells_horizontal(self, layout_data: Dict[str, Any], start_cell_id: str, 
                                y_coord: int, dimension_name_with_sign: str, 
                                x_sign: int, max_x_half: int) -> None:
        """Helper to lay out cells horizontally from a starting point."""
        current_cell_id = start_cell_id
        for i in range(1, max_x_half + 1):
            next_cell_id = self.cell_nbr(current_cell_id, dimension_name_with_sign)
            
            if next_cell_id is None or next_cell_id not in self.cells:
                break
            # Check for loop back to start_cell_id on the very first step if the chain is just start_cell_id <--> next_cell_id (which is start_cell_id)
            if next_cell_id == start_cell_id and i == 1 and current_cell_id == start_cell_id : # e.g. 0 linked to 0
                 if self.cell_nbr(start_cell_id, dimension_name_with_sign) == start_cell_id : # Confirmed self-loop on start
                    break

            prev_x_coord = (i - 1) * x_sign if i > 1 else 0 # x_coord of current_cell_id, or 0 if current_cell_id is start_cell_id
            if current_cell_id == start_cell_id and i == 1: # Special case for the first step from center
                 prev_x_coord = 0


            current_cell_id = next_cell_id # Advance to the new cell
            x_coord = x_sign * i
            
            layout_data[f"{x_coord},{y_coord}"] = current_cell_id
            # Link from previous cell in this horizontal scan to the current cell
            # If x_sign is positive (rightward), link is from (x-1) to (x)
            # If x_sign is negative (leftward), link is from (x+1) to (x)
            # The prev_x_coord needs to be calculated relative to the direction
            link_prev_x = x_coord - x_sign 
            layout_data[f"link:{link_prev_x},{y_coord}:to:{x_coord},{y_coord}"] = dimension_name_with_sign
            
            if current_cell_id == start_cell_id and i > 0: # Completed a loop back to the start_cell_id (not the first step)
                break

    def layout_cells_vertical(self, layout_data: Dict[str, Any], start_cell_id: str, 
                              x_coord: int, dimension_name_with_sign: str, 
                              y_sign: int, max_y_half: int) -> None:
        """Helper to lay out cells vertically from a starting point."""
        current_cell_id = start_cell_id
        for i in range(1, max_y_half + 1):
            next_cell_id = self.cell_nbr(current_cell_id, dimension_name_with_sign)

            if next_cell_id is None or next_cell_id not in self.cells:
                break
            if next_cell_id == start_cell_id and i == 1 and current_cell_id == start_cell_id :
                 if self.cell_nbr(start_cell_id, dimension_name_with_sign) == start_cell_id :
                    break

            current_cell_id = next_cell_id
            y_coord = y_sign * i
            
            layout_data[f"{x_coord},{y_coord}"] = current_cell_id
            link_prev_y = y_coord - y_sign
            layout_data[f"link:{x_coord},{link_prev_y}:to:{x_coord},{y_coord}"] = dimension_name_with_sign

            if current_cell_id == start_cell_id and i > 0:
                break

    def layout_preview(self, center_cell_id: str, right_dim: str, down_dim: str, 
                       Hcells: int, Vcells: int) -> Dict[str, Any]:
        """Generates a 'preview' layout (cross shape)."""
        if center_cell_id not in self.cells:
            print(f"Error: Center cell ID '{center_cell_id}' not found for layout_preview.")
            return {}
        
        layout_data: Dict[str, Any] = {"0,0": center_cell_id}
        
        if not (right_dim.startswith('+') or right_dim.startswith('-')):
            print(f"Error: right_dim '{right_dim}' must start with '+' or '-'.")
            return layout_data # Return what we have so far (just center)
        if not (down_dim.startswith('+') or down_dim.startswith('-')):
            print(f"Error: down_dim '{down_dim}' must start with '+' or '-'.")
            return layout_data

        left_dim = self._reverse_dimension_sign(right_dim)
        up_dim = self._reverse_dimension_sign(down_dim)

        self.layout_cells_horizontal(layout_data, center_cell_id, 0, left_dim, -1, Hcells // 2)
        self.layout_cells_horizontal(layout_data, center_cell_id, 0, right_dim, 1, Hcells // 2)
        self.layout_cells_vertical(layout_data, center_cell_id, 0, up_dim, -1, Vcells // 2)
        self.layout_cells_vertical(layout_data, center_cell_id, 0, down_dim, 1, Vcells // 2)
        
        return layout_data

    def layout_Iraster(self, center_cell_id: str, right_dim: str, down_dim: str, 
                       Hcells: int, Vcells: int) -> Dict[str, Any]:
        """Generates an 'I-raster' layout (scan vertically, then horizontally for each row)."""
        if center_cell_id not in self.cells:
            print(f"Error: Center cell ID '{center_cell_id}' not found for layout_Iraster.")
            return {}

        layout_data: Dict[str, Any] = {"0,0": center_cell_id}

        if not (right_dim.startswith('+') or right_dim.startswith('-')):
            print(f"Error: right_dim '{right_dim}' must start with '+' or '-'.")
            return layout_data
        if not (down_dim.startswith('+') or down_dim.startswith('-')):
            print(f"Error: down_dim '{down_dim}' must start with '+' or '-'.")
            return layout_data
            
        left_dim = self._reverse_dimension_sign(right_dim)
        up_dim = self._reverse_dimension_sign(down_dim)

        # Central horizontal row (already includes center_cell_id at 0,0)
        self.layout_cells_horizontal(layout_data, center_cell_id, 0, left_dim, -1, Hcells // 2)
        self.layout_cells_horizontal(layout_data, center_cell_id, 0, right_dim, 1, Hcells // 2)

        current_row_center_id = center_cell_id
        for y in range(1, Vcells // 2 + 1): # Upwards rows
            next_row_cell_id = self.cell_nbr(current_row_center_id, up_dim)
            if next_row_cell_id is None or next_row_cell_id not in self.cells:
                break
            
            prev_y_for_link = -(y-1)
            current_row_center_id = next_row_cell_id
            layout_data[f"0,{-y}"] = current_row_center_id
            layout_data[f"link:0,{prev_y_for_link}:to:0,{-y}"] = up_dim
            
            self.layout_cells_horizontal(layout_data, current_row_center_id, -y, left_dim, -1, Hcells // 2)
            self.layout_cells_horizontal(layout_data, current_row_center_id, -y, right_dim, 1, Hcells // 2)
            if current_row_center_id == center_cell_id and y > 0: break 

        current_row_center_id = center_cell_id
        for y in range(1, Vcells // 2 + 1): # Downwards rows
            next_row_cell_id = self.cell_nbr(current_row_center_id, down_dim)
            if next_row_cell_id is None or next_row_cell_id not in self.cells:
                break

            prev_y_for_link = y-1
            current_row_center_id = next_row_cell_id
            layout_data[f"0,{y}"] = current_row_center_id
            layout_data[f"link:0,{prev_y_for_link}:to:0,{y}"] = down_dim

            self.layout_cells_horizontal(layout_data, current_row_center_id, y, left_dim, -1, Hcells // 2)
            self.layout_cells_horizontal(layout_data, current_row_center_id, y, right_dim, 1, Hcells // 2)
            if current_row_center_id == center_cell_id and y > 0: break
            
        return layout_data

    def layout_Hraster(self, center_cell_id: str, right_dim: str, down_dim: str, 
                       Hcells: int, Vcells: int) -> Dict[str, Any]:
        """Generates an 'H-raster' layout (scan horizontally, then vertically for each column)."""
        if center_cell_id not in self.cells:
            print(f"Error: Center cell ID '{center_cell_id}' not found for layout_Hraster.")
            return {}

        layout_data: Dict[str, Any] = {"0,0": center_cell_id}

        if not (right_dim.startswith('+') or right_dim.startswith('-')):
            print(f"Error: right_dim '{right_dim}' must start with '+' or '-'.")
            return layout_data
        if not (down_dim.startswith('+') or down_dim.startswith('-')):
            print(f"Error: down_dim '{down_dim}' must start with '+' or '-'.")
            return layout_data

        left_dim = self._reverse_dimension_sign(right_dim)
        up_dim = self._reverse_dimension_sign(down_dim)

        # Central vertical column (already includes center_cell_id at 0,0)
        self.layout_cells_vertical(layout_data, center_cell_id, 0, up_dim, -1, Vcells // 2)
        self.layout_cells_vertical(layout_data, center_cell_id, 0, down_dim, 1, Vcells // 2)

        current_col_center_id = center_cell_id
        for x in range(1, Hcells // 2 + 1): # Leftwards columns
            next_col_cell_id = self.cell_nbr(current_col_center_id, left_dim)
            if next_col_cell_id is None or next_col_cell_id not in self.cells:
                break
            
            prev_x_for_link = -(x-1)
            current_col_center_id = next_col_cell_id
            layout_data[f"{-x},0"] = current_col_center_id
            layout_data[f"link:{prev_x_for_link},0:to:{-x},0"] = left_dim

            self.layout_cells_vertical(layout_data, current_col_center_id, -x, up_dim, -1, Vcells // 2)
            self.layout_cells_vertical(layout_data, current_col_center_id, -x, down_dim, 1, Vcells // 2)
            if current_col_center_id == center_cell_id and x > 0: break

        current_col_center_id = center_cell_id
        for x in range(1, Hcells // 2 + 1): # Rightwards columns
            next_col_cell_id = self.cell_nbr(current_col_center_id, right_dim)
            if next_col_cell_id is None or next_col_cell_id not in self.cells:
                break
            
            prev_x_for_link = x-1
            current_col_center_id = next_col_cell_id
            layout_data[f"{x},0"] = current_col_center_id
            layout_data[f"link:{prev_x_for_link},0:to:{x},0"] = right_dim
            
            self.layout_cells_vertical(layout_data, current_col_center_id, x, up_dim, -1, Vcells // 2)
            self.layout_cells_vertical(layout_data, current_col_center_id, x, down_dim, 1, Vcells // 2)
            if current_col_center_id == center_cell_id and x > 0: break
            
        return layout_data

    def atcursor_clone(self, cursor_number: int, operation_type: str = 'clone') -> None:
        """Clones or copies cells from the active selection (or accursed cell) and updates cursor."""
        cursor_cell_id = self.get_cursor(cursor_number)
        # Although cursor_cell_id is fetched, it's only used at the end to jump.
        # The primary operations depend on accursed_cell_id and the selection.

        accursed_cell_id = self.get_accursed(cursor_number)
        # If no accursed_cell_id, and no selection, then there's nothing to clone/copy.
        # get_accursed prints errors if cursor_cell_id is None or invalid.

        selection = self.get_active_selection()

        if not selection:
            if accursed_cell_id:
                selection = [accursed_cell_id]
            else:
                print("Error: No cell accursed or selected to clone/copy.")
                return
        
        if not selection: # Should be redundant if above logic is correct, but as a safeguard.
            print("Error: No cells to process for clone/copy.")
            return

        new_cell_ids_map: Dict[str, str] = {}
        last_new_cell_id: Optional[str] = None

        for original_cell_id in selection:
            if original_cell_id not in self.cells: # Ensure original cell exists
                print(f"Warning: Cell {original_cell_id} in selection not found, skipping.")
                continue

            new_id = self.cell_new() # Creates cell with default content (its own ID)
            new_cell_ids_map[original_cell_id] = new_id

            if operation_type == 'clone':
                self.cell_set(new_id, f"Clone of {original_cell_id}")
                # cell_insert will link original_cell_id -- "+d.clone" --> new_id
                self.cell_insert(new_id, original_cell_id, "+d.clone")
            else: # operation_type == 'copy'
                original_content = self.cell_get(original_cell_id)
                # The content of the new cell is "Copy of <original_content>"
                # or "Copy of cell <original_cell_id>" if original_content is None
                self.cell_set(new_id, f"Copy of {original_content}" if original_content is not None else f"Copy of cell {original_cell_id}")
            
            last_new_cell_id = new_id

        if operation_type == 'copy':
            for original_cell_id in selection:
                new_copied_cell_id = new_cell_ids_map.get(original_cell_id)
                if new_copied_cell_id is None: # Original cell might have been skipped if not found
                    continue
                
                original_cell_obj = self.cells.get(original_cell_id)
                if original_cell_obj is None: # Should not happen if selection elements are validated
                    continue

                for dim_link, linked_original_id in original_cell_obj.connections.items():
                    # Only replicate links if the target of the link was also part of the selection
                    if linked_original_id in new_cell_ids_map:
                        new_target_id = new_cell_ids_map[linked_original_id]
                        # Ensure both new_copied_cell_id and new_target_id are valid before linking
                        if new_copied_cell_id in self.cells and new_target_id in self.cells:
                             self.link_make(new_copied_cell_id, new_target_id, dim_link)
                        # else: print(f"Warning: Could not make link between new cells {new_copied_cell_id} and {new_target_id}, one or both missing.")
        
        if last_new_cell_id and cursor_cell_id:
            # Ensure last_new_cell_id is valid before jumping
            if last_new_cell_id in self.cells:
                 self.cursor_jump(cursor_cell_id, last_new_cell_id)
            # else: print(f"Warning: last_new_cell_id '{last_new_cell_id}' not found, cannot jump cursor.")
        # display_dirty()

    def atcursor_copy(self, cursor_number: int) -> None:
        """Copies the selected cells (or accursed cell) and their internal links."""
        self.atcursor_clone(cursor_number, operation_type='copy')

    def atcursor_shear(self, cursor_number: int, shear_direction_char: str, link_direction_char: str) -> None:
        """Performs a shear operation on the row of cells starting at the accursed cell."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None:
            return

        head_cell_for_shear = self.get_accursed(cursor_number)
        if head_cell_for_shear is None:
            print(f"Error: Cursor (number {cursor_number}, cell {cursor_cell_id}) is not pointing to any cell for shear operation.")
            return

        shear_dimension = self.get_dimension(cursor_cell_id, shear_direction_char)
        if shear_dimension is None:
            # Error already printed by get_dimension
            return

        link_dimension = self.get_dimension(cursor_cell_id, link_direction_char)
        if link_dimension is None:
            # Error already printed by get_dimension
            return
        
        # Default n=1, hang=False as per Perl's typical usage for this kind of shear
        self.do_shear(head_cell_for_shear, shear_dimension, link_dimension, n=1, hang=False)
        # display_dirty() or equivalent would be called here.

    def _get_cursor_view_config_cell(self, cursor_cell_id: str, config_type: str) -> Optional[str]:
        """Helper to get the specific view-related cell for a cursor."""
        if not cursor_cell_id or cursor_cell_id not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: cursor_cell_id '{cursor_cell_id}' invalid or not found.")
            return None
        
        current_cell = self.cell_nbr(cursor_cell_id, "+d.1") # X-dim cell
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from {cursor_cell_id} -> {current_cell} (for X)")
        if config_type == "X": return current_cell
        if not current_cell or current_cell not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: X-dim cell '{current_cell}' invalid or not found.")
            return None
        
        current_cell = self.cell_nbr(current_cell, "+d.1") # Y-dim cell
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from X-dim cell -> {current_cell} (for Y)")
        if config_type == "Y": return current_cell
        if not current_cell or current_cell not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: Y-dim cell '{current_cell}' invalid or not found.")
            return None

        current_cell = self.cell_nbr(current_cell, "+d.1") # Z-dim cell
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from Y-dim cell -> {current_cell} (for Z)")
        if config_type == "Z": return current_cell
        if not current_cell or current_cell not in self.cells: 
            # print(f"Debug: _get_cursor_view_config_cell: Z-dim cell '{current_cell}' invalid or not found.")
            return None

        current_cell = self.cell_nbr(current_cell, "+d.1") # ViewStyle_cell (I, H, Q)
        # print(f"Debug: _get_cursor_view_config_cell: after +d.1 from Z-dim cell -> {current_cell} (for Style)")
        if config_type == "Style": return current_cell
        # If looking for Style, and current_cell is None or not in cells, it will be caught by the caller.
        
        return None # Should not be reached if config_type is one of X, Y, Z, Style

    def view_quadrant_toggle(self, cursor_number: int) -> None:
        """Toggles the 'Q' (quadrant) suffix for the view style of a cursor."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        style_cell_id = self._get_cursor_view_config_cell(cursor_cell_id, "Style")
        if style_cell_id and style_cell_id in self.cells:
            current_style = self.cell_get(style_cell_id)
            if current_style is None: current_style = "I" # Default to "I" if no content

            if current_style.endswith("Q"):
                self.cell_set(style_cell_id, current_style[:-1])
            else:
                self.cell_set(style_cell_id, current_style + "Q")
            # display_dirty()
        else:
            print(f"Error: View style cell not found for cursor {cursor_number} (cell {cursor_cell_id}).")

    def view_raster_toggle(self, cursor_number: int) -> None:
        """Toggles the base view style (I/H) of a cursor, preserving Quadrant status."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        style_cell_id = self._get_cursor_view_config_cell(cursor_cell_id, "Style")
        if style_cell_id and style_cell_id in self.cells:
            current_style = self.cell_get(style_cell_id)
            if current_style is None: current_style = "I" 

            quadrant_suffix = "Q" if "Q" in current_style else ""
            base_style = current_style.replace("Q", "")

            if base_style == "I":
                self.cell_set(style_cell_id, "H" + quadrant_suffix)
            else: # Covers "H" or any other base style, defaults to "I"
                self.cell_set(style_cell_id, "I" + quadrant_suffix)
            # display_dirty()
        else:
            print(f"Error: View style cell not found for cursor {cursor_number} (cell {cursor_cell_id}).")

    def view_reset(self, cursor_number: int) -> None:
        """Resets the view dimensions (X,Y,Z) for a cursor to default d.1, d.2, d.3."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        x_dim_config_cell = self._get_cursor_view_config_cell(cursor_cell_id, "X")
        y_dim_config_cell = self._get_cursor_view_config_cell(cursor_cell_id, "Y")
        z_dim_config_cell = self._get_cursor_view_config_cell(cursor_cell_id, "Z")

        if CURSOR_HOME_ID not in self.cells:
            print(f"Error: CURSOR_HOME_ID '{CURSOR_HOME_ID}' not found. Cannot find default dimensions.")
            return

        dim_list_head = self.cell_nbr(CURSOR_HOME_ID, "+d.1")
        if not dim_list_head or dim_list_head not in self.cells:
            print("Error: Default dimension list head (CURSOR_HOME_ID -> +d.1) not found.")
            return
        
        d1 = self.cell_get(dim_list_head)

        dim_list_next = self.cell_nbr(dim_list_head, "+d.2")
        if not dim_list_next or dim_list_next not in self.cells:
            print(f"Error: Default dimension list (for d.2) broken after cell {dim_list_head}.")
            return
        d2 = self.cell_get(dim_list_next)

        dim_list_next_next = self.cell_nbr(dim_list_next, "+d.2")
        if not dim_list_next_next or dim_list_next_next not in self.cells:
            print(f"Error: Default dimension list (for d.3) broken after cell {dim_list_next}.")
            return
        d3 = self.cell_get(dim_list_next_next)
        
        if not (d1 and d2 and d3): # Check if any content is None or empty string
            print("Error: Default dimensions (d.1, d.2, or d.3 content) not found or empty in dimension list.")
            return

        if x_dim_config_cell and x_dim_config_cell in self.cells:
            self.cell_set(x_dim_config_cell, "+" + d1)
        if y_dim_config_cell and y_dim_config_cell in self.cells:
            self.cell_set(y_dim_config_cell, "+" + d2)
        if z_dim_config_cell and z_dim_config_cell in self.cells:
            self.cell_set(z_dim_config_cell, "+" + d3)
        # display_dirty()

    def view_rotate(self, cursor_number: int, axis_char: str) -> None:
        """Rotates the dimension used for a specific view axis (X, Y, or Z)."""
        valid_axis_chars = {'X', 'Y', 'Z'}
        if axis_char not in valid_axis_chars:
            print(f"Error: Invalid axis_char '{axis_char}'. Must be one of {valid_axis_chars}.")
            return

        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        dim_config_cell_to_rotate = self._get_cursor_view_config_cell(cursor_cell_id, axis_char)
        if not dim_config_cell_to_rotate or dim_config_cell_to_rotate not in self.cells:
            print(f"Error: Dimension config cell for axis '{axis_char}' not found for cursor {cursor_number}.")
            return

        current_dim_setting = self.cell_get(dim_config_cell_to_rotate)
        if current_dim_setting is None:
            print(f"Error: Dimension config cell '{dim_config_cell_to_rotate}' has no content.")
            return

        sign = current_dim_setting[0] if current_dim_setting and current_dim_setting[0] in ['+', '-'] else '+'
        base_dim_name = self._get_base_dimension(current_dim_setting)

        dim_list_cell = self.dimension_find(base_dim_name) 
        if not dim_list_cell:
            print(f"Error: Base dimension '{base_dim_name}' not found in dimension list.")
            return

        next_dim_list_cell = self.cell_nbr(dim_list_cell, "+d.2")
        
        dimension_home_found = self.dimension_home() 
        if not dimension_home_found:
             print("Error: Dimension home (CURSOR_HOME_ID) not found, cannot determine start of dimension list for rotation loop.")
             return

        if not next_dim_list_cell or next_dim_list_cell == dimension_home_found: 
            next_dim_list_cell = self.cell_nbr(dimension_home_found, "+d.1")
        
        if next_dim_list_cell and next_dim_list_cell in self.cells:
            new_base_dim = self.cell_get(next_dim_list_cell)
            if new_base_dim:
                self.cell_set(dim_config_cell_to_rotate, sign + new_base_dim)
                # display_dirty()
            else:
                print(f"Error: Next dimension cell '{next_dim_list_cell}' has no content.")
        else:
            print("Error: Cannot find next dimension in list for rotation.")

    def view_flip(self, cursor_number: int, axis_char: str) -> None:
        """Flips the sign of the dimension used for a specific view axis (X, Y, or Z)."""
        valid_axis_chars = {'X', 'Y', 'Z'}
        if axis_char not in valid_axis_chars:
            print(f"Error: Invalid axis_char '{axis_char}'. Must be one of {valid_axis_chars}.")
            return

        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        dim_config_cell_to_flip = self._get_cursor_view_config_cell(cursor_cell_id, axis_char)
        if not dim_config_cell_to_flip or dim_config_cell_to_flip not in self.cells:
            print(f"Error: Dimension config cell for axis '{axis_char}' not found for cursor {cursor_number}.")
            return

        current_dim_setting = self.cell_get(dim_config_cell_to_flip)
        if current_dim_setting:
            self.cell_set(dim_config_cell_to_flip, self._reverse_dimension_sign(current_dim_setting))
            # display_dirty()
        else:
            print(f"Error: Dimension config cell '{dim_config_cell_to_flip}' has no content to flip.")

    def get_contained(self, start_cell_id: str) -> list[str]:
        """
        Retrieves a list of cell IDs "contained" within a given start_cell_id.
        Aims to replicate the logic of Perl's get_contained/add_contents.
        1. Includes the start_cell_id.
        2. Traverses the +d.inside chain from start_cell_id. Each cell in this chain is added.
        3. For each cell added from the +d.inside chain, its +d.contents chain is traversed.
           Items from +d.contents are added (and recursed upon) only if they are not
           container heads themselves (i.e., no -d.inside link).
        Returns a list of unique cell IDs in the order they were visited.
        """
        if start_cell_id not in self.cells:
            # Though other methods raise CellNotFoundError, problem statement for previous
            # get_contained asked for print and empty list. Keep for now unless specified.
            print(f"Error: Cell '{start_cell_id}' not found for get_contained.")
            return []

        output_list: list[str] = []
        # globally_visited is used to ensure each cell is added to output_list only once
        # and to prevent reprocessing in recursive calls.
        globally_visited: set[str] = set()

        # This is the direct translation of Perl's add_contents
        def _add_contents_recursive_inner(current_start_node_id: str) -> None:
            # This function processes current_start_node_id, then its .insides,
            # and for each of those .insides, their .contents.
            
            if current_start_node_id not in self.cells: # Safety check
                print(f"Warning (get_contained): Cell ID '{current_start_node_id}' in traversal not found.")
                return

            # Add current_start_node_id to results if not already processed
            if current_start_node_id not in globally_visited:
                output_list.append(current_start_node_id)
                globally_visited.add(current_start_node_id)
            else: # If already visited (e.g. start_cell_id passed again), do not reprocess its children from this path
                return

            # Iterate through the +d.inside chain of current_start_node_id
            cell_in_inside_chain = self.cell_nbr(current_start_node_id, "+d.inside")
            visited_this_inside_chain: set[str] = {current_start_node_id} 

            while cell_in_inside_chain is not None and \
                  cell_in_inside_chain not in visited_this_inside_chain:
                
                if cell_in_inside_chain not in self.cells: # Broken chain
                    print(f"Warning (get_contained): Cell ID '{cell_in_inside_chain}' in +d.inside chain not found.")
                    break 
                visited_this_inside_chain.add(cell_in_inside_chain)

                # Add this cell from .inside chain to results (if not already globally processed)
                if cell_in_inside_chain not in globally_visited:
                    output_list.append(cell_in_inside_chain)
                    globally_visited.add(cell_in_inside_chain)
                
                # For this cell_in_inside_chain, process its +d.contents chain
                item_in_contents_chain = self.cell_nbr(cell_in_inside_chain, "+d.contents")
                visited_this_contents_chain: set[str] = {cell_in_inside_chain}

                while item_in_contents_chain is not None and \
                      item_in_contents_chain not in visited_this_contents_chain:
                    
                    if item_in_contents_chain not in self.cells: # Broken chain
                        print(f"Warning (get_contained): Cell ID '{item_in_contents_chain}' in +d.contents chain not found.")
                        break
                    visited_this_contents_chain.add(item_in_contents_chain)

                    # Process only if not globally visited AND it's not a container head itself
                    if item_in_contents_chain not in globally_visited and \
                       self.cell_nbr(item_in_contents_chain, "-d.inside") is None:
                        _add_contents_recursive_inner(item_in_contents_chain) # Recurse for this item
                    elif item_in_contents_chain not in globally_visited:
                        # If it's a container head but not globally visited, add it to list.
                        # Its own .inside/.contents will be handled if it's visited via an .inside chain path.
                        output_list.append(item_in_contents_chain)
                        globally_visited.add(item_in_contents_chain)
                        
                    item_in_contents_chain = self.cell_nbr(item_in_contents_chain, "+d.contents")
                
                cell_in_inside_chain = self.cell_nbr(cell_in_inside_chain, "+d.inside")
        
        # Initial call to the recursive helper for the start_cell_id
        _add_contents_recursive_inner(start_cell_id)
        
        return output_list

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # (The current simplified get_contained will only return empty if accursed_cell_id was not found,
            # which should have been caught by get_accursed already).
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    # Using globals={'__builtins__': __builtins__} for safety, and locals for context
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Stop on first error as per refined guidance
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, start_cell_id: str) -> list[str]:
        """
        Retrieves a list of cell IDs "contained" within a given start_cell_id.
        This implements a traversal logic similar to Perl's add_contents:
        1. Includes the start_cell_id.
        2. Recursively includes cells in its +d.inside chain.
        3. For each cell in that +d.inside chain (including start_cell_id for its own contents),
           it recursively includes cells from their +d.contents chain, provided those
           content cells do not themselves have a -d.inside link (i.e., are not container heads).
        Returns a list of unique cell IDs in the order they were visited.
        """
        if start_cell_id not in self.cells:
            print(f"Error: Cell '{start_cell_id}' not found for get_contained.")
            return []

        output_list: list[str] = []
        # Globally visited set for the entire get_contained call to avoid redundant processing and loops.
        globally_visited_for_get_contained: set[str] = set()

        # Recursive helper function
        def _collect_recursive(cell_to_process_id: str) -> None:
            if cell_to_process_id in globally_visited_for_get_contained:
                return
            
            if cell_to_process_id not in self.cells: # Should not happen if links are consistent
                print(f"Warning: Cell ID '{cell_to_process_id}' encountered during get_contained traversal but not found in main cells dictionary.")
                return

            globally_visited_for_get_contained.add(cell_to_process_id)
            results.append(cell_to_process_id) # 'results' should be 'output_list'

            # Process +d.contents chain for the current cell_to_process_id
            # This must happen *before* traversing the current cell's +d.inside chain,
            # as per the original Perl's logic where add_contents processes the current cell,
            # then its .contents, then its .inside.
            # This interpretation is difficult. Let's follow the plan's structure.
            # The plan was:
            #   1. Add current cell.
            #   2. Process +d.inside chain (recursively adding those).
            #   3. Re-iterate the +d.inside chain for their +d.contents.
            # This seems more like the Perl `add_contents` structure where `cell` is from `+d.inside`
            # and then `index` is from `cell.+d.contents`.

            # For now, let's stick to a structure that processes current cell, then its direct contents, then its direct insides.
            # This is a common pattern. If it doesn't match Perl, we'll see in testing.

            # Process +d.contents for *this* cell_to_process_id, if they are not container heads
            current_contents_item_id = self.cell_nbr(cell_to_process_id, "+d.contents")
            visited_in_this_contents_chain: set[str] = {cell_to_process_id}
            while current_contents_item_id is not None and \
                  current_contents_item_id not in visited_in_this_contents_chain:
                
                if current_contents_item_id not in self.cells: break # Broken chain
                visited_in_this_contents_chain.add(current_contents_item_id)

                if self.cell_nbr(current_contents_item_id, "-d.inside") is None:
                    # If not a container head itself, recurse
                    _collect_recursive(current_contents_item_id)
                else:
                    # If it is a container head, just add it to results if not visited, but don't recurse its contents here.
                    # Its own .inside/.contents will be handled if it's visited through an .inside chain.
                    if current_contents_item_id not in globally_visited_for_get_contained:
                        globally_visited_for_get_contained.add(current_contents_item_id)
                        output_list.append(current_contents_item_id) # Corrected to output_list
                
                current_contents_item_id = self.cell_nbr(current_contents_item_id, "+d.contents")


            # Process +d.inside chain for the current cell_to_process_id
            current_inside_item_id = self.cell_nbr(cell_to_process_id, "+d.inside")
            visited_in_this_inside_chain: set[str] = {cell_to_process_id}
            while current_inside_item_id is not None and \
                  current_inside_item_id not in visited_in_this_inside_chain:

                if current_inside_item_id not in self.cells: break # Broken chain
                visited_in_this_inside_chain.add(current_inside_item_id)
                
                _collect_recursive(current_inside_item_id) # Recurse for each item in .inside chain
                current_inside_item_id = self.cell_nbr(current_inside_item_id, "+d.inside")
        
        # Initial call to the recursive helper
        _collect_recursive(start_cell_id)
        
        return output_list

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # (The current simplified get_contained will only return empty if accursed_cell_id was not found,
            # which should have been caught by get_accursed already).
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    # Using globals={'__builtins__': __builtins__} for safety, and locals for context
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Stop on first error as per refined guidance
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, start_cell_id: str) -> list[str]:
        """
        Retrieves a list of cell IDs "contained" within a given start_cell_id.
        This implements a traversal logic similar to Perl's add_contents:
        1. Includes the start_cell_id.
        2. Recursively includes cells in its +d.inside chain.
        3. For each cell in that +d.inside chain (including start_cell_id for its own contents),
           it recursively includes cells from their +d.contents chain, provided those
           content cells do not themselves have a -d.inside link (i.e., are not container heads).
        Returns a list of unique cell IDs in the order they were visited.
        """
        if start_cell_id not in self.cells:
            print(f"Error: Cell '{start_cell_id}' not found for get_contained.")
            return []

        output_list: list[str] = []
        # Globally visited set for the entire get_contained call to avoid redundant processing and loops.
        globally_visited_for_get_contained: set[str] = set()

        # Recursive helper function
        def _collect_recursive(cell_to_process_id: str) -> None:
            if cell_to_process_id in globally_visited_for_get_contained:
                return
            
            if cell_to_process_id not in self.cells: # Should not happen if links are consistent
                print(f"Warning: Cell ID '{cell_to_process_id}' encountered during get_contained traversal but not found in main cells dictionary.")
                return

            globally_visited_for_get_contained.add(cell_to_process_id)
            output_list.append(cell_to_process_id) # Corrected: was 'results' in my thought process

            # Process +d.contents chain for the current cell_to_process_id
            current_contents_item_id = self.cell_nbr(cell_to_process_id, "+d.contents")
            visited_in_this_contents_chain: set[str] = {cell_to_process_id}
            while current_contents_item_id is not None and \
                  current_contents_item_id not in visited_in_this_contents_chain:
                
                if current_contents_item_id not in self.cells: break # Broken chain
                visited_in_this_contents_chain.add(current_contents_item_id)

                if self.cell_nbr(current_contents_item_id, "-d.inside") is None:
                    # If not a container head itself, recurse
                    _collect_recursive(current_contents_item_id)
                else:
                    # If it is a container head, just add it to results if not visited, but don't recurse its contents here.
                    if current_contents_item_id not in globally_visited_for_get_contained:
                        globally_visited_for_get_contained.add(current_contents_item_id)
                        output_list.append(current_contents_item_id)
                
                current_contents_item_id = self.cell_nbr(current_contents_item_id, "+d.contents")


            # Process +d.inside chain for the current cell_to_process_id
            current_inside_item_id = self.cell_nbr(cell_to_process_id, "+d.inside")
            visited_in_this_inside_chain: set[str] = {cell_to_process_id}
            while current_inside_item_id is not None and \
                  current_inside_item_id not in visited_in_this_inside_chain:

                if current_inside_item_id not in self.cells: break # Broken chain
                visited_in_this_inside_chain.add(current_inside_item_id)
                
                _collect_recursive(current_inside_item_id) # Recurse for each item in .inside chain
                current_inside_item_id = self.cell_nbr(current_inside_item_id, "+d.inside")
        
        # Initial call to the recursive helper
        _collect_recursive(start_cell_id)
        
        return output_list

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # (The current simplified get_contained will only return empty if accursed_cell_id was not found,
            # which should have been caught by get_accursed already).
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    # Using globals={'__builtins__': __builtins__} for safety, and locals for context
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Stop on first error as per refined guidance
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, cell_id: str) -> List[str]:
        """
        Retrieves a list of cell IDs "contained" within a given cell.
        SIMPLIFIED VERSION: For this subtask, it ONLY returns a list containing cell_id itself if it exists.
        A more complete implementation would recursively traverse +d.inside and +d.contents.
        """
        if cell_id not in self.cells:
            # Consistent with subtask guidance to print here for get_contained, though exceptions are used elsewhere.
            print(f"Error: Cell '{cell_id}' not found for get_contained.")
            return []
        return [cell_id]

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # (The current simplified get_contained will only return empty if accursed_cell_id was not found,
            # which should have been caught by get_accursed already).
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    # Using globals={'__builtins__': __builtins__} for safety, and locals for context
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Stop on first error as per refined guidance
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, cell_id: str) -> List[str]:
        """
        Retrieves a list of cell IDs "contained" within a given cell.
        SIMPLIFIED VERSION: For this subtask, it ONLY returns a list containing cell_id itself if it exists.
        A more complete implementation would recursively traverse +d.inside and +d.contents.
        """
        if cell_id not in self.cells:
            # Consistent with subtask guidance to print here for get_contained, though exceptions are used elsewhere.
            print(f"Error: Cell '{cell_id}' not found for get_contained.")
            return []
        return [cell_id]

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # (The current simplified get_contained will only return empty if accursed_cell_id was not found,
            # which should have been caught by get_accursed already).
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    # Using globals={'__builtins__': __builtins__} for safety, and locals for context
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Stop on first error as per refined guidance
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, cell_id: str) -> List[str]:
        """
        Retrieves a list of cell IDs "contained" within a given cell.
        SIMPLIFIED VERSION: For this subtask, it ONLY returns a list containing cell_id itself if it exists.
        A more complete implementation would recursively traverse +d.inside and +d.contents.
        """
        if cell_id not in self.cells:
            # Consistent with subtask guidance to print here for get_contained,
            # though exceptions are used elsewhere for CellNotFoundError.
            print(f"Error: Cell '{cell_id}' not found for get_contained.")
            return []
        return [cell_id]

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # (The current simplified get_contained will only return empty if accursed_cell_id was not found,
            # which should have been caught by get_accursed already).
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    # Using globals={'__builtins__': __builtins__} for safety, and locals for context
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Stop on first error as per refined guidance
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, cell_id: str) -> List[str]:
        """
        Retrieves a list of cell IDs "contained" within a given cell.
        SIMPLIFIED VERSION: For this subtask, it ONLY returns a list containing cell_id itself if it exists.
        A more complete implementation would recursively traverse +d.inside and +d.contents.
        """
        if cell_id not in self.cells:
            # Consistent with subtask guidance to print here for get_contained, though exceptions are used elsewhere.
            print(f"Error: Cell '{cell_id}' not found for get_contained.")
            return []
        return [cell_id]

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    # Using globals={'__builtins__': __builtins__} for safety, and locals for context
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # As per refined guidance, stop on first error.
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, cell_id: str) -> List[str]:
        """
        Retrieves a list of cell IDs "contained" within a given cell.
        SIMPLIFIED VERSION: For this subtask, it ONLY returns a list containing cell_id itself if it exists.
        A more complete implementation would recursively traverse +d.inside and +d.contents.
        """
        if cell_id not in self.cells:
            # Consistent with subtask guidance to print here for get_contained, though exceptions are used elsewhere.
            print(f"Error: Cell '{cell_id}' not found for get_contained.")
            return []
        return [cell_id]

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell
        (or cells as defined by the current simple get_contained).
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance),
        'current_cursor_number', and 'current_cell_id' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE " # Note the space

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            # If get_accursed raises an error (e.g., cursor invalid, or not pointing),
            # we print it and return, as there's no cell to execute.
            print(f"Error in atcursor_execute (determining accursed cell): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # This case might be hit if get_contained printed an error and returned [].
            # Or if accursed_cell_id was valid but get_contained had a reason to return empty.
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                # print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    exec(code_to_execute, {'__builtins__': __builtins__}, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # As per refined guidance, stop on first error.
                    break 
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, cell_id: str) -> list[str]:
        """
        Retrieves a list of cell IDs "contained" within a given cell.
        For this version, it SIMPLY returns a list containing cell_id itself if it exists.
        A more complete implementation would recursively traverse +d.inside and +d.contents.
        """
        if cell_id not in self.cells:
            # This would ideally raise CellNotFoundError, but print for now as per subtask example.
            print(f"Error: Cell '{cell_id}' not found for get_contained.")
            return []
        return [cell_id]

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell.
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance) and
        'current_cursor_number' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE "

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            print(f"Error in atcursor_execute (getting accursed): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # get_contained might print its own error if accursed_cell_id was not found
            # Or, if it's empty for other reasons (though current simplified version won't be if accursed_cell_id is valid)
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    exec(code_to_execute, execution_locals, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Decide whether to continue to next cell or stop all execution.
                    # Original Perl implies "last if $@" (stop on error).
                    # To emulate, we could re-raise or return here. For now, print and continue.
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def get_contained(self, cell_id: str) -> list[str]:
        """
        Retrieves a list of cell IDs "contained" within a given cell.
        For this version, it SIMPLY returns a list containing cell_id itself if it exists.
        A more complete implementation would recursively traverse +d.inside and +d.contents.
        """
        if cell_id not in self.cells:
            # This would ideally raise CellNotFoundError, but print for now as per subtask example.
            print(f"Error: Cell '{cell_id}' not found for get_contained.")
            return []
        return [cell_id]

    def atcursor_execute(self, cursor_number: int) -> None:
        """
        Executes Python code found in the cell(s) pointed to by the cursor.

        This version uses a simplified get_contained, processing only the accursed cell.
        If the cell's content (after resolving clones via get_cell_contents)
        starts with '#PYTHONECUTE ' (note the space), the rest of the string is executed.

        The executed code will have 'zz' (the ZigzagSpace instance) and
        'current_cursor_number' available in its local scope.

        SECURITY WARNING:
        This method uses exec() to run code from cell contents. Executing
        arbitrary code can be dangerous if the source of the cell content
        is not trusted. Use this feature with extreme caution.
        """
        EXECUTE_PREFIX = "#PYTHONECUTE "

        try:
            accursed_cell_id = self.get_accursed(cursor_number)
        except ZigzagError as e:
            print(f"Error in atcursor_execute (getting accursed): {e}")
            return
        
        # Using the simplified get_contained for now
        cells_to_process = self.get_contained(accursed_cell_id) 

        if not cells_to_process:
            # get_contained might print its own error if accursed_cell_id was not found
            # Or, if it's empty for other reasons (though current simplified version won't be if accursed_cell_id is valid)
            # print(f"Info: No cells found by get_contained for accursed cell '{accursed_cell_id}' to execute.")
            return

        for cell_id_to_execute in cells_to_process:
            try:
                # Use get_cell_contents to respect clones for the content to be executed
                effective_content = self.get_cell_contents(cell_id_to_execute)
            except ZigzagError as e:
                print(f"Error in atcursor_execute (getting content for '{cell_id_to_execute}'): {e}")
                continue # Skip this cell

            if effective_content and effective_content.startswith(EXECUTE_PREFIX):
                code_to_execute = effective_content[len(EXECUTE_PREFIX):]
                
                execution_locals = {
                    'zz': self,
                    'current_cursor_number': cursor_number,
                    'current_cell_id': cell_id_to_execute 
                }
                
                print(f"Executing code from cell '{cell_id_to_execute}': {code_to_execute.strip()}")
                try:
                    exec(code_to_execute, execution_locals, execution_locals) 
                except Exception as e:
                    print(f"Error during execution of code from cell '{cell_id_to_execute}': {e}")
                    # Decide whether to continue to next cell or stop all execution.
                    # Original Perl implies "last if $@" (stop on error).
                    # To emulate, we could re-raise or return here. For now, print and continue.
            # else:
                # print(f"Info: Cell '{cell_id_to_execute}' content does not start with prefix, not executed.")
        # display_dirty() or equivalent might be called by the executed code itself if needed

    def do_shear(self, first_cell_in_row: str, row_dimension_with_sign: str, 
                 link_dimension_with_sign: str, n: int = 1, hang: bool = False) -> None:
        """Shears connections along a row of cells."""
        if first_cell_in_row not in self.cells:
            print(f"Error: First cell in row '{first_cell_in_row}' not found.")
            return
        if not (row_dimension_with_sign.startswith('+') or row_dimension_with_sign.startswith('-')):
            print(f"Error: Invalid row_dimension_with_sign format '{row_dimension_with_sign}'.")
            return
        if not (link_dimension_with_sign.startswith('+') or link_dimension_with_sign.startswith('-')):
            print(f"Error: Invalid link_dimension_with_sign format '{link_dimension_with_sign}'.")
            return

        shear_cells = self.cells_row(first_cell_in_row, row_dimension_with_sign)
        if not shear_cells:
            return

        linked_cells_targets: list[Optional[str]] = [self.cell_nbr(sc, link_dimension_with_sign) for sc in shear_cells]
        
        new_link_targets: list[Optional[str]] = list(linked_cells_targets) 

        if new_link_targets: 
            num_targets = len(new_link_targets)
            if num_targets > 0: # Avoid modulo by zero if list becomes empty
                actual_rotations = n % num_targets
                elements_to_move = [new_link_targets.pop(0) for _ in range(actual_rotations)]
                new_link_targets.extend(elements_to_move)

        # Break old links
        for i in range(len(shear_cells)):
            if linked_cells_targets[i] is not None: # Check if there was a link to break
                # Ensure shear_cells[i] and linked_cells_targets[i] are valid before breaking
                if shear_cells[i] in self.cells and linked_cells_targets[i] in self.cells:
                     self.link_break(shear_cells[i], linked_cells_targets[i], link_dimension_with_sign)
                # else: print(f"Warning: Cannot break link, cell(s) not found: {shear_cells[i]} or {linked_cells_targets[i]}")

        # Make new links
        for i in range(len(shear_cells)):
            # Ensure new_link_targets[i] is a valid cell ID before trying to link
            if i < len(new_link_targets) and new_link_targets[i] is not None and new_link_targets[i] in self.cells:
                # Check for hanging condition
                rotation_occurred = False
                if shear_cells and len(shear_cells) > 0: # Avoid division by zero
                    rotation_occurred = (n % len(shear_cells)) != 0
                
                if hang and i == (len(shear_cells) - 1) and rotation_occurred:
                    continue
                if shear_cells[i] in self.cells: # Ensure source cell still exists
                    self.link_make(shear_cells[i], new_link_targets[i], link_dimension_with_sign)
                # else: print(f"Warning: Cannot make link, source cell {shear_cells[i]} not found.")
            # elif i < len(new_link_targets) and new_link_targets[i] is not None:
                # print(f"Warning: Cannot make link, target cell {new_link_targets[i]} not found.")
        # display_dirty() or equivalent

    def atcursor_select(self, cursor_number: int) -> None:
        """Toggles the selection status of the cell pointed to by the cursor for the active selection list."""
        accursed_cell_id = self.get_accursed(cursor_number)
        if accursed_cell_id is None:
            return

        is_already_selected = self.is_selected(accursed_cell_id)
        
        # Get the selection list head cell ID if the cell is already selected
        which_selection_head: Optional[str] = None
        if is_already_selected:
            which_selection_head = self.get_which_selection(accursed_cell_id)
            # Note: get_which_selection as per prompt (v16) returns the start of the -d.mark chain
            # if the cell has an incoming -d.mark. We need to confirm if this start of the chain
            # is indeed SELECT_HOME_ID for the "active selection" case.
            # The logic of is_selected and get_which_selection might need to be perfectly aligned.
            # For the purpose of this function, if is_selected is true, we assume it's in *some* selection.
            # The prompt for atcursor_select specifically checks `which_selection_head == SELECT_HOME_ID`.
            # My get_which_selection (as per prompt v14) returns the "selection list head cell",
            # which is the cell in the SELECT_HOME's +d.2 chain. So this comparison is correct.

        self.cell_excise(accursed_cell_id, "d.mark") # Always remove from any current d.mark chain

        if is_already_selected and which_selection_head == SELECT_HOME_ID:
            # It was selected and was part of the active selection list (list 0, headed by SELECT_HOME_ID directly)
            print(f"Info: Deselected cell {accursed_cell_id} from active selection.")
        else:
            # Either it was not selected, or it was selected but in a different selection list.
            # In both cases, add it to the active selection list.
            if SELECT_HOME_ID not in self.cells:
                print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot add to active selection.")
                return
            self.cell_insert(accursed_cell_id, SELECT_HOME_ID, "+d.mark")
            print(f"Info: Selected cell {accursed_cell_id} into active selection.")
        # display_dirty()

    def rotate_selection(self, n_rotations: int = 1) -> None:
        """Rotates the selection lists themselves."""
        if SELECT_HOME_ID not in self.cells:
            print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot rotate selections.")
            return
        self.do_shear(SELECT_HOME_ID, "-d.2", "+d.mark", n_rotations, hang=False)
        # display_dirty()

    def push_selection(self) -> None:
        """Creates a new selection list and makes it the active one, pushing others back."""
        if SELECT_HOME_ID not in self.cells:
            print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot push selection.")
            return
        
        num_existing_selections = len(self.cells_row(SELECT_HOME_ID, "+d.2"))
        new_sel_head_content = f"Selection #{num_existing_selections}" 
        new_sel_head_id = self.cell_new(content=new_sel_head_content)
        
        self.cell_insert(new_sel_head_id, SELECT_HOME_ID, "+d.2")
        self.do_shear(SELECT_HOME_ID, "+d.2", "+d.mark", 1, hang=False)
        # display_dirty()

    def atcursor_make_link(self, cursor_number: int, direction_char: str, target_cell_id_param: Optional[str] = None) -> None:
        """Creates a link from the accursed cell along the specified dimension."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        accursed_cell_id = self.get_accursed(cursor_number)
        if accursed_cell_id is None: return

        dim_to_link_along = self.get_dimension(cursor_cell_id, direction_char)
        if dim_to_link_along is None: return

        if self._get_base_dimension(dim_to_link_along) == "d.cursor":
            print("Error: Cannot link along d.cursor.")
            return

        if target_cell_id_param is None:
            self.cursor_move_dimension(cursor_cell_id, dim_to_link_along)
            print("Info: No target cell provided, moved cursor instead.")
        else:
            if target_cell_id_param not in self.cells:
                print("Error: Target cell for link does not exist.")
                return
            self.cell_insert(target_cell_id_param, accursed_cell_id, dim_to_link_along)
            # display_dirty()

    def atcursor_break_link(self, cursor_number: int, direction_char: str) -> None:
        """Breaks a link from the accursed cell along the specified dimension."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        accursed_cell_id = self.get_accursed(cursor_number)
        if accursed_cell_id is None: return

        dim_to_break_along = self.get_dimension(cursor_cell_id, direction_char)
        if dim_to_break_along is None: return

        if self._get_base_dimension(dim_to_break_along) == "d.cursor":
            print("Error: Cannot break links along d.cursor.")
            return

        target_to_break = self.cell_nbr(accursed_cell_id, dim_to_break_along)
        if target_to_break is None:
            print("Error: No link to break in that direction.")
            return
        
        self.link_break(accursed_cell_id, target_to_break, dim_to_break_along)
        # display_dirty()

    def do_shear(self, first_cell_in_row: str, row_dimension_with_sign: str, 
                 link_dimension_with_sign: str, n: int = 1, hang: bool = False) -> None:
        """Shears connections along a row of cells."""
        if first_cell_in_row not in self.cells:
            print(f"Error: First cell in row '{first_cell_in_row}' not found.")
            return
        if not (row_dimension_with_sign.startswith('+') or row_dimension_with_sign.startswith('-')):
            print(f"Error: Invalid row_dimension_with_sign format '{row_dimension_with_sign}'.")
            return
        if not (link_dimension_with_sign.startswith('+') or link_dimension_with_sign.startswith('-')):
            print(f"Error: Invalid link_dimension_with_sign format '{link_dimension_with_sign}'.")
            return

        shear_cells = self.cells_row(first_cell_in_row, row_dimension_with_sign)
        if not shear_cells:
            # cells_row might print an error if start_cell_id is invalid, or return [start_cell_id] if no links
            # If it's truly empty (e.g. start_cell_id was invalid and it returned empty list), then return.
            # If it only contains start_cell_id and no actual row, shear might not make sense.
            # The original Perl logic implies it can work on a single-cell row (no rotation but link break/make might occur).
            # For now, if cells_row returns an empty list (which it does on error), we return.
            # If it returns a list with one cell, that's a valid scenario for shear.
            return

        linked_cells_targets: list[Optional[str]] = [self.cell_nbr(sc, link_dimension_with_sign) for sc in shear_cells]
        
        new_link_targets: list[Optional[str]] = list(linked_cells_targets) # Make a mutable copy

        if new_link_targets: # Only attempt rotation if there are targets to rotate
            num_targets = len(new_link_targets)
            actual_rotations = n % num_targets
            
            elements_to_move = [new_link_targets.pop(0) for _ in range(actual_rotations)]
            new_link_targets.extend(elements_to_move)

        # Break old links
        for i in range(len(shear_cells)):
            if linked_cells_targets[i] is not None:
                self.link_break(shear_cells[i], linked_cells_targets[i], link_dimension_with_sign)
        
        # Make new links
        for i in range(len(shear_cells)):
            if i < len(new_link_targets) and new_link_targets[i] is not None: # Ensure new_link_targets[i] is valid index
                # Check for hanging condition
                # "n % len(shear_cells) != 0" - original Perl used len of shear_cells for rotation check.
                # If new_link_targets can be shorter (e.g. if some cells had no links), this might be an issue.
                # Assuming len(new_link_targets) == len(shear_cells) due to list(linked_cells_targets) copy.
                rotation_occurred = False
                if shear_cells: # Avoid division by zero if shear_cells is empty (though guarded earlier)
                    rotation_occurred = (n % len(shear_cells)) != 0
                
                if hang and i == (len(shear_cells) - 1) and rotation_occurred:
                    # If it's the last cell, and 'hang' is true, and an actual rotation of elements happened,
                    # then skip linking this cell.
                    continue
                self.link_make(shear_cells[i], new_link_targets[i], link_dimension_with_sign)
        # display_dirty() or equivalent

    def atcursor_select(self, cursor_number: int) -> None:
        """Toggles the selection status of the cell pointed to by the cursor for the active selection list."""
        accursed_cell_id = self.get_accursed(cursor_number)
        if accursed_cell_id is None:
            # Error already printed by get_accursed if cursor is invalid or not pointing
            return

        is_already_selected = self.is_selected(accursed_cell_id)
        
        # get_which_selection logic needs to be robust.
        # It identifies the head of the *selection list* (a cell in SELECT_HOME's +d.2 chain)
        # that accursed_cell_id is part of.
        # My current get_which_selection returns the cell that is the *start* of the d.mark chain
        # containing accursed_cell_id, and then verifies this start cell is linked from a selection head.
        # For the active selection, we care if it's linked to SELECT_HOME_ID.
        
        # Simplified logic: if is_selected, then excise. If not, insert into active selection.
        # The specific check for which_selection_head == SELECT_HOME_ID is to give a more specific message.

        # Detach from any d.mark chain it might be in.
        # cell_excise handles cases where the cell might not be in a chain or is at an end.
        self.cell_excise(accursed_cell_id, "d.mark")

        if is_already_selected:
            # To determine if it was part of the *active* selection specifically:
            # Check if the ultimate head of its -d.mark chain was SELECT_HOME_ID.
            # This is exactly what is_active_selected(accursed_cell_id) checks (if interpreted as head_cell's parent is SELECT_HOME_ID).
            # Let's use a more direct check:
            was_in_active_selection = False
            head_of_old_mark_chain = self.get_last_cell(accursed_cell_id, "-d.mark") # Find start of its previous chain
            if head_of_old_mark_chain:
                 parent_of_that_chain_head = self.cell_nbr(head_of_old_mark_chain, "-d.mark")
                 if parent_of_that_chain_head == SELECT_HOME_ID:
                     was_in_active_selection = True
            
            # After excise, accursed_cell_id has no d.mark links.
            # If it was previously selected (in any list), and specifically if that list was the active one.
            if was_in_active_selection:
                print(f"Info: Deselected cell {accursed_cell_id} from active selection.")
            else: # Was in another selection list or logic error
                print(f"Info: Deselected cell {accursed_cell_id} from its selection list.")

        else: # Not previously selected, so add to active selection (SELECT_HOME_ID's +d.mark chain)
            if SELECT_HOME_ID not in self.cells:
                print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot add to active selection.")
                return
            # cell_insert will link SELECT_HOME_ID -- "+d.mark" --> accursed_cell_id (if no existing +d.mark from SELECT_HOME_ID)
            # or insert accursed_cell_id into the chain starting from SELECT_HOME_ID's +d.mark.
            self.cell_insert(accursed_cell_id, SELECT_HOME_ID, "+d.mark")
            print(f"Info: Selected cell {accursed_cell_id} into active selection.")
        # display_dirty()

    def rotate_selection(self, n_rotations: int = 1) -> None:
        """Rotates the selection lists themselves."""
        if SELECT_HOME_ID not in self.cells:
            print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot rotate selections.")
            return
        # The selection lists are in a chain along +d.2 from SELECT_HOME_ID.
        # Rotating this chain means the "active" selection (0) changes.
        # However, the links being sheared are the "+d.mark" links from these selection list head cells.
        # The Perl code is: $self->do_shear($SELECT_HOME, "-d.2", "+d.mark", $n);
        # First cell in row is SELECT_HOME_ID.
        # Row dimension is -d.2 (meaning it traverses the selection list heads in reverse order of creation).
        # Link dimension is +d.mark (the actual selection lists).
        self.do_shear(SELECT_HOME_ID, "-d.2", "+d.mark", n_rotations, hang=False)
        # display_dirty()

    def push_selection(self) -> None:
        """Creates a new selection list and makes it the active one, pushing others back."""
        if SELECT_HOME_ID not in self.cells:
            print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot push selection.")
            return
        
        # Count existing selections. SELECT_HOME_ID is the 0th, its +d.2 is 1st, etc.
        # The cells_row for "+d.2" from SELECT_HOME_ID includes SELECT_HOME_ID itself.
        # So, if only SELECT_HOME_ID exists, len is 1. A new selection would be #1.
        num_existing_selections = len(self.cells_row(SELECT_HOME_ID, "+d.2"))
        
        new_sel_head_content = f"Selection #{num_existing_selections}" 
        new_sel_head_id = self.cell_new(content=new_sel_head_content)
        
        # Insert the new selection head at the "front" of the +d.2 chain from SELECT_HOME_ID.
        # This means SELECT_HOME_ID --+d.2--> new_sel_head_id
        self.cell_insert(new_sel_head_id, SELECT_HOME_ID, "+d.2")
        
        # Now, rotate all actual selection lists (+d.mark links) one step
        # so that the new selection head (now at SELECT_HOME_ID's +d.2 position)
        # gets the +d.mark list that SELECT_HOME_ID used to have.
        # The old SELECT_HOME_ID's +d.mark list moves to the next selection head in the original +d.2 chain.
        # The shear should be on the +d.2 chain starting from SELECT_HOME_ID, affecting +d.mark links.
        self.do_shear(SELECT_HOME_ID, "+d.2", "+d.mark", 1, hang=False)
        # display_dirty()

    def atcursor_make_link(self, cursor_number: int, direction_char: str, target_cell_id_param: Optional[str] = None) -> None:
        """Creates a link from the accursed cell along the specified dimension."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        accursed_cell_id = self.get_accursed(cursor_number)
        if accursed_cell_id is None: return

        dim_to_link_along = self.get_dimension(cursor_cell_id, direction_char)
        if dim_to_link_along is None: return

        if self._get_base_dimension(dim_to_link_along) == "d.cursor":
            print("Error: Cannot link along d.cursor.")
            return

        if target_cell_id_param is None:
            self.cursor_move_dimension(cursor_cell_id, dim_to_link_along)
            print("Info: No target cell provided, moved cursor instead.")
        else:
            if target_cell_id_param not in self.cells:
                print("Error: Target cell for link does not exist.")
                return
            # Perl: cell_insert($targetcell, $accursed, $dim);
            # This means: $accursed ---$dim---> $targetcell (if $accursed has no prior link on $dim)
            # Or inserts $targetcell into the chain at $accursed along $dim.
            self.cell_insert(target_cell_id_param, accursed_cell_id, dim_to_link_along)
            # display_dirty()

    def atcursor_break_link(self, cursor_number: int, direction_char: str) -> None:
        """Breaks a link from the accursed cell along the specified dimension."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None: return

        accursed_cell_id = self.get_accursed(cursor_number)
        if accursed_cell_id is None: return

        dim_to_break_along = self.get_dimension(cursor_cell_id, direction_char)
        if dim_to_break_along is None: return

        if self._get_base_dimension(dim_to_break_along) == "d.cursor":
            print("Error: Cannot break links along d.cursor.")
            return

        target_to_break = self.cell_nbr(accursed_cell_id, dim_to_break_along)
        if target_to_break is None:
            print("Error: No link to break in that direction.")
            return
        
        self.link_break(accursed_cell_id, target_to_break, dim_to_break_along)
        # display_dirty()

    def atcursor_insert(self, cursor_number: int, direction_char: str) -> None:
        """Inserts a new cell at the accursed cell, along the specified direction's dimension."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None:
            # Error already printed by get_cursor
            return

        accursed_cell_id = self.get_accursed(cursor_number)
        if accursed_cell_id is None:
            print(f"Error: Cursor (number {cursor_number}, cell {cursor_cell_id}) is not pointing to any cell.")
            return
        
        dimension_to_insert_along = self.get_dimension(cursor_cell_id, direction_char)
        if dimension_to_insert_along is None:
            # Error already printed by get_dimension
            return

        base_dim = self._get_base_dimension(dimension_to_insert_along)
        if base_dim in {"d.clone", "d.cursor"}:
            print(f"Error: Cannot insert along dimension {base_dim}.")
            return

        new_cell_id = self.cell_new() # Default content is its own ID
        self.cell_insert(new_cell_id, accursed_cell_id, dimension_to_insert_along)
        # display_dirty() or equivalent would be called here.

    def atcursor_delete(self, cursor_number: int) -> None:
        """Deletes the cell pointed to by the cursor, moving it to the recycle pile."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None:
            return

        cell_to_delete_id = self.get_accursed(cursor_number)
        if cell_to_delete_id is None:
            print(f"Error: Cursor (number {cursor_number}, cell {cursor_cell_id}) is not pointing to any cell to delete.")
            return
        
        if cell_to_delete_id == ROOT_CELL_ID: # Explicitly prevent ROOT_CELL_ID deletion
            print("Error: Cannot delete the ROOT_CELL_ID ('0').")
            return

        if self.is_essential(cell_to_delete_id):
            print(f"Error: Cannot delete an essential cell: '{cell_to_delete_id}'.")
            return

        # Check if the cell represents an essential dimension
        dim_home_for_check = self.dimension_home() # Typically CURSOR_HOME_ID
        if dim_home_for_check:
            first_dim_cell_in_list = self.cell_nbr(dim_home_for_check, "+d.1")
            if first_dim_cell_in_list:
                content_of_cell_to_delete = self.cell_get(cell_to_delete_id)
                if content_of_cell_to_delete is not None: # Ensure it has content to be a dimension name
                    # Check if this content is an essential dimension AND cell_to_delete_id is the cell representing it
                    if self.dimension_is_essential(content_of_cell_to_delete) and \
                       self.cell_find(first_dim_cell_in_list, "+d.2", content_of_cell_to_delete) == cell_to_delete_id:
                        print(f"Error: Cannot delete cell '{cell_to_delete_id}' as it represents essential dimension '{content_of_cell_to_delete}'.")
                        return
        
        # Handle clone promotion
        first_clone_id = self.cell_nbr(cell_to_delete_id, "+d.clone")
        if first_clone_id and self.cell_nbr(cell_to_delete_id, "-d.clone") is None:
            original_content = self.cell_get(cell_to_delete_id)
            if original_content is not None:
                self.cell_set(first_clone_id, original_content)
                # After content promotion, the original cell's -d.clone link (which was None)
                # should now be established to the first_clone_id to signify it's now a clone.
                # And the first_clone_id's +d.clone link should be removed.
                # This is more complex than just content setting; it involves restructuring clone links.
                # For now, sticking to the prompt's level of detail: just set content.
                # A more complete solution would involve:
                # self.link_break(cell_to_delete_id, first_clone_id, "+d.clone")
                # self.link_make(first_clone_id, cell_to_delete_id, "-d.clone") # Make original a clone of first_clone

        neighbor_to_move_cursor_to: Optional[str] = None
        
        # Iterate over a copy of dimensions, as cell_excise might modify connections
        # or potentially self.dimensions if it were to clean them up (though it currently doesn't).
        # Using a predefined list of common dimensions can be more robust if self.dimensions is not always accurate
        # or if we want to ensure specific dimensions are checked.
        # For now, using self.dimensions as per typical ZZ behavior.
        dimensions_to_check = list(self.dimensions) 

        for dim_name in dimensions_to_check:
            if neighbor_to_move_cursor_to is None:
                potential_neighbor_neg = self.cell_nbr(cell_to_delete_id, "-" + dim_name)
                if potential_neighbor_neg and potential_neighbor_neg != cell_to_delete_id and \
                   not self.is_cursor(potential_neighbor_neg) and potential_neighbor_neg != ROOT_CELL_ID:
                    neighbor_to_move_cursor_to = potential_neighbor_neg
                else:
                    potential_neighbor_pos = self.cell_nbr(cell_to_delete_id, "+" + dim_name)
                    if potential_neighbor_pos and potential_neighbor_pos != cell_to_delete_id and \
                       not self.is_cursor(potential_neighbor_pos) and potential_neighbor_pos != ROOT_CELL_ID:
                        neighbor_to_move_cursor_to = potential_neighbor_pos
            
            self.cell_excise(cell_to_delete_id, dim_name)

        if neighbor_to_move_cursor_to is None:
            neighbor_to_move_cursor_to = ROOT_CELL_ID
            if neighbor_to_move_cursor_to == cell_to_delete_id: # Should not happen if ROOT_CELL_ID check passed
                 print("Critical Error: neighbor_to_move_cursor_to ended up being cell_to_delete_id, and it's ROOT. Aborting jump.")
                 # Fallback or further error handling might be needed here.
                 # For now, if it's ROOT and was meant to be deleted, something is very wrong.
                 # However, ROOT_CELL_ID deletion is blocked earlier.
                 # If cell_to_delete was not ROOT, but no other neighbor found, cursor jumps to ROOT.
                 # If ROOT was the only option and cell_to_delete was ROOT, this is a problem.
                 # This state suggests an isolated cell_to_delete_id if it's not ROOT.
                 # If cell_to_delete_id was the only cell other than ROOT, and it's deleted, cursor must go to ROOT.

        # Move cell_to_delete_id to the recycle pile (DELETE_HOME_ID is '99')
        # The original Perl uses cell_set_link($DELETE_HOME, "+d.2", $deadcell)
        # which is equivalent to self.cell_insert($deadcell, $DELETE_HOME, "+d.2")
        # Ensure DELETE_HOME_ID exists
        if DELETE_HOME_ID not in self.cells:
            print(f"Warning: DELETE_HOME_ID '{DELETE_HOME_ID}' not found. Cannot move deleted cell to recycle pile.")
        else:
            # Check if cell_to_delete_id still has connections; it shouldn't if excised from all known dims.
            # For safety, clear its connections before adding to recycle list to prevent cross-linking.
            if cell_to_delete_id in self.cells: # It should still be in self.cells
                 self.cells[cell_to_delete_id].connections.clear()
            self.cell_insert(cell_to_delete_id, DELETE_HOME_ID, "+d.2")

        if neighbor_to_move_cursor_to: # Ensure it's not None
             self.cursor_jump(cursor_cell_id, neighbor_to_move_cursor_to)
        else: # Should ideally not happen if ROOT_CELL_ID is always a valid fallback
             print(f"Warning: No valid cell found to jump cursor '{cursor_cell_id}' to after deletion.")
        # display_dirty() or equivalent would be called here.

    def atcursor_hop(self, cursor_number: int, direction_char: str) -> None:
        """Hops a cell over its neighbor in the specified cursor direction."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None:
            return

        cell_to_hop_id = self.get_accursed(cursor_number)
        if cell_to_hop_id is None:
            print(f"Error: Cursor (number {cursor_number}, cell {cursor_cell_id}) is not pointing to any cell to hop.")
            return
        
        dimension_to_hop_along = self.get_dimension(cursor_cell_id, direction_char)
        if dimension_to_hop_along is None:
            return

        if self._get_base_dimension(dimension_to_hop_along) == "d.cursor":
            print("Error: Cannot hop along d.cursor.")
            return

        neighbor_cell_id = self.cell_nbr(cell_to_hop_id, dimension_to_hop_along)
        if neighbor_cell_id is None:
            print(f"Info: No neighbor to hop over in direction '{dimension_to_hop_along}' from cell '{cell_to_hop_id}'.")
            return
        
        if neighbor_cell_id == cell_to_hop_id: # Self-loop, cannot hop
            print(f"Info: Cell '{cell_to_hop_id}' forms a self-loop along '{dimension_to_hop_along}'. Cannot hop.")
            return

        reversed_dim = self._reverse_dimension_sign(dimension_to_hop_along)
        prev_cell_id = self.cell_nbr(cell_to_hop_id, reversed_dim) # Cell before cell_to_hop_id
        next_cell_id = self.cell_nbr(neighbor_cell_id, dimension_to_hop_along) # Cell after neighbor_cell_id

        # Detach cell_to_hop_id from neighbor_cell_id
        self.link_break(cell_to_hop_id, neighbor_cell_id, dimension_to_hop_along)

        # If there was a cell before cell_to_hop_id, link it to neighbor_cell_id
        if prev_cell_id is not None:
            # Detach prev_cell_id from cell_to_hop_id (using reversed_dim from prev_cell_id's perspective)
            # No, this is wrong. The link from prev_cell_id to cell_to_hop_id is dimension_to_hop_along.
            self.link_break(prev_cell_id, cell_to_hop_id, dimension_to_hop_along)
            self.link_make(prev_cell_id, neighbor_cell_id, dimension_to_hop_along)

        # If there was a cell after neighbor_cell_id, link cell_to_hop_id to it
        if next_cell_id is not None:
            # Detach neighbor_cell_id from next_cell_id
            self.link_break(neighbor_cell_id, next_cell_id, dimension_to_hop_along)
            self.link_make(cell_to_hop_id, next_cell_id, dimension_to_hop_along)
        
        # Link neighbor_cell_id to cell_to_hop_id (neighbor is now before cell_to_hop)
        # The dimension from neighbor_cell_id to cell_to_hop_id is dimension_to_hop_along
        self.link_make(neighbor_cell_id, cell_to_hop_id, dimension_to_hop_along)
        # display_dirty() or equivalent would be called here.

    def cursor_move_dimension(self, cursor_cell_id: str, dimension_name_with_sign: str) -> None:
        """Moves a cursor along a specified dimension to point to a new cell."""
        if not (cursor_cell_id in self.cells and self.is_cursor(cursor_cell_id)):
            print(f"Error: Cell ID '{cursor_cell_id}' is not a valid, existing cursor cell.")
            return

        if not (dimension_name_with_sign.startswith('+') or dimension_name_with_sign.startswith('-')):
            print(f"Error: Invalid dimension format '{dimension_name_with_sign}'. Must start with '+' or '-'.")
            return

        accursed_cell_id = self.get_last_cell(cursor_cell_id, "-d.cursor")
        if accursed_cell_id is None:
            print(f"Error: Cursor '{cursor_cell_id}' is not pointing to any cell (accursed_cell_id is None).")
            return
        
        if accursed_cell_id not in self.cells: # Should be caught by get_last_cell if it returns a non-cell ID
            print(f"Error: Accursed cell ID '{accursed_cell_id}' pointed to by cursor '{cursor_cell_id}' does not exist.")
            return

        new_target_accursed_id = self.cell_nbr(accursed_cell_id, dimension_name_with_sign)

        if new_target_accursed_id is None:
            print(f"Info: Cannot move cursor '{cursor_cell_id}': no cell in direction '{dimension_name_with_sign}' from '{accursed_cell_id}'.")
            return
        if new_target_accursed_id == accursed_cell_id:
             print(f"Info: Cannot move cursor '{cursor_cell_id}': already at boundary or no change in position.")
             return
        if new_target_accursed_id not in self.cells:
            print(f"Error: Target cell ID '{new_target_accursed_id}' to move cursor to does not exist.")
            return

        if self.is_cursor(new_target_accursed_id):
            print(f"Error: Cannot move cursor '{cursor_cell_id}' to point directly at another cursor cell '{new_target_accursed_id}'.")
            return

        # All checks passed, proceed with move
        self.cell_excise(cursor_cell_id, "d.cursor") # Base dimension for d.cursor is "d.cursor"
        
        # Find where to insert the cursor cell in the d.cursor chain of the new target.
        # The cursor (cursor_cell_id) should point *to* new_target_accursed_id.
        # This means new_target_accursed_id will be on the -d.cursor side of cursor_cell_id.
        # We need to find where cursor_cell_id fits if new_target_accursed_id already points to other cursors (+d.cursor).
        insertion_point_id = self.get_last_cell(new_target_accursed_id, "+d.cursor")
        
        # If insertion_point_id is None, it means get_last_cell had an issue with new_target_accursed_id
        # or new_target_accursed_id itself has no +d.cursor links (which is the common case).
        # In this case, new_target_accursed_id is the correct cell to link against.
        actual_insertion_point = insertion_point_id if insertion_point_id is not None else new_target_accursed_id
        
        # We are inserting cursor_cell_id such that its -d.cursor points to new_target_accursed_id.
        # The cell_insert method links:
        # existing_cell_id ---dimension_name_with_sign---> new_cell_id
        # So, we want:
        # actual_insertion_point --- "+d.cursor" ---> cursor_cell_id
        # And then internally, cursor_cell_id --- "-d.cursor" ---> new_target_accursed_id (this is done by link_make)
        # This is not quite right. cell_insert is too high level. We need to use link_make directly.
        # The cursor (cursor_cell_id) needs to point to new_target_accursed_id.
        # This means: cursor_cell_id --- "-d.cursor" ---> new_target_accursed_id
        # And if new_target_accursed_id was pointing to other cursors (via its +d.cursor),
        # cursor_cell_id should now be inserted there.
        
        # Corrected logic:
        # cursor_cell_id will point to new_target_accursed_id:
        #   cursor_cell_id --- (-d.cursor) --> new_target_accursed_id
        #   new_target_accursed_id --- (+d.cursor) --> cursor_cell_id
        # This is a simple link_make.
        self.link_make(new_target_accursed_id, cursor_cell_id, "+d.cursor")
        # display_dirty() or equivalent would be called here.

    def cursor_jump(self, cursor_cell_id: str, target_cell_id: str) -> None:
        """Moves a cursor to point directly to a specified target cell."""
        if not (cursor_cell_id in self.cells and self.is_cursor(cursor_cell_id)):
            print(f"Error: Cell ID '{cursor_cell_id}' is not a valid, existing cursor cell.")
            return
        if target_cell_id not in self.cells:
            print(f"Error: Target cell ID '{target_cell_id}' does not exist.")
            return

        if self.is_cursor(target_cell_id):
            print(f"Error: Cannot jump cursor '{cursor_cell_id}' to point directly at another cursor cell '{target_cell_id}'.")
            return

        current_accursed = self.get_last_cell(cursor_cell_id, "-d.cursor")
        if current_accursed == target_cell_id:
            print(f"Info: Cursor '{cursor_cell_id}' already at target cell '{target_cell_id}'.")
            return

        self.cell_excise(cursor_cell_id, "d.cursor") # Base dimension is "d.cursor"
        
        # Similar to cursor_move_dimension, the cursor cell needs to point to the target_cell_id.
        # cursor_cell_id --- (-d.cursor) --> target_cell_id
        # target_cell_id --- (+d.cursor) --> cursor_cell_id
        # The `cell_insert` method is designed to insert into a chain.
        # Here, we are establishing a new primary link for the cursor.
        # The logic from the prompt for `cell_insert` was:
        # self.cell_insert(cursor_cell_id, insertion_point_id or target_cell_id, "+d.cursor")
        # This implies `insertion_point_id` is `existing_cell_id` and `cursor_cell_id` is `new_cell_id`.
        # So, `(insertion_point_id or target_cell_id)` --- `+d.cursor` ---> `cursor_cell_id`.
        # This is what we want: the target (or its +d.cursor end) now points to our cursor.
        # And cursor_cell_id's -d.cursor should point to target_cell_id.
        # This is handled by `link_make(target_cell_id, cursor_cell_id, "+d.cursor")`
        # which means target_cell_id (+d.cursor)--> cursor_cell_id
        # and      cursor_cell_id (-d.cursor)--> target_cell_id. This is correct.

        self.link_make(target_cell_id, cursor_cell_id, "+d.cursor")
        # display_dirty() or equivalent would be called here.

    def cursor_move_direction(self, cursor_number: int, direction_char: str) -> None:
        """Moves a specified cursor in a given cardinal direction."""
        cursor_cell_id = self.get_cursor(cursor_number)
        if cursor_cell_id is None:
            # Error already printed by get_cursor
            return

        dimension_to_move_along = self.get_dimension(cursor_cell_id, direction_char)
        if dimension_to_move_along is None:
            # Error already printed by get_dimension
            return
        
        self.cursor_move_dimension(cursor_cell_id, dimension_to_move_along)

    def get_selection(self, selection_cursor_number: int) -> list[str]:
        """Gets the list of cell IDs in the specified selection."""
        if selection_cursor_number < 0:
            print("Error: Selection cursor number must be non-negative.")
            return []

        selection_head_cell_id: Optional[str] = SELECT_HOME_ID
        if SELECT_HOME_ID not in self.cells:
            print(f"Error: SELECT_HOME_ID '{SELECT_HOME_ID}' not found. Cannot get selection.")
            return []

        for _ in range(selection_cursor_number):
            if selection_head_cell_id is None: # Should not happen if loop is structured correctly
                 print("Error: Internal error, selection_head_cell_id became None unexpectedly.")
                 return []
            selection_head_cell_id = self.cell_nbr(selection_head_cell_id, "+d.2")
            if selection_head_cell_id is None or selection_head_cell_id not in self.cells:
                print(f"Error: Selection number {selection_cursor_number} is too high or selection structure is broken.")
                return []
        
        # After the loop, selection_head_cell_id points to the specific selection list head
        if selection_head_cell_id: # selection_head_cell_id is now the head for the specific selection_cursor_number
            first_selected_cell = self.cell_nbr(selection_head_cell_id, "+d.mark")
            if first_selected_cell is None:
                return [] # Empty selection
            if first_selected_cell not in self.cells: # Check if the first cell in the selection chain exists
                print(f"Error: First selected cell ID '{first_selected_cell}' (from selection head '{selection_head_cell_id}') not found.")
                return []
            return self.cells_row(first_selected_cell, "+d.mark")
        
        return [] # Should not be reached if logic is correct

    def get_active_selection(self) -> list[str]:
        """Gets the list of cell IDs in the active selection (selection 0)."""
        return self.get_selection(0)

    def get_which_selection(self, cell_id: str) -> Optional[str]:
        """Determines which selection list a cell belongs to by finding the head of its -d.mark chain."""
        if cell_id not in self.cells:
            print(f"Error: Cell with ID '{cell_id}' not found.")
            return None
        
        # If cell_id has no -d.mark, it can't be part of a selection chain (other than potentially being a head itself,
        # but selections are identified by their connection to SELECT_HOME_ID structure).
        # The prompt asks for the *ultimate head* of the -d.mark chain.
        # If self.cell_nbr(cell_id, "-d.mark") is None, it implies cell_id itself might be a head.
        # get_last_cell(cell_id, "-d.mark") will return cell_id if it has no further -d.mark links.
        
        head_of_mark_chain = self.get_last_cell(cell_id, "-d.mark")
        
        # If head_of_mark_chain is None, it means start_cell_id for get_last_cell was invalid,
        # but we already checked cell_id existence. So it should return cell_id if it's the head.
        # If the cell is not part of any d.mark chain (i.e., it is the head of its own -d.mark chain,
        # meaning it has no -d.mark connection itself), then it cannot be part of a selection list
        # that originates from the SELECT_HOME structure via +d.mark.
        
        # Consider a cell that is part of a selection: S_HEAD --+d.mark--> A --+d.mark--> B (cell_id=B)
        # get_last_cell(B, "-d.mark") will traverse B -> A -> S_HEAD, returning S_HEAD.
        # If cell_id=A, get_last_cell(A, "-d.mark") -> S_HEAD.
        # If cell_id=S_HEAD, get_last_cell(S_HEAD, "-d.mark") -> S_HEAD.
        # If cell_id is isolated or head of an unrelated chain: X (no -d.mark), get_last_cell(X, "-d.mark") -> X
        
        if head_of_mark_chain is None: # Should not happen if cell_id exists
            return None

        # Now, check if this head_of_mark_chain is one of the selection list heads
        # (i.e., reachable from SELECT_HOME_ID via +d.2 and linked by +d.mark from one of those)
        # The simplest way is to see if this head_of_mark_chain has a "parent" in the SELECT_HOME structure,
        # which means it's linked from a cell in the SELECT_HOME +d.2 chain via -d.mark
        
        # A cell is part of a selection if its -d.mark chain leads to a cell that is a direct +d.mark neighbor of a selection cursor.
        # The returned head_of_mark_chain from get_last_cell IS that cell (e.g. first_selected_cell in get_selection logic).
        # So, we need to find if THIS head_of_mark_chain is pointed to by a selection_head_cell_id via +d.mark.
        
        # This means checking if head_of_mark_chain has a -d.mark link to one of the selection_head_cell_ids
        # (Cells in the chain starting from SELECT_HOME_ID along +d.2)
        
        potential_selection_head = self.cell_nbr(head_of_mark_chain, "-d.mark")
        if potential_selection_head is None: # This means head_of_mark_chain (and thus cell_id) is not part of any selection.
            return None

        # Now, verify if potential_selection_head is indeed one of the selection cursor cells
        # by seeing if it's reachable from SELECT_HOME_ID along the +d.2 chain.
        
        current_scanner: Optional[str] = SELECT_HOME_ID
        if SELECT_HOME_ID not in self.cells: return None # Should be caught by other functions usually

        visited_selection_heads: Set[str] = set()
        while current_scanner is not None:
            if current_scanner == potential_selection_head:
                return potential_selection_head # This is the ID of the selection list head
            if current_scanner in visited_selection_heads: break # Loop in +d.2 chain
            visited_selection_heads.add(current_scanner)
            current_scanner = self.cell_nbr(current_scanner, "+d.2")
            
        return None # Not part of a known selection list

    def get_links_to(self, cell_id: str) -> list[str]:
        """Gets a list of formatted strings representing links pointing to the given cell."""
        if cell_id not in self.cells:
            print(f"Error: Cell with ID '{cell_id}' not found.")
            return []

        result_links: list[str] = []
        # Iterate over a sorted list of known dimensions for consistent output
        # This covers all dimensions that have been used in link_make
        sorted_dimensions = sorted(list(self.dimensions))

        for dim_name in sorted_dimensions:
            # For a dimension "dim", cell_id could be pointed to by:
            # 1. neighbor_cell via "+dim" (so cell_id has a "-dim" link to neighbor_cell)
            #    The link from neighbor_cell perspective is neighbor_cell +dim -> cell_id
            #    So, if self.cell_nbr(cell_id, "-" + dim_name) gives neighbor_cell,
            #    then neighbor_cell is linked to cell_id via "+" + dim_name
            
            # Let's re-evaluate:
            # If cell X is connected to cell_id via X --pos_dim--> cell_id,
            # then cell_id must have cell_id --neg_dim--> X.
            # So, source_cell = self.cell_nbr(cell_id, neg_dim). If it exists, then source_cell --pos_dim--> cell_id.
            
            neg_dim = "-" + dim_name
            source_cell_for_pos_link_to_cell_id = self.cell_nbr(cell_id, neg_dim)
            if source_cell_for_pos_link_to_cell_id is not None:
                # Verification: self.cell_nbr(source_cell_for_pos_link_to_cell_id, "+" + dim_name) should be cell_id
                result_links.append(f"{source_cell_for_pos_link_to_cell_id}{"+" + dim_name}")

            # If cell Y is connected to cell_id via Y --neg_dim--> cell_id,
            # then cell_id must have cell_id --pos_dim--> Y.
            # So, source_cell = self.cell_nbr(cell_id, pos_dim). If it exists, then source_cell --neg_dim--> cell_id.
            pos_dim = "+" + dim_name
            source_cell_for_neg_link_to_cell_id = self.cell_nbr(cell_id, pos_dim)
            if source_cell_for_neg_link_to_cell_id is not None:
                # Verification: self.cell_nbr(source_cell_for_neg_link_to_cell_id, "-" + dim_name) should be cell_id
                result_links.append(f"{source_cell_for_neg_link_to_cell_id}{"-" + dim_name}")
        
        # The prompt's original logic was:
        # source_cell_for_pos = self.cell_nbr(cell_id, pos_dim) -> this is cell_id's neighbor in + direction.
        # If source_cell_for_pos exists, then cell_id --pos_dim--> source_cell_for_pos.
        # The link TO cell_id would be source_cell_for_pos --neg_dim--> cell_id.
        # This means my interpretation above was inverted. Let's correct based on prompt.

        result_links = [] # Resetting for clarity
        for dim_name in sorted_dimensions:
            pos_dim = "+" + dim_name
            neg_dim = "-" + dim_name

            # Who points to cell_id via its neg_dim? (i.e. cell_id is at the positive end of the link)
            # This means we look for a cell X such that X --pos_dim--> cell_id.
            # This X is self.cell_nbr(cell_id, neg_dim).
            source_cell_neg_conn = self.cell_nbr(cell_id, neg_dim)
            if source_cell_neg_conn is not None:
                # source_cell_neg_conn is connected to cell_id.
                # The connection from source_cell_neg_conn to cell_id is pos_dim.
                 result_links.append(f"{source_cell_neg_conn}{pos_dim}")

            # Who points to cell_id via its pos_dim? (i.e. cell_id is at the negative end of the link)
            # This means we look for a cell Y such that Y --neg_dim--> cell_id.
            # This Y is self.cell_nbr(cell_id, pos_dim).
            source_cell_pos_conn = self.cell_nbr(cell_id, pos_dim)
            if source_cell_pos_conn is not None:
                # source_cell_pos_conn is connected to cell_id.
                # The connection from source_cell_pos_conn to cell_id is neg_dim.
                 result_links.append(f"{source_cell_pos_conn}{neg_dim}")
        
        # The problem statement's original phrasing "source_cell_for_pos = self.cell_nbr(cell_id, pos_dim)"
        # means source_cell_for_pos is the cell *at the other end* of cell_id's pos_dim link.
        # If this source_cell_for_pos exists, it means cell_id --pos_dim--> source_cell_for_pos.
        # Therefore, source_cell_for_pos is linked back to cell_id via source_cell_for_pos --neg_dim--> cell_id.
        # This implies the link *to* cell_id is `source_cell_for_pos` + `neg_dim`. This is what I implemented.
        
        # It's important to ensure no duplicates if a dimension is malformed (e.g. cell linked to itself).
        # The current logic should be fine assuming bidirectional links are consistent.
        # Sorting result_links for deterministic output, though the order of dimensions already helps.
        return sorted(list(set(result_links))) # Using set to remove potential duplicates if any odd structures.

    def is_cursor(self, cell_id: str) -> bool:
        """Checks if the cell is a cursor cell (has any d.cursor link)."""
        if cell_id not in self.cells:
            return False
        return (self.cell_nbr(cell_id, "-d.cursor") is not None) or \
               (self.cell_nbr(cell_id, "+d.cursor") is not None)

    def is_clone(self, cell_id: str) -> bool:
        """Checks if the cell is a clone (has an incoming +d.clone link, i.e., an outgoing -d.clone link)."""
        if cell_id not in self.cells:
            return False
        # A cell is a clone if it has a link pointing "back" to its original along -d.clone
        return self.cell_nbr(cell_id, "-d.clone") is not None

    def is_selected(self, cell_id: str) -> bool:
        """Checks if the cell is part of any selection list."""
        if cell_id not in self.cells: # Added check for cell_id existence
            return False

        head_cell = self.get_last_cell(cell_id, "-d.mark")
        
        # If head_cell is None (should not happen if cell_id exists) or if cell_id is its own head
        # (meaning it's not part of a longer -d.mark chain), it can't be "selected" in the typical sense
        # unless it *is* the head_cell that is directly evaluated.
        if head_cell is None:
             return False
        
        # If cell_id is the head of its own -d.mark chain (i.e., it has no -d.mark link),
        # it cannot be part of a selection list unless it itself is directly linked from a selection cursor.
        # The key is whether this ultimate head_cell is connected to the SELECT_HOME structure.
        # A cell is selected if its ultimate -d.mark chain head (head_cell)
        # is itself a first_selected_cell for some selection list.
        # This means head_cell must have a -d.mark link to a cell in the SELECT_HOME's +d.2 chain.
        
        selection_list_head = self.cell_nbr(head_cell, "-d.mark")
        if selection_list_head is None: # head_cell is not pointed to by anything via +d.mark, so it's not a selected item.
            return False

        # Now, check if selection_list_head is part of the main selection cursor structure.
        current_scan_select_home: Optional[str] = SELECT_HOME_ID
        if SELECT_HOME_ID not in self.cells: return False

        visited_sel_heads: Set[str] = set()
        while current_scan_select_home is not None:
            if current_scan_select_home == selection_list_head:
                # And to ensure cell_id is not the selection_list_head itself (unless it's a loop of 1, which is odd for selection)
                # The original Perl implies that the "headcell" should not be the cell itself.
                # "head_cell == cell_id" means cell_id has no incoming -d.mark, so it's a chain head.
                # If this chain head (cell_id) is directly linked from a selection cursor, then it's selected.
                # The condition `head_cell != cell_id` in the original prompt for is_active_selected is important.
                # For is_selected, if cell_id is the first item in a selection chain,
                # head_cell will be cell_id. Its selection_list_head (parent via -d.mark) will be a selection cursor.
                # This seems correct.
                return True
            if current_scan_select_home in visited_sel_heads: break
            visited_sel_heads.add(current_scan_select_home)
            current_scan_select_home = self.cell_nbr(current_scan_select_home, "+d.2")
            
        return False

    def is_active_selected(self, cell_id: str) -> bool:
        """Checks if the cell is part of the active selection list (selection 0)."""
        if cell_id not in self.cells: # Added check
            return False
            
        head_cell = self.get_last_cell(cell_id, "-d.mark") # This is the first cell in this particular mark chain.
        
        if head_cell is None: return False # Should not happen if cell_id exists.
        
        # For cell_id to be actively selected:
        # 1. Its mark chain's head (head_cell) must be pointed to by SELECT_HOME_ID via +d.mark.
        #    This means head_cell's -d.mark link should be SELECT_HOME_ID.
        # 2. head_cell should not be cell_id itself, meaning cell_id is *in* the chain, not the head.
        #    Actually, if cell_id is the *only* item, head_cell == cell_id. It's still selected.
        #    The original Perl: "$headcell ne $cellid"
        #    If head_cell == cell_id, it means cell_id is the first element in the selection. This is fine.
        #    The crucial part is what `head_cell` (the start of this specific d.mark sequence) is connected to.
        
        # The "headcell" in Perl's is_active_selected is the start of the mark sequence containing $cellid.
        # This is what self.get_last_cell(cell_id, "-d.mark") returns.
        
        # Check if this head_cell is the one directly linked from SELECT_HOME_ID (the 0th selection list)
        if self.cell_nbr(head_cell, "-d.mark") == SELECT_HOME_ID:
            # The condition "$headcell ne $cellid" means the cell itself is not the head of the selection list.
            # This is subtle: if cell_id is the first item in the selection, get_last_cell(cell_id, "-d.mark") is cell_id.
            # So head_cell == cell_id.
            # If cell_id is the second, get_last_cell(cell_id, "-d.mark") is still the first item.
            # The prompt here seems to imply that if cell_id is the very first item, it's not "active selected" by this check.
            # However, standard interpretation is that all items in the active selection list are "active selected".
            # Let's assume the Perl's "$headcell ne $cellid" was to avoid some edge case or means something specific
            # about how selection is displayed or interacted with if one points *at* the head.
            # For now, if it's part of the chain whose parent is SELECT_HOME_ID, it's active selected.
            # The prompt's "head_cell == SELECT_HOME_ID and head_cell != cell_id" is confusing.
            # SELECT_HOME_ID is the *parent* of the head_cell of the active selection list.
            # It should be: self.cell_nbr(head_cell, "-d.mark") == SELECT_HOME_ID
            
            # Re-evaluating prompt for is_active_selected:
            # head_cell = self.get_last_cell(cell_id, "-d.mark")
            # Return head_cell == SELECT_HOME_ID and head_cell != cell_id
            # This means the start of the mark chain containing cell_id must BE SELECT_HOME_ID itself,
            # AND cell_id must not be SELECT_HOME_ID.
            # This interpretation implies SELECT_HOME_ID itself is the start of a d.mark chain for active selection.
            # This is different from SELECT_HOME_ID pointing *to* the start of the chain via +d.mark.
            # Let's follow the prompt directly for now.
            return head_cell == SELECT_HOME_ID and cell_id != SELECT_HOME_ID
            # However, this means that items selected under SELECT_HOME_ID would make SELECT_HOME_ID their "head_cell".
            # And if cell_id is one of those, cell_id != SELECT_HOME_ID would be true. This seems more plausible.
            # Example: SELECT_HOME_ID --+d.mark--> A --+d.mark--> B
            # get_last_cell(A, "-d.mark") -> SELECT_HOME_ID. So head_cell = SELECT_HOME_ID. cell_id = A. This is true.
            # get_last_cell(B, "-d.mark") -> SELECT_HOME_ID. So head_cell = SELECT_HOME_ID. cell_id = B. This is true.
            # This is likely the correct interpretation of the prompt.
        
        return False
