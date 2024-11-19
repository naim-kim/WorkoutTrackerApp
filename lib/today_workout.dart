import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TodayWorkoutPage extends StatefulWidget {
  final RoutineCategory? uploadedRoutine;

  TodayWorkoutPage({this.uploadedRoutine});

  @override
  _TodayWorkoutPageState createState() => _TodayWorkoutPageState();
}

class _TodayWorkoutPageState extends State<TodayWorkoutPage> {
  final DateTime today = DateTime.now();
  final List<RoutineCategory> todayRoutines = [];

  @override
  void initState() {
    super.initState();
    if (widget.uploadedRoutine != null) {
      todayRoutines.add(widget.uploadedRoutine!);
    }
    _loadSavedRoutines();
  }

  Future<String> _getSavedRoutinesPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/saved_routines.json';
  }

  Future<void> _loadSavedRoutines() async {
    final path = await _getSavedRoutinesPath();
    if (await File(path).exists()) {
      final file = File(path);
      final jsonData = jsonDecode(await file.readAsString());

      jsonData['saved_routines'].forEach((date, routineData) {
        final DateTime routineDate = DateTime.parse(date);
        if (isSameDay(routineDate, today)) {
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

          setState(() {
            todayRoutines.addAll(categories);
          });
        }
      });
    }
  }

  Future<void> _saveRoutines() async {
    final path = await _getSavedRoutinesPath();
    final Map<String, dynamic> dataToSave = {
      "saved_routines": {
        DateFormat('yyyy-MM-dd').format(today): {
          "categories": todayRoutines.map((cat) {
            return {
              "title": cat.title,
              "exercises": cat.exercises.map((ex) {
                return {
                  "name": ex.name,
                  "sets": ex.sets.map((set) {
                    return {
                      "weight": set.weight,
                      "reps": set.reps,
                      "isCompleted": set.isCompleted,
                    };
                  }).toList(),
                };
              }).toList(),
            };
          }).toList(),
        }
      }
    };

    final file = File(path);
    await file.writeAsString(jsonEncode(dataToSave));
    print('Routines saved to $path');
  }

  Future<void> _resetSavedRoutines() async {
    final path = await _getSavedRoutinesPath();
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
      print("Saved routines file has been deleted.");
      setState(() {
        todayRoutines.clear(); // Clear the in-memory routines
      });
    } else {
      print("No saved routines file to delete.");
    }
  }

  Future<List<RoutineCategory>> _loadMockData() async {
    final String response =
        await rootBundle.loadString('assets/mock_data.json');
    final Map<String, dynamic> data = jsonDecode(response);

    final List<RoutineCategory> categories = [];
    for (var routine in data['routines']) {
      for (var category in routine['categories']) {
        categories.add(
          RoutineCategory(
            title: category['title'],
            exercises: (category['exercises'] as List)
                .map((ex) => Exercise(
                      name: ex['name'],
                      sets: (ex['sets'] as List)
                          .map((set) => SetDetails(
                                weight: set['weight'],
                                reps: set['reps'],
                              ))
                          .toList(),
                    ))
                .toList(),
          ),
        );
      }
    }
    return categories;
  }

  void _showAddRoutineDialog() async {
    final mockRoutines = await _loadMockData();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select a Routine to Add"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mockRoutines.length,
              itemBuilder: (context, index) {
                final routine = mockRoutines[index];
                return ListTile(
                  title: Text(routine.title),
                  onTap: () {
                    setState(() {
                      todayRoutines.add(routine);
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Workout"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRoutines,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRoutineDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Reset Data"),
                    content: const Text(
                        "Are you sure you want to reset all saved routines?"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("Reset"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetSavedRoutines();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: todayRoutines.length,
        itemBuilder: (context, index) {
          final category = todayRoutines[index];
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
                  fontFamily: 'Pretendard',
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
                        fontFamily: 'Pretendard',
                        fontSize: 16,
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
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              set.weight,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              set.reps,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Checkbox(
                              value: set.isCompleted,
                              onChanged: (value) {
                                setState(() {
                                  set.isCompleted = value!;
                                });
                              },
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
        },
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

  SetDetails(
      {required this.weight, required this.reps, this.isCompleted = false});
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
