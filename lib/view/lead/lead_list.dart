import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvaere_app/theme/app_colors.dart';
import 'package:velvaere_app/view/lead/create_lead.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class LeadModel {
  final String id;
  final String name;
  final String company;
  final String source;
  final String status;
  final DateTime date;

  const LeadModel({
    required this.id,
    required this.name,
    required this.company,
    required this.source,
    required this.status,
    required this.date,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class LeadListPage extends StatefulWidget {
  const LeadListPage({super.key});

  @override
  State<LeadListPage> createState() => _LeadListPageState();
}

class _LeadListPageState extends State<LeadListPage> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Mock data
  final List<LeadModel> _all = [
    LeadModel(
      id: 'LD-0038',
      name: 'Ankit Sharma',
      company: 'Zenith Tech',
      source: 'Website',
      status: 'New',
      date: DateTime(2025, 5, 21),
    ),
    LeadModel(
      id: 'LD-0037',
      name: 'Priya Nair',
      company: 'Bloom Retail',
      source: 'Referral',
      status: 'Follow-up',
      date: DateTime(2025, 5, 19),
    ),
    LeadModel(
      id: 'LD-0036',
      name: 'Rahul Mehta',
      company: 'Apex Infra',
      source: 'Cold Call',
      status: 'Converted',
      date: DateTime(2025, 5, 17),
    ),
    LeadModel(
      id: 'LD-0035',
      name: 'Sunita Rao',
      company: 'GreenLeaf Co.',
      source: 'Social Media',
      status: 'New',
      date: DateTime(2025, 5, 14),
    ),
    LeadModel(
      id: 'LD-0034',
      name: 'Vikram Joshi',
      company: 'Prime Logistics',
      source: 'Email Campaign',
      status: 'Follow-up',
      date: DateTime(2025, 5, 12),
    ),
    LeadModel(
      id: 'LD-0033',
      name: 'Kavya Iyer',
      company: 'SunCorp',
      source: 'Website',
      status: 'Converted',
      date: DateTime(2025, 5, 9),
    ),
    LeadModel(
      id: 'LD-0032',
      name: 'Deepak Singh',
      company: 'Urban Spaces',
      source: 'Manual',
      status: 'Lost',
      date: DateTime(2025, 5, 7),
    ),
    LeadModel(
      id: 'LD-0031',
      name: 'Meera Pillai',
      company: 'FastTrack Ltd',
      source: 'Referral',
      status: 'New',
      date: DateTime(2025, 5, 4),
    ),
    LeadModel(
      id: 'LD-0030',
      name: 'Arjun Reddy',
      company: 'DataBridge',
      source: 'Cold Call',
      status: 'Follow-up',
      date: DateTime(2025, 5, 2),
    ),
  ];

  static const _filters = ['All', 'New', 'Follow-up', 'Converted', 'Lost'];

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

  List<LeadModel> get _filtered {
    return _all.where((l) {
      final matchFilter =
          _selectedFilter == 'All' || l.status == _selectedFilter;
      final matchSearch =
          _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.id.toLowerCase().contains(_searchQuery.toLowerCase());
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
              MaterialPageRoute(builder: (_) => const CreateLeadPage()),
            );
          },
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.person_add_rounded),
          label: const Text(
            'New Lead',
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
              'Leads',
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
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_all.length} Total',
              style: const TextStyle(
                color: Color(0xFF10B981),
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
          hintText: 'Search by name, company or ID…',
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
            final color = f == 'All'
                ? const Color(0xFF10B981)
                : _statusColors[f] ?? kPrimary;
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
                              : '${_all.where((l) => l.status == f).length}',
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

  Widget _buildCard(LeadModel l) {
    final statusColor = _statusColors[l.status] ?? kPrimary;
    final statusBg = _statusBgColors[l.status] ?? kPrimaryBg;
    final sourceIcon = _sourceIcons[l.source] ?? Icons.track_changes_rounded;

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
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(
                    child: Text(
                      l.name[0],
                      style: const TextStyle(
                        color: Color(0xFF10B981),
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
                        l.name,
                        style: const TextStyle(
                          color: kText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.company.isNotEmpty ? l.company : l.id,
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
                  _formatDate(l.date),
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
