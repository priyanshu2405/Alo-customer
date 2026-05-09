import 'package:alo_ride_app/api_app_folder/res/common/app_appbar.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_button.dart';
import 'package:alo_ride_app/api_app_folder/res/common/app_text.dart';
import 'package:alo_ride_app/api_app_folder/res/constant/app_colors.dart';
import 'package:alo_ride_app/api_app_folder/screen/card/controller/card_controller.dart';
import 'package:alo_ride_app/api_app_folder/screen/card/view/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final CardController controller = Get.put(CardController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppAppBar(title: 'My Cards'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.getCards,
          color: AppColors.secondary,
          backgroundColor: AppColors.white,
          child: Obx(() {
            final isLoading = controller.isLoadingCards.value;
            final cards = controller.cards;

            if (isLoading && cards.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  backgroundColor:
                      AppColors.secondary.withOpacity(0.20),
                ),
              );
            }

            if (cards.isEmpty) return const _EmptyState();

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const Gap(16),
              itemBuilder: (_, i) {
                final card = cards[i];
                return _CardTile(
                  card: card,
                  onDelete: () => _confirmDelete(card),
                  onSetDefault: () => controller
                      .setDefaultCard(card['id']?.toString() ?? ''),
                );
              },
            );
          }),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            text: 'Add Card',
            onTap: () => Get.to(() => AddCardScreen())?.then((_) {
              controller.getCards();
            }),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> card) {
    final last4 = (card['last4'] ??
            card['last_four'] ??
            card['card_last4'] ??
            '')
        .toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DeleteSheet(
        last4: last4,
        onConfirm: () {
          Navigator.pop(context);
          controller.deleteCard(card['id']?.toString() ?? '');
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightGray, width: 1.5),
            ),
            child: const Icon(
              Icons.credit_card_off_outlined,
              size: 46,
              color: AppColors.secondary,
            ),
          ),
        ),
        const Gap(24),
        const AppText(
          text: 'No saved cards yet',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          textAlign: TextAlign.center,
        ),
        const Gap(10),
        const AppText(
          text: 'Save a card once and use it for\nfaster, hassle-free checkout.',
          fontSize: 14,
          color: AppColors.lightTextColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  final Map<String, dynamic> card;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _CardTile({
    required this.card,
    required this.onDelete,
    required this.onSetDefault,
  });

  String get _brand =>
      (card['brand'] ?? card['card_brand'] ?? 'CARD')
          .toString()
          .toUpperCase();

  String get _last4 => (card['last4'] ??
          card['last_four'] ??
          card['card_last4'] ??
          '')
      .toString();

  String get _maskedNumber =>
      _last4.isEmpty ? '•••• •••• •••• ••••' : '•••• •••• •••• $_last4';

  String get _expiry {
    final m = card['exp_month'] ?? card['expiry_month'];
    final y = card['exp_year'] ?? card['expiry_year'];
    if (m == null || y == null) return '--/--';
    final yy =
        y.toString().length == 4 ? y.toString().substring(2) : y.toString();
    return '${m.toString().padLeft(2, '0')}/$yy';
  }

  bool get _isDefault =>
      card['is_default'] == true || card['default'] == true;

  String get _addedOn {
    final raw = card['created_at']?.toString();
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.replaceAll(' ', 'T'));
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day.toString().padLeft(2, '0')} '
          '${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw.split(' ').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showCardOptions(context);
          },
          child: Hero(
            tag: 'card_${card['id'] ?? _last4}',
            child: Dismissible(
              key: Key(card['id']?.toString() ?? _last4),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                onDelete();
                return false;
              },
              background: const _SwipeBg(),
              child: _buildCardFace(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(
            children: const [
              Icon(
                Icons.touch_app_outlined,
                size: 12,
                color: AppColors.darkTextColor,
              ),
              Gap(4),
              AppText(
                text: 'Hold for options  •  Swipe left to remove',
                fontSize: 11,
                color: AppColors.darkTextColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFace() {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.secondary, AppColors.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.42),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -35,
              right: -35,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -45,
              left: -25,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              child: Icon(
                Icons.memory_rounded,
                color: AppColors.white.withOpacity(0.22),
                size: 28,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.white,
                      size: 32,
                    ),
                    if (_isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: AppColors.white,
                            ),
                            Gap(3),
                            AppText(
                              text: 'Default',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                AppText(
                  text: _maskedNumber,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  letterSpacing: 2.8,
                ),
                const Gap(14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: 'VALID THRU',
                          fontSize: 9,
                          color: AppColors.white.withOpacity(0.75),
                          letterSpacing: 1.3,
                        ),
                        const Gap(3),
                        AppText(
                          text: _expiry,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_addedOn.isNotEmpty)
                          AppText(
                            text: 'Added $_addedOn',
                            fontSize: 10,
                            color: AppColors.white.withOpacity(0.75),
                          ),
                        const Gap(2),
                        AppText(
                          text: _brand,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: 1.6,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: _brand,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    AppText(
                      text: '•••• •••• •••• $_last4',
                      fontSize: 13,
                      color: AppColors.lightTextColor,
                      letterSpacing: 1.2,
                    ),
                  ],
                ),
              ],
            ),
            const Gap(18),
            const Divider(color: AppColors.lightGray, height: 1),
            const Gap(6),
            if (!_isDefault)
              _OptionRow(
                icon: Icons.check_circle_outline_rounded,
                label: 'Set as Default',
                iconBg: AppColors.secondary.withOpacity(0.15),
                iconColor: AppColors.secondary,
                textColor: AppColors.black,
                onTap: () {
                  Navigator.pop(context);
                  onSetDefault();
                },
              ),
            _OptionRow(
              icon: Icons.delete_outline_rounded,
              label: 'Remove Card',
              iconBg: AppColors.pinkColor.withOpacity(0.10),
              iconColor: AppColors.pinkColor,
              textColor: AppColors.pinkColor,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const Gap(8),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: AppText(
                    text: 'Cancel',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.lightTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteSheet extends StatelessWidget {
  final String last4;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteSheet({
    required this.last4,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(22),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.pinkColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 32,
              color: AppColors.pinkColor,
            ),
          ),
          const Gap(14),
          AppText(
            text: last4.isEmpty
                ? 'Remove this card?'
                : 'Remove card ending in $last4?',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          const AppText(
            text: 'This action cannot be undone.',
            fontSize: 13,
            color: AppColors.lightTextColor,
            textAlign: TextAlign.center,
          ),
          const Gap(28),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: AppText(
                        text: 'Cancel',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextColor,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.pinkColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pinkColor.withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AppText(
                        text: 'Remove',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  const _SwipeBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: AppColors.pinkColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pinkColor.withOpacity(0.25)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.pinkColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const Gap(5),
          const AppText(
            text: 'Remove',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.pinkColor,
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const Gap(14),
            AppText(
              text: label,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: textColor.withOpacity(0.45),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
