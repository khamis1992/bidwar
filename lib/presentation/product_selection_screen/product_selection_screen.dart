import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';

class ProductSelectionScreen extends StatefulWidget {
  final String userTier;
  final int creditBalance;

  const ProductSelectionScreen({
    Key? key,
    required this.userTier,
    required this.creditBalance,
  }) : super(key: key);

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
  }

  Future<void> _loadProducts() async {
    try {
      final client = SupabaseService.instance.client;

      // Load products based on user tier
      final response = await client
          .from('system_products')
          .select('*, categories(*)')
          .eq('is_available', true)
          .lte('min_credit_balance', widget.creditBalance)
          .order('featured', ascending: false)
          .order('retail_value', ascending: false);

      setState(() {
        _products = response;
        _filteredProducts = response;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name');

      setState(() {
        _categories = response;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _applyFilters() {
    var filtered = List<dynamic>.from(_products);

    // Apply category filter
    if (_selectedCategoryId != 'all') {
      filtered = filtered
          .where((product) => product['category_id'] == _selectedCategoryId)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final title = product['title']?.toString().toLowerCase() ?? '';
        final brand = product['brand']?.toString().toLowerCase() ?? '';
        final description =
            product['description']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return title.contains(query) ||
            brand.contains(query) ||
            description.contains(query);
      }).toList();
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _selectProduct(Map<String, dynamic> product) {
    Navigator.pop(context, product);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Product',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withAlpha(26),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User Tier Banner
                _buildTierBanner(),

                // Search and Filter Section
                _buildSearchAndFilter(),

                // Products List
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : _buildProductsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildTierBanner() {
    Color tierColor;
    String tierDescription;

    switch (widget.userTier) {
      case 'platinum':
        tierColor = Colors.purple;
        tierDescription = 'Access to exclusive premium products';
        break;
      case 'gold':
        tierColor = Colors.amber.shade600;
        tierDescription = 'Access to luxury products and exclusives';
        break;
      case 'silver':
        tierColor = Colors.grey.shade600;
        tierDescription = 'Access to premium products';
        break;
      default:
        tierColor = Colors.brown;
        tierDescription = 'Access to standard product catalog';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tierColor.withAlpha(26), tierColor.withAlpha(51)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierColor.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tierColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.userTier.toUpperCase()} TIER',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tierDescription,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: tierColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Balance: \$${(widget.creditBalance / 100).toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: tierColor.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFilters();
            },
          ),

          const SizedBox(height: 16),

          // Category Filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('all', 'All Products'),
                ..._categories.map((category) =>
                    _buildCategoryChip(category['id'], category['name'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String categoryId, String label) {
    final isSelected = _selectedCategoryId == categoryId;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategoryId = categoryId;
          });
          _applyFilters();
        },
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.blue,
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final images = product['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.first.toString() : null;
    final retailValue = (product['retail_value'] as int? ?? 0) / 100;
    final startingPrice = (product['starting_price'] as int? ?? 0) / 100;
    final tierRequired = product['tier_requirement'] ?? 'bronze';
    final featured = product['featured'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: featured ? Border.all(color: Colors.orange, width: 2) : null,
      ),
      child: InkWell(
        onTap: () => _selectProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: imageUrl != null
                      ? CustomImageWidget(
                          imageUrl: imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (featured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'FEATURED',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (featured) const SizedBox(width: 8),
                        _buildTierBadge(tierRequired),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['title'] ?? 'Unknown Product',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product['brand'] != null)
                      Text(
                        product['brand'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Retail: \$${retailValue.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Starting: \$${startingPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierBadge(String tier) {
    Color badgeColor;
    switch (tier) {
      case 'platinum':
        badgeColor = Colors.purple;
        break;
      case 'gold':
        badgeColor = Colors.amber.shade600;
        break;
      case 'silver':
        badgeColor = Colors.grey.shade600;
        break;
      default:
        badgeColor = Colors.brown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        tier.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Available',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No products match your current filters.\nTry adjusting your search or category.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}