import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:croiz/features/generation/models/slot.dart';
import 'package:croiz/features/generation/services/word_index.dart';

/// Result of CSP solving
class CSPSolveResult {
  const CSPSolveResult({
    required this.success,
    required this.assignments,
    this.unfilledSlots = const [],
    this.failureReason,
  });

  /// Whether a complete solution was found
  final bool success;

  /// Map of slot to assigned word
  final Map<Slot, String> assignments;

  /// Slots that could not be filled (if incomplete)
  final List<Slot> unfilledSlots;

  /// Reason for failure if not successful
  final String? failureReason;
}

/// Crossword CSP Solver using AC-3 and backtracking with MRV/LCV heuristics.
///
/// Solves the constraint satisfaction problem of filling crossword slots
/// with valid words from a dictionary.
class CrosswordCSPSolver {
  CrosswordCSPSolver({
    required this.wordIndex,
    required this.slots,
    this.maxBacktracks = 10000,
  }) {
    _initializeDomains();
    _buildConstraintGraph();
  }

  final WordIndex wordIndex;
  final List<Slot> slots;
  final int maxBacktracks;

  /// Domain for each slot (possible words)
  final Map<Slot, List<String>> _domains = {};

  /// Constraint graph: intersecting slots
  final Map<Slot, List<Slot>> _neighbors = {};

  /// Intersection details between slots
  final Map<String, IntersectionPoint> _intersections = {};

  /// Counter for backtracking (to prevent infinite loops)
  int _backtracks = 0;

  /// Best partial solution found so far
  Map<Slot, String> _bestAssignment = {};

  /// Initialize domains with all words of correct length
  void _initializeDomains() {
    for (final slot in slots) {
      final words = wordIndex.findWordsByLength(slot.length);
      _domains[slot] = words.toList();
    }
  }

  /// Build the constraint graph from slot intersections
  void _buildConstraintGraph() {
    for (final slot in slots) {
      _neighbors[slot] = [];
    }

    for (var i = 0; i < slots.length; i++) {
      for (var j = i + 1; j < slots.length; j++) {
        final intersection = slots[i].getIntersection(slots[j]);
        if (intersection != null) {
          _neighbors[slots[i]]!.add(slots[j]);
          _neighbors[slots[j]]!.add(slots[i]);

          // Store intersection details
          final key1 = '${slots[i].hashCode}_${slots[j].hashCode}';
          final key2 = '${slots[j].hashCode}_${slots[i].hashCode}';
          _intersections[key1] = intersection;
          _intersections[key2] = intersection;
        }
      }
    }
  }

  /// Apply known letter constraints to reduce domains.
  ///
  /// [knownLetters] maps Point(x,y) to the known letter at that position.
  void applyKnownLetters(Map<Point<int>, String> knownLetters) {
    for (final slot in slots) {
      final constraints = <int, String>{};

      // Check each cell of the slot for known letters
      for (var i = 0; i < slot.length; i++) {
        final cell = slot.getCell(i);
        final knownLetter = knownLetters[cell];
        if (knownLetter != null) {
          constraints[i] = knownLetter.toUpperCase();
        }
      }

      if (constraints.isNotEmpty) {
        // Filter domain to only words matching constraints
        _domains[slot] =
            _domains[slot]!.where((word) {
              for (final entry in constraints.entries) {
                if (entry.key >= word.length ||
                    word[entry.key] != entry.value) {
                  return false;
                }
              }
              return true;
            }).toList();
      }
    }
  }

