import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvaere_app/theme/app_colors.dart';

class CreateQuotationPage extends StatefulWidget {
  const CreateQuotationPage({super.key});

  @override
  State<CreateQuotationPage> createState() => _CreateQuotationPageState();
}

class _CreateQuotationPageState extends State<CreateQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _validUntil;
  bool _submitting = false;

  final List<_LineItem> _items = [_LineItem()];

  @override
  void dispose() {
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kPrimary,
            onPrimary: Colors.white,
            surface: kCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _validUntil = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quotation created successfully!'),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _removeItem(int index) {
    HapticFeedback.mediumImpact();
    final removed = _items[index];
    setState(() => _items.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          removed.name.isNotEmpty
              ? '"${removed.name}" removed'
              : 'Item removed',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kError,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => setState(() => _items.insert(index, removed)),
        ),
      ),
    );
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
              _buildAppBar(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Customer Details'),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _customerController,
                          label: 'Customer Name',
                          hint: 'e.g. Acme Corp',
                          icon: Icons.business_rounded,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _buildDateField(),
                        const SizedBox(height: 24),

                        // ── Items ─────────────────────────────────────
                        Row(
                          children: [
                            _sectionLabel('Items'),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _items.add(_LineItem()));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      color: kPrimary,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Add Item',
                                      style: TextStyle(
                                        color: kPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Card list
                        ...List.generate(
                          _items.length,
                          (i) => _buildItemCard(i),
                        ),

                        const SizedBox(height: 16),
                        _buildTotalRow(),
                        const SizedBox(height: 24),

                        _sectionLabel('Notes / Terms'),
                        const SizedBox(height: 10),
                        _buildTextField(
                          controller: _notesController,
                          label: 'Notes / Terms',
                          hint: 'Payment terms, delivery notes...',
                          icon: Icons.notes_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 32),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Item card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildItemCard(int index) {
    final item = _items[index];
    final canDelete = _items.length > 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card header bar ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kPrimaryBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Item',
                    style: TextStyle(
                      color: kPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 6),
                // Delete button
                GestureDetector(
                  onTap: canDelete ? () => _removeItem(index) : null,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: canDelete
                          ? kError.withOpacity(0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 15,
                      color: canDelete ? kError : kBorder,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card body ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                // Item name field
                TextFormField(
                  initialValue: item.name,
                  onChanged: (v) => setState(() => item.name = v),
                  style: const TextStyle(color: kText, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Item / Service name',
                    prefixIcon: const Icon(
                      Icons.inventory_2_outlined,
                      color: kSubtext,
                      size: 16,
                    ),
                    labelStyle: const TextStyle(color: kSubtext, fontSize: 12),
                    filled: true,
                    fillColor: kSurface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: kPrimary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    isDense: true,
                  ),
                ),

                const SizedBox(height: 10),

                // Qty + Rate row
                Row(
                  children: [
                    // Qty label + stepper
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              color: kSubtext,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(
                              children: [
                                _StepButton(
                                  icon: Icons.remove_rounded,
                                  onTap: item.qty > 0
                                      ? () {
                                          HapticFeedback.selectionClick();
                                          setState(
                                            () => item.qty = (item.qty - 1)
                                                .clamp(0, double.infinity),
                                          );
                                        }
                                      : null,
                                  left: true,
                                ),
                                Expanded(
                                  child: Text(
                                    item.qty.toStringAsFixed(0),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: kText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                _StepButton(
                                  icon: Icons.add_rounded,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => item.qty += 1);
                                  },
                                  left: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Rate
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rate (₹)',
                            style: TextStyle(
                              color: kSubtext,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: item.rate > 0
                                ? item.rate.toStringAsFixed(0)
                                : '',
                            onChanged: (v) => setState(
                              () => item.rate = double.tryParse(v) ?? 0,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(color: kText, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: kSubtext.withOpacity(0.5),
                                fontSize: 13,
                              ),
                              prefixText: '₹ ',
                              prefixStyle: const TextStyle(
                                color: kSubtext,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: kSurface,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: kBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: kPrimary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared helpers
  // ─────────────────────────────────────────────────────────────────────────

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
              'Create Quotation',
              style: TextStyle(
                color: kText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kPrimaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '₹${_subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                color: kPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: kText,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: kText, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: kSubtext, size: 18),
        labelStyle: const TextStyle(color: kSubtext, fontSize: 13),
        hintStyle: const TextStyle(color: kBorder, fontSize: 13),
        filled: true,
        fillColor: kCard,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: kSubtext, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _validUntil == null
                    ? 'Valid Until — select date'
                    : 'Valid Until: ${_validUntil!.day}/${_validUntil!.month}/${_validUntil!.year}',
                style: TextStyle(
                  color: _validUntil == null ? kSubtext : kText,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kSubtext, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kPrimaryBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Subtotal',
            style: TextStyle(
              color: kPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '₹${_subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: kPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: kPrimary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Create Quotation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step button (left = left-rounded, right = right-rounded border)
// ─────────────────────────────────────────────────────────────────────────────

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool left;

  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: double.infinity,
        decoration: BoxDecoration(
          color: onTap != null ? kPrimaryBg : kBorder.withOpacity(0.15),
          borderRadius: BorderRadius.horizontal(
            left: left ? const Radius.circular(9) : Radius.zero,
            right: left ? Radius.zero : const Radius.circular(9),
          ),
          border: Border(
            right: left ? const BorderSide(color: kBorder) : BorderSide.none,
            left: !left ? const BorderSide(color: kBorder) : BorderSide.none,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? kPrimary : kSubtext.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

class _LineItem {
  String name = '';
  double qty = 0;
  double rate = 0;
  double get total => qty * rate;
}
