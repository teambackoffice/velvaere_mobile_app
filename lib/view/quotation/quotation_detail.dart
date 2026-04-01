import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvaere_app/modal/get_quotation_modal.dart';
import 'package:velvaere_app/theme/app_colors.dart';

class QuotationDetailPage extends StatelessWidget {
  final Message message;

  const QuotationDetailPage({super.key, required this.message});

  Quotation get quotation => message.quotation;
  List<Item> get items => message.items;

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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle_rounded;
      case 'Open':
        return Icons.pending_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.edit_note_rounded;
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(quotation.status);

    return Scaffold(
      backgroundColor: kSurface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, statusColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(statusColor),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Quotation Info'),
                  const SizedBox(height: 10),
                  _buildInfoCard([
                    _InfoRow(
                      icon: Icons.tag_rounded,
                      label: 'Quotation ID',
                      value: quotation.name,
                      canCopy: true,
                      context: context,
                    ),
                    _InfoRow(
                      icon: Icons.person_rounded,
                      label: 'Customer Name',
                      value: quotation.customerName,
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Transaction Date',
                      value: _formatDate(quotation.transactionDate),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Financial Summary'),
                  const SizedBox(height: 10),
                  _buildAmountCard(),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle('Items (${items.length})'),
                    const SizedBox(height: 10),
                    _buildItemsCard(),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionTitle('Status'),
                  const SizedBox(height: 10),
                  _buildStatusCard(statusColor),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color statusColor) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: kCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBorder),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: kText,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 40, bottom: 14, right: 16),
        title: Text(
          quotation.name,
          style: const TextStyle(
            color: kText,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary.withOpacity(0.08), kCard],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: kBorder),
      ),
    );
  }

  Widget _buildHeroCard(Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF426E4B),

        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                    'Grand Total',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(quotation.grandTotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(quotation.status),
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      quotation.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  quotation.customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(quotation.transactionDate),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[  
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white70, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: kText,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: kBorder),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.currency_rupee_rounded,
              color: kPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(color: kSubtext, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatCurrency(quotation.grandTotal),
                  style: const TextStyle(
                    color: kText,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStatusIcon(quotation.status),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Status',
                style: TextStyle(color: kSubtext, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                quotation.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kPrimaryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kPrimary,
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
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.itemCode,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kSubtext,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _ItemChip(
                                label: '${item.qty % 1 == 0 ? item.qty.toInt() : item.qty} ${item.uom}',
                                icon: Icons.inventory_2_outlined,
                              ),
                              const SizedBox(width: 6),
                              _ItemChip(
                                label: _formatCurrency(item.rate) + '/unit',
                                icon: Icons.currency_rupee_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(item.amount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: kText,
                          ),
                        ),
                        if (item.discountPercentage > 0)
                          Text(
                            '${item.discountPercentage.toStringAsFixed(0)}% off',
                            style: const TextStyle(
                              fontSize: 10,
                              color: kSuccess,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: kBorder),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ItemChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: kSubtext),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: kSubtext, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── Info Row Widget ─────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool canCopy;
  final BuildContext? context;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.canCopy = false,
    this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: kPrimary, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: kSubtext, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: kText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
