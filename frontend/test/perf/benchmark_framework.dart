/// Performance benchmark utilities for Croiz.
///
/// Wraps `benchmark_harness` with additional utilities for:
/// - Saving/loading baseline results
/// - Comparing runs and detecting regressions
/// - CI integration
library;

import 'dart:convert';
import 'dart:io';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'perf_logger.dart';

export 'package:benchmark_harness/benchmark_harness.dart';

/// Extended result with additional statistics for comparison.
class BenchmarkResultExt {
  const BenchmarkResultExt({
    required this.name,
    required this.runtimeUs,
    this.iterations,
  });

  factory BenchmarkResultExt.fromJson(Map<String, dynamic> json) =>
      BenchmarkResultExt(
        name: json['name'] as String,
        runtimeUs: (json['runtimeUs'] as num).toDouble(),
        iterations: json['iterations'] as int?,
      );

  final String name;

  /// Average runtime in microseconds (per run() call).
  final double runtimeUs;
  final int? iterations;

  double get runtimeMs => runtimeUs / 1000;

  Map<String, dynamic> toJson() => {
    'name': name,
    'runtimeUs': runtimeUs,
    if (iterations != null) 'iterations': iterations,
  };

  @override
  String toString() =>
      '$name: ${runtimeUs.toStringAsFixed(2)} us (${runtimeMs.toStringAsFixed(3)} ms)';
}

/// Comparison between baseline and current benchmark.
class BenchmarkComparison {
  const BenchmarkComparison({
    required this.name,
    required this.baselineUs,
    required this.currentUs,
    required this.deltaPercent,
    required this.isRegression,
  });

  final String name;
  final double baselineUs;
  final double currentUs;
  final double deltaPercent;
  final bool isRegression;

  @override
  String toString() {
    final status = isRegression ? '❌ REGRESSION' : '✅ OK';
    final sign = deltaPercent >= 0 ? '+' : '';
    return '$name: ${baselineUs.toStringAsFixed(2)} us -> '
        '${currentUs.toStringAsFixed(2)} us '
        '($sign${deltaPercent.toStringAsFixed(1)}%) $status';
  }
}

/// Emitter that captures the result for later use.
class CapturingEmitter implements ScoreEmitter {
  double? capturedRuntimeUs;

  @override
  void emit(String testName, double value) {
    capturedRuntimeUs = value;
    // Also print to console for immediate feedback.
    perfPrint('$testName: ${value.toStringAsFixed(2)} us');
  }
}

/// Extension on BenchmarkBase for easier result capture.
extension BenchmarkBaseExt on BenchmarkBase {
  /// Run benchmark and return result with captured runtime.
  BenchmarkResultExt reportAndCapture() {
    final emitter = CapturingEmitter();
    // Use measureFor to get the runtime, then emit manually.
    final runtime = measure();
    emitter.emit(name, runtime);
    return BenchmarkResultExt(name: name, runtimeUs: runtime);
  }
}

/// Utilities for saving, loading and comparing benchmark results.
class BenchmarkStorage {
  BenchmarkStorage({this.resultsDir = 'test/perf/results'});

  final String resultsDir;

  /// Save results to a JSON file.
  void save(List<BenchmarkResultExt> results, String filename) {
    final dir = Directory(resultsDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('$resultsDir/$filename');
    final json = {
      'timestamp': DateTime.now().toIso8601String(),
      'results': results.map((r) => r.toJson()).toList(),
    };
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
    perfPrint('Saved benchmark results to ${file.path}');
  }

  /// Load results from a JSON file.
  List<BenchmarkResultExt> load(String filename) {
    final file = File('$resultsDir/$filename');
    if (!file.existsSync()) {
      throw ArgumentError('Baseline file not found: ${file.path}');
    }

    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final resultsList = json['results'] as List<dynamic>;
    return resultsList
        .map((r) => BenchmarkResultExt.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Check if baseline exists.
  bool hasBaseline(String filename) =>
      File('$resultsDir/$filename').existsSync();

  /// Compare current results against baseline.
  List<BenchmarkComparison> compare(
    List<BenchmarkResultExt> baseline,
    List<BenchmarkResultExt> current, {
    double regressionThresholdPercent = 20.0,
  }) {
    final baselineMap = {for (final r in baseline) r.name: r};
    final comparisons = <BenchmarkComparison>[];

    for (final curr in current) {
      final base = baselineMap[curr.name];
      if (base == null) {
        perfPrint('Missing baseline for ${curr.name}');
        continue;
      }

      final delta = ((curr.runtimeUs - base.runtimeUs) / base.runtimeUs) * 100;
      comparisons.add(
        BenchmarkComparison(
          name: curr.name,
          baselineUs: base.runtimeUs,
          currentUs: curr.runtimeUs,
          deltaPercent: delta,
          isRegression: delta > regressionThresholdPercent,
        ),
      );
    }

    return comparisons;
  }

  /// Check if any comparison shows regression.
  static bool hasRegressions(List<BenchmarkComparison> comparisons) =>
      comparisons.any((c) => c.isRegression);

  /// Print comparison summary.
  static void printSummary(List<BenchmarkComparison> comparisons) {
    perfPrint('Benchmark comparisons:');
    for (final c in comparisons) {
      perfPrint(c.toString());
    }

    final regressions = comparisons.where((c) => c.isRegression).toList();
    if (regressions.isEmpty) {
      perfPrint('All benchmarks within threshold');
    } else {
      perfPrint('${regressions.length} benchmark regression(s) detected');
    }
  }
}

/// Run multiple benchmarks and return results.
List<BenchmarkResultExt> runBenchmarks(List<BenchmarkBase> benchmarks) {
  final results = <BenchmarkResultExt>[];
  for (final b in benchmarks) {
    perfPrint('Running benchmark: ${b.name}');
    final result = b.reportAndCapture();
    results.add(result);
  }
  return results;
}
