import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/step_indicator.dart';

class DriverCreateProfileScreen extends StatefulWidget {
  final VoidCallback onDone;
  final VoidCallback? onBack;
  const DriverCreateProfileScreen({super.key, required this.onDone, this.onBack});

  @override
  State<DriverCreateProfileScreen> createState() => _DriverCreateProfileScreenState();
}

class _DriverCreateProfileScreenState extends State<DriverCreateProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  String _vehicleType = 'Bike';

  final _vehicles = [
    ('Bike', Icons.electric_bike_rounded, AppColors.primary),
    ('Auto', Icons.airport_shuttle_rounded, AppColors.info),
    ('Cab', Icons.local_taxi_rounded, AppColors.success),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Step indicator
            StepProgressIndicator(
              currentStep: 2,
              totalSteps: 3,
              labels: ['Login', 'Verify', 'Profile'],
            ),
            const SizedBox(height: 32),

            // Avatar picker
            Stack(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.darkGradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 52),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Form
            AppTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameCtrl,
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: AppColors.textLight, size: 20),
            ),
            const SizedBox(height: 16),

            // Vehicle type
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vehicle Type', style: AppTextStyles.h5),
                const SizedBox(height: 10),
                Row(
                  children: _vehicles.map((v) {
                    final isSelected = _vehicleType == v.$1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _vehicleType = v.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: v.$1 != 'Cab' ? 10 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? v.$3.withOpacity(0.1) : AppColors.greyBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? v.$3 : AppColors.border,
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(v.$2,
                                  color: isSelected ? v.$3 : AppColors.textLight, size: 26),
                              const SizedBox(height: 5),
                              Text(v.$1,
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: isSelected ? v.$3 : AppColors.textMedium,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            AppTextField(
              label: 'Vehicle Number',
              hint: 'e.g. KA 03 JE 1234',
              controller: _plateCtrl,
              prefixIcon: const Icon(Icons.confirmation_number_rounded,
                  color: AppColors.textLight, size: 20),
            ),

            const SizedBox(height: 28),

            // Info note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.info, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your documents will be verified within 24 hours before you can start riding.',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            AppGradientButton(
              label: 'Continue',
              onTap: () async {
                await Future.delayed(const Duration(milliseconds: 800));
                if (mounted) widget.onDone();
              },
              gradient: AppColors.darkGradient,
            ),
          ],
        ),
      ),
    );
  }
}
