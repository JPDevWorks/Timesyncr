import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class WeekView extends StatefulWidget {
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;

  const WeekView({
    required this.selectedDate,
    required this.onViewChanged,
  });

  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.week,
      onViewChanged: widget.onViewChanged,
      onSelectionChanged: (CalendarSelectionDetails details) {
        setState(() {
          _selectedDate = details.date!;
        });
      },
      initialSelectedDate: _selectedDate,
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
