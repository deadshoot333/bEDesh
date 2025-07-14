import 'package:flutter/material.dart';

class OxfordPage extends StatelessWidget {
  const OxfordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oxford University"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University Image
            Image.asset(
              "assets/oxford.jpg",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 16),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Founded in 1096, the University of Oxford is the oldest university in the English-speaking world. "
                    "It consistently ranks among the world's top universities and offers an unparalleled academic and cultural experience in the historic city of Oxford.",
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 20),

            // Available Scholarships Section (Chips Row)
            sectionTitle("Available Scholarships"),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  infoChip("Rhodes Scholarship"),
                  const SizedBox(width: 8),
                  infoChip("Clarendon Fund"),
                  const SizedBox(width: 8),
                  infoChip("Reach Oxford Scholarship"),
                  const SizedBox(width: 8),
                  infoChip("Weidenfeld-Hoffmann"),
                  const SizedBox(width: 8),
                  infoChip("Simon & June Li Scholarship"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Courses Section (Chips Row)
            sectionTitle("Courses"),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  infoChip("BSc Computer Science"),
                  const SizedBox(width: 8),
                  infoChip("PPE"),
                  const SizedBox(width: 8),
                  infoChip("MSc Data Science"),
                  const SizedBox(width: 8),
                  infoChip("MSc Finance"),
                  const SizedBox(width: 8),
                  infoChip("MBA Business"),
                  const SizedBox(width: 8),
                  infoChip("Law LLB"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Share Icon Button
            Center(
              child: IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Share button pressed!")),
                  );
                },
                icon: const Icon(Icons.share, color: Colors.blueAccent, size: 30),
                tooltip: 'Share',
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Oval Chip Widget (For Scholarships & Courses)
  Widget infoChip(String label) {
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
