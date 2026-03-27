import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velvaere_app/controller/get_customer_list_controller.dart';
import 'package:velvaere_app/controller/get_items_controller.dart';
import 'package:velvaere_app/modal/get_customer_modal.dart';
import 'package:velvaere_app/theme/app_colors.dart';
import '../../modal/get_items_modal.dart';

class CreateQuotationPage extends StatefulWidget {
  const CreateQuotationPage({super.key});

  @override
  State<CreateQuotationPage> createState() => _CreateQuotationPageState();
}

class _CreateQuotationPageState extends State<CreateQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _validUntil;
  bool _submitting = false;

  late final GetItemsController _itemsController;
  late final GetCustomerController _customerController;

  CustomerMessage? _selectedCustomer;
  final List<_LineItem> _items = [_LineItem()];

  @override
  void initState() {
    super.initState();
    _itemsController = GetItemsController();
    _itemsController.getItems();
    _customerController = GetCustomerController();
    _customerController.getCustomers();
  }

  @override
  void dispose() {
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
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a customer'),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _submitting = true);

    // TODO: pass _selectedCustomer!.name as the customer field in your API call
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

  Future<void> _pickItem(int index) async {
    final catalogItems = _itemsController.items;
    if (catalogItems.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ItemPickerSheet(
        catalogItems: catalogItems,
        onSelected: (msg) {
          setState(() {
            _items[index].name = msg.itemName;
            _items[index].itemCode = msg.itemCode;
            _items[index].uom = msg.uom;
            _items[index].rate = msg.priceListRate.toDouble();
            if (_items[index].qty == 0) _items[index].qty = 1;
          });
        },
      ),
    );
  }

  Future<void> _pickCustomer() async {
    final customers = _customerController.customerList;
    if (customers.isEmpty) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CustomerPickerSheet(
        customers: customers,
        onSelected: (customer) => setState(() => _selectedCustomer = customer),
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
                        _buildCustomerField(), // ← replaced
                        const SizedBox(height: 12),
                        _buildDateField(),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            _sectionLabel('Items'),
                            const Spacer(),
                            AnimatedBuilder(
                              animation: _itemsController,
                              builder: (_, __) => _itemsController.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: kPrimary,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
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

  // ── NEW: Customer picker field ─────────────────────────────────────────────

  Widget _buildCustomerField() {
    return AnimatedBuilder(
      animation: _customerController,
      builder: (_, __) {
        final isLoading = _customerController.isLoading;
        final hasCustomer = _selectedCustomer != null;

        return GestureDetector(
          onTap: isLoading ? null : _pickCustomer,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasCustomer ? kPrimary.withOpacity(0.4) : kBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.business_rounded,
                  color: hasCustomer ? kPrimary : kSubtext,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isLoading
                      ? const Text(
                          'Loading customers...',
                          style: TextStyle(color: kSubtext, fontSize: 14),
                        )
                      : hasCustomer
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCustomer!.customerName,
                              style: const TextStyle(
                                color: kText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedCustomer!.name +
                                  (_selectedCustomer!.mobileNo != null
                                      ? '  ·  ${_selectedCustomer!.mobileNo}'
                                      : ''),
                              style: const TextStyle(
                                color: kSubtext,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Select customer',
                          style: TextStyle(color: kSubtext, fontSize: 14),
                        ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPrimary,
                    ),
                  )
                else
                  const Icon(
                    Icons.unfold_more_rounded,
                    color: kSubtext,
                    size: 18,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Unchanged helpers ──────────────────────────────────────────────────────

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: kPrimaryBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickItem(index),
                  child: AnimatedBuilder(
                    animation: _itemsController,
                    builder: (_, __) {
                      final hasItem = item.name.isNotEmpty;
                      final isLoading = _itemsController.isLoading;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasItem
                                ? kPrimary.withOpacity(0.4)
                                : kBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: hasItem ? kPrimary : kSubtext,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: isLoading
                                  ? const Text(
                                      'Loading items...',
                                      style: TextStyle(
                                        color: kSubtext,
                                        fontSize: 13,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hasItem ? item.name : 'Select item',
                                          style: TextStyle(
                                            color: hasItem ? kText : kSubtext,
                                            fontSize: 13,
                                            fontWeight: hasItem
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (hasItem && item.uom.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.itemCode}  ·  ${item.uom}',
                                            style: const TextStyle(
                                              color: kSubtext,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                            ),
                            const Icon(
                              Icons.unfold_more_rounded,
                              color: kSubtext,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
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
                            key: ValueKey('rate_${index}_${item.rate}'),
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
// Customer Picker Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerPickerSheet extends StatefulWidget {
  final List<CustomerMessage> customers;
  final ValueChanged<CustomerMessage> onSelected;

  const _CustomerPickerSheet({
    required this.customers,
    required this.onSelected,
  });

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerMessage> get _filtered => _query.isEmpty
      ? widget.customers
      : widget.customers.where((c) {
          final q = _query.toLowerCase();
          return c.customerName.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q) ||
              (c.mobileNo?.toLowerCase().contains(q) ?? false) ||
              (c.customerGroup?.toLowerCase().contains(q) ?? false);
        }).toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.42,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _CustomerSheetHeader(
              query: _query,
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              resultCount: _filtered.length,
              totalCount: widget.customers.length,
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? _CustomerEmptyState(hasQuery: _query.isNotEmpty)
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 6, bottom: 24),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        return _CustomerTile(
                          customer: c,
                          onTap: () {
                            widget.onSelected(c);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerSheetHeader extends StatelessWidget {
  final String query;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int resultCount;
  final int totalCount;

  const _CustomerSheetHeader({
    required this.query,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.resultCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14),
              child: Container(
                width: 32,
                height: 3.5,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Select Customer',
                  style: TextStyle(
                    color: kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    query.isEmpty
                        ? '$totalCount customers'
                        : '$resultCount of $totalCount',
                    key: ValueKey('$resultCount/$totalCount'),
                    style: const TextStyle(
                      color: kSubtext,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: kText, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Search name, code, group…',
                hintStyle: const TextStyle(color: kSubtext, fontSize: 13.5),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.search_rounded, color: kSubtext, size: 18),
                ),
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: query.isNotEmpty
                    ? GestureDetector(
                        onTap: onClear,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.cancel_rounded,
                            color: kSubtext,
                            size: 17,
                          ),
                        ),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(),
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
                  horizontal: 12,
                  vertical: 11,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: kBorder),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final CustomerMessage customer;
  final VoidCallback onTap;

  const _CustomerTile({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: kPrimary.withOpacity(0.06),
        highlightColor: kPrimary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder),
                ),
                child: Center(
                  child: Text(
                    customer.customerName.isNotEmpty
                        ? customer.customerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: kSubtext,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
                      customer.customerName,
                      style: const TextStyle(
                        color: kText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _MetaChip(label: customer.name),
                        if (customer.customerGroup != null) ...[
                          const SizedBox(width: 5),
                          _MetaDot(),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              customer.customerGroup!,
                              style: const TextStyle(
                                color: kSubtext,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (customer.mobileNo != null) ...[
                const SizedBox(width: 10),
                Text(
                  customer.mobileNo!,
                  style: const TextStyle(color: kSubtext, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerEmptyState extends StatelessWidget {
  final bool hasQuery;
  const _CustomerEmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.business_outlined,
            size: 36,
            color: kSubtext.withOpacity(0.4),
          ),
          const SizedBox(height: 10),
          Text(
            hasQuery
                ? 'No customers match your search'
                : 'No customers available',
            style: TextStyle(
              color: kSubtext.withOpacity(0.7),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasQuery) ...[
            const SizedBox(height: 4),
            Text(
              'Try a different name, code, or group',
              style: TextStyle(color: kSubtext.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item Picker (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _ItemPickerSheet extends StatefulWidget {
  final List<Message> catalogItems;
  final ValueChanged<Message> onSelected;

  const _ItemPickerSheet({
    required this.catalogItems,
    required this.onSelected,
  });

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Message> get _filtered => _query.isEmpty
      ? widget.catalogItems
      : widget.catalogItems.where((m) {
          final q = _query.toLowerCase();
          return m.itemName.toLowerCase().contains(q) ||
              m.itemCode.toLowerCase().contains(q) ||
              m.itemGroup.toLowerCase().contains(q);
        }).toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.42,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _SheetHeader(
              query: _query,
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              resultCount: _filtered.length,
              totalCount: widget.catalogItems.length,
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? _EmptyState(hasQuery: _query.isNotEmpty)
                  : _ItemList(
                      items: _filtered,
                      scrollController: scrollController,
                      onSelected: (msg) {
                        widget.onSelected(msg);
                        Navigator.pop(context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String query;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int resultCount;
  final int totalCount;

  const _SheetHeader({
    required this.query,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.resultCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 14),
              child: Container(
                width: 32,
                height: 3.5,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Select Item',
                  style: TextStyle(
                    color: kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    query.isEmpty
                        ? '$totalCount items'
                        : '$resultCount of $totalCount',
                    key: ValueKey('$resultCount/$totalCount'),
                    style: const TextStyle(
                      color: kSubtext,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: kText, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Search name, code, group…',
                hintStyle: const TextStyle(color: kSubtext, fontSize: 13.5),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.search_rounded, color: kSubtext, size: 18),
                ),
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: query.isNotEmpty
                    ? GestureDetector(
                        onTap: onClear,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.cancel_rounded,
                            color: kSubtext,
                            size: 17,
                          ),
                        ),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(),
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
                  horizontal: 12,
                  vertical: 11,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: kBorder),
        ],
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final List<Message> items;
  final ScrollController scrollController;
  final ValueChanged<Message> onSelected;

  const _ItemList({
    required this.items,
    required this.scrollController,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final msg = items[i];
        return _ItemTile(item: msg, onTap: () => onSelected(msg));
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Message item;
  final VoidCallback onTap;

  const _ItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: kPrimary.withOpacity(0.06),
        highlightColor: kPrimary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder),
                ),
                child: Center(
                  child: Text(
                    item.itemName.isNotEmpty
                        ? item.itemName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: kSubtext,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
                        color: kText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _MetaChip(label: item.itemCode),
                        const SizedBox(width: 5),
                        _MetaDot(),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            item.itemGroup,
                            style: const TextStyle(
                              color: kSubtext,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.priceListRate}',
                    style: const TextStyle(
                      color: kPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.uom,
                    style: const TextStyle(color: kSubtext, fontSize: 10.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared supporting widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: kBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kSubtext,
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _MetaDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 3,
    height: 3,
    decoration: BoxDecoration(color: kBorder, shape: BoxShape.circle),
  );
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.inventory_2_outlined,
            size: 36,
            color: kSubtext.withOpacity(0.4),
          ),
          const SizedBox(height: 10),
          Text(
            hasQuery ? 'No items match your search' : 'No items available',
            style: TextStyle(
              color: kSubtext.withOpacity(0.7),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasQuery) ...[
            const SizedBox(height: 4),
            Text(
              'Try a different name, code, or group',
              style: TextStyle(color: kSubtext.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

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

class _LineItem {
  String name = '';
  String itemCode = '';
  String uom = '';
  double qty = 0;
  double rate = 0;
  double get total => qty * rate;
}
