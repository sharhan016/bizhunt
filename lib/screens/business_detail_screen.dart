import 'package:bizhunt/utils/common_widgets.dart';
import 'package:bizhunt/utils/date_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Map<String, dynamic> business;

  const BusinessDetailScreen({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          launchUrl(Uri.parse('tel:${business['display_phone']}'),
              mode: LaunchMode.externalApplication);
        },
        backgroundColor: const Color(0XFF3F51B5),
        child: const Icon(
          Icons.call_outlined,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text(business['name']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: business['image_url'],
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => loadingIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 16),
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
                    business['price'] != null &&
                            RegExp(r'\d').hasMatch(business['price'])
                        ? business['price']
                        : '',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                business['categories']
                    .map((category) => category['title'])
                    .join(', '),
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${business['review_count']} Reviews',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
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
              const Text(
                'Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                business['location']['display_address'].join(', '),
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (business['business_hours'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hours',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...getFormattedBusinessHours(business['business_hours'])
                  ],
                ),
              const SizedBox(height: 16),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              entry["timing"]!,
              style: const TextStyle(fontSize: 16),
            ),
           const SizedBox(height: 8),
          ],
        ),
      );
    }

    return hoursWidgets;
  }
}
