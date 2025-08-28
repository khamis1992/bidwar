class CreatorTier {
  final String id;
  final String tierName;
  final int minCreditRequirement;
  final int? maxCreditRequirement;
  final double commissionRate;
  final Map<String, dynamic> tierBenefits;
  final String tierColor;
  final String? tierDescription;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreatorTier({
    required this.id,
    required this.tierName,
    required this.minCreditRequirement,
    this.maxCreditRequirement,
    required this.commissionRate,
    required this.tierBenefits,
    required this.tierColor,
    this.tierDescription,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreatorTier.fromJson(Map<String, dynamic> json) {
    return CreatorTier(
      id: json['id'] as String,
      tierName: json['tier_name'] as String,
      minCreditRequirement: json['min_credit_requirement'] as int,
      maxCreditRequirement: json['max_credit_requirement'] as int?,
      commissionRate: (json['commission_rate'] as num).toDouble(),
      tierBenefits:
          Map<String, dynamic>.from(json['tier_benefits'] as Map? ?? {}),
      tierColor: json['tier_color'] as String,
      tierDescription: json['tier_description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tier_name': tierName,
      'min_credit_requirement': minCreditRequirement,
      'max_credit_requirement': maxCreditRequirement,
      'commission_rate': commissionRate,
      'tier_benefits': tierBenefits,
      'tier_color': tierColor,
      'tier_description': tierDescription,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    return tierName[0].toUpperCase() + tierName.substring(1).toLowerCase();
  }

  String get commissionRateText {
    return '${(commissionRate * 100).toStringAsFixed(0)}%';
  }

  List<String> get features {
    final featuresList = tierBenefits['features'] as List<dynamic>?;
    return featuresList?.cast<String>() ?? [];
  }

  int? get maxProducts {
    return tierBenefits['max_products'] as int?;
  }

  String get creditRangeText {
    if (maxCreditRequirement == null) {
      return '${minCreditRequirement.toString()}+ credits';
    }
    return '${minCreditRequirement.toString()} - ${maxCreditRequirement.toString()} credits';
  }

  bool canAccessProduct(int productMinCredit, String productTier) {
    // Check if user's tier can access the product
    final tierOrder = ['bronze', 'silver', 'gold', 'platinum'];
    final currentTierIndex = tierOrder.indexOf(tierName.toLowerCase());
    final requiredTierIndex = tierOrder.indexOf(productTier.toLowerCase());

    return currentTierIndex >= requiredTierIndex;
  }

  CreatorTier copyWith({
    String? id,
    String? tierName,
    int? minCreditRequirement,
    int? maxCreditRequirement,
    double? commissionRate,
    Map<String, dynamic>? tierBenefits,
    String? tierColor,
    String? tierDescription,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreatorTier(
      id: id ?? this.id,
      tierName: tierName ?? this.tierName,
      minCreditRequirement: minCreditRequirement ?? this.minCreditRequirement,
      maxCreditRequirement: maxCreditRequirement ?? this.maxCreditRequirement,
      commissionRate: commissionRate ?? this.commissionRate,
      tierBenefits: tierBenefits ?? this.tierBenefits,
      tierColor: tierColor ?? this.tierColor,
      tierDescription: tierDescription ?? this.tierDescription,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
