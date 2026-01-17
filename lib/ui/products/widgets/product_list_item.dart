import 'package:flutter/material.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/services/api_service.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final String? categoryName;
  final VoidCallback? onTap;

  const ProductListItem({
    super.key,
    required this.product,
    this.categoryName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color (keep for detailed view if needed, or use generic blue/grey)
    // User requested "category display ... instead of stock level"
    // We will show Category Name in the badge area

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or Icon Placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: product.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(
                            ApiService.getImageUrl(product.imageUrl)!,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.imageUrl == null
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF1E293B),
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'F${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Keep units count or remove? User said "instead of stock level".
                        // Usually "units" is fine, but "Badge" [Low Stock] is the "level".
                        // Let's keep units for detail but replace badge.
                        Text(
                          '${product.stockQuantity} units',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (categoryName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1E293B,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              categoryName!,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Uncategorized',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
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
}
