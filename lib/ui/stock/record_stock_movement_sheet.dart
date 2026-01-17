import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_management/models/product_model.dart';
import 'package:stock_management/providers/product_provider.dart';
import 'package:stock_management/providers/stock_movement_provider.dart';

class RecordStockMovementSheet extends StatefulWidget {
  const RecordStockMovementSheet({super.key});

  @override
  State<RecordStockMovementSheet> createState() =>
      _RecordStockMovementSheetState();
}

class _RecordStockMovementSheetState extends State<RecordStockMovementSheet> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'IN'; // IN, OUT
  String? _selectedProductId;
  final TextEditingController _quantityController = TextEditingController(
    text: '0',
  );
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch products to populate dropdown
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _quantityController.text = (current + 1).toString();
    });
  }

  void _decrementQuantity() {
    int current = int.tryParse(_quantityController.text) ?? 0;
    if (current > 0) {
      setState(() {
        _quantityController.text = (current - 1).toString();
      });
    }
  }

  Future<void> _submitbox() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quantity = int.parse(_quantityController.text);

      await Provider.of<StockMovementProvider>(
        context,
        listen: false,
      ).addStockMovement(
        _selectedProductId!,
        _type,
        quantity,
        _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock $_type recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Record Movement',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 60), // Balance
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Type Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(child: _buildTypeToggle('Stock In', 'IN')),
                          Expanded(child: _buildTypeToggle('Stock Out', 'OUT')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product Dropdown
                    _buildLabel('Product'),
                    Consumer<ProductProvider>(
                      builder: (context, provider, _) {
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedProductId,
                          decoration: _buildInputDecoration(
                            'Select product name or SKU...',
                          ),
                          items: provider.products.map((Product p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedProductId = val),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    _buildLabel('Quantity'),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _decrementQuantity,
                          icon: const Icon(Icons.remove, color: Colors.grey),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('0'),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final n = int.tryParse(val);
                              if (n == null || n <= 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _incrementQuantity,
                          icon: const Icon(Icons.add, color: Colors.blue),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('Reason / Notes (Optional)'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _buildInputDecoration(
                        'e.g. New shipment from supplier...',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitbox,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Greenish
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Confirm Stock ${_type == 'IN' ? 'In' : 'Out'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(String title, String value) {
    final isSelected = _type == value;
    final color = value == 'IN' ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'IN' ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black87 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
