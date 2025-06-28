import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final double progress;

  const ProgressDialog({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Processing...'),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text('${(progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}
