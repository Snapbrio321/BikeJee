import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class RideOptionsScreen extends StatefulWidget {
  final VoidCallback? onSelectBike;
  final VoidCallback? onSelectParcel;
  final VoidCallback? onBack;

  const RideOptionsScreen({
    super.key,
    this.onSelectBike,
    this.onSelectParcel,
    this.onBack,
  });

  @override
  State<RideOptionsScreen> createState() => _RideOptionsScreenState();
}

class _RideOptionsScreenState extends State<RideOptionsScreen> {
  int _selectedIndex = 0;

  final _rideOptions = [
    _RideOpt(
      'Bike',
      '1–10 min',
      'Best for short rides',
      Icons.electric_bike_rounded,
      AppColors.primary,
      AppColors.bikeCardBg,
    ),
    _RideOpt(
      'Auto',
      '3–15 min',
      'Affordable auto rides',
      Icons.airport_shuttle_rounded,
      AppColors.info,
      AppColors.autoCardBg,
    ),
    _RideOpt(
      'Parcel',
      '1–5 min',
      'Door to Door Delivery',
      Icons.inventory_2_rounded,
      AppColors.primary,
      AppColors.parcelCardBg,
    ),
    _RideOpt(
      'Cab',
      '4–20 min',
      'Coming Soon',
      Icons.local_taxi_rounded,
      AppColors.success,
      AppColors.cabCardBg,
      comingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select a Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          // Service Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Service cards grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _rideOptions.length,
                    itemBuilder: (ctx, i) {
                      final opt = _rideOptions[i];
                      final isSelected = _selectedIndex == i;
                      return GestureDetector(
                        onTap: opt.comingSoon
                            ? null
                            : () => setState(() => _selectedIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? opt.iconColor.withOpacity(0.1)
                                : AppColors.cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? opt.iconColor
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 0.8,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: opt.iconColor.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: opt.bgColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(opt.icon,
                                        color: opt.iconColor, size: 26),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: opt.iconColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 13),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Text(opt.name, style: AppTextStyles.h4),
                              const SizedBox(height: 2),
                              Text(opt.eta,
                                  style: AppTextStyles.bodyMd.copyWith(
                                      color: opt.iconColor,
                                      fontWeight: FontWeight.w600)),
                              Text(opt.sublabel, style: AppTextStyles.bodySm),
                              if (opt.comingSoon) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.textLight.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Coming Soon',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textLight),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: AppGradientButton(
              label: 'Continue with ${_rideOptions[_selectedIndex].name}',
              onTap: () {
                if (_selectedIndex == 2) {
                  widget.onSelectParcel?.call();
                } else {
                  widget.onSelectBike?.call();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RideOpt {
  final String name, eta, sublabel;
  final IconData icon;
  final Color iconColor, bgColor;
  final bool comingSoon;
  const _RideOpt(this.name, this.eta, this.sublabel, this.icon, this.iconColor,
      this.bgColor,
      {this.comingSoon = false});
}
