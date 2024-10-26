import 'dart:math';

String formatTime(String time) {
  int hour = int.parse(time.substring(0, 2));
  int minute = int.parse(time.substring(2, 4));
  String period = hour >= 12 ? 'PM' : 'AM';
  hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  return '$hour:${minute.toString().padLeft(2, '0')} $period';
}

String getDayName(int day) {
  List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  return daysOfWeek[day];
}

String formatDayRange(List<String> days) {
  if (days.length == 1) {
    return days[0];
  } else {
    return '${days.first}-${days.last}';
  }
}
