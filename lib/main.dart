import 'package:flutter/material.dart';
import 'today_workout.dart';
import 'monthly_page.dart';
import 'routines_list.dart';
import 'modals/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple,
          secondary: Colors.purple.shade100,
          background: Colors.white,
          surface: Colors.purple.shade50,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          toolbarHeight: 80,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          color: Colors.purple.shade50,
          margin: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: 'Pretendard',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontFamily: 'Pretendard',
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontFamily: 'Pretendard',
          ),
        ),
        iconTheme: IconThemeData(color: Colors.deepPurple),
      ),
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final PageController _pageController = PageController();
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    MonthlyPage(),
    TodayWorkoutPage(),
    RoutinesListPage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        pageController: _pageController,
      ),
    );
  }
}
