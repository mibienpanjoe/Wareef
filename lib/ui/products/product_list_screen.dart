import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/providers/product_provider.dart';
import 'package:stock_management/providers/category_provider.dart';
import 'package:stock_management/ui/categories/widgets/category_form_sheet.dart';
import 'package:stock_management/ui/products/widgets/product_list_item.dart';
import 'package:stock_management/ui/products/product_form_sheet.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedCategoryId = 'All'; // 'All' or category ID

  @override
  void initState() {
    super.initState();
    // Fetch products and categories when screen loads
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      if (_selectedCategoryId == 'All') return true;
      return product.categoryId == _selectedCategoryId;
    }).toList();
  }

  void _showProductForm(BuildContext context, [Product? product]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ProductFormSheet(product: product),
      ),
    ).then((_) {
      if (!context.mounted) return;
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<ProductProvider, CategoryProvider>(
        builder: (context, productProvider, categoryProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredProducts = _filterProducts(productProvider.products);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Action Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: 'Add Product',
                          subtitle: 'Update Inventory',
                          icon: Icons.add_box_outlined,
                          onTap: () => _showProductForm(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          title: 'New Category',
                          subtitle: 'Organize Items',
                          icon: Icons.category_outlined,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const CategoryFormSheet(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _buildCategoryChip('All Items', 'All'),
                      ...categoryProvider.categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _buildCategoryChip(category.name, category.id),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Inventory Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inventory Items (${filteredProducts.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: Color(0xFF1E293B),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Filter',
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Product List
                if (filteredProducts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items in this category',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      String? categoryName;
                      try {
                        categoryName = categoryProvider.categories
                            .firstWhere((c) => c.id == product.categoryId)
                            .name;
                      } catch (_) {}

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProductListItem(
                          product: product,
                          categoryName: categoryName,
                          onTap: () => _showProductForm(context, product),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String id) {
    final isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[200]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
