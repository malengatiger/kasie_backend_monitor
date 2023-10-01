import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/app_auth.dart';
import 'package:kasie_transie_library/utils/environment.dart';
import 'package:kasie_transie_library/utils/functions.dart';

final GetIt getIt = GetIt.instance;

class NetworkService {
  final Dio dio;
  Map<String, String> headers = {
    'Content-type': 'application/json',
    'Accept-Encoding': 'gzip, deflate',
    // 'Access-Control-Allow-Origin': '*'
  };
  static const mm = ' 🅿️ 🅿️ 🅿️ NetworkService  🅿️';

  NetworkService({required this.dio});

  Future<void> initialize() async {
    final token = await appAuth.getAuthToken();
    headers['Authorization'] = 'Bearer $token';
    dio.options = BaseOptions(
      baseUrl: KasieEnvironment.getUrl(),
      headers: headers,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 120),
    );

    pp('$mm Dio networking options initialized ');
  }

  Future getHttp(String url) async {
    Response response;
    response = await dio.get(url);
    pp(response.data.toString());
  }
}

void setupNetworkService() {
  getIt.registerSingleton<NetworkService>(
    NetworkService(dio: Dio()),
  );
  pp('🍑🍑🍑 setupNetworkService: Network service registered to GetIt');
}

NetworkService getNetworkService() {
  pp('🍑🍑🍑 getNetworkService: Network service registered to GetIt');
  return getIt<NetworkService>();
}