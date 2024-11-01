import 'package:flutter_test/flutter_test.dart';
import 'package:bizhunt/services/yelp_service.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'yelp_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  group('YelpService', () {
    late YelpService yelpService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      yelpService = YelpService(dio: mockDio);
    });

    test('fetches businesses successfully with specific values', () async {
      final mockResponseData = {
        'businesses': [<String, dynamic>{}]
      };

      when(mockDio.get(any,
              options: anyNamed('options'),
              queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
                data: mockResponseData,
              ));

      final List<Map<String, dynamic>> businesses =
          List<Map<String, dynamic>>.from(
              await yelpService.fetchBusinesses('NYC'));

      expect(businesses, isNotEmpty);

      expect(businesses, isNotEmpty);
      expect(businesses.first, isA<Map<String, dynamic>>());
    });

    test('returns empty list on error', () async {
      when(mockDio.get(any,
              options: anyNamed('options'),
              queryParameters: anyNamed('queryParameters')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final businesses = await yelpService.fetchBusinesses('NYC');

      expect(businesses, isEmpty);
    });
  });
}
