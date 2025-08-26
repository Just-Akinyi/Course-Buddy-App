import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔧 needed
import '../../widgets/shared_button.dart';
import '../../utils/error_util.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});
  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _passCtl = TextEditingController();
  String _role = 'student';
  final _linkedToCtl = TextEditingController();
  bool _isLoading = false;

  // 🔧 in State class: list of available users
  List<Map<String, dynamic>> _availableUsers = [];

  Future<void> _loadAvailableUsers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('roles')
        .where('role', isEqualTo: 'student') // list only students
        .get();
    setState(() {
      _availableUsers = snapshot.docs
          .map((d) => {'uid': d.id, 'name': d.data()['name']})
          .toList();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final res = await FirebaseFunctions.instance
          .httpsCallable('createUser')
          .call(<String, dynamic>{
            'email': _emailCtl.text.trim(),
            'password': _passCtl.text,
            'displayName': _nameCtl.text.trim(),
            'role': _role,
            'linkedTo': _linkedToCtl.text
                .trim()
                .split(',')
                .where((s) => s.isNotEmpty)
                .toList(),
          });

      if (res.data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created: ${res.data['uid']}')),
        );
        _formKey.currentState!.reset();
        setState(() => _availableUsers = []);
      } else {
        showError(context, 'Failed: ${res.data}');
      }
    } catch (e, s) {
      showError(context, e, s);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@')
                    ? null
                    : 'Valid email required',
              ),
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: _passCtl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : '6+ chars',
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                value: _role,
                items: ['student', 'teacher', 'parent', 'admin']
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.capitalize()),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _role = v!);
                  if (_role != 'student') _loadAvailableUsers();
                },
              ),
              if (_role != 'student') ...[
                const SizedBox(height: 10),
                const Text("Link to:"),
                ..._availableUsers.map((u) {
                  final selected = _linkedToCtl.text
                      .split(',')
                      .contains(u['uid']);
                  return CheckboxListTile(
                    title: Text(u['name']),
                    value: selected,
                    onChanged: (checked) {
                      final list = _linkedToCtl.text
                          .trim()
                          .split(',')
                          .where((s) => s.isNotEmpty)
                          .toList();
                      checked == true && !list.contains(u['uid'])
                          ? list.add(u['uid'])
                          : checked == false
                          ? list.remove(u['uid'])
                          : null;
                      setState(() => _linkedToCtl.text = list.join(','));
                    },
                  );
                }),
              ],
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SharedButton(
                      label: 'Create User',
                      icon: Icons.add,
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : (this[0].toUpperCase() + substring(1));
}
