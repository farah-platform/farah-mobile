import 'package:farah/core/network/dio_client.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/data/models/home/homeResponsemodel.dart';

class HomeRepository {
  final DioClient _dioClient;

  HomeRepository(this._dioClient);

  Future<HomeResponseModel> fetchHome() async {
    final response = await _dioClient.dio.get(ApiEndpoints.home);

    return HomeResponseModel.fromJson(response.data);
  }
}
