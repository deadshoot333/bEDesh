import 'package:bedesh/features/university/presentation/widgets/course_card.dart';
import 'package:bedesh/features/university/presentation/widgets/university_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../widgets/scholarship_filter_tags.dart';
import '../widgets/scholarship_card.dart';
import '../widgets/course_filter_tags.dart';

class CambridgeUniversityPage extends StatefulWidget {
  const CambridgeUniversityPage({super.key});

  @override
  State<CambridgeUniversityPage> createState() =>
      _CambridgeUniversityPageState();
}

class _CambridgeUniversityPageState extends State<CambridgeUniversityPage> {
  final String universityApplyUrl = 'https://www.cam.ac.uk/apply';
  
  // Scholarship filtering state
  String? _selectedType;
  String? _selectedFunding;
  String? _selectedDegreeLevel;
  String? _selectedDeadline;

  // Course filter state
  String _selectedField = 'All Fields';
  String _selectedLevel = 'All Levels';
  String _selectedIntake = 'All Intakes';
  String _selectedFeeRange = 'All Fees';
  
  // Cambridge-specific scholarship data with comprehensive details
  final List<Map<String, dynamic>> _cambridgeScholarships = [
    {
      'title': 'Gates Cambridge Scholarship',
      'offeredBy': 'Gates Cambridge Trust',
      'description': 'Full funding for outstanding international graduate students to pursue a full-time postgraduate degree at Cambridge.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Masters',
      'deadline': 'Upcoming',
      'amount': '£45,000',
      'fieldsOfStudy': ['All Graduate Programs', 'Research', 'Taught Masters', 'PhD Programs'],
      'eligibility': [
        'Outstanding intellectual ability',
        'Commitment to improving lives of others',
        'Leadership potential',
        'International students outside UK',
        'Strong academic references'
      ],
      'applicationProcess': 'Apply through Cambridge graduate application system. Complete Gates application by December deadline with essays on leadership and commitment to social good.',
      'deadlineStatus': 'Upcoming',
      'url': 'https://www.gatescambridge.org/',
    },
    {
      'title': 'Cambridge International Scholarship',
      'offeredBy': 'University of Cambridge',
      'description': 'Merit-based funding for exceptional international PhD candidates from developing countries.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'PhD',
      'deadline': 'Ongoing',
      'amount': '£40,000',
      'fieldsOfStudy': ['All PhD Research Programs', 'STEM Fields', 'Humanities', 'Social Sciences'],
      'eligibility': [
        'From developing countries',
        'Exceptional academic merit',
        'Strong research proposal',
        'English language proficiency',
        'PhD admission to Cambridge'
      ],
      'applicationProcess': 'Submit PhD application to Cambridge. Automatic consideration for scholarship. No separate application required.',
      'deadlineStatus': 'Ongoing',
      'url': 'https://www.cambridgetrust.org/scholarships/cambridge-international-scholarship',
    },
    {
      'title': 'Churchill Scholarship',
      'offeredBy': 'Winston Churchill Foundation',
      'description': 'For American students to pursue graduate studies in science, engineering, and mathematics at Cambridge.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Masters',
      'deadline': 'Upcoming',
      'amount': '£55,000',
      'fieldsOfStudy': ['Engineering', 'Mathematics', 'Computer Science', 'Natural Sciences', 'Physics'],
      'eligibility': [
        'US citizens only',
        'Outstanding academic achievement in STEM',
        'Commitment to advancing STEM fields',
        'Leadership potential',
        'Strong recommendations'
      ],
      'applicationProcess': 'Apply through Churchill Foundation. Requires US university endorsement, transcripts, research proposal, and interviews.',
      'deadlineStatus': 'Upcoming',
      'url': 'https://www.churchillscholarship.org/',
    },
    {
      'title': 'Peterhouse Graduate Scholarship',
      'offeredBy': 'Peterhouse College',
      'description': 'College-specific funding for graduate students demonstrating academic excellence and financial need.',
      'type': 'International',
      'funding': 'Partial',
      'degreeLevel': 'Masters',
      'deadline': 'Ongoing',
      'amount': '£15,000',
      'fieldsOfStudy': ['All Graduate Programs', 'Preference for Humanities'],
      'eligibility': [
        'Admission to Peterhouse College',
        'Academic excellence',
        'Financial need',
        'Contribution to college community',
        'Strong personal statement'
      ],
      'applicationProcess': 'Apply for admission to Peterhouse. Complete college funding application with financial documentation.',
      'deadlineStatus': 'Ongoing',
      'url': 'https://www.pet.cam.ac.uk/prospective-students/funding',
    },
    {
      'title': 'Cambridge Commonwealth Trust',
      'offeredBy': 'Cambridge Commonwealth Trust',
      'description': 'Supporting students from Commonwealth countries to study at Cambridge University.',
      'type': 'International',
      'funding': 'Partial',
      'degreeLevel': 'PhD',
      'deadline': 'Upcoming',
      'amount': '£25,000',
      'fieldsOfStudy': ['All Fields', 'Development Studies', 'Public Policy', 'International Relations'],
      'eligibility': [
        'Commonwealth country citizens',
        'Academic merit',
        'Commitment to home country development',
        'Leadership experience',
        'Clear career goals'
      ],
      'applicationProcess': 'Submit Cambridge application. Complete Commonwealth Trust application with essays on development goals.',
      'deadlineStatus': 'Upcoming',
      'url': 'https://www.cambridgetrust.org/',
    },
    {
      'title': 'Jardine Foundation Scholarship',
      'offeredBy': 'Jardine Foundation',
      'description': 'For students from Hong Kong and mainland China to pursue undergraduate or graduate studies.',
      'type': 'International',
      'funding': 'Full',
      'degreeLevel': 'Bachelors',
      'deadline': 'Closed',
      'amount': 'Full tuition + living costs',
      'fieldsOfStudy': ['All Undergraduate Programs', 'Liberal Arts', 'Sciences'],
      'eligibility': [
        'Hong Kong or mainland China residents',
        'Exceptional academic achievement',
        'Leadership potential',
        'Community service experience',
        'Strong English proficiency'
      ],
      'applicationProcess': 'Apply through Jardine Foundation portal. Requires academic transcripts, essays, interviews, and Cambridge admission.',
      'deadlineStatus': 'Closed',
      'url': 'https://www.jardines.com/en/community/jardine-foundation.html',
    },
  ];
  
