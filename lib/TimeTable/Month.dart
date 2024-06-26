import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MonthView extends StatefulWidget {
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;

  const MonthView({
    required this.selectedDate,
    required this.onViewChanged,
  });

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      view: CalendarView.month,
      onViewChanged: widget.onViewChanged,
      onSelectionChanged: (CalendarSelectionDetails details) {
        setState(() {
          _selectedDate = details.date!;
        });
      },
      initialSelectedDate: _selectedDate,
      headerStyle:const CalendarHeaderStyle(
        backgroundColor: Color(0xFF0D6E6E),
      ),
      todayHighlightColor: Color(0xFF0D6E6E),
      selectionDecoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}
