import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/subscription_service.dart';

part 'subscription_provider.g.dart';

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(Ref ref) => SubscriptionService();

@Riverpod(keepAlive: true)
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  FutureOr<bool> build() async {
    final service = ref.watch(subscriptionServiceProvider);

    // 1. Initialize Service (if not already)
    await service.init();

    // 2. Refresh logic
    // In real app:
    // final info = await service.getCustomerInfo();
    // return info?.entitlements.all['pro_access']?.isActive ?? false;

    return false;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(subscriptionServiceProvider);
      final info = await service.getCustomerInfo();
      return info?.entitlements.all['pro_access']?.isActive ?? false;
    });
  }
}
