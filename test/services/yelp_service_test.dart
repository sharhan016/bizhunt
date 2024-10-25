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
      // Arrange: Set up mock response data with specific values
      final mockResponseData = {
        'businesses': [
          {
            'name': 'Rubirosa',
            'location': {
              'address1': '235 Mulberry St',
              'city': 'New York',
              'state': 'NY',
              'zip_code': '10012'
            },
          },
        ]
      };

      // Mock the Dio response to return our mock data
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

      // Assert: Verify the expected values
      expect(businesses, isNotEmpty);

      // Look for the specific business by name
      final business = businesses.firstWhere((b) => b['name'] == 'Rubirosa',
          orElse: () => {});

      // Check if "Rubirosa" is found, and then verify specific values
      expect(business, isNotNull);
      expect(business['location']['address1'], '235 Mulberry St');
      expect(business['location']['city'], 'New York');
      expect(business['location']['state'], 'NY');
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
