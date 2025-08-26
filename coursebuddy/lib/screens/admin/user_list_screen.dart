import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/error_util.dart';
import '../../widgets/shared_button.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Guests'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('guests').snapshots(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = d.id.toLowerCase();
            return name.contains(_search) || email.contains(_search);
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No guests found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Text('${d.id} • ${data['status']}'),
                trailing: SharedButton(
                  label: '',
                  icon: Icons.upgrade,
                  onPressed: () => _showPromoteDialog(context, d.id, data),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPromoteDialog(
    BuildContext context,
    String email,
    Map<String, dynamic> guestData,
  ) {
    String? selectedRole;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Promote Guest'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Role'),
          items: const [
            DropdownMenuItem(value: 'students', child: Text('Student')),
            DropdownMenuItem(value: 'parents', child: Text('Parent')),
            DropdownMenuItem(value: 'teachers', child: Text('Teacher')),
            DropdownMenuItem(value: 'admins', child: Text('Admin')),
          ],
          onChanged: (v) => selectedRole = v,
        ),
        actions: [
          SharedButton(
            label: 'Cancel',
            icon: Icons.cancel,
            onPressed: () => Navigator.pop(context),
          ),
          SharedButton(
            label: 'Promote',
            icon: Icons.check,
            onPressed: () async {
              if (selectedRole == null) return;

              try {
                // copy guest data → role collection
                await FirebaseFirestore.instance
                    .collection(selectedRole!)
                    .doc(email)
                    .set({
                      'uid': guestData['uid'],
                      'name': guestData['name'],
                      'createdAt': guestData['createdAt'],
                    });

                // delete from guests
                await FirebaseFirestore.instance
                    .collection('guests')
                    .doc(email)
                    .delete();

                if (mounted) Navigator.pop(context);
              } catch (e, s) {
                showError(context, e, s);
              }
            },
          ),
        ],
      ),
    );
  }
}
