// CourseDetailsPage.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsPage extends StatelessWidget {
  final Map<String, String> course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course['name'] ?? 'Course Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course['name'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Level: ${course['level']}"),
            Text("Category: ${course['category']}"),
            Text("Duration: ${course['duration']}"),
            Text("Session: ${course['availability']}"),
            Text("Popularity: ${course['popularity']}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final url = course['url'];
                if (url != null) {
                  launchUrl(Uri.parse(url));
                }
              },
              child: const Text("View Course on Website"),
            ),
          ],
        ),
      ),
    );
  }
}
