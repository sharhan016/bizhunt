import 'package:bizhunt/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Map<String, dynamic> business;

  const BusinessDetailScreen({Key? key, required this.business})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business['name']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Image
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(business['image_url']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Business Name and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      business['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    business['price'] != null && business['price'] != '\$\$'
                        ? business['price']
                        : '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Categories
              Text(
                business['categories']
                    .map((category) => category['title'])
                    .join(', '),
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  // Review Count Text
                  Text(
                    '${business['review_count']} Reviews',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),

                  // Rating Bar
                  RatingBarIndicator(
                    rating: business['rating'].toDouble(),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 15.0,
                    direction: Axis.horizontal,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Business Address
              const Text(
                'Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                business['location']['display_address'].join(', '),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              // Business Hours
              if (business['business_hours'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hours',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...getFormattedBusinessHours(business['business_hours'])
                  ],
                ),
              SizedBox(height: 16),

              // Open/Closed Status & Call Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    business['business_hours'][0]['is_open_now'] == true
                        ? 'Open Now'
                        : 'Closed',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          business['business_hours'][0]['is_open_now'] == true
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Call logic
                    },
                    icon: Icon(Icons.phone),
                    label: Text(business['display_phone']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getFormattedBusinessHours(List<dynamic> businessHours) {
    Map<String, List<String>> hoursMap = {
      'Sunday': [],
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': []
    };

    var hoursList = businessHours[0]['open'];
    for (var hour in hoursList) {
      String day = getDayName(hour['day']);
      String start = formatTime(hour['start']);
      String end = formatTime(hour['end']);
      hoursMap[day]?.add('$start - $end');
    }

    List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    List<String> currentDays = [];
    String lastTiming = '';
    List<Map<String, String>> consolidatedHours = [];

    for (String day in daysOfWeek) {
      String dayTiming = hoursMap[day]?.join(', ') ?? '';

      if (dayTiming == lastTiming) {
        currentDays.add(day);
      } else {
        if (currentDays.isNotEmpty && lastTiming.isNotEmpty) {
          consolidatedHours
              .add({"days": formatDayRange(currentDays), "timing": lastTiming});
        }
        currentDays = [day];
        lastTiming = dayTiming;
      }
    }

    if (currentDays.isNotEmpty && lastTiming.isNotEmpty) {
      consolidatedHours
          .add({"days": formatDayRange(currentDays), "timing": lastTiming});
    }

    List<Widget> hoursWidgets = [];
    for (var entry in consolidatedHours) {
      hoursWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry["days"]}:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              entry["timing"]!,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
          ],
        ),
      );
    }

    return hoursWidgets;
  }
}
