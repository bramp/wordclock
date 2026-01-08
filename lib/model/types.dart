// Common type aliases for word clock grid operations.
//
// These types improve code readability by providing semantic names
// for commonly used list types in grid operations.

/// A single cell in the grid (a character or multi-char unit like O' in O'Clock).
typedef Cell = String;

/// A word as a list of cells (e.g., ['O\'', 'C', 'L', 'O', 'C', 'K']).
typedef Word = List<Cell>;

/// A phrase as a list of words (e.g., [['F','I','V','E'], ['P','A','S','T']]).
typedef Phrase = List<Word>;
