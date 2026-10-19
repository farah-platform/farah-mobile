import 'dart:convert';
import 'dart:io';

import 'package:farah/cubits/provider_services/provider_services_cubit.dart';
import 'package:farah/cubits/provider_services/provider_services_state.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// "إضافة خدمة جديدة" and, with [isPackage], "إضافة باقة جديدة".
/// Categories come from the API; services without booking periods are
/// booked for the whole day. Editing has its own screen.
class ProviderAddServiceScreen extends StatefulWidget {
  final bool isPackage;

  const ProviderAddServiceScreen({super.key, this.isPackage = false});

  @override
  State<ProviderAddServiceScreen> createState() =>
      _ProviderAddServiceScreenState();
}

class _FeatureRow {
  final controller = TextEditingController();
  bool removable = false;
}

class _ProviderAddServiceScreenState extends State<ProviderAddServiceScreen> {
  static const _maxImages = 5;
  static const _fieldBorder = Color(0xFFDADADA);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerController = TextEditingController();
  final _durationController = TextEditingController();
  final List<_FeatureRow> _features = [_FeatureRow()];
  final List<File> _images = [];

  List<dynamic> _categories = [];
  String? _categoryId;
  bool _savingDraft = false;

  bool get _package => widget.isPackage;

  // Labels that differ between a service and a package.
  String get _noun => _package ? 'الباقة' : 'الخدمة';

  @override
  void initState() {
    super.initState();
    context.read<ProviderServicesCubit>().loadFormData();
  }

  @override
  void dispose() {
    for (final c in [
      _titleController,
      _descriptionController,
      _priceController,
      _offerController,
      _durationController,
    ]) {
      c.dispose();
    }
    for (final f in _features) {
      f.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final left = _maxImages - _images.length;
    if (left <= 0) return;
    final picked = await ImagePicker().pickMultiImage(
      limit: left > 1 ? left : null,
    );
    if (picked.isEmpty) return;
    setState(() {
      _images.addAll(picked.take(left).map((x) => File(x.path)));
    });
  }

  void _submit({required bool draft}) {
    if (!_formKey.currentState!.validate()) return;
    if (!draft && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف صورة واحدة على الأقل قبل النشر')),
      );
      return;
    }

    final features = _features
        .where((f) => f.controller.text.trim().isNotEmpty)
        .toList();
    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'category_id': _categoryId,
      'description': _descriptionController.text.trim(),
      'price': _priceController.text.trim(),
      if (_offerController.text.trim().isNotEmpty)
        'offer_price': _offerController.text.trim(),
      'execution_duration': _durationController.text.trim(),
      'service_type': _package ? 'package' : 'service',
      'currency': 'ILS',
      if (_package)
        'package_items': jsonEncode([
          for (final (i, f) in features.indexed)
            {'title': f.controller.text.trim(), 'sort_order': i},
        ])
      else ...{
        'features': jsonEncode([
          for (final f in features) f.controller.text.trim(),
        ]),
        'removable_features': jsonEncode([
          for (final f in features.where((f) => f.removable))
            f.controller.text.trim(),
        ]),
      },
      'save_as_draft': draft ? '1' : '0',
    };

