import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DayView extends StatefulWidget {
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;

  const DayView({
    required this.selectedDate,
    required this.onViewChanged,
  });

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.day,
      onViewChanged: widget.onViewChanged,
      headerStyle: CalendarHeaderStyle(
        backgroundColor: Color(0xff2dd4bf),
      ),
      todayHighlightColor: Color(0xff0f766e),
      selectionDecoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}
