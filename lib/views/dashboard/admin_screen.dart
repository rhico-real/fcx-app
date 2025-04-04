import 'dart:convert';

import 'package:fcx_app/remote_db/admin_repository.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> listUsers = [];

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    var response = await AdminRepository().httpGetUsers();

    if (response != null) {
      List usersList = jsonDecode(response.body);

      for (var user in usersList) {
        listUsers.add({
          'id': user['_id'],
          'name': user['name'],
          'email': user['email'],
          'isEditing': false,
        });
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void showDeleteDialog(int index, dynamic id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Warning'),
              ],
            ),
            content: Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Cancel
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  var res = await AdminRepository().httpDeleteProfile(
                    id.toString(),
                  );

                  if (res != null && res.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Successfully deleted!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(res?.body ?? "Error deleting.")),
                    );
                  }

                  setState(() {
                    listUsers.removeAt(index);
                  });

                  Navigator.pop(context);
                },
                child: Text('OK', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 30,
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Actions')),
            ],
            rows: List.generate(listUsers.length, (index) {
              var user = listUsers[index];
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: TextField(
                        enabled: user['isEditing'],
                        controller: TextEditingController(text: user['name']),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                        ),
                        onChanged: (value) => listUsers[index]['name'] = value,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: TextField(
                        enabled: user['isEditing'],
                        controller: TextEditingController(text: user['email']),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                        ),
                        onChanged: (value) => listUsers[index]['email'] = value,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            user['isEditing'] ? Icons.save : Icons.edit,
                            color:
                                user['isEditing'] ? Colors.green : Colors.blue,
                          ),
                          onPressed: () async {
                            if (user['isEditing']) {
                              var userId = user['id'];

                              Map<String, dynamic> payload = {
                                'name': user['name'],
                                'email': user['email'],
                              };

                              var res = await AdminRepository()
                                  .httpUpdateProfile(
                                    payload,
                                    userId.toString(),
                                  );

                              if (res != null && res.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Successfully updated!"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      res?.body ?? "Error updating.",
                                    ),
                                  ),
                                );
                              }
                            }
                            setState(() {
                              listUsers[index]['name'] = user['name'];

                              listUsers[index]['isEditing'] =
                                  !listUsers[index]['isEditing'];
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => showDeleteDialog(index, user['id']),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
