import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SwanseaUniPage extends StatelessWidget {
  const SwanseaUniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Swansea University"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Image
            Image.asset(
              "assets/swanseauni.jpg",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 16),

            // University Name
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Swansea University",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Founded in 1920, Swansea University is a research-led institution located on the beautiful coastline of South Wales, UK. "
                    "The university is renowned for its high student satisfaction rates, excellent employability outcomes, and a supportive academic environment. "
                    "It offers a wide range of undergraduate and postgraduate courses, with a strong reputation in engineering, computer science, business, and health sciences. "
                    "Swansea provides a unique student experience, combining quality education with vibrant campus life and stunning natural scenery.",
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 24),

            // Info List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoRow(Icons.work, "Employment Rate", "83%"),
                  infoRow(Icons.calendar_today, "Upcoming Intake", "September 2025"),
                  infoRow(Icons.monetization_on, "Tuition Fee", "Starts from 20,800 GBP"),
                  infoRow(Icons.language, "English Requirement", "IELTS, TOEFL"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Courses Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.menu_book, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Courses",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Study Level
            sectionSubtitle("Study Level"),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  courseChip("Undergraduate"),
                  const SizedBox(width: 8),
                  courseChip("Postgraduate"),
                  const SizedBox(width: 8),
                  courseChip("Doctorate"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Subject Section
            sectionSubtitle("Subjects"),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  courseChip("Computer Sciences"),
                  const SizedBox(width: 8),
                  courseChip("Business Administration"),
                  const SizedBox(width: 8),
                  courseChip("Finance"),
                  const SizedBox(width: 8),
                  courseChip("Medicine"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Share Button Section
            // Share Icon Button Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: IconButton(
                  onPressed: () {
                    Share.share("Check out Swansea University — high employability rates and great coastal campus in the UK!");
                  },
                  icon: const Icon(Icons.share, color: Colors.blueAccent, size: 30),
                  tooltip: 'Share',
                ),
              ),
            ),


            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Info Row Widget
  Widget infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Section Subtitle Widget
  Widget sectionSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Course Chip Widget (Oval shape)
  Widget courseChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.blueAccent),
      ),
      labelStyle: const TextStyle(color: Colors.blueAccent, fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    );
  }
}
