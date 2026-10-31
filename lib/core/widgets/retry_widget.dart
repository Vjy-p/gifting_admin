import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  const RetryWidget({
    super.key,
    this.message,
    this.buttonLabel,
    required this.onPressed,
  });

  final String? message;
  final String? buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(message ?? 'Something went wrong!', textAlign: TextAlign.center),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonLabel ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}
