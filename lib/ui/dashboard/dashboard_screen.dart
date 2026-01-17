import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stock_management/providers/dashboard_provider.dart';
import 'package:stock_management/providers/category_provider.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).fetchDashboardData();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1E293B),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<DashboardProvider, CategoryProvider>(
        builder: (context, dashboardProvider, categoryProvider, child) {
          if (dashboardProvider.isLoading || categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dashboardProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      dashboardProvider.fetchDashboardData();
                      categoryProvider.fetchCategories();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final currencyFormat = NumberFormat.currency(
            symbol: 'F ',
            decimalDigits: 0,
          );

          return RefreshIndicator(
            onRefresh: () async {
              await dashboardProvider.fetchDashboardData();
              await categoryProvider.fetchCategories();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Value',
                          currencyFormat.format(dashboardProvider.totalValue),
                          Icons.account_balance_wallet,
                          const Color(0xFF3B82F6),
                          trend: '+5.2%',
                          isTrendPositive: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Low Stock Items',
                          '${dashboardProvider.lowStockCount}',
                          Icons.warning_amber_rounded,
                          const Color(0xFFF59E0B),
                          trend: '+2 items',
                          isTrendPositive: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stock Movement Card
                  _buildStockMovementCard(dashboardProvider),
                  const SizedBox(height: 24),

                  // Inventory Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Inventory Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.sort, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(dashboardProvider, 'All Items'),
                        const SizedBox(width: 8),
                        _buildFilterChip(dashboardProvider, 'Low Stock'),
                        const SizedBox(width: 8),
                        _buildFilterChip(dashboardProvider, 'Out of Stock'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Inventory List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboardProvider.filteredProducts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = dashboardProvider.filteredProducts[index];
                      final category = categoryProvider.categories
                          .cast<dynamic>()
                          .firstWhere(
                            (c) => c.id == product.categoryId,
                            orElse: () => null,
                          );
                      return _InventoryItemTile(
                        product: product,
                        categoryName: category?.name ?? 'General',
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    required String trend,
    required bool isTrendPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isTrendPositive ? Icons.trending_up : Icons.trending_up,
                size: 14,
                color: isTrendPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isTrendPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockMovementCard(DashboardProvider dp) {
    if (dp.dailyStats.isEmpty) return const SizedBox();

    final now = DateTime.now();
    final List<String> last7Days = [];
    for (int i = 6; i >= 0; i--) {
      last7Days.add(DateFormat('E').format(now.subtract(Duration(days: i))));
    }

    final List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      final stats = dp.dailyStats[day] ?? {'IN': 0.0, 'OUT': 0.0};
      final inValue = (stats['IN'] ?? 0.0).toDouble();
      final outValue = (stats['OUT'] ?? 0.0).toDouble();

      if (inValue > maxY) maxY = inValue;
      if (outValue > maxY) maxY = outValue;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: inValue,
              color: const Color(0xFF1E293B),
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: outValue,
              color: const Color(0xFFE2E8F0),
              width: 8,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          barsSpace: 4,
        ),
      );
    }

    maxY = (maxY == 0) ? 10 : maxY * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stock Movement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'In vs Out (Last 7 Days)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendDot(const Color(0xFF1E293B), 'In'),
                  const SizedBox(width: 12),
                  _buildLegendDot(const Color(0xFFE2E8F0), 'Out'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: barGroups,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= last7Days.length) {
                          return const SizedBox();
                        }
                        final isToday = index == 6;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            last7Days[index],
                            style: TextStyle(
                              color: isToday
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey[500],
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFilterChip(DashboardProvider dp, String label) {
    final isSelected = dp.inventoryFilter == label;
    return GestureDetector(
      onTap: () => dp.setInventoryFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _InventoryItemTile extends StatelessWidget {
  final Product product;
  final String categoryName;

  const _InventoryItemTile({required this.product, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final isLow = product.stockQuantity > 0 && product.stockQuantity <= 5;
    final isEmpty = product.stockQuantity == 0;

    Color statusColor;
    String statusLabel;

    if (isEmpty) {
      statusColor = Colors.red;
      statusLabel = 'Empty';
    } else if (isLow) {
      statusColor = Colors.orange;
      statusLabel = 'Low';
    } else {
      statusColor = Colors.green;
      statusLabel = 'Good';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.imageUrl != null
                  ? Image.network(
                      ApiService.getImageUrl(product.imageUrl)!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'SKU: ${product.id.substring(0, 8).toUpperCase()} • $categoryName',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.stockQuantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
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
