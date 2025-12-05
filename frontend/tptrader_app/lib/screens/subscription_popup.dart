import 'package:flutter/material.dart';
import '../screens/profile/profile_form_popup.dart';   // adjust path if needed

class SubscriptionPopup extends StatelessWidget {
  final VoidCallback onFreeTrial;

  const SubscriptionPopup({
    super.key,
    required this.onFreeTrial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Choose Plan",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          // FREE TRIAL
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: onFreeTrial,
            child: const Text(
              "Start Free Trial",
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 12),

          // PREMIUM PLAN
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.deepPurpleAccent,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Premium plan coming soon")),
              );
            },
            child: const Text(
              "Premium – ₹299/month",
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