    setState(() => _savingDraft = draft);
    context.read<ProviderServicesCubit>().addService(data, _images);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(
        context,
        _package ? 'إضافةباقة جديدة' : 'إضافة خدمة جديدة',
      ),
      body: BlocConsumer<ProviderServicesCubit, ProviderServicesState>(
        listener: (context, state) {
          if (state is ProviderServicesFormReady) {
            setState(() => _categories = state.categories);
          } else if (state is ProviderServicesAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _savingDraft ? 'تم حفظ $_noun كمسودة' : 'تم نشر $_noun',
                ),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ProviderServicesAddError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProviderServicesLoading && _categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProviderServicesError && _categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () =>
                        context.read<ProviderServicesCubit>().loadFormData(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          final saving = state is ProviderServicesAdding;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 4, 28, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _card(children: _imagesSection(primary)),
                  const SizedBox(height: 16),
                  _card(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                    children: [
                      _label('اسم $_noun'),
                      TextFormField(
                        controller: _titleController,
                        decoration: _input(
                          _package ? 'مثال:باقة عروس' : 'مثال:مسكة عروس',
                        ),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'أدخل اسم $_noun' : null,
                      ),
                      _label('فئة $_noun'),
                      DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: primary),
                        decoration: _input(
                          _package
                              ? 'اختر الفئات التي تندرج تحت الباقة'
                              : 'اختر الفئة',
                        ),
                        items: [
                          for (final c in _categories)
                            DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['name']?.toString() ?? ''),
                            ),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                        validator: (v) => v == null ? 'اختر فئة $_noun' : null,
                      ),
                      _label(_package ? 'محتويات الباقة' : 'مميزات  الخدمة'),
                      for (final feature in _features)
                        _featureField(feature, primary),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _features.add(_FeatureRow())),
                          icon: Icon(Icons.add_circle_outline, color: primary),
                          label: Text(
                            _package ? 'إضافة عنصر جديد' : 'إضافة ميزة جديدة',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      _label('تفاصيل $_noun'),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: _input('اكتب وصف مختصر عن الخدمة'),
                      ),
                      _label('السعر'),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [_decimal],
                        decoration: _input('ادخل السعر بالشيكل فقط'),
                        validator: (v) {
                          final price = double.tryParse((v ?? '').trim());
                          return price == null || price <= 0
                              ? 'أدخل سعر الخدمة'
                              : null;
                        },
                      ),
                      _label('سعر العرض', optional: true),
                      TextFormField(
                        controller: _offerController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [_decimal],
                        decoration: _input('ادخل سعر العرض بالشيكل فقط'),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return null;
                          final offer = double.tryParse(v!.trim());
                          final price = double.tryParse(
                            _priceController.text.trim(),
                          );
                          if (offer == null || offer <= 0) {
                            return 'أدخل سعر عرض صحيح';
                          }
                          return price != null && offer >= price
                              ? 'سعر العرض يجب أن يكون أقل من السعر'
                              : null;
                        },
                      ),
                      _label('مدة التسليم', optional: true),
                      TextFormField(
                        controller: _durationController,
                        decoration: _input('مثال:خلال 24 ساعة'),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F2F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'التنسيق حول الاستلام يتم مباشرة بينك وبين العميل',
                                style: TextStyle(color: primary, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ProviderPrimaryButton(
                    label: 'نشر الان',
                    loading: saving && !_savingDraft,
                    onPressed: saving ? null : () => _submit(draft: false),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: saving ? null : () => _submit(draft: true),
                    child: saving && _savingDraft
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'حفظ كمسودة',
                            style: TextStyle(color: Colors.black87),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static final _decimal = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d{0,2}'),
  );

  List<Widget> _imagesSection(Color primary) {
    return [
      const Text(
        'رفع الصور',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      const SizedBox(height: 14),
      InkWell(
        onTap: _pickImages,
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: DashedBorderPainter(color: primary.withValues(alpha: 0.7)),
          child: SizedBox(
            height: 110,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, color: primary),
                const SizedBox(height: 8),
                Text(
                  'اضف صور $_noun',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'يمكنك اضافة حتى 5صور',
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          _thumbBox(
            onTap: _images.length < _maxImages ? _pickImages : null,
            border: const Color(0xFFDADADA),
            child: Icon(Icons.add, color: primary),
          ),
          for (var i = 0; i < _images.length; i++)
            _thumbBox(
              child: _removable(
                Image.file(_images[i], fit: BoxFit.cover),
                () => setState(() => _images.removeAt(i)),
              ),
            ),
          for (var i = _images.length; i < _maxImages - 1; i++)
            _thumbBox(
              fill: const Color(0xFFF5F5F5),
              child: const Icon(
                Icons.image_outlined,
                color: Colors.black26,
                size: 20,
              ),
            ),
        ],
      ),
    ];
  }

  Widget _removable(Widget image, VoidCallback onRemove) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: image),
        PositionedDirectional(
          top: 2,
          end: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 9,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _thumbBox({
    required Widget child,
    VoidCallback? onTap,
    Color? border,
    Color? fill,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fill ?? Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: border != null ? Border.all(color: border) : null,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _featureField(_FeatureRow feature, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: feature.controller,
        // Package contents are plain items; service features get a type menu.
        decoration: _package
            ? _input('اضف عنصر')
            : _input('اضف ميزة').copyWith(
                suffixIcon: PopupMenuButton<bool>(
                  tooltip: 'نوع الميزة',
                  initialValue: feature.removable,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (v) => setState(() => feature.removable = v),
                  itemBuilder: (_) => [
                    _typeItem(false, 'مشمولة', feature.removable == false),
                    _typeItem(true, 'قابلة للازالة', feature.removable == true),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          feature.removable ? 'قابلة للازالة' : 'مشمولة',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  PopupMenuItem<bool> _typeItem(bool value, String label, bool selected) {
    return PopupMenuItem(
      value: value,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5E4E6) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _card({
    required List<Widget> children,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _label(String text, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
          children: [
            if (optional)
              const TextSpan(
                text: '(اختياري)',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.black45,
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(_fieldBorder),
      border: border(_fieldBorder),
      focusedBorder: border(Theme.of(context).colorScheme.primary),
    );
  }
}
