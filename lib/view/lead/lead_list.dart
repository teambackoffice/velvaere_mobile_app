import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:velvaere_app/controller/get_lead_controller.dart';
import 'package:velvaere_app/modal/get_lead_modal.dart';
import 'package:velvaere_app/theme/app_colors.dart';
import 'package:velvaere_app/view/lead/create_lead.dart';
import 'package:velvaere_app/view/lead/lead_detail.dart';

class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  static const _filters = ['All', 'New', 'Converted'];

  static const Map<String, Color> _statusColors = {
    'New': kPrimary,
    'Follow-up': kWarning,
    'Converted': kSuccess,
    'Lost': kError,
  };

  static const Map<String, Color> _statusBgColors = {
    'New': kPrimaryBg,
    'Follow-up': Color(0xFFFEF3C7),
    'Converted': Color(0xFFDCFCE7),
    'Lost': Color(0xFFFEE2E2),
  };

  static const Map<String, IconData> _sourceIcons = {
    'Website': Icons.language_rounded,
    'Referral': Icons.people_rounded,
    'Cold Call': Icons.phone_rounded,
    'Social Media': Icons.share_rounded,
    'Email Campaign': Icons.email_rounded,
    'Manual': Icons.edit_rounded,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadController>().fetchLeads();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Message> _filtered(List<Message> all) {
    return all.where((l) {
      final matchFilter =
          _selectedFilter == 'All' || l.status == _selectedFilter;
      final matchSearch =
          _searchQuery.isEmpty ||
          l.leadName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase());
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
  Widget build(BuildContext context) {
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
              MaterialPageRoute(builder: (_) => const CreateLeadPage()),
            );
          },
          backgroundColor: Color(0xFF426E4B),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.person_add_rounded),
          label: const Text(
            'New Lead',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: Consumer<LeadController>(
            builder: (context, controller, _) {
              final filtered = _filtered(controller.leads);
              return Column(
                children: [
                  _buildAppBar(controller.leads.length),
                  const SizedBox(height: 10),
                  _buildSearchBar(),
                  _buildFilterChips(controller.leads),
                  Expanded(
                    child: controller.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF10B981),
                            ),
                          )
                        : controller.error != null
                        ? _buildErrorState(controller)
                        : filtered.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => _buildCard(filtered[i]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(int total) {
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
              'Leads',
              style: TextStyle(
                color: kText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFD1FAE5),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Text(
          //     '$total Total',
          //     style: const TextStyle(
          //       color: Color(0xFF10B981),
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
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
          hintText: 'Search by name...',
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
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<Message> all) {
    return Container(
      color: kCard,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((f) {
            final isSelected = _selectedFilter == f;
            final color = f == 'All'
                ? const Color(0xFF426E4B)
                : _statusColors[f] ?? const Color(0xFF426E4B);
            final count = f == 'All'
                ? all.length
                : all.where((l) => l.status == f).length;
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
                          '$count',
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

  Widget _buildCard(Message l) {
    final statusColor = _statusColors[l.status] ?? kPrimary;
    final statusBg = _statusBgColors[l.status] ?? kPrimaryBg;
    final sourceIcon = _sourceIcons[l.source] ?? Icons.track_changes_rounded;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LeadDetailPage(lead: l)),
        );
      },
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      l.leadName.isNotEmpty ? l.leadName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Color(0xFF426E4B),
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
                        l.leadName,
                        style: const TextStyle(
                          color: kText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.mobileNo.isNotEmpty ? l.mobileNo : l.name,
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
                    l.status,
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
                  _formatDate(l.creation),
                  style: const TextStyle(color: kSubtext, fontSize: 12),
                ),
                const Spacer(),
                Icon(sourceIcon, size: 13, color: kSubtext),
                const SizedBox(width: 5),
                Text(
                  l.source,
                  style: const TextStyle(
                    color: kSubtext,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(LeadController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.wifi_off_rounded, color: kError, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load leads',
            style: TextStyle(
              color: kText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.error ?? '',
            style: const TextStyle(color: kSubtext, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.fetchLeads();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Color(0xFF10B981),
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No leads found',
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