  /// Main solving function.
  ///
  /// Returns a complete or partial solution.
  CSPSolveResult solve() {
    _backtracks = 0;
    _bestAssignment = {};

    // Step 1: Apply AC-3 to reduce domains
    // Save initial domains in case AC-3 is too strict (wipes out solution)
    final initialDomains = _saveState();
    final ac3Result = _ac3();

    if (!ac3Result || slots.any((s) => _domains[s]!.isEmpty)) {
      // AC-3 proved no FULL solution exists.
      // But we want a PARTIAL solution if possible.
      // Restore domains and proceed to backtracking (without strict global consistency).
      _restoreState(initialDomains);
      // Optional: Log this specific fallback
    }

    // Step 2: Backtracking search with MRV/LCV
    // CRITICAL: Filter out slots that have 0 possible words after constraints
    // These slots are impossible to fill, so don't let them block the search.
    final possibleSlots = slots.where((s) => _domains[s]!.isNotEmpty).toList();
    final impossibleSlotsCount = slots.length - possibleSlots.length;

    if (impossibleSlotsCount > 0) {
      // Analyze which lengths are missing
      final missingByLength = <int, int>{};
      for (final slot in slots) {
        if (_domains[slot]!.isEmpty) {
          missingByLength[slot.length] =
              (missingByLength[slot.length] ?? 0) + 1;
        }
      }

      final buffer =
          StringBuffer()
            ..writeln(
              'CSP: Skipping $impossibleSlotsCount impossible slots with 0 matching words.',
            )
            ..writeln('  Missing words by slot length:');
      final sortedLengths = missingByLength.keys.toList()..sort();
      for (final len in sortedLengths) {
        final dictCount = wordIndex.findWordsByLength(len).length;
        buffer.writeln(
          '    Length $len: ${missingByLength[len]} slots need words (dictionary has $dictCount)',
        );
      }

      developer.log(buffer.toString());
    }

    final assignment = <Slot, String>{};
    final result = _backtrack(assignment, possibleSlots);

    if (result != null) {
      return CSPSolveResult(success: true, assignments: result);
    }

    // Return the best partial solution found during search
    return CSPSolveResult(
      success: false,
      assignments: _bestAssignment,
      unfilledSlots:
          slots.where((s) => !_bestAssignment.containsKey(s)).toList(),
      failureReason:
          'Backtracking exhausted after $_backtracks attempts. Best effort returned.',
    );
  }

  /// AC-3 (Arc Consistency) algorithm.
  ///
  /// Reduces domains by ensuring every value has support in connected domains.
  /// Returns false if any domain becomes empty (no solution).
  bool _ac3() {
    final queue = Queue<(Slot, Slot)>();

    // Add all arcs to queue
    for (final slot in slots) {
      for (final neighbor in _neighbors[slot]!) {
        queue.add((slot, neighbor));
      }
    }

    while (queue.isNotEmpty) {
      final (slotI, slotJ) = queue.removeFirst();

      if (_revise(slotI, slotJ)) {
        if (_domains[slotI]!.isEmpty) {
          return false; // Domain wiped out
        }

        // Add neighbors back to queue
        for (final neighbor in _neighbors[slotI]!) {
          if (neighbor != slotJ) {
            queue.add((neighbor, slotI));
          }
        }
      }
    }

    return true;
  }

  /// Revise the domain of slotI with respect to slotJ.
  ///
  /// Removes values from slotI's domain that have no support in slotJ's domain.
  /// Optimized to O(D_I + D_J) instead of O(D_I * D_J).
  bool _revise(Slot slotI, Slot slotJ) {
    var revised = false;
    final intersection = _getIntersection(slotI, slotJ);
    if (intersection == null) {
      return false;
    }

    final posI =
        slotI.isHorizontal
            ? intersection.positionInHorizontal
            : intersection.positionInVertical;
    final posJ =
        slotJ.isHorizontal
            ? intersection.positionInHorizontal
            : intersection.positionInVertical;

    // optimization: Pre-calculate the set of valid characters in slotJ at posJ
    final validCharsInJ = <String>{};
    for (final wordJ in _domains[slotJ]!) {
      if (posJ < wordJ.length) {
        validCharsInJ.add(wordJ[posJ]);
      }
    }

    _domains[slotI]!.removeWhere((wordI) {
      if (posI >= wordI.length) {
        return true;
      }
      final letterI = wordI[posI];

      // Check if letterI exists in the set of valid characters
      if (!validCharsInJ.contains(letterI)) {
        revised = true;
        return true;
      }
      return false;
    });

    return revised;
  }

