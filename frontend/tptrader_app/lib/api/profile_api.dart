import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'config_api.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'config_api.dart';

// --------------------------------------------------------
// CREATE PROFILE
// --------------------------------------------------------
Future<bool> createProfileApi(String name, String company, String mobile) async {
  final url = Uri.parse('$kBaseUrl/profile/create');

  try {
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_name": name,
        "company_name": company,
        "mobile": mobile,
      }),
    );

    return res.statusCode == 200;
  } catch (e) {
    print("Create profile error → $e");
    return false;
  }
}

// --------------------------------------------------------
// GET PROFILE (IMPORTANT FOR AVATAR LOADING)
// --------------------------------------------------------
Future<Map<String, dynamic>?> getProfile(String mobile) async {
  final url = Uri.parse('$kBaseUrl/profile/$mobile');

  try {
    final res = await http.get(url);

    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final data = jsonDecode(res.body);

      if (data is Map<String, dynamic> && data.isNotEmpty) {
        print("📥 Profile loaded: $data");
        return data;
      }
    }
  } catch (e) {
    print("Get profile error → $e");
  }

  return null;
}

// --------------------------------------------------------
// UPDATE PROFILE
// --------------------------------------------------------
Future<bool> updateProfileApi({
  required String mobile,
  String? name,
  String? company,
  String? gstNumber,
  String? address,
  String? logoUrl,     // <- IMPORTANT FOR IMAGE UPDATE
}) async {
  final url = Uri.parse('$kBaseUrl/profile/$mobile');

  final body = {
    if (name != null) "user_name": name,
    if (company != null) "company_name": company,
    if (gstNumber != null) "gst_number": gstNumber,
    if (address != null) "address": address,
    if (logoUrl != null) "logo_url": logoUrl,   // <- THIS UPDATES IMAGE
  };

  try {
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  } catch (e) {
    print("Update profile error → $e");
    return false;
  }
}

/// --------------PROFILE PHOTO UPLOAD API----------------------------------------------
/// 1. GET PRESIGNED UPLOAD URL
/// ------------------------------------------------------------
Future<Map<String, dynamic>> getPresignedUrl(String mobile) async {
  final url = Uri.parse('$kBaseUrl/profile/photo/presign');

  final res = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"mobile": mobile}),
  );

  return jsonDecode(res.body);
}

/// ------------------------------------------------------------
/// 2. UPLOAD FILE TO MINIO
/// ------------------------------------------------------------
Future<bool> uploadToMinIO(String uploadUrl, XFile file) async {
  final bytes = await file.readAsBytes();

  final res = await http.put(
    Uri.parse(uploadUrl),
    body: bytes,
    headers: {"Content-Type": "image/jpeg"},
  );

  return res.statusCode == 200;
}

/// ------------------------------------------------------------
/// 3. SAVE LOGO URL BACK IN BACKEND
/// ------------------------------------------------------------
Future<bool> saveLogoUrlToBackend(String mobile, String finalUrl) async {
  final url = Uri.parse('$kBaseUrl/profile/update_logo');

  final res = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "mobile": mobile,
      "logo_url": finalUrl,
    }),
  );

  return res.statusCode == 200;
}

/// ------------------------------------------------------------
/// 4. COMPLETE FLOW: UPLOAD IMAGE + SAVE URL
///     Returns final URL with cache-bust version appended
/// ------------------------------------------------------------
Future<String?> uploadProfilePhoto(String mobile, XFile file) async {
  try {
    final urls = await getPresignedUrl(mobile);
    final uploadUrl = urls["uploadUrl"];
    final finalUrl = urls["finalUrl"];

    final uploaded = await uploadToMinIO(uploadUrl, file);
    if (!uploaded) return null;

    final saved = await saveLogoUrlToBackend(mobile, finalUrl);
    if (!saved) return null;

    // Add timestamp to break caching
    return "$finalUrl?v=${DateTime.now().millisecondsSinceEpoch}";
  } catch (e) {
    print("❌ uploadProfilePhoto ERROR → $e");
    return null;
  }
}

/// ------------------------------------------------------------
/// 5. UPDATE PROFILE DETAILS
/// ------------------------------------------------------------
Future<bool> updateFullProfile({
  required String mobile,
  required String name,
  required String company,
  required String gst,
  required String address,
  required String logoUrl,
}) async {
  final url = Uri.parse('$kBaseUrl/profile/$mobile');

  final res = await http.put(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_name": name,
      "company_name": company,
      "gst_number": gst,
      "address": address,
      "logo_url": logoUrl,
    }),
  );

  return res.statusCode == 200;
}
