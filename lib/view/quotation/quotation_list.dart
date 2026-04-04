import 'package:flutter/material.dart';
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

  static const _kGreen = Color(0xFF1A3D2B);
  static const _kGreenLight = Color(0xFFEAF3DE);
  static const _kGreenText = Color(0xFF3B6D11);

  static const _filters = ['All', 'Draft', 'Open', 'Approved', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotationController>().fetchQuotationDetails();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  ({Color bg, Color fg}) _badgeColors(String status) {
    switch (status) {
      case 'Approved':
        return (bg: const Color(0xFFEAF3DE), fg: const Color(0xFF3B6D11));
      case 'Open':
        return (bg: const Color(0xFFFDF0DA), fg: const Color(0xFFA05C0A));
      case 'Cancelled':
        return (bg: const Color(0xFFFCEBEB), fg: const Color(0xFFA32D2D));
      default: // Draft
        return (bg: const Color(0xFFF0EFE8), fg: const Color(0xFF5E5C50));
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String _formatAmountFull(double amount) =>
      '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthAbbr(d.month)} ${d.year}';

  String _monthAbbr(int m) => const [
    '',
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
  ][m];

  List<Message> _applyFilters(List<Message> all) => all.where((m) {
    final q = m.quotation;
    final matchFilter = _selectedFilter == 'All' || q.status == _selectedFilter;
    final matchSearch =
        q.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        q.name.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchFilter && matchSearch;
  }).toList();

  // ── summary stats ─────────────────────────────────────────────────────────

  ({double totalValue, int approved, int pending}) _stats(List<Message> data) {
    double total = 0;
    int approved = 0;
    int pending = 0;
    for (final m in data) {
      total += m.quotation.grandTotal;
      if (m.quotation.status == 'Approved') approved++;
      if (m.quotation.status == 'Open' || m.quotation.status == 'Draft') {
        pending++;
      }
    }
    return (totalValue: total, approved: approved, pending: pending);
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      floatingActionButton: _buildFab(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            Expanded(
              child: Consumer<QuotationController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: _kGreen),
                    );
                  }
                  if (controller.error != null) {
                    return _buildErrorState(controller.error!);
                  }

                  final all = controller.quotationData?.message ?? [];
                  final filtered = _applyFilters(all);
                  final stats = _stats(all);

                  return RefreshIndicator(
                    color: _kGreen,
                    onRefresh: () => controller.fetchQuotationDetails(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      children: [
                        if (filtered.isEmpty)
                          _buildEmptyState()
                        else
                          ...filtered.map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildCard(m),
                            ),
                          ),
                      ],
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

  // ── top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          _CircleIconButton(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back_ios_new, size: 14, color: kText),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Quotations',
              style: TextStyle(
                color: kText,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Consumer<QuotationController>(
            builder: (_, controller, __) {
              final count = controller.quotationData?.message.length ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder, width: 0.5),
                ),
                child: Text(
                  '$count total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kSubtext,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── search ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder, width: 0.5),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, color: kText),
          decoration: InputDecoration(
            hintText: 'Search by customer or ref...',
            hintStyle: const TextStyle(fontSize: 14, color: kSubtext),
            prefixIcon: const Icon(Icons.search, size: 18, color: kSubtext),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close, size: 16, color: kSubtext),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ── filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final selected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _kGreen : kCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _kGreen : kBorder,
                  width: 0.5,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : kSubtext,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── section label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: kSubtext,
        letterSpacing: 0.6,
      ),
    );
  }

  // ── quotation card ────────────────────────────────────────────────────────

  Widget _buildCard(Message message) {
    final q = message.quotation;
    final badge = _badgeColors(q.status);

    final itemCount = message.items.length;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuotationDetailPage(message: message),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── row 1: ref + badge ──
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 12,
                  color: kSubtext,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    q.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: kSubtext,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badge.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    q.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: badge.fg,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── row 2: customer name ──
            Text(
              q.customerName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),

            const SizedBox(height: 8),

            // ── row 3: hints (items + expiry) ──
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '$itemCount items',
                  style: const TextStyle(fontSize: 11, color: kSubtext),
                ),
                const SizedBox(width: 10),
                const Text('|', style: TextStyle(fontSize: 11, color: kBorder)),
                const SizedBox(width: 10),
              ],
            ),

            const Divider(height: 20, thickness: 0.5, color: kBorder),

            // ── row 4: date + amount ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: kSubtext,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(q.transactionDate),
                      style: const TextStyle(fontSize: 11, color: kSubtext),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateQuotationPage()),
      ),
      backgroundColor: _kGreen,
      elevation: 3,
      label: const Text(
        'New Quotation',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      icon: const Icon(Icons.add, color: Colors.white, size: 18),
    );
  }

  // ── empty / error ─────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 40, color: kSubtext),
            SizedBox(height: 12),
            Text(
              'No quotations found',
              style: TextStyle(color: kSubtext, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final displayError = error.contains('502')
        ? 'Server is temporarily unavailable.\nWe\'re working on it.'
        : error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kError.withOpacity(0.15), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with soft glow
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kError.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kError.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: kError,
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle / error message
              Text(
                displayError,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kText.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Retry button — full width, filled
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => context
                      .read<QuotationController>()
                      .fetchQuotationDetails(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Try again',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── reusable widgets ──────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _CircleIconButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: kSurface,
          shape: BoxShape.circle,
          border: Border.all(color: kBorder, width: 0.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: kSubtext)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
            const SizedBox(height: 1),
            Text(sub, style: const TextStyle(fontSize: 10, color: kSubtext)),
          ],
        ),
      ),
    );
  }
}
