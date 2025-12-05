import 'package:flutter/material.dart';

class UpdateProfilePopup extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Function({
  String? name,
  String? company,
  String? gst,
  String? address,
  }) onSubmit;

  const UpdateProfilePopup({
    super.key,
    required this.profile,
    required this.onSubmit,
  });

  @override
  State<UpdateProfilePopup> createState() => _UpdateProfilePopupState();
}

class _UpdateProfilePopupState extends State<UpdateProfilePopup> {
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _gstController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profile["user_name"] ?? "");
    _companyController =
        TextEditingController(text: widget.profile["company_name"] ?? "");
    _gstController =
        TextEditingController(text: widget.profile["gst_number"] ?? "");
    _addressController =
        TextEditingController(text: widget.profile["address"] ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Your Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: "Company Name"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _gstController,
              decoration: const InputDecoration(labelText: "GST Number"),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: "Address"),
              maxLines: 2,
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                widget.onSubmit(
                  name: _nameController.text,
                  company: _companyController.text,
                  gst: _gstController.text,
                  address: _addressController.text,
                );
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
