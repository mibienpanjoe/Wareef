import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/providers/category_provider.dart';
import 'package:stock_management/providers/product_provider.dart';
import 'package:stock_management/models/category_model.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/services/api_service.dart';
import 'package:stock_management/ui/categories/category_detail_screen.dart';
import 'package:stock_management/ui/categories/widgets/category_form_sheet.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Category> _filterCategories(List<Category> categories) {
    String query = _searchController.text.toLowerCase();
    if (query.isEmpty) return categories;
    return categories.where((category) {
      return category.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _showAddCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryFormSheet(),
    );
  }

  void _showUpdateCategoryBottomSheet(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormSheet(category: category),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Consumer<CategoryProvider>(
            builder: (context, provider, child) => TextButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      try {
                        await provider.deleteCategory(category.id);
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      }
                    },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () => _showAddCategoryBottomSheet(context),
              ),
            ),
          ),
        ],
      ),
      body: Consumer2<CategoryProvider, ProductProvider>(
        builder: (context, categoryProvider, productProvider, child) {
          if ((categoryProvider.isLoading &&
                  categoryProvider.categories.isEmpty) ||
              (productProvider.isLoading && productProvider.products.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.errorMessage != null &&
              categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading categories',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      categoryProvider.fetchCategories();
                      productProvider.fetchProducts();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Categories',
                        value: '${categoryProvider.categories.length}',
                        isDark: true,
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Items',
                        value: '${productProvider.products.length}',
                        isDark: false,
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50]?.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.sort, size: 16, color: Color(0xFF1E293B)),
                          SizedBox(width: 4),
                          Text(
                            'Sort',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Category List
                if (_filterCategories(categoryProvider.categories).isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No categories found'
                                : 'No categories yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filterCategories(
                      categoryProvider.categories,
                    ).length,
                    itemBuilder: (context, index) {
                      final category = _filterCategories(
                        categoryProvider.categories,
                      )[index];
                      // Filter products for this category
                      final categoryProducts = productProvider.products
                          .where((p) => p.categoryId == category.id)
                          .toList();

                      return _CategoryTile(
                        category: category,
                        products: categoryProducts, // Pass filtered products
                        iconBgColor: [
                          Colors.blue[50]!,
                          Colors.orange[50]!,
                          Colors.teal[50]!,
                          Colors.purple[50]!,
                          Colors.grey[200]!,
                        ][index % 5],
                        onUpdate: () =>
                            _showUpdateCategoryBottomSheet(context, category),
                        onDelete: () => _confirmDelete(context, category),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                // Add Another Category Button
                GestureDetector(
                  onTap: () => _showAddCategoryBottomSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[200]!,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_circle,
                          color: Color(0xFF1E293B),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add another category',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isDark;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.isDark,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112D4E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.grey[100]!),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: const Color(0xFF112D4E).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.blue[100] : Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF112D4E),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final List<Product> products;
  final Color iconBgColor;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.products,
    required this.iconBgColor,
    required this.onUpdate,
    required this.onDelete,
  });

  String _calculateTotalValue() {
    double total = 0;
    for (var product in products) {
      total += product.price * product.stockQuantity;
    }
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(total).replaceAll(',', '.')} F';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              image: category.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                        ApiService.getImageUrl(category.imageUrl)!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: category.imageUrl == null
                ? const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF1E293B),
                    size: 24,
                  )
                : null,
          ),
          title: Text(
            category.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.description != null &&
                  category.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  category.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${products.length} items • ${_calculateTotalValue()} F',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'update') {
                onUpdate();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Update'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete'),
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
