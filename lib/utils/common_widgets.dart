import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

Widget loadingIndicator() {
  return const Center(
    child: LoadingIndicator(
        indicatorType: Indicator.ballPulse,
        colors: [Colors.white],
        strokeWidth: 2,
        backgroundColor: Colors.black,
        pathBackgroundColor: Colors.black),
  );
}
