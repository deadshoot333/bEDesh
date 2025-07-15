import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common/section_header.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        "question": "What is the process to study in UK?",
        "answer": "The process includes choosing a course and university, checking entry requirements, applying through UCAS (for undergraduate) or directly to universities (for postgraduate), obtaining student visa, and arranging accommodation."
      },
      {
        "question": "How much money is required to study in UK?",
        "answer": "The total cost varies by university and city, but typically ranges from £10,000 to £38,000 per year for tuition. Additionally, you need at least £1,023 per month for living expenses outside London and £1,334 per month in London."
      },
      {
        "question": "Can I get a permanent residency in UK after my studies?",
        "answer": "Yes, after completing your studies, you can apply for a 2-year Graduate Route visa (3 years for PhD graduates). With skilled employment, you may later qualify for a Skilled Worker visa and eventually permanent residency (Indefinite Leave to Remain) after 5 years of continuous residence."
      },
      {
        "question": "What are the English language requirements?",
        "answer": "Most universities require IELTS score of 6.0-7.5 overall (depending on the course), with minimum scores in each component. Alternative tests like TOEFL, PTE Academic, or Cambridge English may also be accepted."
      },
      {
        "question": "Can I work while studying in the UK?",
        "answer": "Yes, with a Student visa you can work up to 20 hours per week during term time and full-time during holidays. Some work placements and internships may have different rules."
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Frequently Asked Questions',
          icon: Icons.question_answer_outlined,
        ),
        const SizedBox(height: AppConstants.spaceM),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              final isLast = index == faqs.length - 1;

              return Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceL,
                        vertical: AppConstants.spaceXS,
                      ),
                      childrenPadding: const EdgeInsets.only(
                        left: AppConstants.spaceL,
                        right: AppConstants.spaceL,
                        bottom: AppConstants.spaceM,
                      ),
                      title: Text(
                        faq["question"]!,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      iconColor: AppColors.primary,
                      collapsedIconColor: AppColors.textSecondary,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(AppConstants.spaceM),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundSecondary.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            child: Text(
                              faq["answer"]!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      color: AppColors.borderLight,
                      height: 1,
                      indent: AppConstants.spaceL,
                      endIndent: AppConstants.spaceL,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
