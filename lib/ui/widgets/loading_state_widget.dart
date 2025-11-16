import 'package:flutter/material.dart';

// TODO: Implement loading state widget
// Shows loading indicator with app theme

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
