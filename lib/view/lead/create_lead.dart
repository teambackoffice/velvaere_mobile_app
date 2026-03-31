import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:velvaere_app/theme/app_colors.dart';
import 'package:velvaere_app/controller/create_lead_controller.dart';

class CreateLeadPage extends StatefulWidget {
  const CreateLeadPage({super.key});

  @override
  State<CreateLeadPage> createState() => _CreateLeadPageState();
}

class _CreateLeadPageState extends State<CreateLeadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  String _source = 'Advertisement';

  static const _sources = [
    'Walk In',
    'Campaign',
    'Mass Mailing',
    'Supplier Reference',
    'Advertisement',
    'Exhibition',
    'Cold Calling',
    'Reference',
    'Existing Customer',
    'Customer\'s Vendor',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(CreateLeadController controller) async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    await controller.createLead(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      source: _source,
      note: _notesController.text.trim(),
    );

    if (!mounted) return;

    if (controller.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lead created successfully!'),
          backgroundColor: kSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Failed to create lead'),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateLeadController(),
      child: Consumer<CreateLeadController>(
        builder: (context, controller, _) {
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
                              _sectionLabel('Lead Information'),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _nameController,
                                label: 'Lead Name',
                                hint: 'e.g. John Doe',
                                icon: Icons.person_rounded,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),

                              const SizedBox(height: 24),

                              _sectionLabel('Contact Details'),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone',
                                hint: '+91 98765 43210',
                                icon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return null;
                                  if (v.trim().length < 7)
                                    return 'Invalid phone';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'john@company.com',
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return null;
                                  if (!v.contains('@')) return 'Invalid email';
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              _buildDropdown(
                                label: 'Source',
                                value: _source,
                                icon: Icons.track_changes_rounded,
                                items: _sources,
                                onChanged: (v) => setState(() => _source = v!),
                              ),

                              const SizedBox(height: 24),

                              _sectionLabel('Notes'),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _notesController,
                                label: 'Notes',
                                hint: 'Additional context, requirements...',
                                icon: Icons.notes_rounded,
                                maxLines: 4,
                              ),

                              const SizedBox(height: 32),
                              _buildSubmitButton(controller),
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
        },
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
              'Create Lead',
              style: TextStyle(
                color: kText,
                fontSize: 16,
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: const TextStyle(color: kText, fontSize: 14),
      dropdownColor: kCard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kSubtext, size: 18),
        labelStyle: const TextStyle(color: kSubtext, fontSize: 13),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
    );
  }

  Widget _buildSubmitButton(CreateLeadController controller) {
    final isLoading = controller.isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _submit(controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF426E4B),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF10B981).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Create Lead',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
