import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  factory SubscriptionService() => _instance;

  SubscriptionService._internal();

  static final SubscriptionService _instance = SubscriptionService._internal();

  Future<void> init() async {
    // NOTE: Replace with your actual RevenueCat API keys
    // Ideally put these in an Env file or obfuscated config
    // For now, we use placeholders.
    await Purchases.setLogLevel(LogLevel.debug);

    // PurchasesConfiguration? configuration;

    // Attempt to detect platform - minimal config for now
    // In production, split mainly by platform
    // if (Platform.isAndroid) {
    //   configuration = PurchasesConfiguration('goog_api_key');
    // } else if (Platform.isIOS) {
    //    configuration = PurchasesConfiguration('appl_api_key');
    // }

    // Note: We need real keys to proceed.
    // For now I will mock the init if keys are missing or
    // encourage the user to add them.

    // if (configuration != null) {
    //   await Purchases.configure(configuration);
    // }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } on PlatformException catch (e) {
      debugPrint('Purchases error: $e');
      return null;
    }
  }

  Future<void> purchaseLifetimeAccess(BuildContext context) async {
    try {
      // Fetch offerings
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.lifetime != null) {
        final package = offerings.current!.lifetime!;
        // ignore: deprecated_member_use
        await Purchases.purchasePackage(package);
        // Provider will update automatically via listener if set up
      } else {
        // Show error: No offering found
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No purchase options available currently.'),
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Purchase error: $e');
    }
  }
}
