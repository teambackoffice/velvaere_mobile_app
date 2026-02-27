import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvaere_app/theme/app_colors.dart';
import 'package:velvaere_app/view/quotation/create_quotation.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class QuotationModel {
  final String id;
  final String customer;
  final double total;
  final String status;
  final DateTime date;

  const QuotationModel({
    required this.id,
    required this.customer,
    required this.total,
    required this.status,
    required this.date,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class QuotationListPage extends StatefulWidget {
  const QuotationListPage({super.key});

  @override
  State<QuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Mock data
  final List<QuotationModel> _all = [
    QuotationModel(
      id: 'QT-0024',
      customer: 'Acme Corp',
      total: 45200,
      status: 'Approved',
      date: DateTime(2025, 5, 20),
    ),
    QuotationModel(
      id: 'QT-0023',
      customer: 'TechVision Ltd',
      total: 12800,
      status: 'Pending',
      date: DateTime(2025, 5, 18),
    ),
    QuotationModel(
      id: 'QT-0022',
      customer: 'Nova Builders',
      total: 98500,
      status: 'Approved',
      date: DateTime(2025, 5, 15),
    ),
    QuotationModel(
      id: 'QT-0021',
      customer: 'Skyline Retail',
      total: 7650,
      status: 'Rejected',
      date: DateTime(2025, 5, 12),
    ),
    QuotationModel(
      id: 'QT-0020',
      customer: 'Kiran Enterprises',
      total: 33000,
      status: 'Pending',
      date: DateTime(2025, 5, 10),
    ),
    QuotationModel(
      id: 'QT-0019',
      customer: 'Blue Ridge Co.',
      total: 19200,
      status: 'Approved',
      date: DateTime(2025, 5, 8),
    ),
    QuotationModel(
      id: 'QT-0018',
      customer: 'Zara Wholesale',
      total: 5500,
      status: 'Rejected',
      date: DateTime(2025, 5, 5),
    ),
    QuotationModel(
      id: 'QT-0017',
      customer: 'Metro Solutions',
      total: 61000,
      status: 'Pending',
      date: DateTime(2025, 5, 2),
    ),
  ];

  static const _filters = ['All', 'Approved', 'Pending', 'Rejected'];

  static const Map<String, Color> _statusColors = {
    'Approved': kSuccess,
    'Pending': kWarning,
    'Rejected': kError,
  };

  static const Map<String, Color> _statusBgColors = {
    'Approved': Color(0xFFDCFCE7),
    'Pending': Color(0xFFFEF3C7),
    'Rejected': Color(0xFFFEE2E2),
  };

  List<QuotationModel> get _filtered {
    return _all.where((q) {
      final matchFilter =
          _selectedFilter == 'All' || q.status == _selectedFilter;
      final matchSearch =
          _searchQuery.isEmpty ||
          q.customer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.id.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kSurface,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateQuotationPage()),
            );
          },
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'New',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _buildCard(filtered[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      decoration: const BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: kText,
              size: 18,
            ),
          ),
          const Expanded(
            child: Text(
              'Quotations',
              style: TextStyle(
                color: kText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kPrimaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_all.length} Total',
              style: const TextStyle(
                color: kPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: kCard,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: kText, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by customer or ID…',
          hintStyle: const TextStyle(color: kSubtext, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: kSubtext,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: kSubtext,
                    size: 18,
                  ),
                )
              : null,
          filled: true,
          fillColor: kSurface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: kCard,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((f) {
            final isSelected = _selectedFilter == f;
            final color = f == 'All' ? kPrimary : _statusColors[f] ?? kPrimary;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFilter = f);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : kSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? color : kBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        f,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kSubtext,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.25)
                              : kBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          f == 'All'
                              ? '${_all.length}'
                              : '${_all.where((q) => q.status == f).length}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : kSubtext,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCard(QuotationModel q) {
    final statusColor = _statusColors[q.status] ?? kPrimary;
    final statusBg = _statusBgColors[q.status] ?? kPrimaryBg;
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kPrimaryBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      q.customer[0],
                      style: const TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.customer,
                        style: const TextStyle(
                          color: kText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        q.id,
                        style: const TextStyle(color: kSubtext, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    q.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: kBorder),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: kSubtext,
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(q.date),
                  style: const TextStyle(color: kSubtext, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '₹${q.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    color: kText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kPrimaryBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: kPrimary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No quotations found',
            style: TextStyle(
              color: kText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your search or filter',
            style: TextStyle(color: kSubtext, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
