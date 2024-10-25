import 'package:flutter/material.dart';

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

              // Review Count and Rating Stars
              Row(
                children: [
                  Text(
                    '${business['review_count']} Reviews',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(width: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < business['rating']
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Business Address
              Text(
                'Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
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
                    ..._getFormattedBusinessHours(business['business_hours'])
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

  List<Widget> _getFormattedBusinessHours(List<dynamic> businessHours) {
    var hoursList = businessHours[0]['open'];
    List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return hoursList.map<Widget>((hour) {
      String day = daysOfWeek[hour['day']];
      String start = _formatTime(hour['start']);
      String end = _formatTime(hour['end']);

      return Text('$day: $start - $end');
    }).toList();
  }

  String _formatTime(String time) {
    int hour = int.parse(time.substring(0, 2));
    int minute = int.parse(time.substring(2, 4));
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }
}