  late List<Map<String, dynamic>> _filteredScholarships;

  @override
  void initState() {
    super.initState();
    _filteredScholarships = List.from(_cambridgeScholarships);
  }
  
  void _filterScholarships() {
    setState(() {
      _filteredScholarships = _cambridgeScholarships.where((scholarship) {
        bool matchesType = _selectedType == null || scholarship['type'] == _selectedType;
        bool matchesFunding = _selectedFunding == null || scholarship['funding'] == _selectedFunding;
        bool matchesDegreeLevel = _selectedDegreeLevel == null || scholarship['degreeLevel'] == _selectedDegreeLevel;
        bool matchesDeadline = _selectedDeadline == null || scholarship['deadline'] == _selectedDeadline;
        
        return matchesType && matchesFunding && matchesDegreeLevel && matchesDeadline;
      }).toList();
    });
  }

  void _onTypeChanged(String value) {
    setState(() {
      _selectedType = value == 'All Types' ? null : value;
    });
    _filterScholarships();
  }

  void _onFundingChanged(String value) {
    setState(() {
      _selectedFunding = value == 'All Funding' ? null : value;
    });
    _filterScholarships();
  }

  void _onDegreeLevelChanged(String value) {
    setState(() {
      _selectedDegreeLevel = value == 'All Levels' ? null : value;
    });
    _filterScholarships();
  }

  void _onDeadlineChanged(String value) {
    setState(() {
      _selectedDeadline = value == 'All Deadlines' ? null : value;
    });
    _filterScholarships();
  }
  
  void _clearScholarshipFilters() {
    setState(() {
      _selectedType = null;
      _selectedFunding = null;
      _selectedDegreeLevel = null;
      _selectedDeadline = null;
      _filteredScholarships = List.from(_cambridgeScholarships);
    });
  }

