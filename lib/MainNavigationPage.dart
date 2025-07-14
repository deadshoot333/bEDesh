import 'package:flutter/material.dart';
import 'AustraliaScholarPage.dart';
import 'OxfordPage.dart';
import 'SwanseaUni.dart';
import 'UKDetailsPage.dart';
import 'CommunityFeedPage.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [const HomePage(), const CommunityFeedPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const CommunityFeedPage();
      default:
        return const HomePage();
    }
  }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue, // Changed from deepPurple to blue
        unselectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "bEDesh",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Find Universities and Courses',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sliding Banner Carousel
              SizedBox(
                height: 120,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SwanseaUniPage(),
                          ),
                        );
                      },
                      child: bannerCard(
                        "assets/abroad11.png",
                        "Swansea University",
                        "83% employability",
                        "High satisfaction",
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AustraliaScholarPage(),
                          ),
                        );
                      },
                      child: bannerImage("assets/australliascolar.jpg"),
                    ),
                  ],
                ),
              ),

              // Popular Destinations
              sectionTitle("Popular Destinations"),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    DestinationCard(
                      title: "United Kingdom",
                      count: 108,
                      imageAsset: "assets/uk.jpg",
                    ),
                    DestinationCard(
                      title: "United States",
                      count: 137,
                      imageAsset: "assets/abroad13.jpg",
                    ),
                    DestinationCard(
                      title: "Canada",
                      count: 39,
                      imageAsset: "assets/canada.jpg",
                    ),
                    DestinationCard(
                      title: "Australlia",
                      count: 15,
                      imageAsset: "assets/autrallia.jpg",
                    ),
                  ],
                ),
              ),

              // In-demand Courses
              sectionTitle("In-demand courses"),
              SizedBox(
                height: 150, // Reduced height
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      courseCard(
                        "MSc Future Vehicle Technologies",
                        "Aston University",
                        "GBP 21,500",
                      ),
                      const SizedBox(width: 12),
                      courseCard(
                        "MSc Computer Science",
                        "University of Glasgow",
                        "GBP 19,000",
                      ),
                      const SizedBox(width: 12),
                      courseCard(
                        "MSc International Business",
                        "University of Leeds",
                        "GBP 18,500",
                      ),
                      const SizedBox(width: 12),
                      courseCard(
                        "MBA in Finance",
                        "University of Warwick",
                        "GBP 22,000",
                      ),
                      const SizedBox(width: 12),
                      courseCard(
                        "MSc Artificial Intelligence",
                        "University of Edinburgh",
                        "GBP 20,500",
                      ),
                    ],
                  ),
                ),
              ),

              // Top Institutions (circular like destinations)
              sectionTitle("Top Institutions"),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: const [
                    DestinationCard(
                      title: "Oxford",
                      imageAsset: "assets/oxford.jpg",
                      label: "United Kingdom",
                    ),
                    DestinationCard(
                      title: "MIT",
                      imageAsset: "assets/mit.jpg",
                      label: "United States",
                    ),
                    DestinationCard(
                      title: "Toronto",
                      imageAsset: "assets/canadauni.jpg",
                      label: "Canada",
                    ),
                    DestinationCard(
                      title: "Victoria",
                      imageAsset: "assets/victoria.jpg",
                      label: "Australia",
                    ),
                  ],
                ),
              ),

              // Trending Subjects
              sectionTitle("Trending Subjects"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  SubjectChip(label: "Business"),
                  SubjectChip(label: "Business Administration"),
                  SubjectChip(label: "Education"),
                  SubjectChip(label: "Computer Sciences"),
                  SubjectChip(label: "Media Studies And Communication"),
                ],
              ),

              // What's New
              sectionTitle("What's new?"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  FeatureCard(
                    icon: Icons.attach_money,
                    title: "Funds",
                    subtitle: "Explore education loans",
                  ),
                  FeatureCard(
                    icon: Icons.home_work,
                    title: "Stays",
                    subtitle: "Find affordable stays",
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.blue, size: 20),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget bannerCard(
    String imageAsset,
    String title,
    String line1,
    String line2,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Row(
        children: [
          Image.asset(imageAsset, width: 50, height: 50),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(line1),
                Text(line2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bannerImage(String imageAsset) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget courseCard(String course, String university, String price) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(university),
          const SizedBox(height: 6),
          Text(price, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final int? count;
  final String? label;

  const DestinationCard({
    super.key,
    required this.title,
    required this.imageAsset,
    this.count,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == "United Kingdom") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UKDetailsPage()),
          );
        } else if (title == "Oxford") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OxfordPage()),
          );
        }
      },

      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            CircleAvatar(backgroundImage: AssetImage(imageAsset), radius: 35),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              label ?? (count != null ? '$count Institutions' : ''),
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectChip extends StatelessWidget {
  final String label;

  const SubjectChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.grey),
      ),
      label: Text(label),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
