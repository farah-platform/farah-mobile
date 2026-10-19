import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../cubits/provider_services/provider_services_cubit.dart';
import '../../../../cubits/provider_services/provider_services_state.dart';

class ProviderEditPackageScreen extends StatefulWidget {
  final Map<String, dynamic> packageData;
  const ProviderEditPackageScreen({super.key, required this.packageData});

  @override
  State<ProviderEditPackageScreen> createState() => _ProviderEditPackageScreenState();
}

class _ProviderEditPackageScreenState extends State<ProviderEditPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _basePriceController;
  
  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  late List<Map<String, dynamic>> _packageItems;
  final _itemController = TextEditingController();

  late bool _isAvailable;
  String? _executionDuration;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.packageData['title']);
    _descController = TextEditingController(text: widget.packageData['description']);
    // Read the shape GET /provider/services returns.
    final pricing = widget.packageData['pricing'] as Map?;
    final price = pricing?['original_price'] ?? pricing?['price'] ?? widget.packageData['price'];
    _basePriceController = TextEditingController(text: price?.toString());

    _isAvailable = widget.packageData['is_published'] == true;

    // The dropdown only accepts its own options; anything else would crash it.
    const durations = ['خلال يومين من الطلب', 'خلال 5 ايام من الطلب', 'خلال اسبوع من الطلب'];
    final duration = widget.packageData['execution_duration'];
    _executionDuration = durations.contains(duration) ? duration : null;

    final items = widget.packageData['package_items'];
    _packageItems = items is List
        ? items.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : [];
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImages.add(File(pickedFile.path));
      });
    }
  }

  void _addItem() {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        _packageItems.add({"title": _itemController.text, "quantity": 1});
        _itemController.clear();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'title': _titleController.text,
      'description': _descController.text,
      'price': _basePriceController.text,
      'currency': 'ILS',
      'service_type': 'package',
      'package_items': jsonEncode(_packageItems),
      'execution_duration': _executionDuration ?? widget.packageData['execution_duration'] ?? '',
      'is_available': _isAvailable ? '1' : '0',
    };

    context.read<ProviderServicesCubit>().updateService(widget.packageData['id'], data, _newImages);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
        content: const Text('هل انت متأكد من حذف الباقة؟\nلن تتمكن من التراجع عن هذا الإجراء وسيتم حذفها نهائياً من حسابك.', textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<ProviderServicesCubit>().deleteService(widget.packageData['id']);
                Navigator.pop(context); // Go back to services list
              },
              child: const Text('حذف الباقة', style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تعديل الباقة', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: BlocListener<ProviderServicesCubit, ProviderServicesState>(
        listener: (context, state) {
          if (state is ProviderServicesAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل الباقة بنجاح')));
            Navigator.pop(context);
          } else if (state is ProviderServicesAddError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('صور الباقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 32),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade300,
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                      ..._newImages.map((img) => Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: FileImage(img), fit: BoxFit.cover),
                        ),
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => setState(() => _newImages.remove(img)),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: CircleAvatar(radius: 12, backgroundColor: Colors.white, child: Icon(Icons.close, size: 16, color: Colors.black)),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField('اسم الباقة', 'مثال: باقة العروس', _titleController),
                const SizedBox(height: 16),
                _buildTextField('وصف الباقة', 'وصف الباقة', _descController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField('السعر الاجمالي', 'شيكل', _basePriceController, isNumber: true),
                const SizedBox(height: 24),
                const Text('محتويات الباقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ..._packageItems.map((f) => ListTile(
                  title: Text(f['title'] ?? '', style: const TextStyle(fontSize: 14)),
                  trailing: Switch(
                    value: true,
                    activeColor: primary,
                    onChanged: (val) {
                      if (!val) {
                         setState(() => _packageItems.remove(f));
                      }
                    }
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _itemController,
                        decoration: InputDecoration(
                          hintText: 'إضافة مرفق',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: primary),
                      onPressed: _addItem,
                    )
                  ],
                ),
                const SizedBox(height: 24),
                const Text('مدة التسليم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  value: _executionDuration,
                  items: const [
                    DropdownMenuItem(value: 'خلال يومين من الطلب', child: Text('خلال يومين من الطلب')),
                    DropdownMenuItem(value: 'خلال 5 ايام من الطلب', child: Text('خلال 5 ايام من الطلب')),
                    DropdownMenuItem(value: 'خلال اسبوع من الطلب', child: Text('خلال اسبوع من الطلب')),
                  ],
                  onChanged: (val) => setState(() => _executionDuration = val),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('حالة النشر\nالباقة جاهزة للعملاء ويمكن حجزها', style: TextStyle(fontSize: 12)),
                    Switch(
                      value: _isAvailable,
                      activeColor: primary,
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                BlocBuilder<ProviderServicesCubit, ProviderServicesState>(
                  builder: (context, state) {
                    bool isLoading = state is ProviderServicesAdding;
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: isLoading ? null : _submit,
                        child: isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          validator: isRequired ? (val) => val == null || val.isEmpty ? 'مطلوب' : null : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
