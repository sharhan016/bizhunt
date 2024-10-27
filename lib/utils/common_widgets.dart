import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

Widget loadingIndicator() {
  return const Center(
    child: SizedBox(
      height: 50,
      child: LoadingIndicator(
          indicatorType: Indicator.ballClipRotateMultiple,
          colors: [Color(0XFF3F51B5)],
          strokeWidth: 2,
          pathBackgroundColor: Colors.black),
    ),
  );
}
