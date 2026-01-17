import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/category_model.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/providers/product_provider.dart';
import 'package:stock_management/services/api_service.dart';
import 'package:intl/intl.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    final categoryProducts = allProducts
        .where((p) => p.categoryId == widget.category.id)
        .toList();

    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return categoryProducts;

    return categoryProducts.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.id.toLowerCase().contains(query);
    }).toList();
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(value).replaceAll(',', '.')} F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1E293B),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          final products = _getFilteredProducts(provider.products);
          final totalValue = products.fold<double>(
            0,
            (sum, p) => sum + (p.price * p.stockQuantity),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Header
                Row(
                  children: [
                    Text(
                      widget.category.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Category',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tracking ${products.length} products in inventory',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'TOTAL ITEMS',
                        value: '${products.length}',
                        subtitle: '+12 new', // Mocked as per design
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFF1E3A8A),
                        iconBg: const Color(0xFFDBEAFE),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'TOTAL VALUE',
                        value: _formatCurrency(totalValue),
                        subtitle: 'Updated today',
                        icon: Icons.attach_money,
                        iconColor: const Color(0xFF10B981),
                        iconBg: const Color(0xFFD1FAE5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by name or SKU...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      icon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Product List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(products[index]);
                  },
                ),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E3A8A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitle.startsWith('+')
                  ? const Color(0xFF10B981)
                  : Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    bool isLowStock = product.stockQuantity > 0 && product.stockQuantity <= 10;
    String statusText = product.stockQuantity == 0
        ? 'OUT OF STOCK'
        : (isLowStock ? 'LOW STOCK' : 'IN STOCK');
    Color statusColor = product.stockQuantity == 0
        ? Colors.red
        : (isLowStock ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
    Color statusBg = product.stockQuantity == 0
        ? Colors.red[50]!
        : (isLowStock ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5));

    // Simulate SKU from ID
    String sku =
        'SKU: ${product.id.substring(max(0, product.id.length - 6)).toUpperCase()}';

    // Progress calculation (mocking full capacity as 100 for visual)
    double progress = (product.stockQuantity / 100).clamp(0.0, 1.0);
    Color progressColor = isLowStock
        ? const Color(0xFFF59E0B)
        : const Color(0xFF1E3A8A);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              image: product.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                        ApiService.getImageUrl(product.imageUrl!)!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imageUrl == null
                ? Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.grey[300],
                    size: 32,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sku,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${product.stockQuantity} left',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int max(int a, int b) => a > b ? a : b;
}
