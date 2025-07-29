import 'package:bedesh/features/university/presentation/widgets/course_card.dart';
import 'package:bedesh/features/university/presentation/widgets/scholarship_card.dart';
import 'package:bedesh/features/university/presentation/widgets/university_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common/section_header.dart';

class CambridgeUniversityPage extends StatefulWidget {
  const CambridgeUniversityPage({super.key});

  @override
  State<CambridgeUniversityPage> createState() =>
      _CambridgeUniversityPageState();
}

class _CambridgeUniversityPageState extends State<CambridgeUniversityPage> {
  final String universityApplyUrl = 'https://www.cam.ac.uk/apply';

  final Map<String, Map<String, String>> scholarshipDetails = {
    'Cambridge International Scholarship': {
      'description': 'Supports the top-scoring international PhD students.',
      'url':
          'https://www.cam.ac.uk/study/international/international-scholarships',
    },
    'Gates Cambridge Scholarship': {
      'description':
          'Highly competitive scholarship for outstanding applicants from outside the UK.',
      'url': 'https://www.gatescambridge.org/',
    },
    'Vice-Chancellor\'s Award': {
      'description': 'Merit-based scholarship for postgraduate students.',
      'url': 'https://www.postgraduate.study.cam.ac.uk/funding/how-apply',
    },
  };

  final Map<String, Map<String, String>> courseDetails = {
    'Computer Science': {
      'description':
          'Study of computation, algorithms, and programming at Cambridge.',
      'url': 'https://www.cam.ac.uk/courses/computer-science',
    },
    'Law': {
      'description':
          'Comprehensive law degree focusing on UK and international legal systems.',
      'url': 'https://www.cam.ac.uk/courses/law',
    },
    'Engineering': {
      'description':
          'Covers mechanical, electrical, and civil engineering with world-class research.',
      'url': 'https://www.cam.ac.uk/courses/engineering',
    },
  };

  late final List<String> scholarships = scholarshipDetails.keys.toList();

  void _viewScholarship(String title) {
    final details = scholarshipDetails[title];
    if (details == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details['description'] ?? ''),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchURL(details['url'] ?? ''),
              child: const Text(
                'Visit Scholarship Page',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewCourse(String courseName) {
    final details = courseDetails[courseName];
    if (details == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(courseName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details['description'] ?? ''),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchURL(details['url'] ?? ''),
              child: const Text(
                'Visit Course Page',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _applyToUniversity() async {
    final uri = Uri.parse(universityApplyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the application link.')),
      );
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cambridge University'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/cambridge.jpg', // Replace this with the correct image path
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            const SectionHeader(
              title: 'About Cambridge University',
              icon: Icons.info_outline,
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              'The University of Cambridge is a globally respected institution, known for academic excellence and groundbreaking research across various disciplines. Located in the historic city of Cambridge, UK.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppConstants.spaceM),
            const SectionHeader(
              title: 'University Stats',
              icon: Icons.bar_chart_outlined,
            ),
            const SizedBox(height: AppConstants.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                UniversityStatCard(
                  icon: Icons.school_outlined,
                  label: 'Rank',
                  value: '#2',
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppConstants.spaceM),
                UniversityStatCard(
                  icon: Icons.language_outlined,
                  label: 'QS Score',
                  value: '98.8',
                  color: AppColors.info,
                ),
                const SizedBox(height: AppConstants.spaceM),
                UniversityStatCard(
                  icon: Icons.people_outline,
                  label: 'Students',
                  value: '24,000+',
                  color: AppColors.success,
                ),
                const SizedBox(height: AppConstants.spaceM),
              ],
            ),
            const SizedBox(height: AppConstants.spaceM),
            const SectionHeader(
              title: 'Available Scholarships',
              icon: Icons.card_giftcard_outlined,
            ),
            const SizedBox(height: AppConstants.spaceM),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceS),
                itemCount: scholarships.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppConstants.spaceM),
                itemBuilder: (context, index) {
                  return ScholarshipCard(
                    title: scholarships[index],
                    onTap: () => _viewScholarship(scholarships[index]), name: '', eligibility: '',
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
            const SectionHeader(
              title: 'Popular Courses',
              icon: Icons.menu_book_outlined,
            ),
            const SizedBox(height: AppConstants.spaceM),
            CourseCard(
              courseName: 'Computer Science',
              duration: '3 Years',
              fee: '£35,000/year',
              name: 'Computer Science',
              level: 'Undergraduate',
              onTap: () => _viewCourse('Computer Science'), course: {}, tuitionFee: null, description: null, universityName: '', price: null, rating: null, tags: [], imageUrl: '',
            ),
            CourseCard(
              courseName: 'Law',
              duration: '3 Years',
              fee: '£32,500/year',
              name: 'Law',
              level: 'Undergraduate',
              onTap: () => _viewCourse('Law'), course: {}, tuitionFee: null, description: null, universityName: '', price: null, rating: null, tags: [], imageUrl: '',
            ),
            CourseCard(
              courseName: 'Engineering',
              duration: '4 Years',
              fee: '£36,000/year',
              name: 'Engineering',
              level: 'Undergraduate',
              onTap: () => _viewCourse('Engineering'), course: {}, tuitionFee: null, description: null, universityName: '', price: null, rating: null, tags: [], imageUrl: '',
            ),
            const SizedBox(height: AppConstants.spaceL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyToUniversity,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}