  // Course filtering methods
  List<Map<String, String>> get filteredCourses {
    List<Map<String, String>> coursesList = courses;
    
    if (_selectedField != 'All Fields') {
      coursesList = coursesList.where((c) => 
        c['field']?.toString().toLowerCase() == _selectedField.toLowerCase()
      ).toList();
    }
    
    if (_selectedLevel != 'All Levels') {
      coursesList = coursesList.where((c) => 
        c['level']?.toString().toLowerCase() == _selectedLevel.toLowerCase()
      ).toList();
    }
    
    if (_selectedIntake != 'All Intakes') {
      coursesList = coursesList.where((c) => 
        c['intake']?.toString().toLowerCase() == _selectedIntake.toLowerCase()
      ).toList();
    }
    
    if (_selectedFeeRange != 'All Fees') {
      coursesList = coursesList.where((c) => 
        c['feeRange']?.toString() == _selectedFeeRange
      ).toList();
    }
    
    return coursesList;
  }

  void _onFieldChanged(String value) {
    setState(() {
      _selectedField = value;
    });
  }

  void _onLevelChanged(String value) {
    setState(() {
      _selectedLevel = value;
    });
  }

  void _onIntakeChanged(String value) {
    setState(() {
      _selectedIntake = value;
    });
  }

  void _onFeeRangeChanged(String value) {
    setState(() {
      _selectedFeeRange = value;
    });
  }

  void _clearCourseFilters() {
    setState(() {
      _selectedField = 'All Fields';
      _selectedLevel = 'All Levels';
      _selectedIntake = 'All Intakes';
      _selectedFeeRange = 'All Fees';
    });
  }

