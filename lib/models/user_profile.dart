class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final Map<String, dynamic>? address;
  final int creditBalance;
  final bool isVerified;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.address,
    required this.creditBalance,
    required this.isVerified,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? 'bidder',
      phone: map['phone'],
      address: map['address'],
      creditBalance: map['credit_balance'] ?? 0,
      isVerified: map['is_verified'] ?? false,
      profilePictureUrl: map['profile_picture_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'address': address,
      'credit_balance': creditBalance,
      'is_verified': isVerified,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    Map<String, dynamic>? address,
    int? creditBalance,
    bool? isVerified,
    String? profilePictureUrl,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      creditBalance: creditBalance ?? this.creditBalance,
      isVerified: isVerified ?? this.isVerified,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Utility methods
  bool get isAdmin => role == 'admin';
  bool get isSeller => role == 'seller';
  bool get isBidder => role == 'bidder';

  String get displayName =>
      fullName.isNotEmpty ? fullName : email.split('@').first;

  String get avatarUrl =>
      profilePictureUrl ??
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop&crop=face';
}
