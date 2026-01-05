import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) =>
    AlchemistConfig.runWithConfig(
      config: AlchemistConfig(
        theme: ThemeData(),
        platformGoldensConfig: const PlatformGoldensConfig(enabled: true),
      ),
      run: () async => await testMain(),
    );
