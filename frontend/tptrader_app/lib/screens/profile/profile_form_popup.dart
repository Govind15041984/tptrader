import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../theme/app_colors.dart';


class ProfileFormPopup extends StatefulWidget {
  final String mobile;
  final Function(String name, String company) onSubmit;

  const ProfileFormPopup({
    super.key,
    required this.mobile,
    required this.onSubmit,
  });

  @override
  State<ProfileFormPopup> createState() => _ProfileFormPopupState();
}

class _ProfileFormPopupState extends State<ProfileFormPopup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mobileController.text = widget.mobile; // auto-fill
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Create Your Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // NAME
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Your Name"),
            ),

            const SizedBox(height: 12),

            // COMPANY
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: "Company Name"),
            ),

            const SizedBox(height: 12),

            // MOBILE (read-only)
            TextFormField(
              controller: _mobileController,
              enabled: false,
              decoration: const InputDecoration(labelText: "Mobile Number"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _companyController.text.isNotEmpty) {

                  //Navigator.pop(context); // close popup first

                  // Call parent handler
                  widget.onSubmit(
                    _nameController.text,
                    _companyController.text,
                  );

                  // Show toast after closing
                  Fluttertoast.showToast(
                    msg: "Profile created successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              child: const Text(
                "Create Profile",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
