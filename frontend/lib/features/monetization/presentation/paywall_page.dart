import 'package:croiz/features/monetization/providers/subscription_provider.dart';
import 'package:croiz/features/monetization/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to purchase status. If becomes true, pop.
    ref.listen(subscriptionProvider, (previous, next) {
      next.whenData((isPremium) {
        if (isPremium) {
          if (context.mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Welcome to Premium! Ads removed.')),
            );
          }
        }
      });
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6E207C), // Deep Purple
                  Color(0xFF2196F3), // Blue
                  Color(0xFF00BCD4), // Cyan
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  const Spacer(),
                  // Icon / Lottie
                  Icon(Icons.diamond_outlined, size: 15.h, color: Colors.white)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .shimmer(delay: 1000.ms, duration: 1500.ms),

                  SizedBox(height: 4.h),

                  Text(
                    'Unlock Croiz Premium',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.3),

                  SizedBox(height: 2.h),

                  Text(
                    'Enjoy a distraction-free experience and support independent development.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),

                  SizedBox(height: 6.h),

                  // Benefits
                  _buildBenefitRow(
                    context,
                    Icons.block,
                    'No Ads (Banners & Popups)',
                  ),
                  SizedBox(height: 2.h),
                  _buildBenefitRow(
                    context,
                    Icons.favorite,
                    'Support Development',
                  ),

                  const Spacer(flex: 2),

                  // Price Card
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lifetime Access',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              'One-time purchase',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          r'$9.99',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  SizedBox(height: 4.h),

                  // Purchase Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.5.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6E207C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        // Trigger purchase logic
                        SubscriptionService().purchaseLifetimeAccess(context);
                      },
                      child: Text(
                        'Purchase',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(),

                  SizedBox(height: 2.h),

                  // Restore
                  TextButton(
                    onPressed: () {
                      // SubscriptionService().restore();
                    },
                    child: Text(
                      'Restore Purchases',
                      style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(BuildContext context, IconData icon, String text) =>
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 300.ms).slideX();
}
