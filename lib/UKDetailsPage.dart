import 'package:flutter/material.dart';
import 'UKUniversitiesPage';

class UKDetailsPage extends StatelessWidget {
  const UKDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("United Kingdom"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top UK Banner Image
            Image.asset(
              "assets/uk.jpg",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 16),

            // Flag and Text Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/british_flag2.jpg",
                    width: 80,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "United Kingdom",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UKUniversitiesPage()),
                          );
                        },
                        child: const Text(
                          "108 Universities",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stat Cards Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  statCard(Icons.person, "758K", "International Students"),
                  statCard(Icons.emoji_emotions, "20", "Happiness Rank"),
                  statCard(Icons.work, "75%", "Employment Rate"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Why Study in UK
            sectionTitle("Why Study in the UK?"),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "The UK is a globally renowned study destination with over 758,000 international students. Graduates enjoy strong job prospects, with a 75% employment rate, and can work for two years post-study. PhD students can stay for three years. The UK has a rich history, diverse culture, and is home to some of the world’s best universities like Oxford and Cambridge.",
              ),
            ),

            const SizedBox(height: 24),

            // Start Dates Card
            startDateCard(),

            const SizedBox(height: 24),

            // Best Universities Section
            sectionTitle("Best Universities"),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  universityCard("assets/oxford.jpg", "Oxford"),
                  universityCard("assets/mit.jpg", "Cambridge"),
                  universityCard("assets/canadauni.jpg", "Imperial"),
                  universityCard("assets/victoria.jpg", "UCL"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Popular Programs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.gavel, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Popular Programs",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: programChip("Law"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: programChip("Finance"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: programChip("Education"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: programChip("Business"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: programChip("Computer Sciences"),
                    ),
                  ],

                ),
              )

            ),

            const SizedBox(height: 24),

// Required Documents Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Required Documents",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

// Required Documents Section (like Popular Programs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.file_copy, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Required Documents",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: programChip("English Language Tests (IELTS)"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: programChip("Medical"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

// What Sets the UK Apart? Section (Paragraph)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.star, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "What Sets the UK Apart?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "The United Kingdom offers internationally respected universities, a dynamic student experience, and globally valued qualifications. "
                    "With a two-year post-study work visa and access to rich history, diverse cities, and countless travel opportunities, "
                    "studying in the UK provides excellent academic growth and career prospects in a welcoming, multicultural environment.",
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
            ),

// Student Life Section
            // Student Life Section with icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Icon(Icons.star, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    "Student Life",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "The UK offers a dynamic student life with access to countless cultural activities, "
                    "clubs and societies, international student communities, part-time job opportunities, "
                    "and travel connections to Europe. It’s a welcoming, safe, and intellectually stimulating "
                    "environment to build your future.",
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
            ),



            temperatureSection(),
            const SizedBox(height: 24),


            const SizedBox(height: 40),
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
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Stat Card Widget
  Widget statCard(IconData icon, String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Start Date Card Widget
  Widget startDateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.date_range, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  "Start Dates",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [
                dateChip("January"),
                dateChip("May"),
                dateChip("September"),
                dateChip("July"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Date Chip Widget
  static Widget dateChip(String month) {
    return Chip(
      label: Text(month),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.blueAccent),
      ),
      labelStyle: const TextStyle(color: Colors.blueAccent),
    );
  }

  // University Circle Avatar Widget
  Widget universityCard(String imagePath, String name) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(imagePath),
            radius: 35,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Program Chip Widget
  static Widget programChip(String program) {
    return Chip(
      label: Text(program),
      backgroundColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: Colors.blueAccent),
      ),
      labelStyle: const TextStyle(color: Colors.blueAccent),
    );
  }

  // Temperature Section Widget
  Widget temperatureSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.thermostat, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Temperature",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("London", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("2°C to 22°C"),
                SizedBox(height: 12),
                Text("Manchester", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("1°C to 19°C"),
                SizedBox(height: 12),
                Text("Edinburgh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("-1°C to 18°C"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
