import 'package:dio/dio.dart';
import 'package:farah/data/models/home/homeResponsemodel.dart';
import 'package:farah/data/repositories/home_repostory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repo;

  HomeCubit(this._repo) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());

    try {
      // استدعاء الباك إند الحقيقي عبر الـ Repository
      final homeData = await _repo.fetchHome();
      emit(HomeLoaded(home: homeData));
    } catch (e) {
      emit(HomeError(_mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة الاتصال، يرجى المحاولة مجدداً';
      }
      if (e.response?.statusCode == 401) {
        return 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً';
      }
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
