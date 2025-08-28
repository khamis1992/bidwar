import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/recommendation.dart';
import '../../routes/app_routes.dart';
import '../../services/ai_recommendation_service.dart';
import './widgets/discovery_modes_widget.dart';
import './widgets/personalization_dashboard_widget.dart';
import './widgets/recommendation_explanation_widget.dart';
import './widgets/recommendation_header_widget.dart';
import './widgets/recommended_streams_list_widget.dart';

class AIPoweredStreamRecommendationsEngine extends StatefulWidget {
  const AIPoweredStreamRecommendationsEngine({Key? key}) : super(key: key);

  @override
  State<AIPoweredStreamRecommendationsEngine> createState() =>
      _AIPoweredStreamRecommendationsEngineState();
}

class _AIPoweredStreamRecommendationsEngineState
    extends State<AIPoweredStreamRecommendationsEngine>
    with TickerProviderStateMixin {
  final AIRecommendationService _aiService = AIRecommendationService();
  late TabController _tabController;

  bool _isLoading = true;
  String _selectedDiscoveryMode = 'similar_to_watched';
  List<Recommendation> _recommendations = [];
  Map<String, dynamic> _userPreferences = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRecommendations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        _aiService.getPersonalizedRecommendations(_selectedDiscoveryMode),
        _aiService.getUserPreferences(),
      ]);

      setState(() {
        _recommendations = results[0] as List<Recommendation>;
        _userPreferences = results[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onDiscoveryModeChanged(String mode) async {
    if (_selectedDiscoveryMode != mode) {
      setState(() {
        _selectedDiscoveryMode = mode;
      });
      await _loadRecommendations();
    }
  }

  Future<void> _onRecommendationTapped(Recommendation recommendation) async {
    try {
      // Track interaction
      await _aiService.trackInteraction(
        recommendation.auctionItem.id,
        'click',
        {
          'recommendation_id': recommendation.id,
          'confidence_score': recommendation.confidenceScore
        },
      );

      // Navigate to auction detail
      Navigator.pushNamed(
        context,
        AppRoutes.auctionDetail,
        arguments: recommendation.auctionItem.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to open recommendation: ${e.toString()}')),
      );
    }
  }

  Future<void> _onRecommendationFeedback(Recommendation recommendation,
      String feedbackType, String? reason) async {
    try {
      await _aiService.submitRecommendationFeedback(
        recommendation.id,
        feedbackType,
        reason,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: ${e.toString()}')),
      );
    }
  }

  Future<void> _refreshRecommendations() async {
    await _loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'AI Recommendations',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshRecommendations,
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
          ),
          IconButton(
            onPressed: () {
              _tabController.animateTo(3); // Navigate to personalization tab
            },
            icon: Icon(Icons.tune, color: Colors.grey[600]),
          ),
        ],
      ),
      body: Column(
        children: [
          RecommendationHeaderWidget(
            totalRecommendations: _recommendations.length,
            lastUpdated: DateTime.now(),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Discovery'),
                Tab(text: 'Explanation'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // For You Tab
                _isLoading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : RefreshIndicator(
                            onRefresh: _refreshRecommendations,
                            child: RecommendedStreamsListWidget(
                              recommendations: _recommendations,
                              onRecommendationTapped: _onRecommendationTapped,
                              onFeedback: _onRecommendationFeedback,
                            ),
                          ),

                // Discovery Tab
                Column(
                  children: [
                    DiscoveryModesWidget(
                      selectedMode: _selectedDiscoveryMode,
                      onModeChanged: _onDiscoveryModeChanged,
                    ),
                    Expanded(
                      child: _isLoading
                          ? _buildLoadingState()
                          : RecommendedStreamsListWidget(
                              recommendations: _recommendations,
                              onRecommendationTapped: _onRecommendationTapped,
                              onFeedback: _onRecommendationFeedback,
                              showDiscoveryMode: true,
                            ),
                    ),
                  ],
                ),

                // Explanation Tab
                RecommendationExplanationWidget(
                  recommendations: _recommendations,
                ),

                // Settings Tab
                PersonalizationDashboardWidget(
                  userPreferences: _userPreferences,
                  onPreferencesUpdated: (preferences) async {
                    try {
                      await _aiService.updateUserPreferences(preferences);
                      setState(() {
                        _userPreferences = preferences;
                      });
                      await _loadRecommendations();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Preferences updated successfully!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Failed to update preferences: ${e.toString()}')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Column(
        children: [
          SizedBox(height: 40.sp),
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
          SizedBox(height: 16.sp),
          Text(
            'Analyzing your preferences...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Generating personalized recommendations',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(24.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red[600],
          ),
          SizedBox(height: 16.sp),
          Text(
            'Unable to load recommendations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            _error ?? 'Something went wrong. Please try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.sp),
          ElevatedButton(
            onPressed: _refreshRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}