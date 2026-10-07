import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/shop_item.dart';
import '../../widgets/common_widgets.dart';

final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  final db = DatabaseService();
  final items = await db.getShopItems();
  return items.map((json) => ShopItem.fromJson(json)).toList();
});

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shopItemsProvider);
    final userData = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          userData.when(
            data: (user) => user != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CoinDisplay(coins: user.coins),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shopping_bag_outlined,
              title: 'No items available',
              subtitle: 'Check back later for new items!',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _ShopItemCard(item: item);
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading shop...'),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(shopItemsProvider),
        ),
      ),
    );
  }
}

class _ShopItemCard extends ConsumerWidget {
  final ShopItem item;

  const _ShopItemCard({required this.item});

  Future<void> _purchaseItem(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userDataProvider).value;
    if (user == null) return;

    if (user.coins < item.priceCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase ${item.name}?'),
        content: Text('This will cost ${item.priceCoins} coins.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final db = DatabaseService();
      await db.purchaseItem(
        userId: user.id,
        itemId: item.id,
        price: item.priceCoins,
      );

      // Refresh user data
      await ref.read(userDataProvider.notifier).loadUserData(user.firebaseUid);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} purchased!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: InkWell(
        onTap: () => _purchaseItem(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Item image placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(item.itemType),
                  size: 40,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              // Item name
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Price
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.priceCoins}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'profile_decoration':
        return Icons.style;
      case 'mascot_skin':
        return Icons.pets;
      case 'mascot_accessory':
        return Icons.diamond;
      default:
        return Icons.shopping_bag;
    }
  }
}
