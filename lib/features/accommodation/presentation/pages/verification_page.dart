import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/buttons/modern_buttons.dart';

/// Verification page for accommodation posting
class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isUploading = false;
  String? _uploadedFileName;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Account Verification',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Security Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.spaceXL),
                
                // Title and description
                Text(
                  '🔒 Protect Our Community',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.spaceM),
                
                Text(
                  'To protect our community, roommate and housing posts require verification. This helps us ensure all listings are from genuine students.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.spaceXL),
                
                // Upload Section
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceL),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Documents',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.spaceM),
                      
                      // Document options
                      _buildDocumentOption(
                        icon: Icons.school,
                        title: 'University Admission Letter',
                        description: 'Upload your official admission letter or acceptance email',
                        isRequired: true,
                      ),
                      
                      const SizedBox(height: AppConstants.spaceM),
                      
                      _buildDocumentOption(
                        icon: Icons.badge,
                        title: 'Student ID Card',
                        description: 'Photo of your current student ID (front side only)',
                        isRequired: true,
                      ),
                      
                      const SizedBox(height: AppConstants.spaceM),
                      
                      _buildDocumentOption(
                        icon: Icons.email,
                        title: '.edu Email Address',
                        description: 'Your university email for instant verification',
                        isRequired: false,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.spaceXL),
                
                // Upload Area
                GestureDetector(
                  onTap: _handleDocumentUpload,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spaceXL),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _uploadedFileName != null ? Icons.check_circle : Icons.cloud_upload,
                          size: 48,
                          color: _uploadedFileName != null ? AppColors.success : AppColors.primary,
                        ),
                        
                        const SizedBox(height: AppConstants.spaceM),
                        
                        Text(
                          _uploadedFileName ?? 'Tap to upload documents',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _uploadedFileName != null ? AppColors.success : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: AppConstants.spaceS),
                        
                        Text(
                          'Supported formats: PDF, JPG, PNG (Max 5MB)',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.spaceXL),
                
                // Submit Button
                PrimaryButton(
                  text: _isUploading ? 'Submitting...' : 'Submit for Review',
                  isExpanded: true,
                  size: ButtonSize.large,
                  isLoading: _isUploading,
                  onPressed: _uploadedFileName != null ? _handleSubmit : null,
                ),
                
                const SizedBox(height: AppConstants.spaceM),
                
                // Info text
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.spaceS),
                      Expanded(
                        child: Text(
                          'Review typically takes 24-48 hours. You\'ll receive a notification once approved.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentOption({
    required IconData icon,
    required String title,
    required String description,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppConstants.spaceM),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: AppConstants.spaceXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Required',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleDocumentUpload() async {
    // Simulate file upload
    setState(() {
      _isUploading = true;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isUploading = false;
      _uploadedFileName = 'admission_letter.pdf';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Document uploaded successfully!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleSubmit() async {
    setState(() {
      _isUploading = true;
    });
    
    // Simulate submission
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate successful submission
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification submitted! You\'ll receive a notification once approved.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary,
            ),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
