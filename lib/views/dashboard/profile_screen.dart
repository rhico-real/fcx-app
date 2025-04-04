import 'dart:convert';

import 'package:fcx_app/remote_db/auth_repository.dart';
import 'package:fcx_app/remote_db/profile_repository.dart';
import 'package:fcx_app/views/auth/login_screen.dart';
import 'package:fcx_app/views/dashboard/admin_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ValueNotifier<Map<String, dynamic>> userData = ValueNotifier({});

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    var response = await ProfileRepository().httpGetProfile();

    if (response != null) {
      userData.value = jsonDecode(response.body);

      _fullNameController.text = userData.value['name'];
      _emailController.text = userData.value['email'];
      _accountNumberController.text = userData.value['accountNumber'];
      _billingAddressController.text = userData.value['billingAddress'];
      _contactController.text = userData.value['contact'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value.toLowerCase() == 'logout') {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text('Warning'),
                          ],
                        ),
                        content: Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed:
                                () => Navigator.of(context).pop(), // Cancel
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await AuthRepository().logout().then((_) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              });
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
              } else if (value.toLowerCase() == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminScreen()),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(value: 'Logout', child: Text('Logout')),
                  PopupMenuItem(value: 'Admin', child: Text('Admin')),
                ],
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ValueListenableBuilder(
          valueListenable: userData,
          builder: (context, val, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userData.value.isNotEmpty) ...[
                    CircleAvatar(
                      backgroundImage: NetworkImage(userData.value['photo']),
                      radius: 70,
                    ),
                  ] else ...[
                    CircularProgressIndicator(),
                  ],

                  _buildTextfield('Full Name', _fullNameController),
                  _buildTextfield('Email', _emailController),
                  _buildTextfield('Account Number', _accountNumberController),
                  _buildTextfield('Billing Address', _billingAddressController),
                  _buildTextfield('Contact Number', _contactController),
                  _buildUpdateProfileButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ValueListenableBuilder<bool> _buildUpdateProfileButton() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, val, child) {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return InkWell(
          onTap: () async {
            Map<String, dynamic> payload = {
              'name': _emailController.text,
              'email': _emailController.text,
              'accountNumber': _accountNumberController.text,
              'billingAddress': _billingAddressController.text,
              'contact': _contactController.text,
            };

            isLoading.value = true;
            var response = await ProfileRepository().httpUpdateProfile(payload);

            if (response != null && response.statusCode == 200) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Update Successful!')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response?.body ?? "Error updating profile."),
                ),
              );
            }
            isLoading.value = false;
          },
          borderRadius: BorderRadius.circular(5),
          child: Material(
            color: Colors.orange.shade400,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextfield(String text, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: text,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
