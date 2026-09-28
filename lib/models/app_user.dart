class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user' o 'admin'

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'role': role};
  }
}
