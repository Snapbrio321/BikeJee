import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_map_placeholder.dart';
import '../../../core/widgets/app_text_field.dart';

class ParcelDeliveryScreen extends StatefulWidget {
  final VoidCallback? onBooked;
  final VoidCallback? onBack;

  const ParcelDeliveryScreen({super.key, this.onBooked, this.onBack});

  @override
  State<ParcelDeliveryScreen> createState() => _ParcelDeliveryScreenState();
}

class _ParcelDeliveryScreenState extends State<ParcelDeliveryScreen> {
  final _pickupCtrl = TextEditingController(text: 'Koramangala, Bangalore');
  final _dropCtrl = TextEditingController();
  final _instrCtrl = TextEditingController();
  String _selectedType = 'Document / Paper';
  String _selectedWeight = 'Upto 1kg';
  bool _showEstimate = false;

  final _parcelTypes = [
    ('Document / Paper', Icons.description_rounded),
    ('Clothes', Icons.checkroom_rounded),
    ('Electronics', Icons.devices_rounded),
    ('Food', Icons.fastfood_rounded),
    ('Other', Icons.inventory_2_rounded),
  ];

  final _weights = ['Upto 1kg', '1–5 kg', '5–10 kg', '10+ kg'];

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropCtrl.dispose();
    _instrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Parcel Delivery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: Stack(
        children: [
          // Map preview
          const SizedBox(
            height: 200,
            child: AppMapPlaceholder(height: 200, showRoute: false),
          ),
          // Content
          DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.55,
            maxChildSize: 0.96,
            builder: (ctx, sc) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))
                  ],
                ),
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.border, borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Text('Parcel Delivery', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text('Door to Door Delivery · Send anything', style: AppTextStyles.bodyMd),
                    const SizedBox(height: 20),

                    // Route
                    _RouteInputCard(pickupCtrl: _pickupCtrl, dropCtrl: _dropCtrl),
                    const SizedBox(height: 16),

                    // Parcel Type
                    Text('Parcel Type', style: AppTextStyles.h5),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _parcelTypes.length,
                        itemBuilder: (_, i) {
                          final t = _parcelTypes[i];
                          final isSelected = _selectedType == t.$1;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = t.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.greyBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(t.$2,
                                    color: isSelected ? AppColors.primary : AppColors.textMedium,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.$1.split(' ').first,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: isSelected ? AppColors.primary : AppColors.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Weight
                    Text('Weight', style: AppTextStyles.h5),
                    const SizedBox(height: 10),
                    Row(
                      children: _weights.map((w) {
                        final isSelected = _selectedWeight == w;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedWeight = w;
                              _showEstimate = true;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: EdgeInsets.only(right: w != _weights.last ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.greyBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.5 : 0.8,
                                ),
                              ),
                              child: Text(
                                w,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: isSelected ? AppColors.primary : AppColors.textMedium,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Instructions
                    AppTextField(
                      hint: 'Add instructions (optional)',
                      label: 'Delivery Instructions',
                      controller: _instrCtrl,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),

                    // Fare Estimate
                    if (_showEstimate) ...[
                      AppCard(
                        color: AppColors.greyBg,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Fare Estimate', style: AppTextStyles.h5),
                                Text('₹60', style: AppTextStyles.priceSmall.copyWith(color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            _FareRow('Base Fare', '₹40'),
                            _FareRow('Weight Charge', '₹15'),
                            _FareRow('Service Fee', '₹5'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AppGradientButton(
                      label: 'Book Parcel',
                      onTap: widget.onBooked,
                      prefixIcon: Icons.inventory_2_rounded,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RouteInputCard extends StatelessWidget {
  final TextEditingController pickupCtrl, dropCtrl;
  const _RouteInputCard({required this.pickupCtrl, required this.dropCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _LocationRow(
            icon: Icons.radio_button_checked_rounded,
            iconColor: AppColors.mapPickup,
            hint: 'Pickup Location',
            controller: pickupCtrl,
          ),
          const Divider(height: 1, indent: 48),
          _LocationRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.mapDrop,
            hint: 'Drop Location',
            controller: dropCtrl,
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String hint;
  final TextEditingController controller;
  const _LocationRow({
    required this.icon, required this.iconColor,
    required this.hint, required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label, value;
  const _FareRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd),
          Text(value, style: AppTextStyles.labelLg),
        ],
      ),
    );
  }
}
