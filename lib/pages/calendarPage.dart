import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TextEditingController _eventText = TextEditingController();
  late ValueNotifier<List<Event>> _selectedEvents;
  Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents =
        ValueNotifier<List<Event>>(_getEventsForDay(_selectedDay!));
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        accent: Colors.blue,
        backButton: true,
        locale: 'id',
        onDateChanged: (value) {
          _onDaySelected(value, value);
        },
        firstDate: DateTime.now().subtract(Duration(days: 140)),
        lastDate: DateTime.now(),
      ),
      body: content(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: Text('Event Name'),
                content: Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: _eventText,
                    decoration: InputDecoration(hintText: 'Enter event name'),
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (_eventText.text.isEmpty) return;
                      final newEvent = Event(_eventText.text);
                      setState(() {
                        if (events[_selectedDay] != null) {
                          events[_selectedDay]!.add(newEvent);
                        } else {
                          events[_selectedDay!] = [newEvent];
                        }
                        _selectedEvents.value = _getEventsForDay(_selectedDay!);
                      });
                      Navigator.of(context).pop();
                      _eventText.clear();
                    },
                    child: Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget content() {
    return Column(
      children: [
        TableCalendar<Event>(
          rowHeight: 50,
          headerStyle: HeaderStyle(titleCentered: true),
          availableGestures: AvailableGestures.all,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          focusedDay: _focusedDay,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: _onDaySelected,
          firstDay: DateTime.utc(2010, 10, 15),
          lastDay: DateTime.utc(2030, 10, 15),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(value[index].title),
                      onTap: () => print('Tapped on: ${value[index].title}'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class Event {
  final String title;

  Event(this.title);

  @override
  String toString() => title;
}
