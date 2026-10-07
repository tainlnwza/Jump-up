class ShopItem {
  final String id;
  final String name;
  final String? description;
  final String itemType; // 'profile_decoration', 'mascot_skin', 'mascot_accessory'
  final int priceCoins;
  final String? imageUrl;
  final bool isAvailable;

  ShopItem({
    required this.id,
    required this.name,
    this.description,
    required this.itemType,
    required this.priceCoins,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      itemType: json['item_type'],
      priceCoins: json['price_coins'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'item_type': itemType,
      'price_coins': priceCoins,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }
}

class UserInventoryItem {
  final String userId;
  final String itemId;
  final ShopItem? item;
  final DateTime purchasedAt;
  final bool isEquipped;

  UserInventoryItem({
    required this.userId,
    required this.itemId,
    this.item,
    required this.purchasedAt,
    this.isEquipped = false,
  });

  factory UserInventoryItem.fromJson(Map<String, dynamic> json) {
    return UserInventoryItem(
      userId: json['user_id'],
      itemId: json['item_id'],
      item: json['shop_items'] != null
          ? ShopItem.fromJson(json['shop_items'])
          : null,
      purchasedAt: DateTime.parse(json['purchased_at']),
      isEquipped: json['is_equipped'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'item_id': itemId,
      'purchased_at': purchasedAt.toIso8601String(),
      'is_equipped': isEquipped,
    };
  }
}
