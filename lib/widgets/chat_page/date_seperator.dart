import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSeperator extends StatefulWidget {
  final DateTime date;
  const DateSeperator({super.key, required this.date});

  @override
  State<DateSeperator> createState() => _DateSeperatorState();
}

class _DateSeperatorState extends State<DateSeperator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(68),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        DateFormat('EEE, MMM d').format(widget.date),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
