import 'dart:convert';
import 'dart:io';

import 'package:farah/cubits/provider_service_editor/provider_service_editor_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// "تعديل الخدمة" / "تعديل الباقة" for a service from GET /provider/services.
///
/// Halls (category `wedding-halls`, or any service with booking periods) also
/// edit their amenities, available dates and periods.
class ProviderEditServiceScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ProviderEditServiceScreen({super.key, required this.service});

  @override
  State<ProviderEditServiceScreen> createState() =>
      _ProviderEditServiceScreenState();
}

class _Entry {
  String name;
  bool removable;
  _Entry(this.name, this.removable);
}

class _ProviderEditServiceScreenState extends State<ProviderEditServiceScreen> {
  static const _maxImages = 5;
  static const _fieldFill = Color(0xFFFDF8F9);
  static const _cardBorder = Color(0xFFE3DADD);
  static const _durations = [
    'خلال يومين من الطلب',
    'خلال 3أيام من الطلب',
    'خلال أسبوع من الطلب',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _offerController = TextEditingController();
  final _imagesScroll = ScrollController();

  final List<Map<String, dynamic>> _existingImages = [];
  final List<int> _removedImageIds = [];
  final List<File> _newImages = [];
  final List<_Entry> _entries = [];
  final List<Map<String, dynamic>> _periods = [];
  String _duration = '';
  bool _published = false;

  // Calendar: what the server has, plus the provider's unsaved changes.
  late DateTime _month;
  Set<String> _serverBlocked = {};
  Set<String> _reserved = {};
  final Set<String> _toBlock = {};
  final Set<String> _toUnblock = {};
  bool _loadingDates = false;

  Map<String, dynamic> get _service => widget.service;
  int get _id => int.parse(_service['id'].toString());
  bool get _isPackage => _service['type'] == 'package';
  bool get _isHall =>
      (_service['category'] as Map?)?['slug'] == 'wedding-halls';
  bool get _isVenue =>
      !_isPackage &&
      (_isHall ||
          ((_service['booking_periods'] as List?)?.isNotEmpty ?? false));
  bool get _showOffer =>
      _isVenue || (_service['pricing'] as Map?)?['original_price'] != null;
  String get _noun => _isPackage ? 'الباقة' : 'الخدمة';

  @override
  void initState() {
    super.initState();
    String text(dynamic v) => v == null ? '' : v.toString();
    String amount(dynamic v) {
      final n = num.tryParse(text(v));
      if (n == null) return '';
      return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
    }

    final pricing = (_service['pricing'] as Map?) ?? const {};
    final original = pricing['original_price'];
    _titleController.text = text(_service['title']);
    _descriptionController.text = text(_service['description']);
    _priceController.text = amount(original ?? pricing['price']);
    _offerController.text = original != null ? amount(pricing['price']) : '';
    _duration = text(_service['execution_duration']);
    _published = _service['is_published'] == true;
    _existingImages.addAll(
      ((_service['images'] as List?) ?? const []).whereType<Map>().map(
        (i) => Map<String, dynamic>.from(i),
      ),
    );
    if (_isPackage) {
      for (final item in (_service['package_items'] as List?) ?? const []) {
        if (item is Map) {
          _entries.add(_Entry(text(item['title']), item['removable'] == true));
        }
      }
    } else {
      for (final f in (_service['feature_items'] as List?) ?? const []) {
        if (f is Map) {
          _entries.add(_Entry(text(f['name']), f['removable'] == true));
        }
      }
    }
    for (final p in (_service['booking_periods'] as List?) ?? const []) {
      if (p is Map) _periods.add(Map<String, dynamic>.from(p));
    }

    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    if (_isVenue) _loadMonth();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _offerController.dispose();
    _imagesScroll.dispose();
    super.dispose();
  }

  String _monthKey(DateTime m) =>
      '${m.year}-${m.month.toString().padLeft(2, '0')}';

  String _dateKey(DateTime d) =>
      '${_monthKey(d)}-${d.day.toString().padLeft(2, '0')}';

  void _loadMonth() {
    setState(() => _loadingDates = true);
    context.read<ProviderServiceEditorCubit>().loadAvailability(
      _id,
      _monthKey(_month),
    );
  }

  bool _isBlocked(String date) =>
      (_serverBlocked.contains(date) || _toBlock.contains(date)) &&
      !_toUnblock.contains(date);

  void _toggleDate(String date) {
    setState(() {
      if (_isBlocked(date)) {
        if (!_toBlock.remove(date)) _toUnblock.add(date);
      } else {
        if (!_toUnblock.remove(date)) _toBlock.add(date);
      }
    });
  }

  Future<void> _pickImages() async {
    final left = _maxImages - _existingImages.length - _newImages.length;
    if (left <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يمكنك اضافة حتى 5صور')));
      return;
    }
    final picked = await ImagePicker().pickMultiImage(
      limit: left > 1 ? left : null,
    );
    if (picked.isEmpty) return;
    setState(
      () => _newImages.addAll(picked.take(left).map((x) => File(x.path))),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_existingImages.isEmpty && _newImages.isEmpty && _published) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف صورة واحدة على الأقل قبل النشر')),
      );
      return;
    }

