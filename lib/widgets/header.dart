import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class Header extends StatelessWidget {
  final String repoLabel;
  final bool isLive;
  final int documentedCount;
  final ValueListenable<int> pulseTrigger;

  const Header({
    super.key,
    required this.repoLabel,
    required this.isLive,
    required this.documentedCount,
    required this.pulseTrigger,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                alignment: Alignment.center,
                child: Text(
                  'AD',
                  style: GoogleFonts.ibmPlexMono(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سجل التوثيق',
                    style: GoogleFonts.fraunces(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Auto Docs · n8n workflow',
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                repoLabel,
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              LiveIndicator(isLive: isLive, pulseTrigger: pulseTrigger),
            ],
          ),
          const SizedBox(height: 18),
          _CountUpStat(count: documentedCount),
        ],
      ),
    );
  }
}

class _CountUpStat extends StatelessWidget {
  final int count;
  const _CountUpStat({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: count),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Text(
              '$value',
              style: GoogleFonts.ibmPlexMono(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        Text(
          'ملف تم توثيقه',
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// نقطة الحالة "live" بالهيدر:
/// - نبضة هادئة مستمرة (breathing) طول الوقت
/// - نبضة أقوى لمرة واحدة عبر [pulseTrigger] كل ما توصل عملية جديدة فعليًا
class LiveIndicator extends StatefulWidget {
  final bool isLive;
  final ValueListenable<int> pulseTrigger;

  const LiveIndicator({
    super.key,
    required this.isLive,
    required this.pulseTrigger,
  });

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    widget.pulseTrigger.addListener(_pulseOnce);
  }

  void _pulseOnce() => _burstController.forward(from: 0);

  @override
  void dispose() {
    widget.pulseTrigger.removeListener(_pulseOnce);
    _breathController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isLive ? AppColors.successText : AppColors.failedText;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _burstController]),
      builder: (context, _) {
        final breathScale = 1.0 + (_breathController.value * 0.35);
        final breathOpacity = (1 - _breathController.value) * 0.5;

        final burstT = _burstController.value;
        final burstScale = 1.0 + (burstT * 1.4);
        final burstOpacity = burstT == 0 ? 0.0 : (1 - burstT) * 0.9;

        return SizedBox(
          width: 22,
          height: 22,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isLive)
                Transform.scale(
                  scale: burstScale,
                  child: Opacity(
                    opacity: burstOpacity,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                ),
              if (widget.isLive)
                Transform.scale(
                  scale: breathScale,
                  child: Opacity(
                    opacity: breathOpacity,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }
}