# Zigzag Hyperstructure Kit - Python Port

This project is a Python port of the core functionalities of the Xanadu(R) Zigzag(tm) Hyperstructure Kit, originally implemented in Perl as `Zigzag.pm` (version 0.70).

## Description

Zigzag is a system for creating, viewing, and exploring complex multidimensional structures. It utilizes a network of "cells" connected by "links" across various "dimensions," allowing for flexible and powerful data organization and navigation. This port aims to replicate the fundamental data structures and operational logic of the original Perl module.

## Directory Structure

-   `python/zigzag/`: Contains the main library code.
    -   `core.py`: Defines the core classes (`Cell`, `ZigzagSpace`) and implements the majority of Zigzag operations, including cell manipulation, linking, navigation, cursor actions, and view logic.
    -   `persistence.py`: Handles data serialization and deserialization, including loading initial geometry and saving/loading the Zigzag space to/from JSON files.
-   `python/tests/`: Contains unit tests for the library.
    -   `test_core_basic.py`: Tests for fundamental cell and link operations.
    -   `test_core_advanced.py`: Tests for more complex operations, getters, and cursor logic.
    -   `test_persistence.py`: Tests for data loading and saving.

## Basic Usage (Conceptual)

```python
from zigzag.core import ZigzagSpace
from zigzag.persistence import slice_open, slice_sync_all

# Create a new Zigzag space (loads initial geometry if no file)
zz = ZigzagSpace()
slice_open(zz, "my_zigzag_space.json")

# --- Example operations ---
# Get content of cell '0' (typically "Home")
home_content = zz.cell_get("0")
print(f"Cell '0' content: {home_content}")

# Create a new cell
new_cell_id = zz.cell_new("My new data")

# Link cell '0' to the new cell along dimension '+d.example'
if home_content is not None: # Ensure cell '0' exists
    zz.link_make("0", new_cell_id, "+d.example")

# Navigate
neighbor_id = zz.cell_nbr("0", "+d.example")
if neighbor_id:
    print(f"Cell '0' is connected to cell '{neighbor_id}' along '+d.example'")

# Save changes
slice_sync_all(zz)
```

## Status of the Port

-   This port is based on `Zigzag.pm` version 0.70.
-   Most core data structures (`Cell`, `ZigzagSpace`), cell operations, linking, dimension management, cursor operations, "at cursor" actions, and view/layout logic have been ported.
-   The `atcursor_execute` function (which involved `eval` in Perl) has been intentionally omitted from this port due to security considerations.
-   User interface-specific components or hooks from the original Perl version (e.g., for Curses or web UIs) are not part of this core library port.
-   Custom exceptions are defined in `core.py`. Docstrings are present for these exceptions and for the main `Cell` and `ZigzagSpace` class definitions. Comprehensive in-code docstrings for all methods were planned, but their addition faced tooling issues during the automated generation process.
-   The persistence layer uses JSON files instead of `DB_File`.

## How to Run Tests (Conceptual)

To run the included unit tests, navigate to the directory containing the `python` folder and run:

```bash
python -m unittest discover python/tests
```
(This assumes a standard Python environment where the `zigzag` module can be found.)

## Dependencies

This core library port currently relies only on standard Python libraries.
