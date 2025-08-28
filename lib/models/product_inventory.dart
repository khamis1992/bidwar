class ProductInventory {
  final String id;
  final String title;
  final String description;
  final String? categoryId;
  final int startingPrice;
  final int? reservePrice;
  final int retailValue;
  final int minCreditRequirement;
  final String requiredTier;
  final List<String> images;
  final Map<String, dynamic> specifications;
  final String? brand;
  final String? model;
  final String condition;
  final String availabilityStatus;
  final int estimatedDurationHours;
  final Map<String, dynamic> historicalPerformance;
  final List<String> tags;
  final bool isFeatured;
  final bool isActive;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed fields from RPC function
  final bool? isAccessible;
  final int? commissionPotential;
  final String? categoryName;

  const ProductInventory({
    required this.id,
    required this.title,
    required this.description,
    this.categoryId,
    required this.startingPrice,
    this.reservePrice,
    required this.retailValue,
    required this.minCreditRequirement,
    required this.requiredTier,
    required this.images,
    required this.specifications,
    this.brand,
    this.model,
    required this.condition,
    required this.availabilityStatus,
    required this.estimatedDurationHours,
    required this.historicalPerformance,
    required this.tags,
    required this.isFeatured,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isAccessible,
    this.commissionPotential,
    this.categoryName,
  });

  factory ProductInventory.fromJson(Map<String, dynamic> json) {
    return ProductInventory(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as String?,
      startingPrice: json['starting_price'] as int,
      reservePrice: json['reserve_price'] as int?,
      retailValue: json['retail_value'] as int,
      minCreditRequirement: json['min_credit_requirement'] as int,
      requiredTier: json['required_tier'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      specifications:
          Map<String, dynamic>.from(json['specifications'] as Map? ?? {}),
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      condition: json['condition'] as String,
      availabilityStatus: json['availability_status'] as String,
      estimatedDurationHours: json['estimated_duration_hours'] as int,
      historicalPerformance: Map<String, dynamic>.from(
          json['historical_performance'] as Map? ?? {}),
      tags: List<String>.from(json['tags'] as List? ?? []),
      isFeatured: json['is_featured'] as bool,
      isActive: json['is_active'] as bool,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isAccessible: json['is_accessible'] as bool?,
      commissionPotential: json['commission_potential'] as int?,
      categoryName: json['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'starting_price': startingPrice,
      'reserve_price': reservePrice,
      'retail_value': retailValue,
      'min_credit_requirement': minCreditRequirement,
      'required_tier': requiredTier,
      'images': images,
      'specifications': specifications,
      'brand': brand,
      'model': model,
      'condition': condition,
      'availability_status': availabilityStatus,
      'estimated_duration_hours': estimatedDurationHours,
      'historical_performance': historicalPerformance,
      'tags': tags,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_accessible': isAccessible,
      'commission_potential': commissionPotential,
      'category_name': categoryName,
    };
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';

  String get brandModel => '${brand ?? ''} ${model ?? ''}'.trim();

  String get tierBadgeColor {
    switch (requiredTier.toLowerCase()) {
      case 'bronze':
        return '#CD7F32';
      case 'silver':
        return '#C0C0C0';
      case 'gold':
        return '#FFD700';
      case 'platinum':
        return '#E5E4E2';
      default:
        return '#CCCCCC';
    }
  }

  String get commissionText {
    if (commissionPotential != null) {
      return 'Earn up to ${commissionPotential!.toString()} credits';
    }
    final potential = (retailValue * 0.10).round();
    return 'Earn up to ${potential.toString()} credits';
  }

  bool get isHighValue => retailValue >= 100000;

  ProductInventory copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    int? startingPrice,
    int? reservePrice,
    int? retailValue,
    int? minCreditRequirement,
    String? requiredTier,
    List<String>? images,
    Map<String, dynamic>? specifications,
    String? brand,
    String? model,
    String? condition,
    String? availabilityStatus,
    int? estimatedDurationHours,
    Map<String, dynamic>? historicalPerformance,
    List<String>? tags,
    bool? isFeatured,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAccessible,
    int? commissionPotential,
    String? categoryName,
  }) {
    return ProductInventory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      startingPrice: startingPrice ?? this.startingPrice,
      reservePrice: reservePrice ?? this.reservePrice,
      retailValue: retailValue ?? this.retailValue,
      minCreditRequirement: minCreditRequirement ?? this.minCreditRequirement,
      requiredTier: requiredTier ?? this.requiredTier,
      images: images ?? this.images,
      specifications: specifications ?? this.specifications,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      condition: condition ?? this.condition,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      estimatedDurationHours:
          estimatedDurationHours ?? this.estimatedDurationHours,
      historicalPerformance:
          historicalPerformance ?? this.historicalPerformance,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAccessible: isAccessible ?? this.isAccessible,
      commissionPotential: commissionPotential ?? this.commissionPotential,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
