import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rating_stars.dart';

class DriverProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const DriverProfileScreen({super.key, this.onLogout});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabCtrl,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMedium,
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                tabs: const [
                  Tab(text: 'Profile'),
                  Tab(text: 'My Vehicle'),
                  Tab(text: 'Documents'),
                  Tab(text: 'Settings'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _ProfileTab(onLogout: widget.onLogout),
            const _VehicleTab(),
            const _DocumentsTab(),
            const _SettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 24, height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Arjun Kumar', style: AppTextStyles.h3White),
                const SizedBox(height: 4),
                Text('+91 98765-43210', style: AppTextStyles.bodySmWhite),
                const SizedBox(height: 2),
                Text('KA 03 JE 1234', style: AppTextStyles.caption.copyWith(color: Colors.white54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    RatingStars(rating: 4.8, size: 14, color: AppColors.starColor),
                    const SizedBox(width: 5),
                    Text('4.8', style: AppTextStyles.caption.copyWith(color: AppColors.starColor)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Active',
                          style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final VoidCallback? onLogout;
  const _ProfileTab({this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MenuSection(title: 'Personal Information', items: [
          _MItem(Icons.person_rounded, 'Personal Information', AppColors.primary),
          _MItem(Icons.directions_car_rounded, 'Vehicle Information', AppColors.info),
          _MItem(Icons.account_balance_rounded, 'Bank Details', AppColors.success),
          _MItem(Icons.lock_rounded, 'Change Password', AppColors.primary),
        ]),
        const SizedBox(height: 16),
        _MenuSection(title: 'Earnings & Trips', items: [
          _MItem(Icons.receipt_long_rounded, 'My Trips', AppColors.primary),
          _MItem(Icons.star_rounded, 'Incentives & Bonuses', AppColors.warning),
          _MItem(Icons.bar_chart_rounded, 'Ratings', AppColors.success),
        ]),
        const SizedBox(height: 16),
        _MenuSection(title: 'App', items: [
          _MItem(Icons.headset_mic_rounded, 'Support', AppColors.info),
          _MItem(Icons.settings_rounded, 'Settings', AppColors.textMedium),
        ]),
        const SizedBox(height: 20),
        AppButton(
          label: 'Logout',
          variant: AppButtonVariant.outline,
          customColor: AppColors.error,
          onTap: onLogout,
          prefixIcon: Icons.logout_rounded,
          height: 50,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _VehicleTab extends StatelessWidget {
  const _VehicleTab();

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('Vehicle Type', 'Bike'),
      ('Make & Model', 'Honda Activa'),
      ('Vehicle Number', 'KA 03 JE 1234'),
      ('RC Number', 'KA 03 2021 1234567'),
      ('Color', 'Black'),
      ('Year', '2021'),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryLight]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.electric_bike_rounded, color: AppColors.primary, size: 56),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Honda Active', style: AppTextStyles.h4White),
                  Text('KA 03 JE 1234', style: AppTextStyles.bodyMdWhite),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('✓ Verified',
                        style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: fields.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(f.$1, style: AppTextStyles.bodyMd)),
                  Text(f.$2, style: AppTextStyles.labelLg),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();

  static final _docs = [
    ('Driving License', '15 Dec 2024', true),
    ('RC Book', '20 Jun 2025', true),
    ('Insurance', '12 Jan 2025', true),
    ('Pollution Certificate', '30 Nov 2024', true),
    ('Aadhaar Card', '—', false),
    ('PAN Card', '—', false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 10),
              Text('All documents verified ✓',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: _docs.asMap().entries.map((e) {
              final doc = e.value;
              final isVerified = doc.$3;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: (isVerified ? AppColors.success : AppColors.textLight)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isVerified ? Icons.description_rounded : Icons.upload_file_rounded,
                            color: isVerified ? AppColors.success : AppColors.textLight,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.$1, style: AppTextStyles.bodyLg),
                              if (doc.$2 != '—')
                                Text('Expiry: ${doc.$2}', style: AppTextStyles.bodySm),
                            ],
                          ),
                        ),
                        if (isVerified)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 20)
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Upload',
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                          ),
                      ],
                    ),
                  ),
                  if (e.key < _docs.length - 1)
                    const Divider(height: 1, indent: 62),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  bool _incomingSound = true;
  bool _tripNotif = true;
  // ignore: prefer_final_fields
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SwitchTile(
                icon: Icons.volume_up_rounded,
                label: 'Incoming Request Sound',
                color: AppColors.primary,
                value: _incomingSound,
                onChanged: (v) => setState(() => _incomingSound = v),
              ),
              const Divider(height: 1, indent: 62),
              _SwitchTile(
                icon: Icons.notifications_active_rounded,
                label: 'Trip Notifications',
                color: AppColors.info,
                value: _tripNotif,
                onChanged: (v) => setState(() => _tripNotif = v),
              ),
              const Divider(height: 1, indent: 62),
              _SelectTile(
                icon: Icons.language_rounded,
                label: 'Language',
                value: _language,
                color: AppColors.success,
                onTap: () {},
              ),
              const Divider(height: 1, indent: 62),
              _SelectTile(
                icon: Icons.privacy_tip_rounded,
                label: 'Privacy Policy',
                value: '',
                color: AppColors.textMedium,
                onTap: () {},
              ),
              const Divider(height: 1, indent: 62),
              _SelectTile(
                icon: Icons.article_rounded,
                label: 'Terms & Conditions',
                value: '',
                color: AppColors.textMedium,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool value;
  final Function(bool) onChanged;
  const _SwitchTile({
    required this.icon, required this.label, required this.color,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyLg)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final VoidCallback onTap;
  const _SelectTile({
    required this.icon, required this.label, required this.value,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyLg)),
            if (value.isNotEmpty)
              Text(value, style: AppTextStyles.labelMd.copyWith(color: AppColors.textMedium)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h5.copyWith(color: AppColors.textLight)),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: item.color, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item.label, style: AppTextStyles.bodyLg)),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 13, color: AppColors.textLight),
                        ],
                      ),
                    ),
                  ),
                  if (e.key < items.length - 1)
                    const Divider(height: 1, indent: 62),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MItem {
  final IconData icon;
  final String label;
  final Color color;
  const _MItem(this.icon, this.label, this.color);
}
