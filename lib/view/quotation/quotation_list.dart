import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:velvaere_app/controller/get_quotation_controller.dart';
import 'package:velvaere_app/theme/app_colors.dart';
import 'package:velvaere_app/modal/get_quotation_modal.dart';
import 'package:velvaere_app/view/quotation/create_quotation.dart';
import 'package:velvaere_app/view/quotation/quotation_detail.dart';

class QuotationListPage extends StatefulWidget {
  const QuotationListPage({super.key});

  @override
  State<QuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotationController>().fetchQuotationDetails();
    });
  }

  static const _filters = ['All', 'Draft', 'Open', 'Approved', 'Cancelled'];

  // Status mapping for API values
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return kSuccess;
      case 'Open':
        return kWarning;
      case 'Cancelled':
        return kError;
      default:
        return kSubtext;
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateQuotationPage()),
        ),
        backgroundColor: kPrimary,
        label: const Text(
          'New',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            // _buildFilterChips(),
            Expanded(
              child: Consumer<QuotationController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    );
                  }

                  if (controller.error != null) {
                    return _buildErrorState(controller.error!);
                  }

                  final allData = controller.quotationData?.message ?? [];
                  final filtered = allData.where((m) {
                    final q = m.quotation;
                    final matchesFilter =
                        _selectedFilter == 'All' || q.status == _selectedFilter;
                    final matchesSearch =
                        q.customerName.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        q.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                    return matchesFilter && matchesSearch;
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchQuotationDetails(),
                    child: filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) => _buildCard(filtered[i]),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Message message) {
    final q = message.quotation;
    final color = _getStatusColor(q.status);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuotationDetailPage(quotation: q),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  q.name,
                  style: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    q.status,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              q.customerName,
              style: const TextStyle(
                color: kText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const Divider(height: 24, color: kBorder),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${q.transactionDate.day}/${q.transactionDate.month}/${q.transactionDate.year}',
                  style: const TextStyle(color: kSubtext, fontSize: 12),
                ),
                Text(
                  _formatCurrency(q.grandTotal),
                  style: const TextStyle(
                    color: kText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: kText),
          ),
          const SizedBox(width: 12),
          const Text(
            'Quotations',
            style: TextStyle(
              color: kText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search quotations...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: kCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _selectedFilter == f,
                  onSelected: (val) => setState(() => _selectedFilter = f),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("No quotations found", style: TextStyle(color: kSubtext)),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: kError, size: 40),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kText, fontSize: 12),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                context.read<QuotationController>().fetchQuotationDetails(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