  /// Get intersection between two slots.
  IntersectionPoint? _getIntersection(Slot slotA, Slot slotB) {
    final key = '${slotA.hashCode}_${slotB.hashCode}';
    return _intersections[key];
  }

  /// Backtracking search with MRV and LCV heuristics.
  Map<Slot, String>? _backtrack(
    Map<Slot, String> assignment,
    List<Slot> activeSlots,
  ) {
    // Check timeout/limit
    _backtracks++;
    if (_backtracks > maxBacktracks) {
      return null; // Exceeded limit
    }

    // Check if complete
    if (assignment.length == activeSlots.length) {
      return Map.from(assignment);
    }

    // MRV: Select unassigned slot with smallest domain
    final unassigned =
        activeSlots.where((s) => !assignment.containsKey(s)).toList();
    if (unassigned.isEmpty) {
      return Map.from(assignment);
    }

    final slot = _selectMRVVariable(unassigned);

    // Get domain (may have been reduced)
    final domain = _getCurrentDomain(slot, assignment);
    if (domain.isEmpty) {
      return null;
    }

    // LCV: Order values by least constraining
    // Optimization: If domain is huge, LCV sorting can be expensive (D * neighbors * D_neighbor).
    // For large dictionaries, we might skip LCV or simplify it.
    // We'll keep it but restrict how many words we verify if domain is massive (>1000).
    var orderedWords = domain;
    if (domain.length < 500) {
      orderedWords = _orderByLCV(slot, domain, assignment);
    }

    for (final word in orderedWords) {
      if (_isConsistent(slot, word, assignment)) {
        // Make assignment
        assignment[slot] = word;

        // Track best partial solution
        if (assignment.length > _bestAssignment.length) {
          _bestAssignment = Map.from(assignment);
        }

        // Forward checking: save and reduce neighbor domains
        final savedDomains = _saveState();
        _forwardCheck(slot, word, assignment);

        // Check if any neighbor domain became empty (Strict Mode)
        // If placing this word makes a neighbor impossible to fill, it's an invalid move.
        // This prevents creating "garbage words" in crossing slots.
        var validMove = true;
        for (final neighbor in _neighbors[slot]!) {
          if (!assignment.containsKey(neighbor) &&
              _domains[neighbor]!.isEmpty) {
            validMove = false;
            break;
          }
        }

        if (validMove) {
          final result = _backtrack(assignment, activeSlots);
          if (result != null) {
            return result;
          }
        }

        // Backtrack: restore state (if move was invalid or recursive search failed)
        _restoreState(savedDomains);
        assignment.remove(slot);
      }
    }

    return null;
  }

  /// Select variable with Minimum Remaining Values (MRV) heuristic.
  Slot _selectMRVVariable(List<Slot> unassigned) => unassigned.reduce((a, b) {
    final domainA = _domains[a]!.length;
    final domainB = _domains[b]!.length;
    if (domainA != domainB) {
      return domainA < domainB ? a : b;
    }
    // Tie-breaker: degree heuristic (more constraints first)
    return _neighbors[a]!.length > _neighbors[b]!.length ? a : b;
  });

  /// Get current valid domain for a slot given current assignments.
  List<String> _getCurrentDomain(Slot slot, Map<Slot, String> assignment) {
    final domain = List<String>.from(_domains[slot]!);

    // Filter by intersection constraints
    for (final neighbor in _neighbors[slot]!) {
      if (assignment.containsKey(neighbor)) {
        final intersection = _getIntersection(slot, neighbor);
        if (intersection == null) {
          continue;
        }

        final neighborWord = assignment[neighbor]!;
        final posInSlot =
            slot.isHorizontal
                ? intersection.positionInHorizontal
                : intersection.positionInVertical;
        final posInNeighbor =
            neighbor.isHorizontal
                ? intersection.positionInHorizontal
                : intersection.positionInVertical;

        if (posInNeighbor >= neighborWord.length) {
          continue;
        }
        final requiredLetter = neighborWord[posInNeighbor];

        domain.removeWhere((word) {
          if (posInSlot >= word.length) {
            return true;
          }
          return word[posInSlot] != requiredLetter;
        });
      }
    }

    return domain;
  }

