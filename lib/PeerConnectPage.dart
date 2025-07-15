import 'package:flutter/material.dart';

class PeerConnectPage extends StatefulWidget {
  const PeerConnectPage({super.key});

  @override
  State<PeerConnectPage> createState() => _PeerConnectPageState();
}

class _PeerConnectPageState extends State<PeerConnectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peer Connect"),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "University"),
            Tab(text: "City"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search students...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (query) {
                setState(() {}); // For live filtering
              },
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildStudentList(context, "university"),
                buildStudentList(context, "city"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStudentList(BuildContext context, String filterType) {
    // Dummy data
    final List<Map<String, String>> peers = [
      {
        'name': 'Ayaan Khan',
        'university': 'University of Glasgow',
        'city': 'Glasgow',
        'avatar': 'assets/user1.jpg',
      },
      {
        'name': 'Zara Rahman',
        'university': 'University of Toronto',
        'city': 'Toronto',
        'avatar': 'assets/user2.jpg',
      },
      {
        'name': 'Tanisha Chowdhury',
        'university': 'University of Sydney',
        'city': 'Sydney',
        'avatar': 'assets/user3.jpg',
      },
    ];

    final query = _searchController.text.toLowerCase();

    final filteredPeers = peers.where((peer) {
      final target = filterType == 'university'
          ? peer['university']!
          : peer['city']!;
      return peer['name']!.toLowerCase().contains(query) ||
          target.toLowerCase().contains(query);
    }).toList();

    return ListView.builder(
      itemCount: filteredPeers.length,
      itemBuilder: (context, index) {
        final peer = filteredPeers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(peer['avatar']!),
              radius: 25,
            ),
            title: Text(peer['name']!),
            subtitle: Text(
              filterType == 'university'
                  ? peer['university']!
                  : "Lives in ${peer['city']!}",
            ),
            trailing: ElevatedButton.icon(
              onPressed: () {
                // Trigger chat connection or send request
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Request sent to ${peer['name']}")),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text("Connect"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}
