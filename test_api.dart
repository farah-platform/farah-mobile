import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'https://farah-production.up.railway.app/api'));
  try {
    final response = await dio.get('/cities');
    final data = response.data;
    if (data is Map && data['data'] != null) {
       final list = data['data'] as List;
       final ids = list.map((e) => e['id']).toList();
       final names = list.map((e) => e['name']).toList();
       final uniqueIds = ids.toSet().toList();
       print('Total cities: ' + list.length.toString());
       print('Unique ids: ' + uniqueIds.length.toString());
       print('Has null names: ' + names.any((e) => e == null).toString());
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
