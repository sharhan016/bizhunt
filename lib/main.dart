import 'package:bizhunt/screens/home_screen.dart';
import 'package:bizhunt/services/yelp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'bloc/business_bloc.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final YelpService yelpService = YelpService();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BizHunt',
      home: BlocProvider(
        lazy: false,
        create: (_) {
          final businessBloc = BusinessBloc(yelpService);
          businessBloc.add(FetchBusinesses('NYC'));
          return businessBloc;
        },
        child: HomeScreen(),
      ),
    );
  }
}
