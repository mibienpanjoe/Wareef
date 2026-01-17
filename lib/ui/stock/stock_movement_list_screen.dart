import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/stock_movement_model.dart';
import 'package:stock_management/providers/stock_movement_provider.dart';
import 'package:stock_management/ui/stock/record_stock_movement_sheet.dart';
import 'package:intl/intl.dart';

class StockMovementListScreen extends StatefulWidget {
  const StockMovementListScreen({super.key});

  @override
  State<StockMovementListScreen> createState() =>
      _StockMovementListScreenState();
}

class _StockMovementListScreenState extends State<StockMovementListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<StockMovementProvider>(
        context,
        listen: false,
      ).fetchStockMovements();
    });
  }

  void _showRecordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const RecordStockMovementSheet(),
      ),
    ).then((_) {
      // Refresh list
      if (!context.mounted) return;
      Provider.of<StockMovementProvider>(
        context,
        listen: false,
      ).fetchStockMovements();
    });
  }

  void _showSortMenu(BuildContext context) {
    final provider = Provider.of<StockMovementProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              _buildSortOption(
                context,
                'Newest First',
                StockMovementSort.dateNewest,
                provider,
              ),
              _buildSortOption(
                context,
                'Oldest First',
                StockMovementSort.dateOldest,
                provider,
              ),
              _buildSortOption(
                context,
                'Quantity (High to Low)',
                StockMovementSort.quantityHigh,
                provider,
              ),
              _buildSortOption(
                context,
                'Quantity (Low to High)',
                StockMovementSort.quantityLow,
                provider,
              ),
              _buildSortOption(
                context,
                'Product Name (A-Z)',
                StockMovementSort.productNameAZ,
                provider,
              ),
              _buildSortOption(
                context,
                'Product Name (Z-A)',
                StockMovementSort.productNameZA,
                provider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String label,
    StockMovementSort value,
    StockMovementProvider provider,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: provider.sortBy == value
              ? Colors.blue
              : const Color(0xFF1E293B),
          fontWeight: provider.sortBy == value
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      trailing: provider.sortBy == value
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        provider.setSortBy(value);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Stock Movements',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1E293B)),
            onPressed: () => _showSortMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search product...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    Provider.of<StockMovementProvider>(
                      context,
                      listen: false,
                    ).setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'ALL'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Stock In', 'IN'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Stock Out', 'OUT'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: Consumer<StockMovementProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchStockMovements(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredMovements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No movements found',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: provider.filteredMovements.length,
                  itemBuilder: (context, index) {
                    final movement = provider.filteredMovements[index];
                    return _buildMovementItem(movement);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecordSheet(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Consumer<StockMovementProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.filterType == value;

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (bool selected) {
            if (selected) {
              provider.setFilterType(value);
            }
          },
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF1E293B),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? const Color(0xFF1E293B) : Colors.grey[300]!,
            ),
          ),
          showCheckmark: false,
        );
      },
    );
  }

  Widget _buildMovementItem(StockMovement movement) {
    final isStockIn = movement.type == 'IN';
    final date = movement.createdAt != null
        ? DateFormat(
            'MMM dd, yyyy • hh:mm a',
          ).format(DateTime.parse(movement.createdAt!).toLocal())
        : 'Unknown Date';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isStockIn
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
              color: isStockIn ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.productName ?? 'Unknown Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'ID: #${movement.productId.substring(0, 6)}...', // Shortened ID
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (movement.description != null &&
                    movement.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      movement.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isStockIn ? '+' : '-'}${movement.quantity}',
                style: TextStyle(
                  color: isStockIn ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isStockIn
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isStockIn
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isStockIn ? 'Stock In' : 'Stock Out',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isStockIn ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
