import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'skeleton.dart';
import '../core/app_colors.dart';

/// Large circular gauge widget showing soil moisture percentage.
class MoistureGauge extends StatelessWidget {
  final double percentage; // 0.0 - 100.0
  final String status;
  final bool isLoading;

  const MoistureGauge({
    super.key,
    required this.percentage,
    required this.status,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = (percentage / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Background Tree Image
          Positioned(
            right: -200,
            bottom: -155,
            // top tidak perlu diisi agar tingginya tidak mengikuti tinggi card
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/tree.png',
                height: 450, // Set ukuran yang pas secara manual di sini
                fit: BoxFit.contain,
                // cacheHeight: 700, // Optimize memory decode
              ),
            ),
          ),

          // Foreground Content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Kelembaban Tanah',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                CircularPercentIndicator(
                  radius: 80,
                  lineWidth: 10,
                  percent: isLoading ? 0.0 : clampedPercent,
                  animation: !isLoading,
                  animationDuration: 1200,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.gaugeTrack,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading) ...[
                        const Skeleton(width: 80, height: 36, borderRadius: 6),
                        const SizedBox(height: 10),
                        const Skeleton(width: 60, height: 20, borderRadius: 20),
                      ] else ...[
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: GoogleFonts.outfit(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
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
