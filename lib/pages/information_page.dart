import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/app_colors.dart';
import '../widgets/sensor_card.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/skeleton.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  bool _isRefreshing = false;
  Key _animKey = UniqueKey();

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await FirebaseDatabase.instance.ref('soil_monitoring/realtime').get();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _animKey = UniqueKey();
      });
    }
  }

  String _formatFirebaseTimestamp(String? timestampStr) {
    if (timestampStr == null || timestampStr.isEmpty) {
      return '15 Juli 2026, 12:02'; // Default fallback
    }
    try {
      // Expected format: YYYY-MM-DD_HH-mm-ss (e.g. 2026-07-15_12-02-29)
      final parts = timestampStr.split('_');
      if (parts.length < 2) return timestampStr;

      final dateParts = parts[0].split('-');
      final timeParts = parts[1].split('-');

      if (dateParts.length < 3 || timeParts.length < 2) return timestampStr;

      final year = dateParts[0];
      final monthNum = int.tryParse(dateParts[1]);
      final day = int.tryParse(dateParts[2])?.toString() ?? dateParts[2];

      final hour = timeParts[0];
      final minute = timeParts[1];

      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];

      String monthName = dateParts[1];
      if (monthNum != null && monthNum >= 1 && monthNum <= 12) {
        monthName = months[monthNum - 1];
      }

      return '$day $monthName $year, $hour:$minute';
    } catch (e) {
      return timestampStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('soil_monitoring/realtime').onValue,
      builder: (context, snapshot) {
        final bool isDataLoading =
            (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData ||
                snapshot.data?.snapshot.value == null);

        double phVal = 6.5;
        double moistureVal = 65.0;
        double ecVal = 1.2;
        double rainfallVal = 120.0;
        String weatherDesc = 'Mendung ☁️';
        int rainProb = 20;
        String weather3DaysStr = 'Mendung ☁️ | Mendung ☁️ | Sebagian Cerah 🌤️';
        String rawTimestamp = '2026-07-15_12-02-29';

        if (!isDataLoading) {
          final data = snapshot.data!.snapshot.value;
          if (data is Map) {
            final ph = data['ph'];
            if (ph is num) phVal = ph.toDouble();

            final moisture = data['moisture'];
            if (moisture is num) moistureVal = moisture.toDouble();

            final ec = data['ec'];
            if (ec is num) ecVal = ec.toDouble();

            final rainfall = data['weather_rainfall_mm'];
            if (rainfall is num) rainfallVal = rainfall.toDouble();

            final desc = data['weather_description'];
            if (desc is String) weatherDesc = desc;

            final prob = data['weather_rain_probability'];
            if (prob is num) rainProb = prob.toInt();

            final desc3d = data['weather_description_3days'];
            if (desc3d is String) weather3DaysStr = desc3d;

            final ts = data['timestamp'];
            if (ts is String) rawTimestamp = ts;
          }
        }

        // pH Status
        String phStatus = 'Normal';
        Color phStatusColor = AppColors.primary;
        if (phVal < 6.0) {
          phStatus = 'Asam';
          phStatusColor = AppColors.accent;
        } else if (phVal > 7.0) {
          phStatus = 'Basa';
          phStatusColor = AppColors.accent;
        }

        // Moisture Status
        String moistureStatus = 'Cukup';
        Color moistureStatusColor = AppColors.primary;
        if (moistureVal < 40) {
          moistureStatus = 'Kurang';
          moistureStatusColor = AppColors.accent;
        } else if (moistureVal > 75) {
          moistureStatus = 'Basah';
          moistureStatusColor = AppColors.accent;
        }

        // EC Status
        String ecStatus = 'Sedang';
        Color ecStatusColor = AppColors.accent;
        if (ecVal < 0.8) {
          ecStatus = 'Rendah';
          ecStatusColor = AppColors.accent;
        } else if (ecVal > 2.0) {
          ecStatus = 'Tinggi';
          ecStatusColor = AppColors.accent;
        } else {
          ecStatus = 'Sedang';
          ecStatusColor = AppColors.primary;
        }

        // Rainfall Status
        String rainfallStatus = 'Normal';
        Color rainfallStatusColor = AppColors.primary;
        if (rainfallVal == 0) {
          rainfallStatus = 'Tidak Hujan';
        } else if (rainfallVal > 50) {
          rainfallStatus = 'Tinggi';
          rainfallStatusColor = AppColors.accent;
        } else if (rainfallVal < 20) {
          rainfallStatus = 'Rendah';
        } else {
          rainfallStatus = 'Sedang';
        }

        final formattedTime = _formatFirebaseTimestamp(rawTimestamp);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Informasi',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: _isRefreshing ? null : _onRefresh,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isRefreshing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          )
                        : Icon(
                            Iconsax.refresh,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              key: _animKey,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLastUpdated(formattedTime, isDataLoading),
                  AnimatedListItem(
                    index: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        'Data Sensor',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  AnimatedListItem(
                    index: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: SensorCard(
                            icon: Iconsax.drop,
                            label: 'pH Tanah',
                            value: phVal.toStringAsFixed(1),
                            unit: 'pH',
                            status: phStatus,
                            statusColor: phStatusColor,
                            highlightMode: SensorHighlightMode.value,
                            isLoading: isDataLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SensorCard(
                            icon: Iconsax.cloud_drizzle,
                            label: 'Kelembaban',
                            value: moistureVal.toStringAsFixed(0),
                            unit: '%',
                            status: moistureStatus,
                            statusColor: moistureStatusColor,
                            highlightMode: SensorHighlightMode.value,
                            isLoading: isDataLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedListItem(
                    index: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: SensorCard(
                            icon: Iconsax.flash_1,
                            label: 'EC Tanah',
                            value: ecVal.toStringAsFixed(3),
                            unit: 'mS/cm',
                            status: ecStatus,
                            statusColor: ecStatusColor,
                            highlightMode: SensorHighlightMode.value,
                            isLoading: isDataLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SensorCard(
                            icon: Iconsax.cloud_sunny,
                            label: 'Curah Hujan',
                            value: rainfallVal.toStringAsFixed(0),
                            unit: 'mm',
                            status: rainfallStatus,
                            statusColor: rainfallStatusColor,
                            highlightMode: SensorHighlightMode.value,
                            isLoading: isDataLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedListItem(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 14),
                      child: Text(
                        'Informasi Cuaca',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  AnimatedListItem(
                    index: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Iconsax.cloud_sunny,
                                        color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cuaca Saat Ini',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (isDataLoading)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Skeleton(
                                              width: 100,
                                              height: 16,
                                              borderRadius: 4),
                                        )
                                      else
                                        Text(
                                          weatherDesc,
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Peluang Hujan',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (isDataLoading)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Skeleton(
                                          width: 40,
                                          height: 16,
                                          borderRadius: 4),
                                    )
                                  else
                                    Text(
                                      '$rainProb%',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: AppColors.divider),
                          ),
                          Text(
                            'Prakiraan 3 Hari Ke Depan',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: () {
                                if (isDataLoading) {
                                  return List.generate(3, (idx) {
                                    return Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: idx == 2 ? 0 : 8,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.gaugeTrack
                                              .withValues(alpha: 0.3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Column(
                                          children: [
                                            Skeleton(
                                                width: 40,
                                                height: 10,
                                                borderRadius: 4),
                                            SizedBox(height: 8),
                                            Skeleton(
                                                width: 60,
                                                height: 14,
                                                borderRadius: 4),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                }

                                final days = weather3DaysStr.split('|');
                                return List.generate(days.length, (idx) {
                                  final dayForecast = days[idx].trim();
                                  return Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: idx == days.length - 1 ? 0 : 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.gaugeTrack
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Hari ${idx + 1}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textTertiary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            dayForecast,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              }(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLastUpdated(String formattedTime, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 4),
      child: Row(
        children: [
          Icon(Iconsax.clock, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 6),
          if (isLoading)
            const Skeleton(width: 180, height: 14, borderRadius: 4)
          else
            Text(
              'Terakhir diperbaharui: $formattedTime',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
