import 'package:flutter/material.dart';
import '../profile_page.dart';

AppBar buildAppBar(String title, BuildContext context) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    actions: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.asset(
                'assets/profile.jpg',
                fit: BoxFit.cover,
                width: 44,
                height: 44,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