    final entries = _entries.where((e) => e.name.trim().isNotEmpty).toList();
    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category_id': (_service['category'] as Map?)?['id']?.toString(),
      'service_type': _isPackage ? 'package' : 'service',
      'price': _priceController.text.trim(),
      if (_showOffer) 'offer_price': _offerController.text.trim(),
      'execution_duration': _duration,
      'is_available': _published ? '1' : '0',
      if (_isPackage)
        'package_items': jsonEncode([
          for (final (i, e) in entries.indexed)
            {'title': e.name.trim(), 'removable': e.removable, 'sort_order': i},
        ])
      else ...{
        'features': jsonEncode([for (final e in entries) e.name.trim()]),
        'removable_features': jsonEncode([
          for (final e in entries.where((e) => e.removable)) e.name.trim(),
        ]),
      },
      if (_isVenue) 'booking_slots': jsonEncode(_periods),
      if (_removedImageIds.isNotEmpty)
        'remove_image_ids': jsonEncode(_removedImageIds),
    };

    context.read<ProviderServiceEditorCubit>().save(
      serviceId: _id,
      data: data,
      newImages: _newImages,
      blockDates: _toBlock.toList(),
      unblockDates: _toUnblock.toList(),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => _DeleteDialog(noun: _noun),
    );
    if (confirmed == true && mounted) {
      context.read<ProviderServiceEditorCubit>().delete(_id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(
        context,
        'تعديل $_noun',
        actions: [
          IconButton(
            tooltip: 'حذف $_noun',
            onPressed: _confirmDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFF2B8BF),
              size: 30,
            ),
          ),
        ],
      ),
      body:
          BlocConsumer<ProviderServiceEditorCubit, ProviderServiceEditorState>(
            listener: (context, state) {
              if (state is ProviderServiceEditorAvailability) {
                setState(() {
                  _loadingDates = false;
                  _serverBlocked = state.blocked;
                  _reserved = state.reserved;
                });
              } else if (state is ProviderServiceEditorSaved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ التعديلات')),
                );
                Navigator.pop(context, true);
              } else if (state is ProviderServiceEditorDeleted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('تم حذف $_noun')));
                Navigator.pop(context, true);
              } else if (state is ProviderServiceEditorError) {
                setState(() => _loadingDates = false);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              final saving = state is ProviderServiceEditorSaving;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _imagesCard(primary),
                      _textCard(
                        _isHall ? 'اسم الصالة' : 'اسم $_noun',
                        _titleController,
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'أدخل اسم $_noun' : null,
                      ),
                      _textCard(
                        _isPackage ? 'وصف الباقة' : 'نبذة عن الخدمة',
                        _descriptionController,
                        multiline: true,
                      ),
                      if (_isPackage) ...[
                        _priceCard(primary),
                        _entriesCard(primary),
                        _card(
                          title: 'مدة التسليم',
                          child: _durationField(primary),
                        ),
                        _note(primary),
                      ] else if (_showOffer) ...[
                        _priceCard(primary),
                        if (!_isVenue)
                          _card(
                            title: 'مدة التسليم',
                            child: _durationField(primary),
                          ),
                        if (_isVenue || _entries.isNotEmpty)
                          _entriesCard(primary),
                        if (_isVenue) ...[
                          _datesCard(primary),
                          _periodsCard(primary),
                        ],
                        if (!_isVenue) _note(primary),
                      ] else ...[
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _card(
                                  title: 'مدة التسليم',
                                  child: _durationField(primary),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _card(
                                  title: 'السعر',
                                  child: _amountField(
                                    _priceController,
                                    suffix: 'ILS',
                                    required: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_entries.isNotEmpty) _entriesCard(primary),
                        _note(primary),
                      ],
                      _publishCard(primary),
                      const SizedBox(height: 28),
                      ProviderPrimaryButton(
                        label: 'حفظ التعديلات',
                        loading: saving,
                        onPressed: saving ? null : _save,
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: saving
                            ? null
                            : () => Navigator.maybePop(context),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
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

  // ---- Cards ---------------------------------------------------------------

  Widget _card({String? title, Widget? trailing, required Widget child}) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: primary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }

  Widget _imagesCard(Color primary) {
    final images = <Widget>[
      for (final image in _existingImages)
        _imageTile(
          Image.network(
            image['url']?.toString() ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
          ),
          () => setState(() {
            _existingImages.remove(image);
            final id = int.tryParse(image['id'].toString());
            if (id != null) _removedImageIds.add(id);
          }),
        ),
      for (var i = 0; i < _newImages.length; i++)
        _imageTile(
          Image.file(_newImages[i], fit: BoxFit.cover),
          () => setState(() => _newImages.removeAt(i)),
        ),
      if (_existingImages.length + _newImages.length < _maxImages)
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: DashedBorderPainter(color: primary.withValues(alpha: 0.6)),
            child: SizedBox(
              width: 120,
              child: Icon(Icons.add_photo_alternate_outlined, color: primary),
            ),
          ),
        ),
    ];

    void scrollBy(double delta) {
      if (!_imagesScroll.hasClients) return;
      _imagesScroll.animateTo(
        (_imagesScroll.offset + delta).clamp(
          0,
          _imagesScroll.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    return _card(
      title: _isHall ? 'صور الصالة' : 'صور $_noun',
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: ListView.separated(
              controller: _imagesScroll,
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => images[i],
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'السابق',
                onPressed: () => scrollBy(-128),
                icon: const Icon(
                  Icons.arrow_right,
                  color: Colors.black38,
                  size: 32,
                ),
              ),
              Expanded(
                child: Container(
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'التالي',
                onPressed: () => scrollBy(128),
                icon: const Icon(
                  Icons.arrow_left,
                  color: Colors.black38,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageTile(Widget image, VoidCallback onRemove) {
    return SizedBox(
      width: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
          PositionedDirectional(
            top: 6,
            end: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white70,
                child: Icon(Icons.close, size: 14, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textCard(
    String title,
    TextEditingController controller, {
    bool multiline = false,
    String? Function(String?)? validator,
  }) {
    return _card(
      title: title,
      trailing: const Icon(
        Icons.edit_outlined,
        size: 16,
        color: Colors.black45,
      ),
      child: TextFormField(
        controller: controller,
        minLines: multiline ? 3 : 1,
        maxLines: multiline ? 6 : 1,
        validator: validator,
        style: const TextStyle(
          fontSize: 14,
          height: 1.7,
          color: Colors.black87,
        ),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _amountField(
    TextEditingController controller, {
    required String suffix,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: c),
    );
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator:
          validator ??
          (v) {
            if (!required) return null;
            final n = double.tryParse((v ?? '').trim());
            return n == null || n <= 0 ? 'أدخل السعر' : null;
          },
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldFill,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            suffix,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: suffix == 'ILS' ? 11 : 15,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        enabledBorder: border(const Color(0xFFF1E7EA)),
        border: border(const Color(0xFFF1E7EA)),
        focusedBorder: border(primary),
      ),
    );
  }

  Widget _priceCard(Color primary) {
    final subtitle = TextStyle(
      color: primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    if (!_showOffer) {
      return _card(
        title: 'السعر الاجمالي',
        child: _amountField(_priceController, suffix: 'شيكل', required: true),
      );
    }
    return _card(
      title: 'السعر',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isPackage ? 'السعر الاجمالي' : 'السعر الاساسي',
            style: subtitle,
          ),
          const SizedBox(height: 10),
          _amountField(_priceController, suffix: 'شيكل', required: true),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              text: 'سعر العرض ',
              style: subtitle,
              children: const [
                TextSpan(
                  text: '(اختياري)',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _amountField(
            _offerController,
            suffix: 'شيكل',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return null;
              final offer = double.tryParse(v!.trim());
              final price = double.tryParse(_priceController.text.trim());
              if (offer == null || offer <= 0) return 'أدخل سعر عرض صحيح';
              return price != null && offer >= price
                  ? 'سعر العرض يجب أن يكون أقل من السعر'
                  : null;
            },
          ),
        ],
      ),
    );
  }

  Widget _durationField(Color primary) {
    final options = [
      ..._durations,
      if (_duration.isNotEmpty && !_durations.contains(_duration)) _duration,
    ];
    return PopupMenuButton<String>(
      tooltip: 'مدة التسليم',
      initialValue: _duration.isEmpty ? null : _duration,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) => setState(() => _duration = v),
      itemBuilder: (_) => [
        for (final option in options)
          PopupMenuItem(
            value: option,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: option == _duration ? const Color(0xFFF3DFE2) : null,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(option, style: const TextStyle(fontSize: 14)),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF1E7EA)),
        ),
        child: Text(
          _duration.isEmpty ? 'اختر مدة التسليم' : _duration,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: _duration.isEmpty ? Colors.black38 : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _note(Color primary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EEF0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primary, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'التنسيق حول الاستلام يتم مباشرة بينك وبين العميل',
              style: TextStyle(fontSize: 10, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entriesCard(Color primary) {
    return _card(
      title: _isPackage ? 'محتويات الباقة' : 'تفاصيل الخدمة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in _entries)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1E7EA)),
              ),
              child: Row(
                children: [
                  Icon(amenityIcon(entry.name), color: primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_isPackage)
                    Tooltip(
                      message: entry.removable ? 'قابل للإزالة' : 'مشمول',
                      child: Switch(
                        value: !entry.removable,
                        activeTrackColor: const Color(0xFF4A0019),
                        activeThumbColor: Colors.white,
                        onChanged: (v) => setState(() => entry.removable = !v),
                      ),
                    ),
                  PopupMenuButton<String>(
                    tooltip: 'خيارات',
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: const Icon(Icons.more_vert, color: Colors.black87),
                    onSelected: (action) async {
                      if (action == 'delete') {
                        setState(() => _entries.remove(entry));
                        return;
                      }
                      final name = await _askName(entry.name);
                      if (name != null) setState(() => entry.name = name);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 6),
                            Text('تعديل المرفق'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Color(0xFFD9534F),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'حذف المرفق',
                              style: TextStyle(color: Color(0xFFD9534F)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () async {
                final name = await _askName('');
                if (name != null) {
                  setState(() => _entries.add(_Entry(name, false)));
                }
              },
              icon: Icon(Icons.add_circle_outline, color: primary),
              label: const Text(
                'إضافة مرفق',
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _askName(String initial) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(initial.isEmpty ? 'إضافة مرفق' : 'تعديل المرفق'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'اسم المرفق'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              Navigator.pop(dialog, name.isEmpty ? null : name);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget _datesCard(Color primary) {
    const weekdays = [
      'جمعة',
      'سبت',
      'أحد',
      'اثنين',
      'ثلاثاء',
      'اربعاء',
      'خميس',
    ];
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // The design's weeks start on Friday.
    final offset =
        (DateTime(_month.year, _month.month).weekday - DateTime.friday + 7) % 7;
    final canGoBack = _month.isAfter(DateTime(today.year, today.month));

    return _card(
      title: 'المواعيد المتاحة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر اكثر من موعد متاح للحجز',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1E7EA)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'الشهر السابق',
                      onPressed: canGoBack
                          ? () {
                              _month = DateTime(_month.year, _month.month - 1);
                              _loadMonth();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                    Expanded(
                      child: Text(
                        '${_monthNames[_month.month - 1]} ${_month.year}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      tooltip: 'الشهر التالي',
                      onPressed: () {
                        _month = DateTime(_month.year, _month.month + 1);
                        _loadMonth();
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ],
                ),
                const Divider(height: 8),
                Row(
                  children: [
                    for (final d in weekdays)
                      Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_loadingDates)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  )
                else
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 4,
                    children: [
                      for (var i = 0; i < offset; i++) const SizedBox(),
                      for (var day = 1; day <= daysInMonth; day++)
                        _dayCell(
                          DateTime(_month.year, _month.month, day),
                          todayStart,
                          primary,
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

  Widget _dayCell(DateTime date, DateTime today, Color primary) {
    final key = _dateKey(date);
    final past = date.isBefore(today);
    final reserved = _reserved.contains(key);
    final available = !past && !_isBlocked(key);
    return Tooltip(
      message: reserved ? 'محجوز' : (available ? 'متاح' : 'غير متاح'),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: past || reserved ? null : () => _toggleDate(key),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: available ? primary : const Color(0xFFF2F2F2),
            border: reserved
                ? Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  )
                : null,
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 11,
              color: available
                  ? Colors.white
                  : (past ? Colors.black26 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _periodsCard(Color primary) {
    return _card(
      title: 'الفترات المتاحة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, period) in _periods.indexed)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              decoration: BoxDecoration(
                color: _fieldFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1E7EA)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period['label']?.toString() ?? '',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${_time12(period['start_time'])} _ ${_time12(period['end_time'])}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'تعديل الفترة',
                    onPressed: () => _editPeriod(i),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _editPeriod(null),
              icon: Icon(Icons.add_circle_outline, color: primary),
              label: const Text(
                'إضافة فترة',
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _time12(dynamic hhmm) {
    final parts = (hhmm?.toString() ?? '').split(':');
    if (parts.length < 2) return '';
    final h = int.tryParse(parts[0]) ?? 0;
    final suffix = h < 12 ? 'ص' : 'م';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${parts[1]}$suffix';
  }

  Future<void> _editPeriod(int? index) async {
    final current = index == null ? null : _periods[index];
    final label = TextEditingController(
      text: current?['label']?.toString() ?? '',
    );
    TimeOfDay parse(dynamic v, TimeOfDay fallback) {
      final p = (v?.toString() ?? '').split(':');
      return p.length < 2
          ? fallback
          : TimeOfDay(
              hour: int.tryParse(p[0]) ?? 0,
              minute: int.tryParse(p[1]) ?? 0,
            );
    }

    var start = parse(
      current?['start_time'],
      const TimeOfDay(hour: 17, minute: 0),
    );
    var end = parse(current?['end_time'], const TimeOfDay(hour: 22, minute: 0));
    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(sheet).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                index == null ? 'إضافة فترة' : 'تعديل الفترة',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: label,
                decoration: const InputDecoration(
                  hintText: 'اسم الفترة، مثال: الفترة المسائية',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: sheet,
                          initialTime: start,
                        );
                        if (t != null) setSheet(() => start = t);
                      },
                      child: Text('من ${_time12(fmt(start))}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: sheet,
                          initialTime: end,
                        );
                        if (t != null) setSheet(() => end = t);
                      },
                      child: Text('إلى ${_time12(fmt(end))}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ProviderPrimaryButton(
                label: 'حفظ الفترة',
                onPressed: () => Navigator.pop(
                  sheet,
                  label.text.trim().isEmpty ? null : 'save',
                ),
              ),
              if (index != null)
                TextButton(
                  onPressed: () => Navigator.pop(sheet, 'delete'),
                  child: const Text(
                    'حذف الفترة',
                    style: TextStyle(color: Color(0xFFD9534F)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      if (result == 'delete') {
        _periods.removeAt(index!);
        return;
      }
      final period = {
        ...?current,
        'label': label.text.trim(),
        'start_time': fmt(start),
        'end_time': fmt(end),
      };
      if (index == null) {
        _periods.add(period);
      } else {
        _periods[index] = period;
      }
    });
  }

  Widget _publishCard(Color primary) {
    return _card(
      title: 'حالة النشر',
      child: Row(
        children: [
          Expanded(
            child: Text(
              _published
                  ? 'الخدمة ظاهرة للعملاء ويمكن حجزها'
                  : 'الخدمة مخفية عن العملاء',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
          Switch(
            value: _published,
            activeTrackColor: const Color(0xFF4A0019),
            activeThumbColor: Colors.white,
            onChanged: (v) => setState(() => _published = v),
          ),
        ],
      ),
    );
  }

  static const _monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
}

/// Icon for an amenity or package item, picked from its name.
IconData amenityIcon(String name) {
  const icons = <String, IconData>{
    'كرسي': Icons.event_seat_outlined,
    'كراسي': Icons.event_seat_outlined,
    'اضاءة': Icons.lightbulb_outline,
    'إضاءة': Icons.lightbulb_outline,
    'انترنت': Icons.wifi,
    'واي فاي': Icons.wifi,
    'كوشة': Icons.weekend_outlined,
    'ستاند': Icons.weekend_outlined,
    'تكييف': Icons.ac_unit,
    'مروحة': Icons.ac_unit,
    'شاشة': Icons.tv_outlined,
    'دي جي': Icons.music_note_outlined,
    'صوت': Icons.music_note_outlined,
    'مرآة': Icons.wifi_tethering,
    'مسكة': Icons.local_florist_outlined,
    'ورد': Icons.local_florist_outlined,
    'كيك': Icons.cake_outlined,
    'تصوير': Icons.photo_camera_outlined,
    'سيارة': Icons.directions_car_outlined,
  };
  for (final entry in icons.entries) {
    if (name.contains(entry.key)) return entry.value;
  }
  return Icons.check_circle_outline;
}

class _DeleteDialog extends StatelessWidget {
  final String noun;
  const _DeleteDialog({required this.noun});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD9473F);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFFBE3E3),
              child: Icon(Icons.info_outline, color: red),
            ),
            const SizedBox(height: 14),
            Text(
              'هل انت متأكد من حذف $noun؟',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'لن تتمكن من التراجع عن هذا الاجراء, ستحذف $noun نهائيا من صفحتك',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'حذف $noun',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
