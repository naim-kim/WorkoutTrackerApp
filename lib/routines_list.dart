import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class RoutinesListPage extends StatelessWidget {
  Future<List<RoutineCategory>> loadCategories() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Routines',
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: FutureBuilder<List<RoutineCategory>>(
        future: loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading routines."));
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text("No routines found."));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: categories
                .map((category) => CategoryTile(category: category))
                .toList(),
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

  SetDetails({required this.weight, required this.reps});
}

class CategoryTile extends StatelessWidget {
  final RoutineCategory category;

  CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFEADDFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          category.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        children: category.exercises
            .map((exercise) => ExerciseTile(exercise: exercise))
            .toList(),
      ),
    );
  }
}

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;

  ExerciseTile({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3EDF7),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          exercise.name,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: exercise.sets.asMap().entries.map((entry) {
          //set num 나오게하기 ㅎ
          final index = entry.key + 1;
          final set = entry.value;
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFEF7FF),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
  }
}
