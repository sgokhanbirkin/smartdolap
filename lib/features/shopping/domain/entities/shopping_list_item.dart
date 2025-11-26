/// Represents a shopping list item
class ShoppingListItem {
  /// Creates a shopping list item
  const ShoppingListItem({
    required this.id,
    required this.householdId,
    required this.name,
    required this.addedByUserId,
    required this.isCompleted,
    required this.createdAt,
    this.category,
    this.quantity,
    this.unit,
    this.addedByAvatarId,
    this.completedAt,
    this.completedByUserId,
    this.updatedAt,
  });

  /// Create from Firestore document
  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      ShoppingListItem(
        id: json['id'] as String,
        householdId: json['householdId'] as String,
        name: json['name'] as String,
        category: json['category'] as String?,
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        addedByUserId: json['addedByUserId'] as String,
        addedByAvatarId: json['addedByAvatarId'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
        completedByUserId: json['completedByUserId'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );

  /// Unique identifier
  final String id;

  /// Household ID
  final String householdId;

  /// Item name
  final String name;

  /// Category (optional)
  final String? category;

  /// Quantity (optional)
  final double? quantity;

  /// Unit (optional)
  final String? unit;

  /// User ID who added the item
  final String addedByUserId;

  /// Avatar ID of user who added the item
  final String? addedByAvatarId;

  /// Whether item is completed
  final bool isCompleted;

  /// When item was completed
  final DateTime? completedAt;

  /// User ID who completed the item
  final String? completedByUserId;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Convert to Firestore document
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'householdId': householdId,
        'name': name,
        if (category != null) 'category': category,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        'addedByUserId': addedByUserId,
        if (addedByAvatarId != null) 'addedByAvatarId': addedByAvatarId,
        'isCompleted': isCompleted,
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        if (completedByUserId != null) 'completedByUserId': completedByUserId,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  ShoppingListItem copyWith({
    String? id,
    String? householdId,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    String? addedByUserId,
    String? addedByAvatarId,
    bool? isCompleted,
    DateTime? completedAt,
    String? completedByUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ShoppingListItem(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        addedByUserId: addedByUserId ?? this.addedByUserId,
        addedByAvatarId: addedByAvatarId ?? this.addedByAvatarId,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        completedByUserId: completedByUserId ?? this.completedByUserId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