  final List<Map<String, String>> courses = [
    // Computer Science
    {
      'name': 'Computer Science Tripos',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Computer Science',
      'intake': 'Fall',
      'fee': '£33,825/year',
      'feeRange': '£25K - £35K',
      'popularity': 'Very High',
      'description': 'Study of computation, algorithms, and programming at Cambridge.',
      'url': 'https://www.cam.ac.uk/courses/computer-science',
    },
    {
      'name': 'MPhil Advanced Computer Science',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Computer Science',
      'intake': 'Fall',
      'fee': '£37,632/year',
      'feeRange': '£35K - £45K',
      'popularity': 'High',
      'description': 'Advanced study in computer science research areas.',
      'url': 'https://www.cam.ac.uk/courses/computer-science',
    },
    {
      'name': 'PhD Computer Science',
      'level': 'PhD',
      'duration': '3-4 years',
      'field': 'Computer Science',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'High',
      'description': 'Research degree in computer science.',
      'url': 'https://www.cam.ac.uk/courses/computer-science',
    },
    // Engineering
    {
      'name': 'Engineering Tripos',
      'level': 'Undergraduate',
      'duration': '4 years',
      'field': 'Engineering',
      'intake': 'Fall',
      'fee': '£40,760/year',
      'feeRange': '£35K - £45K',
      'popularity': 'Very High',
      'description': 'Covers mechanical, electrical, and civil engineering with world-class research.',
      'url': 'https://www.cam.ac.uk/courses/engineering',
    },
    {
      'name': 'MPhil Engineering',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Engineering',
      'intake': 'Fall',
      'fee': '£37,632/year',
      'feeRange': '£35K - £45K',
      'popularity': 'High',
      'description': 'Advanced engineering research and design.',
      'url': 'https://www.cam.ac.uk/courses/engineering',
    },
    // Law
    {
      'name': 'Law Tripos',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Law',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'Very High',
      'description': 'Comprehensive law degree focusing on UK and international legal systems.',
      'url': 'https://www.cam.ac.uk/courses/law',
    },
    {
      'name': 'LLM Law',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Law',
      'intake': 'Fall',
      'fee': '£37,632/year',
      'feeRange': '£35K - £45K',
      'popularity': 'High',
      'description': 'Advanced legal studies program.',
      'url': 'https://www.cam.ac.uk/courses/law',
    },
    // Medicine
    {
      'name': 'Medicine',
      'level': 'Undergraduate',
      'duration': '6 years',
      'field': 'Medicine',
      'intake': 'Fall',
      'fee': '£63,990/year',
      'feeRange': 'Above £45K',
      'popularity': 'Very High',
      'description': 'Comprehensive medical degree program.',
      'url': 'https://www.cam.ac.uk/courses/medicine',
    },
    {
      'name': 'MPhil Population Health Sciences',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Medicine',
      'intake': 'Fall',
      'fee': '£37,632/year',
      'feeRange': '£35K - £45K',
      'popularity': 'High',
      'description': 'Advanced study in population health and epidemiology.',
      'url': 'https://www.cam.ac.uk/courses/medicine',
    },
    // Natural Sciences
    {
      'name': 'Natural Sciences Tripos',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Natural Sciences',
      'intake': 'Fall',
      'fee': '£40,760/year',
      'feeRange': '£35K - £45K',
      'popularity': 'Very High',
      'description': 'Broad science degree covering multiple disciplines.',
      'url': 'https://www.cam.ac.uk/courses/natural-sciences',
    },
    {
      'name': 'MPhil Scientific Computing',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Natural Sciences',
      'intake': 'Fall',
      'fee': '£37,632/year',
      'feeRange': '£35K - £45K',
      'popularity': 'Medium',
      'description': 'Computational methods in scientific research.',
      'url': 'https://www.cam.ac.uk/courses/natural-sciences',
    },
    // Mathematics
    {
      'name': 'Mathematical Tripos',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Mathematics',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'High',
      'description': 'Pure and applied mathematics program.',
      'url': 'https://www.cam.ac.uk/courses/mathematics',
    },
    {
      'name': 'Part III Mathematics',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Mathematics',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'High',
      'description': 'Advanced mathematics course.',
      'url': 'https://www.cam.ac.uk/courses/mathematics',
    },
    // Economics
    {
      'name': 'Economics Tripos',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Economics',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'High',
      'description': 'Comprehensive economics program.',
      'url': 'https://www.cam.ac.uk/courses/economics',
    },
    {
      'name': 'MPhil Economics',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Economics',
      'intake': 'Fall',
      'fee': '£37,632/year',
      'feeRange': '£35K - £45K',
      'popularity': 'High',
      'description': 'Advanced economic theory and research methods.',
      'url': 'https://www.cam.ac.uk/courses/economics',
    },
    // Business & Management
    {
      'name': 'MBA',
      'level': 'MBA',
      'duration': '1 year',
      'field': 'Business & Management',
      'intake': 'Fall',
      'fee': '£64,000/year',
      'feeRange': 'Above £45K',
      'popularity': 'Very High',
      'description': 'Full-time MBA program.',
      'url': 'https://www.jbs.cam.ac.uk/programmes/mba/',
    },
    {
      'name': 'MPhil Management',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Business & Management',
      'intake': 'Fall',
      'fee': '£45,000/year',
      'feeRange': '£35K - £45K',
      'popularity': 'High',
      'description': 'Research-focused management degree.',
      'url': 'https://www.jbs.cam.ac.uk/programmes/research-programmes/',
    },
    // Arts & Humanities
    {
      'name': 'English Tripos',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Arts & Humanities',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'High',
      'description': 'English literature and language studies.',
      'url': 'https://www.cam.ac.uk/courses/english',
    },
    {
      'name': 'MPhil European Literature',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Arts & Humanities',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'Medium',
      'description': 'Advanced study of European literary traditions.',
      'url': 'https://www.cam.ac.uk/courses/modern-languages',
    },
    // Psychology
    {
      'name': 'Psychological & Behavioural Sciences',
      'level': 'Undergraduate',
      'duration': '3 years',
      'field': 'Psychology',
      'intake': 'Fall',
      'fee': '£25,734/year',
      'feeRange': '£25K - £35K',
      'popularity': 'High',
      'description': 'Scientific study of mind and behavior.',
      'url': 'https://www.cam.ac.uk/courses/psychology',
    },
    {
      'name': 'MPhil Psychology',
      'level': 'Masters',
      'duration': '1 year',
      'field': 'Psychology',
      'intake': 'Fall',
      'fee': '£37,632/year',
      'feeRange': '£35K - £45K',
      'popularity': 'Medium',
      'description': 'Research methods in psychological sciences.',
      'url': 'https://www.cam.ac.uk/courses/psychology',
    },
  ];

