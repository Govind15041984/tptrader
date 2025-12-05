import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import '../widgets/feature_card.dart';
import '../screens/subscription_popup.dart';
import '../screens/profile/profile_form_popup.dart';
import 'profile/update_profile_popup.dart';
import '../api/profile_api.dart';
import 'profile/profile_overview_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {

  String loggedInMobile = "";
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDashboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔥 Auto refresh when app returns to foreground OR screen becomes visible
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfile();
    }
  }

  // ---------------------------------------------------------
  // INITIAL LOAD
  // ---------------------------------------------------------
  Future<void> _initDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    loggedInMobile = prefs.getString("loggedInMobile") ?? "";

    if (loggedInMobile.isNotEmpty) {
      await _loadProfile();
    }

    setState(() {});
  }

  Future<void> _loadProfile() async {
    final data = await getProfile(loggedInMobile);

    if (data != null && data.isNotEmpty) {
      _profileData = data;
    } else {
      _profileData = null;
    }

    print("🔍 PROFILE LOADED → $_profileData");
    setState(() {});
  }

  // ---------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------
  Widget _buildHeader() {
    if (_profileData == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TPTrader",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 6),
          Text("Welcome!",
              style: TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      );
    }

    final companyName = _profileData!["company_name"] ?? "Trader";
    String? logoUrl = _profileData!["logo_url"];

    // 🔥 Add cache-busting timestamp
    if (logoUrl != null && logoUrl.isNotEmpty) {
      logoUrl = "$logoUrl?v=${DateTime.now().millisecondsSinceEpoch}";
    }

    print("🖼 DASHBOARD AVATAR URL → $logoUrl");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileOverviewScreen(profile: _profileData),
              ),
            );

            // 🔥 Always refresh after returning from profile
            await _loadProfile();
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              backgroundImage:
              (logoUrl != null && logoUrl.isNotEmpty)
                  ? NetworkImage(logoUrl)
                  : null,
              onBackgroundImageError: (_, __) =>
                  print("⚠️ Avatar load failed"),
              child: (logoUrl == null || logoUrl.isEmpty)
                  ? const Icon(Icons.person, size: 40, color: Colors.purple)
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          "Welcome, $companyName!",
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // FEATURE CARDS
  // ---------------------------------------------------------
  Widget _buildFeatureCards() {
    if (_profileData == null) {
      return Column(
        children: [
          FeatureCard(
            icon: Icons.person_outline,
            title: "Create Profile",
            subtitle: "Add your business details",
            onTap: () => _showSubscriptionPopup(context),
          ),
          const SizedBox(height: 20),
          FeatureCard(
            icon: Icons.note_add_outlined,
            title: "Create Order",
            subtitle: "Generate your first job order",
            onTap: () => _showSubscriptionPopup(context),
          ),
        ],
      );
    }

    return Column(
      children: [
        FeatureCard(
          icon: Icons.note_add_outlined,
          title: "Create Order",
          subtitle: "Generate your first job order",
          onTap: () => _showSubscriptionPopup(context),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // POPUPS
  // ---------------------------------------------------------
  void _showSubscriptionPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SubscriptionPopup(
          onFreeTrial: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return ProfileFormPopup(
                  mobile: loggedInMobile,
                  onSubmit: (name, company) async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await Future.delayed(const Duration(milliseconds: 150));

                    final ok =
                    await createProfileApi(name, company, loggedInMobile);

                    await _loadProfile();
                    Fluttertoast.showToast(
                      msg: ok ? "Profile created" : "Failed",
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundGradientStart,
                    AppColors.backgroundGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: _buildHeader(),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFeatureCards(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