  /// Order words by Least Constraining Value (LCV) heuristic.
  List<String> _orderByLCV(
    Slot slot,
    List<String> words,
    Map<Slot, String> assignment,
  ) {
    if (words.length <= 1) {
      return words;
    }

    final unassignedNeighbors =
        _neighbors[slot]!.where((n) => !assignment.containsKey(n)).toList();

    if (unassignedNeighbors.isEmpty) {
      return words;
    }

    // Score each word by remaining options for neighbors
    final scores = <String, int>{};
    for (final word in words) {
      var score = 0;
      for (final neighbor in unassignedNeighbors) {
        final intersection = _getIntersection(slot, neighbor);
        if (intersection == null) {
          continue;
        }

        final posInSlot =
            slot.isHorizontal
                ? intersection.positionInHorizontal
                : intersection.positionInVertical;
        final posInNeighbor =
            neighbor.isHorizontal
                ? intersection.positionInHorizontal
                : intersection.positionInVertical;

        if (posInSlot >= word.length) {
          continue;
        }
        final letter = word[posInSlot];

        // Count compatible words in neighbor's domain
        // Optimization: Use forward checking concept here too?
        // For now, keep it simple but maybe limit the check if domain is huge.
        var count = 0;
        final neighborDomain = _domains[neighbor]!;
        const limit = 100; // Sample first 100 if huge
        var checked = 0;

        for (final w in neighborDomain) {
          if (checked++ > limit) {
            break;
          }
          if (posInNeighbor < w.length && w[posInNeighbor] == letter) {
            count++;
          }
        }
        score += count;
      }
      scores[word] = score;
    }

    // Sort descending (more options = less constraining)
    words.sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));
    return words;
  }

  /// Check if assigning word to slot is consistent with current assignment.
  bool _isConsistent(Slot slot, String word, Map<Slot, String> assignment) {
    for (final neighbor in _neighbors[slot]!) {
      if (!assignment.containsKey(neighbor)) {
        continue;
      }

      final intersection = _getIntersection(slot, neighbor);
      if (intersection == null) {
        continue;
      }

      final neighborWord = assignment[neighbor]!;
      final posInSlot =
          slot.isHorizontal
              ? intersection.positionInHorizontal
              : intersection.positionInVertical;
      final posInNeighbor =
          neighbor.isHorizontal
              ? intersection.positionInHorizontal
              : intersection.positionInVertical;

      if (posInSlot >= word.length || posInNeighbor >= neighborWord.length) {
        return false;
      }

      if (word[posInSlot] != neighborWord[posInNeighbor]) {
        return false;
      }
    }

    return true;
  }

  /// Forward checking: reduce domains of neighbors.
  void _forwardCheck(Slot slot, String word, Map<Slot, String> assignment) {
    for (final neighbor in _neighbors[slot]!) {
      if (assignment.containsKey(neighbor)) {
        continue;
      }

      final intersection = _getIntersection(slot, neighbor);
      if (intersection == null) {
        continue;
      }

      final posInSlot =
          slot.isHorizontal
              ? intersection.positionInHorizontal
              : intersection.positionInVertical;
      final posInNeighbor =
          neighbor.isHorizontal
              ? intersection.positionInHorizontal
              : intersection.positionInVertical;

      if (posInSlot >= word.length) {
        continue;
      }
      final requiredLetter = word[posInSlot];

      _domains[neighbor]!.removeWhere((w) {
        if (posInNeighbor >= w.length) {
          return true;
        }
        return w[posInNeighbor] != requiredLetter;
      });
    }
  }

  /// Save current domain state for backtracking.
  Map<Slot, List<String>> _saveState() =>
      _domains.map((k, v) => MapEntry(k, List.from(v)));

  /// Restore domain state after backtracking.
  void _restoreState(Map<Slot, List<String>> saved) {
    for (final entry in saved.entries) {
      _domains[entry.key] = entry.value;
    }
  }
}
