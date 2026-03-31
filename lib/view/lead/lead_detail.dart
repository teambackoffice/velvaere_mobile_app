import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvaere_app/modal/get_lead_modal.dart';
import 'package:velvaere_app/theme/app_colors.dart';

class LeadDetailPage extends StatefulWidget {
  final Message lead;

  const LeadDetailPage({super.key, required this.lead});

  @override
  State<LeadDetailPage> createState() => _LeadDetailPageState();
}

class _LeadDetailPageState extends State<LeadDetailPage> {
  final _noteController = TextEditingController();
  final _noteFocusNode = FocusNode();
  final List<_Note> _notes = [];
  bool _showNoteInput = false;

  static const Map<String, Color> _statusColors = {
    'Lead': Color(0xFF426E4B),
    'New': kPrimary,
    'Follow-up': kWarning,
    'Converted': kSuccess,
    'Lost': kError,
  };

  static const Map<String, Color> _statusBgColors = {
    'Lead': Color(0xFFD1FAE5),
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
    'Walk In': Icons.directions_walk_rounded,
    'Advertisement': Icons.campaign_rounded,
  };

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

  String _formatDateTime(DateTime d) {
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final period = d.hour >= 12 ? 'PM' : 'AM';
    final min = d.minute.toString().padLeft(2, '0');
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
    return '${d.day} ${months[d.month - 1]}, $hour:$min $period';
  }

  Color _statusColor(String status) =>
      _statusColors[status] ?? const Color(0xFF426E4B);

  Color _statusBgColor(String status) =>
      _statusBgColors[status] ?? const Color(0xFFD1FAE5);

  void _addNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _notes.insert(0, _Note(text: text, createdAt: DateTime.now()));
      _noteController.clear();
      _showNoteInput = false;
    });
    HapticFeedback.mediumImpact();
  }

  void _deleteNote(int index) {
    HapticFeedback.mediumImpact();
    setState(() => _notes.removeAt(index));
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final statusColor = _statusColor(lead.status);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kSurface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, lead, statusColor),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroCard(lead, statusColor),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Contact Information'),
                    const SizedBox(height: 10),
                    _buildInfoCard([
                      _InfoRow(
                        icon: Icons.badge_rounded,
                        label: 'Lead ID',
                        value: lead.name,
                        canCopy: true,
                        context: context,
                        iconBg: const Color(0xFFEEF3FF),
                        iconColor: kPrimary,
                      ),
                      _InfoRow(
                        icon: Icons.phone_rounded,
                        label: 'Mobile Number',
                        value: lead.mobileNo.isNotEmpty ? lead.mobileNo : '—',
                        canCopy: lead.mobileNo.isNotEmpty,
                        context: context,
                        iconBg: const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF426E4B),
                      ),
                      _InfoRow(
                        icon: Icons.email_rounded,
                        label: 'Email Address',
                        value: lead.emailId.isNotEmpty ? lead.emailId : '—',
                        canCopy: lead.emailId.isNotEmpty,
                        context: context,
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: kWarning,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Lead Details'),
                    const SizedBox(height: 10),
                    _buildInfoCard([
                      _InfoRow(
                        icon:
                            _sourceIcons[lead.source] ??
                            Icons.track_changes_rounded,
                        label: 'Source',
                        value: lead.source,
                        iconBg: const Color(0xFFEEF3FF),
                        iconColor: kPrimary,
                      ),
                      // _InfoRow(
                      //   icon: Icons.manage_accounts_rounded,
                      //   label: 'Lead Owner',
                      //   value: lead.leadOwner,
                      //   iconBg: const Color(0xFFD1FAE5),
                      //   iconColor: const Color(0xFF426E4B),
                      // ),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Created On',
                        value: _formatDate(lead.creation),
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: kWarning,
                      ),
                      _InfoRow(
                        icon: Icons.update_rounded,
                        label: 'Last Modified',
                        value: _formatDate(lead.modified),
                        iconBg: const Color(0xFFF0F0F0),
                        iconColor: kSubtext,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Status'),
                    const SizedBox(height: 10),
                    _buildStatusCard(lead, statusColor),
                    const SizedBox(height: 20),
                    // _buildNotesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    Message lead,
    Color statusColor,
  ) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      backgroundColor: kCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          margin: const EdgeInsets.all(9),
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
        titlePadding: const EdgeInsets.only(left: 52, bottom: 14, right: 16),
        title: Text(
          lead.leadName,
          style: const TextStyle(
            color: kText,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E9), kCard],
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

  Widget _buildHeroCard(Message lead, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF426E4B),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF426E4B).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    lead.leadName.isNotEmpty
                        ? lead.leadName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.leadName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lead.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  lead.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.phone_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                lead.mobileNo.isNotEmpty ? lead.mobileNo : '—',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white70,
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(lead.creation),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
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

  Widget _buildStatusCard(Message lead, Color statusColor) {
    final bgColor = _statusBgColor(lead.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.flag_rounded, color: statusColor, size: 20),
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
                lead.status,
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

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Notes'),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showNoteInput = !_showNoteInput);
                if (!_showNoteInput) {
                  Future.delayed(const Duration(milliseconds: 50), () {
                    _noteFocusNode.requestFocus();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showNoteInput ? Icons.close_rounded : Icons.add_rounded,
                      color: const Color(0xFF426E4B),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showNoteInput ? 'Cancel' : 'Add Note',
                      style: const TextStyle(
                        color: Color(0xFF426E4B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Note input area
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _showNoteInput
              ? Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF426E4B).withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        maxLines: 4,
                        minLines: 2,
                        style: const TextStyle(color: kText, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Write a note about this lead…',
                          hintStyle: TextStyle(color: kSubtext, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _addNote,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF426E4B),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            'Save Note',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Notes list or empty
        if (_notes.isEmpty && !_showNoteInput)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sticky_note_2_rounded,
                      color: Color(0xFF426E4B),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No notes yet',
                    style: TextStyle(
                      color: kText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "Add Note" to jot something down',
                    style: TextStyle(color: kSubtext, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_notes.length, (i) => _buildNoteCard(i)),
      ],
    );
  }

  Widget _buildNoteCard(int index) {
    final note = _notes[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.sticky_note_2_rounded,
                  color: Color(0xFF426E4B),
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDateTime(note.createdAt),
                style: const TextStyle(color: kSubtext, fontSize: 11),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _deleteNote(index),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 14,
                    color: kError,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note.text,
            style: const TextStyle(color: kText, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Note Model ───────────────────────────────────────────────────────────────
class _Note {
  final String text;
  final DateTime createdAt;

  _Note({required this.text, required this.createdAt});
}

// ─── Info Row Widget ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool canCopy;
  final BuildContext? context;
  final Color iconBg;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.canCopy = false,
    this.context,
    required this.iconBg,
    required this.iconColor,
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
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
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
          if (canCopy)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                if (context != null) {
                  ScaffoldMessenger.of(context!).showSnackBar(
                    SnackBar(
                      content: const Text('Copied to clipboard'),
                      backgroundColor: const Color(0xFF426E4B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  size: 14,
                  color: kSubtext,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
