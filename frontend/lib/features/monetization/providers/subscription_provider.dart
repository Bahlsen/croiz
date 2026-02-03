import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/subscription_service.dart';

part 'subscription_provider.g.dart';

@Riverpod(keepAlive: true)
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  FutureOr<bool> build() async {
    // 1. Initialize Service (if not already) - strictly speaking should be in main but lazy init is okay for now
    await SubscriptionService().init();

    // 2. Mock check for "pro_access" entitlement
    // In real app:
    // final info = await SubscriptionService().getCustomerInfo();
    // return info?.entitlements.all['pro_access']?.isActive ?? false;

    // Default to false
    return false;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final info = await SubscriptionService().getCustomerInfo();
      return info?.entitlements.all['pro_access']?.isActive ?? false;
    });
  }
}
