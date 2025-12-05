import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/input_box.dart';
import '../widgets/primary_button.dart';
import 'dashboard.dart';
import '../utils/animated_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/config_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool showOtp = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientEnd
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AppCard(
            children: [
              Image.asset("assets/images/tptrader_logo.png", height: 70),

              const SizedBox(height: 12),

              const Text(
                "Welcome",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 4),

              Text(
                showOtp ? "Enter OTP to continue" : "Sign in to continue",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // STEP 1: Mobile input
              if (!showOtp)
                InputBox(
                  controller: mobileController,
                  hint: "Mobile Number",
                  keyboard: TextInputType.number,
                ),

              // STEP 2: OTP input
              if (showOtp)
                InputBox(
                  controller: otpController,
                  hint: "Enter OTP",
                  keyboard: TextInputType.number,
                ),

              const SizedBox(height: 20),

              PrimaryButton(
                text: showOtp ? "Verify OTP" : "Quick Access",
                enabled: !loading,
                onTap: () async {
                  // FIRST SCREEN → Show OTP field
                  if (!showOtp) {
                    setState(() => showOtp = true);
                    return;
                  }

                  final mobile = mobileController.text.trim();
                  final otp = otpController.text.trim();

                  print("📲 Mobile entered: $mobile");
                  print("🔐 OTP entered: $otp");
                  print("🌐 Calling API: $kBaseUrl/auth/login");

                  if (mobile.isEmpty || otp.isEmpty) {
                    print("❌ Mobile or OTP empty!");
                    return;
                  }

                  setState(() => loading = true);

                  try {
                    final url = Uri.parse('$kBaseUrl/auth/login');

                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"mobile": mobile, "otp": otp}),
                    );

                    print("🌍 Backend Status: ${response.statusCode}");
                    print("📨 Backend Body: ${response.body}");

                    if (response.statusCode != 200) {
                      print("❌ Login failed.");
                      setState(() => loading = false);
                      return;
                    }

                    // PARSE RESPONSE
                    final data = jsonDecode(response.body);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString("loggedInMobile", mobile);

                    final profileNeeded = data["profile_needed"];

                    // EXISTING USER → STORE PROFILE
                    if (!profileNeeded) {
                      final p = data["profile"];

                      await prefs.setBool("hasProfile", true);
                      await prefs.setString("profileName", p["name"] ?? "");
                      await prefs.setString("profileCompany", p["company"] ?? "");
                      await prefs.setString("profileMobile", p["mobile"] ?? "");
                      await prefs.setString("profileGst", p["gst_number"] ?? "");
                      await prefs.setString("profileAddress", p["address"] ?? "");
                      await prefs.setString("profileLogo", p["logo_url"] ?? "");

                      print("🟢 Existing user → profile saved locally");
                    } else {
                      await prefs.setBool("hasProfile", false);
                      print("🟡 New user → needs profile creation");
                    }

                    if (!mounted) return;

                    // MOVE TO DASHBOARD
                    Navigator.pushReplacement(
                      context,
                      animatedRoute(const DashboardScreen()),
                    );

                  } catch (e) {
                    print("❌ Login exception: $e");
                  }

                  setState(() => loading = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
