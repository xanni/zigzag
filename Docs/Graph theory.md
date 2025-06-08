Graph theory
============

> In mathematics and computer science, graph theory is the study of graphs, which are mathematical structures used to model pairwise relations between objects. A graph in this context is made up of vertices (also called nodes or points) which are connected by edges (also called arcs, links or lines). A distinction is made between undirected graphs, where edges link two vertices symmetrically, and directed graphs, where edges link two vertices asymmetrically. Graphs are one of the principal objects of study in discrete mathematics.
>
> — [Graph theory](https://en.wikipedia.org/wiki/Graph_theory)

Zigzag is a way of representing, visualising and manipulating any structured information that can be described using graph theory, in other words a collection of items ("vertices", "nodes" or "points" in the conventional terminology and "cells" in Zigzag) connected by relationships between pairs of items ("edges", "arcs", "links" or "lines" in the conventional terminology and "links" in Zigzag).

Each cell has a locally unique identifier (generally a monotonically increasing integer in this implementation, with the largest cell ID stored in the exceptional cell whose ID is "n" rather than an integer).  To support "slices" (multiple collections of cells and links authored independently), it will also be necessary for cells to have globally unique IDs.

The links between cells have "labels" or "types", referred to as "dimensions" in Zigzag.  These links are directional, denoted by having a negative (origin) and positive (destination) endpoint.  The terms "negward" and "posward" are used in Zigzag to describe the negative and positive link directions respectively.

There can only be one link of a particular type between any two cells, so all links can be uniquely identified by the two cells involved and the dimension name.  The order of the two cells is significant and links between two cells in any specific uniquely named dimension can exist in neither, one or both directions:

* ① ②
* ① → ②
* ② ← ①
* ① ↔ ②

This allows Zigzag to describe both directed and undirected graphs, including those containing cycles.  The source and destination can be the same cell which is the degenerate case of a cycle of length zero.

The links can be expressed as the tuple "source, destination, dimension" but when implemented using a key-value store it is typically represented as the pair of items "source + dimension" → "destination" and "destination - dimension" → "source".  In this implementation it is vital that both of these matching entries must always exist as a pair, never in isolation.  This key-value implementation allows for rapidly finding and following links.  Finding all links for any given cell can also be efficiently performed if prefix matching on keys is supported, but in order to find all cells that participate in a specific dimension it is necessary to match key suffixes which is rarely supported and may require a search of the entire keyspace.  However since this information is currently only required when renaming dimensions, a very rarely performed operation, that is generally an acceptable trade-off.

A relational implementation would typically specify two unique indexes on "source, dimension" and "destination, dimension".

A group of cells connected by links with the same name is referred to as a "rank" or "row".  The furthest negatively connected cell in such a group is referred to as the "head".  In the case of a cycle every cell is considered to be the head.

Tree structures are a special case of graphs, and can be represented with the use of pairs of dimensions where one represents a sibling relationship between cells and the other a parent/child relationship.  The recursively furthest negatively connected cell in both such dimensions is considered the root of the tree.

In the original specifications, some dimension names are predefined having special meanings and functions for the user interface. These all now start with the characters lowercase "d" and period for clarity, though this was not the case in earlier versions.

Specifically, `d.1`, `d.2` and `d.3` are default dimensions used as the initial X, Y and Z axes rendered by the current user interfaces.  Currently only `d.1` and `d.2` have any additional special meanings.

`d.inside` and `d.contents` together implenent a concept of "containment" defined as follows: any cell that has a positive link in the `d.inside` dimension to a cell or a group of cells connected by positive links in the `d.contents` dimension, the latter are considered siblings whose individual contents are to be logically concatenated and visualised together by the user interface as "contents" of the initial "parent" cell, including any further cells connected in the same way by recursive depth-first descent.

`d.mark` implements a concept of "selection" defined as follows: given a known starting cell, zero or more groups of cells connected by positive links in the `d.mark` dimension are considered "selected" and visibly rendered distinctly in the user interface, each such group connected in a cycle along the `d.2` dimension starting from the initial selection home cell.  The first such group, connected in the `d.mark` dimension directly to the initial section home cell itself, is considered to be the "active" selection and may be the target of certain user interface operations.

`d.clone` implements "cloning" or "transcluding" in Xanadu terminology, allowing the contents of a cell to be referenced in multiple contexts.  The actual contents of all cells with negative links in the `d.clone` dimension are disregarded by the user interface and instead the contents of the "head" cell (the furthest cell in the negative `d.clone` direction) are used.  If a `d.clone` head cell (having a positive but no negative `d.clone` link) is deleted, the contents are copied to the cell formerly connected by the positive `d.clone` link which has thus become a new head cell or in the degenerate case when there are no remaining `d.clone` links simply an uncloned cell.

`d.cursor` implements visualisation and navigation of the structure in the user interfaces, where given a known starting cell each cell connected by positive links in the `d.2` dimension from the starting cell is considered to represent a "cursor" indicating a user interface focus of attention.  The furthest cell in the negative `d.cursor` direction from each such cursor cell is considered the target of that cursor and referred to as "accursed" in Zigzag terminology.  The various structure visualisations commence rendering from these cursor cells and they will also typically be the subject of user interface operations.

Current implementations maintain a list of dimensions as a rank of cells connected in the `d.2` dimension with the head of the list negatively linked in the `d.1` dimension to the known starting cell for the cursors in order to permit the dimensions to be introspected without an exhaustive search.
