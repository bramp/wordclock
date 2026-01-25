import 'package:wordclock/generator/model/grid_build_result.dart';

/// Standard interface for all grid generation algorithms.
abstract class GridSolver {
  /// Attempts to build a valid grid based on the solver's configuration.
  GridBuildResult build();
}
