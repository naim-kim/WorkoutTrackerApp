import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'modals/appbar.dart';

class MonthlyPage extends StatefulWidget {
  @override
  _MonthlyPageState createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;
  Map<DateTime, List<RoutineCategory>> _savedRoutines = {};

  @override
  void initState() {
    super.initState();
    _selectedDate =
        DateTime(_focusedDate.year, _focusedDate.month, _focusedDate.day);
    _loadSavedRoutines();
  }

  Future<void> _loadSavedRoutines() async {
    try {
      final String response =
          await rootBundle.loadString('assets/saved_routines.json');
      final jsonData = jsonDecode(response);

      final Map<DateTime, List<RoutineCategory>> loadedRoutines = {};
      jsonData['saved_routines'].forEach((date, routineData) {
        final DateTime routineDate = DateTime.parse(date);
        final normalizedDate =
            DateTime(routineDate.year, routineDate.month, routineDate.day);

        final List<RoutineCategory> categories =
            (routineData['categories'] as List)
                .map((cat) => RoutineCategory(
                      title: cat['title'],
                      exercises: (cat['exercises'] as List)
                          .map((ex) => Exercise(
                                name: ex['name'],
                                sets: (ex['sets'] as List)
                                    .map((set) => SetDetails(
                                          weight: set['weight'],
                                          reps: set['reps'],
                                          isCompleted: set['isCompleted'],
                                        ))
                                    .toList(),
                              ))
                          .toList(),
                    ))
                .toList();

        loadedRoutines[normalizedDate] = categories;
      });

      setState(() {
        _savedRoutines = loadedRoutines;
      });
    } catch (e) {
      print("Error loading saved routines: $e");
    }
  }

  Widget _buildRoutinesList() {
    if (_selectedDate == null) {
      return const Center(
        child: Text("Select a date to view routines."),
      );
    }

    final DateTime normalizedSelectedDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    final routinesForDay = _savedRoutines[normalizedSelectedDate] ?? [];
    if (routinesForDay.isEmpty) {
      return const Center(
        child: Text("No routines scheduled for this day."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: routinesForDay.map((category) {
        return Card(
          color: const Color(0xFFEADDFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              category.title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            children: category.exercises.map((exercise) {
              return Container(
                color: const Color(0xFFF3EDF7),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  children: exercise.sets.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final set = entry.value;
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF7FF),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${index} set',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            set.weight,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            set.reps,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TableCalendar(
        focusedDay: _focusedDate,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate =
                DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
            _focusedDate = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: const BoxDecoration(
            color: Color(0xFFE8DEF8),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.deepPurple[300],
            shape: BoxShape.circle,
          ),
          cellMargin: const EdgeInsets.all(6),
        ),
        eventLoader: (date) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          if (_savedRoutines.containsKey(normalizedDate)) {
            return [true];
          }
          return [];
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false, // Hides the format button
          titleCentered: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String selectedDateText = _selectedDate != null
        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
        : "Monthly Routines";

    return Scaffold(
      appBar: buildAppBar(selectedDateText, context),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: _buildRoutinesList(),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutineCategory {
  final String title;
  final List<Exercise> exercises;

  RoutineCategory({required this.title, required this.exercises});
}

class Exercise {
  final String name;
  final List<SetDetails> sets;

  Exercise({required this.name, required this.sets});
}

class SetDetails {
  final String weight;
  final String reps;
  bool isCompleted;

  SetDetails({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });
}
