import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchCtrl = TextEditingController();
  int? _expandedFaq;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _HelpHeader(searchCtrl: _searchCtrl),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _QuickActions(),
            ),
          ),

          // Popular topics
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Popular Topics', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  ..._topics.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TopicTile(topic: t),
                      )),
                ],
              ),
            ),
          ),

          // FAQs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FAQs', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: _faqs.asMap().entries.map((e) {
                        final i = e.key;
                        final faq = e.value;
                        final isExpanded = _expandedFaq == i;
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _expandedFaq = isExpanded ? null : i),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(faq.question,
                                          style: isExpanded
                                              ? AppTextStyles.h5.copyWith(
                                                  color: AppColors.primary)
                                              : AppTextStyles.h5),
                                    ),
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.25 : 0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: isExpanded
                                            ? AppColors.primary
                                            : AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Container(
                                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                child: Text(faq.answer, style: AppTextStyles.bodyMd.copyWith(height: 1.6)),
                              ),
                              secondChild: const SizedBox.shrink(),
                            ),
                            if (i < _faqs.length - 1) const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat with us
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: _ChatWithUs(),
            ),
          ),
        ],
      ),
    );
  }

  static final _topics = [
    _Topic("I want to cancel my ride", Icons.cancel_rounded, AppColors.error),
    _Topic("I have a payment issue", Icons.payment_rounded, AppColors.info),
    _Topic("I didn't receive my parcel", Icons.inventory_2_rounded, AppColors.primary),
    _Topic("Ride Preferences", Icons.tune_rounded, AppColors.warning),
    _Topic("General Safety", Icons.shield_rounded, AppColors.success),
    _Topic("I have charged more", Icons.monetization_on_rounded, AppColors.primary),
  ];

  static final _faqs = [
    _Faq(
      'How do I cancel a ride?',
      'You can cancel a ride by going to the active ride screen and tapping "Cancel Ride". Cancellation within 2 minutes of booking is free. After that, a small fee may apply.',
    ),
    _Faq(
      'How do I contact my driver?',
      'Once a driver is assigned, you can call or message them directly from the tracking screen using the Call or Message buttons.',
    ),
    _Faq(
      'What payment methods are accepted?',
      'We accept Cash, UPI (Google Pay, PhonePe, Paytm), Credit/Debit Cards, and BikeJee Wallet. You can manage your payment preferences in the Payments section.',
    ),
    _Faq(
      'How does the referral program work?',
      'Share your unique referral code with friends. When they take their first ride, you earn ₹50 in your wallet. Your friend gets ₹20 off on their first ride too!',
    ),
    _Faq(
      'What if my parcel is damaged?',
      'We take full responsibility for safe delivery. If your parcel is damaged, please raise a complaint within 24 hours of delivery with photos for a quick resolution.',
    ),
  ];
}

class _HelpHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  const _HelpHeader({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Text('Help & Support', style: AppTextStyles.h3White),
            ],
          ),
          const SizedBox(height: 16),
          Text('How can we help you?',
              style: AppTextStyles.bodyMdWhite),
          const SizedBox(height: 16),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: Colors.white54, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    style: AppTextStyles.bodyMdWhite,
                    decoration: InputDecoration(
                      hintText: 'Search for help...',
                      hintStyle: AppTextStyles.bodySm.copyWith(color: Colors.white38),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Chat', Icons.chat_bubble_rounded, AppColors.success),
      ('Call', Icons.call_rounded, AppColors.info),
      ('Email', Icons.email_rounded, AppColors.primary),
      ('FAQ', Icons.help_rounded, AppColors.primary),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Us', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) {
            return Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.only(right: a.$1 != 'FAQ' ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: a.$3.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: a.$3.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(a.$2, color: a.$3, size: 24),
                      const SizedBox(height: 6),
                      Text(a.$1, style: AppTextStyles.labelSm),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.greyBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Call Support', style: AppTextStyles.h5),
                  Text('080 1234 5678', style: AppTextStyles.bodyMd),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Call', style: AppTextStyles.btnMd),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopicTile extends StatelessWidget {
  final _Topic topic;
  const _TopicTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: topic.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(topic.icon, color: topic.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(topic.label, style: AppTextStyles.bodyLg)),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _ChatWithUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat with us', style: AppTextStyles.h4White),
                const SizedBox(height: 4),
                Text('We typically reply in\na few minutes.',
                    style: AppTextStyles.bodySmWhite),
                const SizedBox(height: 14),
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Start Chat', style: AppTextStyles.btnMd),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded,
                color: AppColors.success, size: 36),
          ),
        ],
      ),
    );
  }
}

class _Topic {
  final String label;
  final IconData icon;
  final Color color;
  const _Topic(this.label, this.icon, this.color);
}

class _Faq {
  final String question, answer;
  const _Faq(this.question, this.answer);
}
