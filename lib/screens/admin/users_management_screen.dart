import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'user_detail_screen.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Gestión de usuarios')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isAdmin = user['role'] == 'admin';
              final uid = user['uid'] as String;
              final name = user['name'] ?? 'Sin nombre';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserDetailScreen(userId: uid, userName: name),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                isAdmin ? AppColors.secondary : AppColors.primary,
                            child: Icon(
                              isAdmin ? Icons.admin_panel_settings : Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(user['email'] ?? '',
                                    style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: isAdmin ? 'Quitar admin' : 'Hacer admin',
                            icon: Icon(
                              Icons.admin_panel_settings,
                              color: isAdmin ? AppColors.secondary : AppColors.textLight.withValues(alpha: 0.5),
                              size: 22,
                            ),
                            onPressed: () async {
                              final newRole = isAdmin ? 'user' : 'admin';
                              await firestoreService.updateUserRole(uid, newRole);
                            },
                          ),
                          IconButton(
                            tooltip: 'Eliminar registro',
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Eliminar usuario'),
                                  content: Text(
                                      '¿Eliminar el registro de "$name"? Esta acción no se puede deshacer.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await firestoreService.deleteUserRecord(uid);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}