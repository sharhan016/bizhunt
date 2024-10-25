import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YelpService {
  final Dio _dio;

  YelpService({Dio? dio}) : _dio = dio ?? Dio();
  final String _apiKey = dotenv.env['API_KEY'] ?? '';

  Future<List<dynamic>> fetchBusinesses(String location) async {
    try {
      final response = await _dio.get(
        'https://api.yelp.com/v3/businesses/search',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        queryParameters: {
          'location': location,
          'limit': 20,
        },
      );

      if (response.statusCode == 200) {
        return response.data['businesses'];
      } else {
        throw Exception('Failed to load businesses');
      }
    } catch (e) {
      print('Error fetching businesses: $e');
      return [];
    }
  }
}
