import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../subscription/subscription_manager.dart';
import '../second.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int selectedIndex = 1;
  bool _acceptedPrivacyPolicy = false;
  bool _acceptedTermsOfUse = false;
  bool _isProcessing = false;
  StreamSubscription? _purchaseSubscription;
  
  StreamSubscription<List<PurchaseDetails>>? _iapStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("Paywall: initState - subscribing to purchase streams");
      final manager = Provider.of<SubscriptionManager>(context, listen: false);
      _purchaseSubscription = manager.purchaseStream.listen((purchaseDetails) {
        debugPrint("Paywall: purchaseStream event - ${purchaseDetails.status}");
        // Reset processing UI on any purchase event (purchased, restored, canceled, or error)
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored ||
            purchaseDetails.status == PurchaseStatus.error ||
            purchaseDetails.status == PurchaseStatus.canceled) {
          setState(() => _isProcessing = false);
          if (purchaseDetails.status == PurchaseStatus.purchased) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CoachIntroPage()),
            );
          }
        }
      });
      _iapStreamSubscription = InAppPurchase.instance.purchaseStream.listen(
        (_) {},
        onError: (error) {
          debugPrint("Paywall: IAP purchaseStream error - $error");
          setState(() {
            _isProcessing = false;
          });
        },
      );
    });
  }

  void _showPurchaseStatusDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Status'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _iapStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sub = Provider.of<SubscriptionManager>(context);

    if (!sub.isAvailable || sub.products.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFFF6C00),
            elevation: 0,
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.restore, color: Colors.white),
                label: const Text(
                  'Restore Purchase',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  final sub = Provider.of<SubscriptionManager>(context, listen: false);
                  await sub.restoreSubscription();
                  final isSubscribed = sub.isSubscribed;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Restore Purchase"),
                      content: Text(
                        isSubscribed
                            ? "Your subscription has been successfully restored."
                            : "No active subscription found for this account.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (isSubscribed) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const CoachIntroPage()),
                              );
                            }
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6C00), Color(0xFFFF6C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Atomfit",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "“Unleash the healthiest version of you.”",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Learn Workouts with Augmented Reality (AR) and improve your posture with AI-powered corrections.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Choose your plan",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildPlanOption(index: 0, label: "1 Month", price: "\$4.99/mo", isSelected: selectedIndex == 0),
                                  _buildPlanOption(index: 1, label: "3 Months", price: "\$11.99/quarterly", isSelected: selectedIndex == 1),
                                  _buildPlanOption(index: 2, label: "12 Months", price: "\$29.99/year", isSelected: selectedIndex == 2),
                                ],
                              ),
                              const SizedBox(height: 24),
                              CheckboxListTile(
                                title: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: const TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                        recognizer: (TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(Uri.parse('https://atomicity.in/privacy-policy'));
                                          }),
                                      ),
                                    ],
                                  ),
                                ),
                                value: _acceptedPrivacyPolicy,
                                onChanged: (val) {
                                  setState(() => _acceptedPrivacyPolicy = val ?? false);
                                  debugPrint("Paywall: Privacy checkbox changed - $_acceptedPrivacyPolicy");
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                              CheckboxListTile(
                                title: RichText(
                                  text: TextSpan(
                                    text: 'By using this app, you agree to Apple’s ',
                                    style: TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Use',
                                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            launchUrl(Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                                          },
                                      ),
                                      TextSpan(
                                        text: '.',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                value: _acceptedTermsOfUse,
                                onChanged: (val) {
                                  setState(() => _acceptedTermsOfUse = val ?? false);
                                  debugPrint("Paywall: Terms checkbox changed - $_acceptedTermsOfUse");
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: (_acceptedPrivacyPolicy && _acceptedTermsOfUse)
                                          ? () async {
                                              debugPrint("Paywall: Button pressed - starting processing");
                                              setState(() => _isProcessing = true);
                                              await Future.delayed(const Duration(milliseconds: 1000));
                                              debugPrint("🔸 Continue button pressed");
                                              debugPrint("🔹 Available products: ${sub.products.length}");
                                              debugPrint("🔹 Selected index: $selectedIndex");

                                              String expectedProductId;
                                              switch (selectedIndex) {
                                                case 0:
                                                  expectedProductId = 'monthly';
                                                  break;
                                                case 1:
                                                  expectedProductId = 'quaterly';
                                                  break;
                                                case 2:
                                                  expectedProductId = 'yearly';
                                                  break;
                                                default:
                                                  expectedProductId = '';
                                              }

                                              final selectedProduct = sub.products.firstWhere(
                                                (p) => p.id == expectedProductId,
                                                orElse: () => throw Exception("❌ Product not found for expected ID: $expectedProductId"),
                                              );

                                              debugPrint("Paywall: Calling buySubscription for $expectedProductId");
                                              debugPrint("🛒 Attempting to purchase: ${selectedProduct.title} (${selectedProduct.id})");
                                              sub.buySubscription(selectedProduct);
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isProcessing ? Colors.grey : const Color(0xFFFF6C00),
                                        minimumSize: const Size(double.infinity, 60),
                                        shape: const StadiumBorder(),
                                      ),
                                      child: Text(
                                        _isProcessing ? "Processing..." : "Continue",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: Column(
                                        children: [
                                          Text(
                                            "Subscribe to Atomfit Premium",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "• Full access to all AR workout demos\n"
                                            "• AI-powered posture tracking and correction\n"
                                            "• Personalized workout plans\n"
                                            "• Access to leaderboard and group challenges\n"
                                            "• Priority support and new feature access",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "*Subscription renews automatically unless cancelled at least 24 hours before the end of the current period.",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanOption({
    required int index,
    required String label,
    String? price,
    String? original,
    String? discounted,
    String? badge,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = index),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFE7D1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFE6B02) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFA500).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (original != null)
                    Text(
                      original,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (discounted != null)
                    const SizedBox(height: 4),
                  Text(
                    discounted ?? price!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFE6B02),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected && badge != null)
              Positioned(
                top: -12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFE6B02),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
