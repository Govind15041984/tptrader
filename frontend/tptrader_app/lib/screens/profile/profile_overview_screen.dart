import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import 'full_profile_screen.dart';
import '../../api/profile_api.dart';

class ProfileOverviewScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;

  const ProfileOverviewScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  late Map<String, dynamic> profile;
  String mobile = "";
  int cacheVersion = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    profile = widget.profile!;
    _loadMobile();
  }

  Future<void> _loadMobile() async {
    final prefs = await SharedPreferences.getInstance();
    mobile = prefs.getString("loggedInMobile") ?? "";

    /// 🌟 FIRST refresh profile from backend immediately
    await _refreshFromBackend();
    setState(() {});
  }

  Future<void> _refreshFromBackend() async {
    final updated = await getProfile(mobile);

    if (updated != null) {
      profile = updated;

      /// 👇 Force image refresh by updating cache version
      cacheVersion = DateTime.now().millisecondsSinceEpoch;

      print("🔄 Updated profile from backend: $profile");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? logo = profile["logo_url"];
    final String? logoWithCache =
    logo != null ? "$logo?v=$cacheVersion" : null;

    print("🖼 PROFILE OVERVIEW AVATAR → $logoWithCache");

    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGradientEnd,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // TOP CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: const BoxDecoration(
              color: AppColors.backgroundGradientStart,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  backgroundImage:
                  logoWithCache != null ? NetworkImage(logoWithCache) : null,
                  onBackgroundImageError: (_, __) {
                    print("❌ OVERVIEW → Avatar load error");
                  },
                  child: logo == null
                      ? const Icon(Icons.person, size: 40, color: Colors.purple)
                      : null,
                ),

                const SizedBox(width: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile["company_name"] ?? "",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      mobile,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                const Spacer(),

                TextButton(
                  onPressed: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullProfileScreen(profile: profile),
                      ),
                    );

                    /// 🌟 VERY IMPORTANT — refresh again after saving image
                    if (changed == true) {
                      await _refreshFromBackend();
                    }
                  },
                  child: const Text("Manage", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _item(Icons.settings, "Preferences"),
                _item(Icons.help_outline, "Help & Support"),
                _item(Icons.info_outline, "About"),
                _item(Icons.logout, "Logout"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData i, String t) {
    return Column(
      children: [
        ListTile(
          leading: Icon(i, color: Colors.white),
          trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          title: Text(t, style: const TextStyle(color: Colors.white)),
        ),
        const Divider()
      ],
    );
  }
}
