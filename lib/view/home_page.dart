import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:velvaere_app/controller/check_in/get_controller.dart';
import 'package:velvaere_app/controller/check_in/post_controller.dart';
import 'package:velvaere_app/controller/logout_controller.dart';
import 'package:velvaere_app/theme/app_colors.dart';
import 'package:velvaere_app/view/lead/create_lead.dart';
import 'package:velvaere_app/view/lead/lead_list.dart';
import 'package:velvaere_app/view/quotation/create_quotation.dart';
import 'package:velvaere_app/view/quotation/quotation_list.dart';

// ─── Data Models ──────────────────────────────────────
enum CheckInStatus { notCheckedIn, checkedIn, checkedOut }

// ─── HomePage Widget ──────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  CheckInStatus _checkInStatus = CheckInStatus.notCheckedIn;
  String _checkInTime = '';
  String _checkOutTime = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _salesPersonName = '';

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
    _loadUserName();

    // Fetch today's checkins after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodayCheckins();
    });
  }

  Future<void> _loadUserName() async {
    const storage = FlutterSecureStorage();
    final name = await storage.read(key: 'full_name');
    if (mounted) {
      setState(() {
        _salesPersonName = name ?? '';
      });
    }
  }

  /// Fetch existing checkins and determine current status
  Future<void> _loadTodayCheckins() async {
    final controller = context.read<CheckinController>();
    await controller.fetchMobileCheckins();

    if (!mounted) return;

    final checkins = controller.checkins;
    if (checkins.isEmpty) {
      setState(() => _checkInStatus = CheckInStatus.notCheckedIn);
      return;
    }

    // Sort by time descending to get the latest record
    final sorted = List<dynamic>.from(checkins)
      ..sort((a, b) {
        final tA = DateTime.tryParse(a['time'] ?? '') ?? DateTime(2000);
        final tB = DateTime.tryParse(b['time'] ?? '') ?? DateTime(2000);
        return tB.compareTo(tA);
      });

    final latest = sorted.first;
    final latestLogType = latest['log_type'] ?? '';

    // Find IN and OUT times
    String inTime = '';
    String outTime = '';
    for (final c in sorted.reversed) {
      if ((c['log_type'] ?? '') == 'IN' && inTime.isEmpty) {
        inTime = _formatTimeFromString(c['time'] ?? '');
      }
      if ((c['log_type'] ?? '') == 'OUT') {
        outTime = _formatTimeFromString(c['time'] ?? '');
      }
    }

    setState(() {
      if (latestLogType == 'IN') {
        _checkInStatus = CheckInStatus.checkedIn;
        _checkInTime = inTime;
        _checkOutTime = '';
      } else if (latestLogType == 'OUT') {
        _checkInStatus = CheckInStatus.checkedOut;
        _checkInTime = inTime;
        _checkOutTime = outTime;
      } else {
        _checkInStatus = CheckInStatus.notCheckedIn;
      }
    });
  }

  String _formatTimeFromString(String rawTime) {
    final dt = DateTime.tryParse(rawTime);
    if (dt == null) return rawTime;
    final local = dt.toLocal();
    final tod = TimeOfDay.fromDateTime(local);
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigate(Widget page) {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ─── Check In ────────────────────────────────────────────────────────────
  Future<void> _handleCheckIn() async {
    if (_checkInStatus == CheckInStatus.checkedIn) return;
    HapticFeedback.mediumImpact();

    final controller = context.read<EmployeeCheckinController>();
    final success = await controller.employeeCheckin(logType: 'IN');

    if (!mounted) return;

    if (success) {
      final now = TimeOfDay.now();
      final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.period == DayPeriod.am ? 'AM' : 'PM';
      setState(() {
        _checkInStatus = CheckInStatus.checkedIn;
        _checkInTime = '$hour:$minute $period';
        _checkOutTime = '';
      });
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.message.isNotEmpty
                ? controller.message
                : 'Checked in successfully',
          ),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.message.isNotEmpty
                ? controller.message
                : 'Check-in failed. Try again.',
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Check Out ───────────────────────────────────────────────────────────
  Future<void> _handleCheckOut() async {
    if (_checkInStatus != CheckInStatus.checkedIn) return;
    HapticFeedback.mediumImpact();

    final controller = context.read<EmployeeCheckinController>();
    final success = await controller.employeeCheckin(logType: 'OUT');

    if (!mounted) return;

    if (success) {
      final now = TimeOfDay.now();
      final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
      final minute = now.minute.toString().padLeft(2, '0');
      final period = now.period == DayPeriod.am ? 'AM' : 'PM';
      setState(() {
        _checkInStatus = CheckInStatus.checkedOut;
        _checkOutTime = '$hour:$minute $period';
      });
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.message.isNotEmpty
                ? controller.message
                : 'Checked out successfully',
          ),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.message.isNotEmpty
                ? controller.message
                : 'Check-out failed. Try again.',
          ),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
    // Listen to EmployeeCheckinController for isLoading
    final checkinCtrl = context.watch<EmployeeCheckinController>();

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
                      _buildCheckInBanner(checkinCtrl.isLoading),
                      const SizedBox(height: 20),
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
                colors: [Color(0xFF0D2A18), Color(0xFF1A3D28)],
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
            child: Center(
              child: Text(
                _salesPersonName.isNotEmpty
                    ? _salesPersonName
                          .trim()
                          .split(' ')
                          .where((p) => p.isNotEmpty)
                          .take(2)
                          .map((p) => p[0].toUpperCase())
                          .join()
                    : '?',
                style: const TextStyle(
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
                  '$_greeting, $_salesPersonName 👋',
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
          GestureDetector(
            onTap: _handleLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF426E4B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF426E4B).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF426E4B),
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFF426E4B),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            content: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      const Color(0xFF426E4B).withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFF426E4B),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Confirm Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2E22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Are you sure you want to log out?',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF426E4B),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () async {
                                    setDialogState(() => isLoading = true);
                                    final controller =
                                        context.read<LogoutController>();
                                    final success = await controller.logout();
                                    if (!ctx.mounted) return;
                                    Navigator.of(ctx).pop();
                                    if (success) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                        (route) => false,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Logout failed'),
                                        ),
                                      );
                                    }
                                  },
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckInBanner(bool isApiLoading) {
    final isCheckedIn = _checkInStatus == CheckInStatus.checkedIn;
    final isCheckedOut = _checkInStatus == CheckInStatus.checkedOut;

    final List<Color> gradientColors = isCheckedIn
        ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
        : [const Color(0xFF0D2A18), const Color(0xFF1A3D28)];

    final Color shadowColor = isCheckedIn ? kSuccess : const Color(0xFF0D2A18);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.35),
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
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  )
                : ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
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
                      : isCheckedOut
                      ? 'Checked Out at $_checkOutTime'
                      : 'Not Checked In',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isCheckedIn
                      ? 'Tap to check out '
                      : isCheckedOut
                      ? 'Tap to check in again'
                      : 'Tap to record attendance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // ── Check In button (shown when not checked in OR after checkout) ──
          if (!isCheckedIn)
            GestureDetector(
              onTap: isApiLoading ? null : _handleCheckIn,
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
                child: isApiLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Color(0xFF0D2A18),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Check In',
                        style: TextStyle(
                          color: Color(0xFF0D2A18),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            )
          else
            // ── Check Out button ──────────────────────────────────────────
            GestureDetector(
              onTap: isApiLoading ? null : _handleCheckOut,
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
                child: isApiLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Color(0xFFDC2626),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Check Out',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Quick Actions Grid ──────────────────────────────────────────────────
  Widget _buildQuickActionsGrid() {
    final actions = [
      _QuickActionData(
        title: 'Create Quotation',
        subtitle: 'New Quotation',
        icon: Icons.description_rounded,
        color: kPrimary,
        bgColor: kPrimaryBg,
        onTap: () => _navigate(const CreateQuotationPage()),
      ),
      _QuickActionData(
        title: 'Quotation List',
        subtitle: 'Quote records',
        icon: Icons.folder_copy_rounded,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF3EEFF),
        onTap: () => _navigate(const QuotationListPage()),
      ),
      _QuickActionData(
        title: 'Create Lead',
        subtitle: 'Quick add',
        icon: Icons.person_add_rounded,
        color: const Color(0xFF0EA5E9),
        bgColor: const Color(0xFFE0F7FF),
        onTap: () => _navigate(const CreateLeadPage()),
      ),
      _QuickActionData(
        title: 'Lead List',
        subtitle: 'Lead records',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFD1FAE5),
        onTap: () => _navigate(const LeadListPage()),
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
      onTap: data.onTap,
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
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(8),
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
                      fontSize: 11,
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
  final VoidCallback? onTap;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onTap,
  });
}
