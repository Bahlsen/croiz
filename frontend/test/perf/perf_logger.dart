// Simple perf logging helper controlled by Dart environment flag.
const bool kPerfVerbose = bool.fromEnvironment(
  'PERF_VERBOSE',
  defaultValue: false,
);

void perfPrint(String message) {
  if (kPerfVerbose) {
    // ignore: avoid_print
    print(message);
  }
}
