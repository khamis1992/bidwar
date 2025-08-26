import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> auctionData;
  final List<Map<String, dynamic>> userEngagementData;

  const ActivityChartWidget({
    Key? key,
    required this.auctionData,
    required this.userEngagementData,
  }) : super(key: key);

  @override
  State<ActivityChartWidget> createState() => _ActivityChartWidgetState();
}

class _ActivityChartWidgetState extends State<ActivityChartWidget> {
  String selectedTab = 'Auctions';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            spreadRadius: 0,
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
                'Activity Analytics',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1E3D),
                ),
              ),
              Row(
                children: [
                  _buildTabButton('Auctions'),
                  SizedBox(width: 1.w),
                  _buildTabButton('Users'),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 300,
            child: selectedTab == 'Auctions'
                ? _buildAuctionChart()
                : _buildUserEngagementChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionChart() {
    if (widget.auctionData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 1.h),
            Text(
              'No auction data available',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Process auction data for chart
    final chartData = _processAuctionDataForChart();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.inter(fontSize: 10.sp),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(
                  days[value.toInt() % 7],
                  style: GoogleFonts.inter(fontSize: 10.sp),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            color: Colors.blue.shade600,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.shade100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserEngagementChart() {
    if (widget.userEngagementData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 1.h),
            Text(
              'No user engagement data available',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Process user engagement data for chart
    final chartData = _processUserEngagementDataForChart();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.inter(fontSize: 10.sp),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(
                  days[value.toInt() % 7],
                  style: GoogleFonts.inter(fontSize: 10.sp),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData,
      ),
    );
  }

  List<FlSpot> _processAuctionDataForChart() {
    final Map<int, int> dailyCounts = {};
    final now = DateTime.now();

    for (var auction in widget.auctionData) {
      final createdAt = DateTime.parse(auction['created_at']);
      final daysDiff = now.difference(createdAt).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        dailyCounts[6 - daysDiff] = (dailyCounts[6 - daysDiff] ?? 0) + 1;
      }
    }

    return List.generate(7, (index) {
      return FlSpot(index.toDouble(), (dailyCounts[index] ?? 0).toDouble());
    });
  }

  List<BarChartGroupData> _processUserEngagementDataForChart() {
    final Map<int, int> dailyCounts = {};
    final now = DateTime.now();

    for (var bid in widget.userEngagementData) {
      final placedAt = DateTime.parse(bid['placed_at']);
      final daysDiff = now.difference(placedAt).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        dailyCounts[6 - daysDiff] = (dailyCounts[6 - daysDiff] ?? 0) + 1;
      }
    }

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (dailyCounts[index] ?? 0).toDouble(),
            color: Colors.green.shade600,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
