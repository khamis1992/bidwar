class ProductSelection {
  final String id;
  final String creatorId;
  final String productInventoryId;
  final String? auctionItemId;
  final DateTime selectedAt;
  final DateTime? scheduledStartTime;
  final DateTime? estimatedEndTime;
  final String? selectionNotes;
  final String? creatorTierAtSelection;
  final int creditBalanceAtSelection;
  final double commissionRate;
  final String status;

  // Related data
  final Map<String, dynamic>? productInventory;
  final Map<String, dynamic>? auctionItem;

  const ProductSelection({
    required this.id,
    required this.creatorId,
    required this.productInventoryId,
    this.auctionItemId,
    required this.selectedAt,
    this.scheduledStartTime,
    this.estimatedEndTime,
    this.selectionNotes,
    this.creatorTierAtSelection,
    required this.creditBalanceAtSelection,
    required this.commissionRate,
    required this.status,
    this.productInventory,
    this.auctionItem,
  });

  factory ProductSelection.fromJson(Map<String, dynamic> json) {
    return ProductSelection(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      productInventoryId: json['product_inventory_id'] as String,
      auctionItemId: json['auction_item_id'] as String?,
      selectedAt: DateTime.parse(json['selected_at'] as String),
      scheduledStartTime: json['scheduled_start_time'] != null
          ? DateTime.parse(json['scheduled_start_time'] as String)
          : null,
      estimatedEndTime: json['estimated_end_time'] != null
          ? DateTime.parse(json['estimated_end_time'] as String)
          : null,
      selectionNotes: json['selection_notes'] as String?,
      creatorTierAtSelection: json['creator_tier_at_selection'] as String?,
      creditBalanceAtSelection: json['credit_balance_at_selection'] as int,
      commissionRate: (json['commission_rate'] as num).toDouble(),
      status: json['status'] as String,
      productInventory: json['product_inventory'] as Map<String, dynamic>?,
      auctionItem: json['auction_items'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'product_inventory_id': productInventoryId,
      'auction_item_id': auctionItemId,
      'selected_at': selectedAt.toIso8601String(),
      'scheduled_start_time': scheduledStartTime?.toIso8601String(),
      'estimated_end_time': estimatedEndTime?.toIso8601String(),
      'selection_notes': selectionNotes,
      'creator_tier_at_selection': creatorTierAtSelection,
      'credit_balance_at_selection': creditBalanceAtSelection,
      'commission_rate': commissionRate,
      'status': status,
      'product_inventory': productInventory,
      'auction_items': auctionItem,
    };
  }

  String get productTitle {
    return productInventory?['title'] as String? ?? 'Unknown Product';
  }

  int get productRetailValue {
    return productInventory?['retail_value'] as int? ?? 0;
  }

  List<String> get productImages {
    final images = productInventory?['images'] as List?;
    return images?.cast<String>() ?? [];
  }

  String get productBrand {
    return productInventory?['brand'] as String? ?? '';
  }

  String get productModel {
    return productInventory?['model'] as String? ?? '';
  }

  String get brandModel {
    return '${productBrand} ${productModel}'.trim();
  }

  String get auctionStatus {
    return auctionItem?['status'] as String? ?? 'not_created';
  }

  int get currentBid {
    return auctionItem?['current_highest_bid'] as int? ?? 0;
  }

  bool get hasWinner {
    return auctionItem?['winner_id'] != null;
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'selected':
        return 'Selected for Auction';
      case 'live':
        return 'Live Auction';
      case 'completed':
        return 'Auction Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get commissionRateText {
    return '${(commissionRate * 100).toStringAsFixed(0)}%';
  }

  int get potentialCommission {
    return (productRetailValue * commissionRate).round();
  }

  String get tierDisplayName {
    if (creatorTierAtSelection == null) return '';
    return creatorTierAtSelection![0].toUpperCase() +
        creatorTierAtSelection!.substring(1).toLowerCase();
  }

  ProductSelection copyWith({
    String? id,
    String? creatorId,
    String? productInventoryId,
    String? auctionItemId,
    DateTime? selectedAt,
    DateTime? scheduledStartTime,
    DateTime? estimatedEndTime,
    String? selectionNotes,
    String? creatorTierAtSelection,
    int? creditBalanceAtSelection,
    double? commissionRate,
    String? status,
    Map<String, dynamic>? productInventory,
    Map<String, dynamic>? auctionItem,
  }) {
    return ProductSelection(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      productInventoryId: productInventoryId ?? this.productInventoryId,
      auctionItemId: auctionItemId ?? this.auctionItemId,
      selectedAt: selectedAt ?? this.selectedAt,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      estimatedEndTime: estimatedEndTime ?? this.estimatedEndTime,
      selectionNotes: selectionNotes ?? this.selectionNotes,
      creatorTierAtSelection:
          creatorTierAtSelection ?? this.creatorTierAtSelection,
      creditBalanceAtSelection:
          creditBalanceAtSelection ?? this.creditBalanceAtSelection,
      commissionRate: commissionRate ?? this.commissionRate,
      status: status ?? this.status,
      productInventory: productInventory ?? this.productInventory,
      auctionItem: auctionItem ?? this.auctionItem,
    );
  }
}