  void _viewScholarship(Map<String, dynamic> scholarship) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 600,
              maxHeight: 700,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            scholarship['title'] ?? '',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Offered by
                    Text(
                      'Offered by ${scholarship['offeredBy'] ?? 'University of Cambridge'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Tags section
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Degree level chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            scholarship['degreeLevel'] ?? '',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        // Funding type chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.success.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${scholarship['funding']} Funding',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        // Type chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: Text(
                            scholarship['type'] ?? '',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      scholarship['description'] ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Information grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          // Fields of study
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.school, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fields of Study',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: (scholarship['fieldsOfStudy'] as List<String>? ?? [])
                                          .map((field) => Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.backgroundTertiary,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: AppColors.borderLight),
                                                ),
                                                child: Text(
                                                  field,
                                                  style: AppTextStyles.labelSmall.copyWith(
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Amount and deadline
                          Row(
                            children: [
                              Icon(Icons.monetization_on, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Amount',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      scholarship['amount'] ?? 'Amount varies',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: scholarship['deadlineStatus'] == 'Upcoming' 
                                      ? AppColors.success.withOpacity(0.1)
                                      : scholarship['deadlineStatus'] == 'Ongoing'
                                          ? AppColors.warning.withOpacity(0.1)
                                          : AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  scholarship['deadlineStatus'] ?? 'Check Website',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: scholarship['deadlineStatus'] == 'Upcoming' 
                                        ? AppColors.success
                                        : scholarship['deadlineStatus'] == 'Ongoing'
                                            ? AppColors.warning
                                            : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Eligibility
                    Text(
                      'Eligibility Requirements',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(scholarship['eligibility'] as List<String>? ?? [])
                        .map((requirement) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• ', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                  Expanded(
                                    child: Text(
                                      requirement,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    const SizedBox(height: 20),
                    
                    // Application process
                    Text(
                      'Application Process',
                      style: AppTextStyles.h5.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scholarship['applicationProcess'] ?? 'Please visit the official website for application details.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Official link button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final url = scholarship['url'];
                          if (url != null && url.isNotEmpty) {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.open_in_new, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Visit Official Page',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _viewCourse(String courseName) {
    final courseDetail = courses.firstWhere(
      (course) => course['name'] == courseName,
      orElse: () => {},
    );
    if (courseDetail.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(courseDetail['name'] ?? courseName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseDetail['description'] ?? ''),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchURL(courseDetail['url'] ?? ''),
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
                UniversityStatCard(
                  icon: Icons.language_outlined,
                  label: 'QS Score',
                  value: '98.8',
                  color: AppColors.info,
                ),
                UniversityStatCard(
                  icon: Icons.people_outline,
                  label: 'Students',
                  value: '24,000+',
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceM),
            const SectionHeader(
              title: 'Available Scholarships',
              icon: Icons.card_giftcard_outlined,
            ),
            const SizedBox(height: AppConstants.spaceM),
            
            // Scholarship Filter Tags
            ScholarshipFilterTags(
              selectedType: _selectedType,
              selectedFunding: _selectedFunding,
              selectedDegreeLevel: _selectedDegreeLevel,
              selectedDeadline: _selectedDeadline,
              onTypeChanged: _onTypeChanged,
              onFundingChanged: _onFundingChanged,
              onDegreeLevelChanged: _onDegreeLevelChanged,
              onDeadlineChanged: _onDeadlineChanged,
              onClearFilters: _clearScholarshipFilters,
            ),
            
            const SizedBox(height: AppConstants.spaceM),
            
            // Filtered Scholarships List
            SizedBox(
              height: 200,
              child: _filteredScholarships.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard_outlined,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppConstants.spaceS),
                          Text(
                            'No scholarships match your filters',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceS),
                          TextButton(
                            onPressed: _clearScholarshipFilters,
                            child: Text(
                              'Clear Filters',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceS),
                      itemCount: _filteredScholarships.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        width: AppConstants.spaceM,
                      ),
                      itemBuilder: (context, index) {
                        final scholarship = _filteredScholarships[index];
                        return ScholarshipCard(
                          title: scholarship['title']!,
                          onTap: () => _viewScholarship(scholarship),
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
            CourseFilterTags(
              selectedField: _selectedField,
              selectedLevel: _selectedLevel,
              selectedIntake: _selectedIntake,
              selectedFeeRange: _selectedFeeRange,
              onFieldChanged: _onFieldChanged,
              onLevelChanged: _onLevelChanged,
              onIntakeChanged: _onIntakeChanged,
              onFeeRangeChanged: _onFeeRangeChanged,
              onClearFilters: _clearCourseFilters,
            ),
            const SizedBox(height: AppConstants.spaceM),
            filteredCourses.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(AppConstants.spaceL),
                    child: Center(
                      child: Text(
                        'No courses match your filter criteria.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      return CourseCard(
                        courseName: course['name']!,
                        duration: course['duration']!,
                        fee: course['fee']!,
                        name: course['name']!,
                        level: course['level']!,
                        onTap: () => _viewCourse(course['name']!),
                      );
                    },
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
