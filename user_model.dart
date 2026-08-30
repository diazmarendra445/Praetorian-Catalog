class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String phone;
  final String email;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.phone,
    required this.email,
    required this.createdAt,
  });

  // Factory constructor: dari Supabase map / Factory constructor: from Supabase map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  // Konversi ke map untuk Supabase / Convert to map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'phone': phone,
      'email': email,
    };
  }

  // CopyWith untuk update immutable / CopyWith for immutable update
  UserModel copyWith({
    String? fullName,
    String? username,
    String? phone,
    String? email,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }

  // Getter untuk nama depan saja / Getter for first name only
  String get firstName => fullName.split(' ').first;

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
