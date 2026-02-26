import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvaere_app/theme/app_colors.dart';

// ─── Data Models ─────────────────────────────────────────────────────────
enum CheckInStatus { notCheckedIn, checkedIn }

// ─── HomePage Widget ──────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  CheckInStatus _checkInStatus = CheckInStatus.notCheckedIn;
  String _checkInTime = '';
  bool _checkingIn = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Mock data
  final String _salesPersonName = 'Rajesh Kumar';

  // Quotation stats
  final int _quotApproved = 12;
  final int _quotPending = 9;
  final int _quotRejected = 3;

  // Lead stats
  final int _leadsNew = 14;
  final int _leadsFollowUp = 18;
  final int _leadsConverted = 6;

  int get _totalQuotations => _quotApproved + _quotPending + _quotRejected;
  int get _totalLeads => _leadsNew + _leadsFollowUp + _leadsConverted;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    if (_checkInStatus == CheckInStatus.checkedIn) return;
    HapticFeedback.mediumImpact();
    setState(() => _checkingIn = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    setState(() {
      _checkInStatus = CheckInStatus.checkedIn;
      _checkInTime = '$hour:$minute $period';
      _checkingIn = false;
    });
    HapticFeedback.lightImpact();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _formattedDate {
    final now = DateTime.now();
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[now.weekday - 1];
    return '$dayName, ${months[now.month - 1]} ${now.day}, ${now.year}';
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
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCheckInBanner(),
                      const SizedBox(height: 20),

                      // ── Quotation Summary ────────────────────────────
                      _buildSummaryCard(
                        title: 'Quotations',
                        total: _totalQuotations,
                        totalLabel: 'Total',
                        icon: Icons.description_rounded,
                        iconColor: kPrimary,
                        iconBg: kPrimaryBg,
                        stats: [
                          _StatChip(
                            label: 'Approved',
                            value: _quotApproved,
                            color: kSuccess,
                          ),
                          _StatChip(
                            label: 'Pending',
                            value: _quotPending,
                            color: kWarning,
                          ),
                          _StatChip(
                            label: 'Rejected',
                            value: _quotRejected,
                            color: kError,
                          ),
                        ],
                        onTap: () => HapticFeedback.selectionClick(),
                      ),

                      const SizedBox(height: 12),

                      // ── Lead Summary ─────────────────────────────────
                      _buildSummaryCard(
                        title: 'Leads',
                        total: _totalLeads,
                        totalLabel: 'Total',
                        icon: Icons.people_alt_rounded,
                        iconColor: const Color(0xFF10B981),
                        iconBg: const Color(0xFFD1FAE5),
                        stats: [
                          _StatChip(
                            label: 'New',
                            value: _leadsNew,
                            color: kPrimary,
                          ),
                          _StatChip(
                            label: 'Follow-up',
                            value: _leadsFollowUp,
                            color: kWarning,
                          ),
                          _StatChip(
                            label: 'Converted',
                            value: _leadsConverted,
                            color: kSuccess,
                          ),
                        ],
                        onTap: () => HapticFeedback.selectionClick(),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          color: kText,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionsGrid(),
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

  // ─── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: kCard,
        border: Border(bottom: BorderSide(color: kBorder, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kPrimary, kPrimaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'RK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
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
                  '$_greeting, ${_salesPersonName.split(' ').first} 👋',
                  style: const TextStyle(
                    color: kText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate,
                  style: const TextStyle(
                    color: kSubtext,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Check-In Banner ────────────────────────────────────────────────────
  Widget _buildCheckInBanner() {
    final isCheckedIn = _checkInStatus == CheckInStatus.checkedIn;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCheckedIn
              ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
              : [kPrimary, kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isCheckedIn ? kSuccess : kPrimary).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: isCheckedIn
                ? const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 24,
                  )
                : ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(
                      Icons.location_off_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckedIn
                      ? 'Checked In at $_checkInTime'
                      : 'Not Checked In',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCheckedIn
                      ? 'GPS location recorded ✓'
                      : 'Tap to record attendance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isCheckedIn)
            GestureDetector(
              onTap: _checkingIn ? null : _handleCheckIn,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _checkingIn
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: kPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Check In',
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: const Text(
                '✓ Active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Summary Card ────────────────────────────────────────────────────────
  Widget _buildSummaryCard({
    required String title,
    required int total,
    required String totalLabel,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required List<_StatChip> stats,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total $totalLabel',
                  style: const TextStyle(
                    color: kSubtext,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 36, color: kBorder),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: stats
                    .map((s) => _buildStatPill(s.label, s.value, s.color))
                    .toList(),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: kSubtext, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: kSubtext,
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Quick Actions Grid ──────────────────────────────────────────────────
  Widget _buildQuickActionsGrid() {
    final actions = [
      _QuickActionData(
        title: 'Create Quotation',
        subtitle: 'New invoice',
        icon: Icons.description_rounded,
        color: kPrimary,
        bgColor: kPrimaryBg,
      ),
      _QuickActionData(
        title: 'Quotation List',
        subtitle: '$_totalQuotations total',
        icon: Icons.folder_copy_rounded,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF3EEFF),
      ),
      _QuickActionData(
        title: 'Create Lead',
        subtitle: 'Quick add',
        icon: Icons.person_add_rounded,
        color: const Color(0xFF0EA5E9),
        bgColor: const Color(0xFFE0F7FF),
      ),
      _QuickActionData(
        title: 'Lead List',
        subtitle: '$_totalLeads total',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFD1FAE5),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) => _buildActionCard(actions[i]),
    );
  }

  Widget _buildActionCard(_QuickActionData data) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(data.icon, color: data.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: kText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: kSubtext,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: kSubtext.withOpacity(0.5),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper classes ──────────────────────────────────────────────────────────
class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _StatChip {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });
}
