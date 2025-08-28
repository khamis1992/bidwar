import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> earnings;

  const EarningsChartWidget({
    Key? key,
    required this.earnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareChartData();

    if (chartData.isEmpty) {
      return Container(
        height: 200.0,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48.0,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12.0),
              Text(
                'No earnings data available',
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 220.0,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last 7 Days',
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${_getTotalEarnings()} credits',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue() / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1.0,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.0,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: GoogleFonts.inter(
                          fontSize: 10.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30.0,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < chartData.length) {
                          return Text(
                            chartData[index]['day'],
                            style: GoogleFonts.inter(
                              fontSize: 10.0,
                              color: Colors.grey.shade600,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: 0,
                maxX: (chartData.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxValue() * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(),
                          entry.value['earnings'].toDouble());
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    barWidth: 3.0,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4.0,
                        color: Colors.blue.shade600,
                        strokeWidth: 2.0,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade100.withAlpha(77),
                          Colors.blue.shade50.withAlpha(26),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blue.shade600,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()} credits',
                          GoogleFonts.inter(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _prepareChartData() {
    if (earnings.isEmpty) return [];

    // Group earnings by day for the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return {
        'day': _getDayLabel(date),
        'date': date,
        'earnings': 0,
      };
    });

    // Add earnings to corresponding days
    for (final earning in earnings) {
      final earnedAt = DateTime.parse(earning['earned_at'] as String);
      for (final dayData in last7Days) {
        if (_isSameDay(earnedAt, dayData['date'] as DateTime)) {
          dayData['earnings'] = (dayData['earnings'] as int) + (earning['commission_amount'] as int? ?? 0);
          break;
        }
      }
    }

    return last7Days;
  }

  String _getDayLabel(DateTime date) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[date.weekday % 7];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  double _getMaxValue() {
    final chartData = _prepareChartData();
    if (chartData.isEmpty) return 100.0;

    final maxEarning = chartData
        .map<int>((data) => data['earnings'] as int)
        .reduce((a, b) => a > b ? a : b);

    return maxEarning > 0 ? maxEarning.toDouble() : 100.0;
  }

  int _getTotalEarnings() {
    return _prepareChartData()
        .map<int>((data) => data['earnings'] as int)
        .fold(0, (sum, earnings) => sum + earnings);
  }
}