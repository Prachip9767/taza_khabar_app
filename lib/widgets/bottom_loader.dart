import 'package:flutter/material.dart';

/// Reusable bottom loader widget for pagination
/// Displays a centered circular progress indicator
class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
