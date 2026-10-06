import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../cubits/provider_services/provider_services_cubit.dart';
import '../../../../cubits/provider_services/provider_services_state.dart';

class ProviderEditServiceScreen extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  const ProviderEditServiceScreen({super.key, required this.serviceData});

  @override
  State<ProviderEditServiceScreen> createState() => _ProviderEditServiceScreenState();
}

class _ProviderEditServiceScreenState extends State<ProviderEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _basePriceController;
  late TextEditingController _individualPriceController;
  
  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  late List<String> _features;
  final _featureController = TextEditingController();

  late bool _isAvailable;
  String? _executionDuration;
  
  final List<Map<String, String>> _slots = [
    {"label": "الفترة الصباحية", "start_time": "10:00", "end_time": "14:00"},
    {"label": "الفترة المسائية", "start_time": "17:00", "end_time": "22:00"}
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.serviceData['title']);
    _descController = TextEditingController(text: widget.serviceData['description']);
    _basePriceController = TextEditingController(text: widget.serviceData['price']?.toString());
    _individualPriceController = TextEditingController(text: widget.serviceData['pricing_unit']); // Or mapping to individual price

    var isAvail = widget.serviceData['is_available'];
    _isAvailable = isAvail == true || isAvail == 1 || isAvail == '1';
    
    _executionDuration = widget.serviceData['execution_duration'];
    
    _features = [];
    try {
      if (widget.serviceData['features'] != null) {
        final List decoded = jsonDecode(widget.serviceData['features']);
        _features = decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImages.add(File(pickedFile.path));
      });
    }
  }

  void _addFeature() {
    if (_featureController.text.isNotEmpty) {
      setState(() {
        _features.add(_featureController.text);
        _featureController.clear();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    final data = {
      'title': _titleController.text,
      'description': _descController.text,
      'price': _basePriceController.text,
      'pricing_unit': _individualPriceController.text,
      'currency': 'ILS',
      'service_type': 'service',
      'features': jsonEncode(_features),
      'booking_slots': jsonEncode(_slots),
      'execution_duration': _executionDuration ?? 'خلال يومين من الطلب',
      'is_available': _isAvailable ? '1' : '0', // the api might expect bool or int, string works for form data
    };

    context.read<ProviderServicesCubit>().updateService(widget.serviceData['id'], data, _newImages);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
        content: const Text('هل انت متأكد من حذف الخدمة؟\nلن تتمكن من التراجع عن هذا الإجراء وسيتم حذفها نهائياً من حسابك.', textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<ProviderServicesCubit>().deleteService(widget.serviceData['id']);
                Navigator.pop(context); // Go back to services list
              },
              child: const Text('حذف الخدمة', style: TextStyle(color: Colors.white)),
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
        title: const Text('تعديل الخدمة', style: TextStyle(color: Colors.black)),
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعديل الخدمة بنجاح')));
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
                const Text('صور الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                      // Mocking existing images from network
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
                _buildTextField('اسم الخدمة', 'مثال: مسكة عروس', _titleController),
                const SizedBox(height: 16),
                _buildTextField('نبذة عن الخدمة', 'وصف الخدمة', _descController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField('السعر الاساسي', 'شيكل', _basePriceController, isNumber: true),
                const SizedBox(height: 16),
                _buildTextField('سعر افرادي (اختياري)', 'شيكل', _individualPriceController, isNumber: true, isRequired: false),
                const SizedBox(height: 24),
                const Text('تفاصيل الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ..._features.map((f) => ListTile(
                  title: Text(f, style: const TextStyle(fontSize: 14)),
                  trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => setState(() => _features.remove(f))),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _featureController,
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
                      onPressed: _addFeature,
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
                const Text('الفترات المتاحة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ..._slots.map((s) => ListTile(
                  title: Text(s['label']!, style: TextStyle(fontSize: 14, color: primary)),
                  subtitle: Text('${s['start_time']} - ${s['end_time']}', style: const TextStyle(fontSize: 12)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('حالة النشر\nالخدمة جاهزة للعملاء ويمكن حجزها', style: TextStyle(fontSize: 12)),
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
