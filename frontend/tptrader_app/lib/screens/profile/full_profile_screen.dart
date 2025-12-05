import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../api/profile_api.dart';   // <-- you already created this


class FullProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const FullProfileScreen({super.key, required this.profile});

  @override
  State<FullProfileScreen> createState() => _FullProfileScreenState();
}

class _FullProfileScreenState extends State<FullProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;

  late TextEditingController nameCtrl;
  late TextEditingController companyCtrl;
  late TextEditingController gstCtrl;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.profile["user_name"] ?? "");
    companyCtrl = TextEditingController(text: widget.profile["company_name"] ?? "");
    gstCtrl = TextEditingController(text: widget.profile["gst_number"] ?? "");
    addressCtrl = TextEditingController(text: widget.profile["address"] ?? "");
  }

  // -----------------------------------------------------------
  // CAMERA PERMISSION
  // -----------------------------------------------------------
  Future<bool> _askCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // -----------------------------------------------------------
  // PROCESS IMAGE USING SERVICE LAYER
  // -----------------------------------------------------------
  Future<void> _processImage(XFile file) async {
    final mobile = widget.profile["mobile"];

    final newUrl = await uploadProfilePhoto(mobile, file); // <-- CORRECT FUNCTION

    if (newUrl == null) {
      print("❌ Photo upload failed");
      return;
    }

    setState(() {
      selectedImage = file;
      widget.profile["logo_url"] = newUrl;
    });
  }

  // PICK FROM CAMERA
  Future<void> _pickFromCamera() async {
    if (!await _askCameraPermission()) return;

    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      await _processImage(file);
    }
  }

  // PICK FROM GALLERY
  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await _processImage(file);
    }
  }

  // OPEN OPTIONS
  void _openPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _pickerButton(Icons.camera_alt, "Camera", _pickFromCamera),
              _pickerButton(Icons.photo, "Gallery", _pickFromGallery),
            ],
          ),
        );
      },
    );
  }

  Widget _pickerButton(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.purple.shade100,
            child: Icon(icon, size: 26, color: Colors.purple),
          ),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // SAVE PROFILE DETAILS
  // -----------------------------------------------------------
  Future<void> _saveFullProfile() async {
    final mobile = widget.profile["mobile"];

    final ok = await updateFullProfile(
      mobile: mobile,
      name: nameCtrl.text,
      company: companyCtrl.text,
      gst: gstCtrl.text,
      address: addressCtrl.text,
      logoUrl: widget.profile["logo_url"],
    );

    if (!ok) {
      print("❌ Failed to update profile info");
      return;
    }

    Navigator.pop(context, true); // tell previous screen to refresh
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.profile["logo_url"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            // --------------------------------
            // PROFILE IMAGE
            // --------------------------------
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.pink],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: selectedImage != null
                          ? FileImage(File(selectedImage!.path))
                          : (imageUrl != null
                          ? NetworkImage(imageUrl)
                          : null),
                      child: (selectedImage == null && imageUrl == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),

                  GestureDetector(
                    onTap: _openPhotoOptions,
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _inputField(nameCtrl, "Your Name"),
            _inputField(companyCtrl, "Company Name"),
            _inputField(gstCtrl, "GST Number"),
            _inputField(addressCtrl, "Address", maxLines: 2),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveFullProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String hint,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
