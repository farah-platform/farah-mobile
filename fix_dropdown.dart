import 'dart:io';

void main() {
  final file = File('lib/view/screens/provider/provider_onboarding_screen.dart');
  var content = file.readAsStringSync();

  // Remove the old buggy replacement
  final badPattern = RegExp(r'_cities\.isEmpty\s*\?\s*const Text\([\s\S]*?\)\s*:\s*DropdownButtonFormField<String>\([\s\S]*?value:\s*_selectedCityId,\s*\),');
  
  if (badPattern.hasMatch(content)) {
    content = content.replaceFirst(badPattern, '''DropdownButtonFormField<String>(
                    value: _selectedCityId,
                    decoration: InputDecoration(
                      hintText: _cities.isEmpty ? 'لا يوجد اتصال' : 'اختر منطقتك',
                      errorText: _cities.isEmpty ? 'خطأ 500: لم يتم تحميل المناطق من السيرفر' : null,
                      suffixIcon: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                    ),
                    items: _cities.isEmpty ? null : _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city['id'].toString(),
                        child: Text(city['name']),
                      );
                    }).toList(),
                    onChanged: _cities.isEmpty ? null : (val) => setState(() => _selectedCityId = val),
                    validator: (val) => val == null ? 'مطلوب' : null,
                  ),''');
    file.writeAsStringSync(content);
    print('Fixed dropdown layout');
  } else {
    print('Could not find bad pattern');
  }
}
