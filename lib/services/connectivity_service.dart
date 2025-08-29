import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../services/supabase_service.dart';
import './environment_service.dart';

enum ConnectionStatus { connected, disconnected, checking, timeout, error }

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Stream controller for connection status
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  ConnectionStatus get currentStatus => _currentStatus;

  // Initialize connectivity monitoring with enhanced error handling
  Future<void> initialize() async {
    try {
      print('🔧 Connectivity Service: Starting initialization...');

      // Check initial connectivity
      await _checkConnection();

      // Listen to connectivity changes with better error handling
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) {
        _handleConnectivityChange(results);
      }, onError: (error) {
        print('❌ Connectivity stream error: $error');
        _updateStatus(ConnectionStatus.error);
      });

      print('✅ Connectivity Service initialized');
    } catch (e) {
      print('❌ ConnectivityService initialization error: $e');
      _updateStatus(ConnectionStatus.error);
    }
  }

  // Enhanced network connectivity check with timeout and retries
  Future<bool> hasNetworkConnection() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await _connectivity.checkConnectivity();

      // If no network connectivity, return false immediately
      if (connectivityResult.contains(ConnectivityResult.none)) {
        print('📱 No network interface available');
        return false;
      }

      // Additional validation: try to ping reliable servers
      if (!kIsWeb) {
        try {
          final List<String> testHosts = [
            'google.com',
            '8.8.8.8',
            'cloudflare.com'
          ];

          for (String host in testHosts) {
            try {
              final result = await InternetAddress.lookup(host)
                  .timeout(const Duration(seconds: 3));

              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                print('✅ Network connectivity confirmed via $host');
                return true;
              }
            } catch (hostError) {
              print('⚠️ Failed to reach $host: $hostError');
              continue;
            }
          }

          print('⚠️ All network tests failed, but interface exists');
          return !connectivityResult.contains(ConnectivityResult.none);
        } catch (e) {
          print('⚠️ Network validation error: $e');
          return !connectivityResult.contains(ConnectivityResult.none);
        }
      }

      // For web, trust the connectivity result
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      print('❌ Network check failed: $e');
      return false;
    }
  }

  // Enhanced Supabase connectivity check with better error categorization
  Future<bool> checkSupabaseConnection({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      print('🔧 Checking Supabase connection...');
      _updateStatus(ConnectionStatus.checking);

      // First check if Supabase is properly initialized
      if (!SupabaseService.isInitialized) {
        print('⚠️ Supabase not initialized, attempting to initialize...');
        final initialized = await SupabaseService.initialize();
        if (!initialized) {
          print('❌ Supabase initialization failed');
          _updateStatus(ConnectionStatus.disconnected);
          return false;
        }
      }

      // Check network connectivity first
      final hasNetwork = await hasNetworkConnection();
      if (!hasNetwork) {
        print('❌ No network connection available for Supabase');
        _updateStatus(ConnectionStatus.disconnected);
        return false;
      }

      // Test Supabase connection using the service's built-in check
      final isConnected = await SupabaseService.checkConnection(
        timeout: timeout,
      );

      _updateStatus(
        isConnected ? ConnectionStatus.connected : ConnectionStatus.error,
      );
      return isConnected;
    } catch (e) {
      print('❌ Supabase connection check failed: $e');
      _updateStatus(ConnectionStatus.error);
      return false;
    }
  }

  // Comprehensive connection check with detailed diagnostics
  Future<Map<String, dynamic>> performFullConnectivityCheck() async {
    final Map<String, dynamic> status = {
      'hasNetwork': false,
      'hasSupabase': false,
      'authStatus': 'unknown',
      'databaseAccess': false,
      'errorMessage': null,
      'timestamp': DateTime.now().toIso8601String(),
      'supabaseInitialized': SupabaseService.isInitialized,
      'hasCredentials': SupabaseService.hasValidCredentials,
      'environmentStatus': EnvironmentService.getStatus(),
      'connectivity': 'checking',
    };

    try {
      print('🔧 Performing full connectivity check...');

      // Step 1: Check network connectivity
      _updateStatus(ConnectionStatus.checking);
      status['hasNetwork'] = await hasNetworkConnection();

      if (!status['hasNetwork']) {
        status['errorMessage'] = 'No network connection available';
        status['connectivity'] = 'no_network';
        _updateStatus(ConnectionStatus.disconnected);
        return status;
      }

      // Step 2: Check Supabase credentials
      if (!SupabaseService.hasValidCredentials) {
        status['hasSupabase'] = false;
        status['errorMessage'] =
            'Supabase credentials not configured or invalid';
        status['connectivity'] = 'no_credentials';
        _updateStatus(ConnectionStatus.error);
        return status;
      }

      // Step 3: Check Supabase initialization
      if (!SupabaseService.isInitialized) {
        print('⚠️ Supabase not initialized, attempting initialization...');
        final initialized = await SupabaseService.initialize();
        if (!initialized) {
          status['hasSupabase'] = false;
          status['errorMessage'] = 'Failed to initialize Supabase service';
          status['connectivity'] = 'init_failed';
          _updateStatus(ConnectionStatus.error);
          return status;
        }
      }

      // Step 4: Test Supabase connectivity with timeout
      try {
        final client = SupabaseService.instance.safeClient;
        if (client == null) {
          throw Exception('Supabase client not available after initialization');
        }

        // Test basic authentication status
        final session = client.auth.currentSession;
        status['authStatus'] =
            session != null ? 'authenticated' : 'unauthenticated';

        // Test database connectivity with progressive timeout
        print('🔧 Testing database connectivity...');
        await client
            .from('categories')
            .select('id')
            .limit(1)
            .timeout(const Duration(seconds: 6));

        status['databaseAccess'] = true;
        status['hasSupabase'] = true;
        status['connectivity'] = 'full_access';
        _updateStatus(ConnectionStatus.connected);

        print('✅ Full connectivity check successful');
      } catch (e) {
        String errorMessage = e.toString();
        status['hasSupabase'] = false;
        status['errorMessage'] = 'Database connection failed: $errorMessage';

        if (errorMessage.contains('timeout')) {
          status['connectivity'] = 'timeout';
          _updateStatus(ConnectionStatus.timeout);
        } else if (errorMessage.contains('network')) {
          status['connectivity'] = 'network_error';
          _updateStatus(ConnectionStatus.error);
        } else {
          status['connectivity'] = 'db_error';
          _updateStatus(ConnectionStatus.error);
        }
      }
    } catch (e) {
      status['errorMessage'] = 'Connectivity check failed: ${e.toString()}';
      status['connectivity'] = 'check_failed';
      _updateStatus(ConnectionStatus.error);
      print('❌ Full connectivity check failed: $e');
    }

    return status;
  }

  // Enhanced connectivity change handler
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    print('📱 Connectivity changed: $results');

    if (results.contains(ConnectivityResult.none)) {
      print('❌ Network disconnected');
      _updateStatus(ConnectionStatus.disconnected);
    } else {
      print('✅ Network connected, rechecking services...');
      // When connectivity returns, recheck connection after a brief delay
      Timer(const Duration(milliseconds: 1500), () {
        _checkConnection();
      });
    }
  }

  // Internal connection check with enhanced error handling
  Future<void> _checkConnection() async {
    try {
      final hasNetwork = await hasNetworkConnection();
      if (!hasNetwork) {
        _updateStatus(ConnectionStatus.disconnected);
        return;
      }

      // Only check Supabase if we have network
      await checkSupabaseConnection(timeout: const Duration(seconds: 6));
    } catch (e) {
      print('❌ Connection check error: $e');
      _updateStatus(ConnectionStatus.error);
    }
  }

  // Update connection status with logging
  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      final oldStatus = _currentStatus;
      _currentStatus = status;
      _connectionStatusController.add(status);

      print('📊 Connection status changed: $oldStatus → $status');
    }
  }

  // Get current connectivity type with error handling
  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      print('❌ Error getting connectivity: $e');
      return [ConnectivityResult.none];
    }
  }

  // Test authentication safely with enhanced error handling
  Future<bool> testAuthentication() async {
    try {
      final client = SupabaseService.instance.safeClient;
      if (client == null) {
        print('⚠️ Supabase client not available for auth test');
        return false;
      }

      final session = client.auth.currentSession;
      final isAuthenticated = session != null;

      print('🔐 Authentication test: ${isAuthenticated ? "✅" : "❌"}');
      return isAuthenticated;
    } catch (e) {
      print('❌ Authentication test failed: $e');
      return false;
    }
  }

  // Enhanced retry connection with exponential backoff and comprehensive logging
  Future<bool> retryConnection({int maxRetries = 3}) async {
    print('🔄 Starting connection retry sequence (max: $maxRetries)');

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('🔄 Connection retry attempt ${attempt + 1}/$maxRetries');

        // Gradually increase timeout with each attempt
        final timeout = Duration(seconds: 4 + (attempt * 2));
        final isConnected = await checkSupabaseConnection(timeout: timeout);

        if (isConnected) {
          print('✅ Connection retry successful on attempt ${attempt + 1}');
          return true;
        }

        // Exponential backoff: 1s, 2s, 4s
        if (attempt < maxRetries - 1) {
          final delay = Duration(seconds: 1 << attempt);
          print('⏱️ Waiting ${delay.inSeconds}s before next retry...');
          await Future.delayed(delay);
        }
      } catch (e) {
        print('❌ Retry attempt ${attempt + 1} failed: $e');
      }
    }

    print('❌ All retry attempts failed');
    return false;
  }

  // Get detailed status for debugging
  Map<String, dynamic> getStatus() {
    return {
      'current_status': _currentStatus.toString(),
      'supabase_initialized': SupabaseService.isInitialized,
      'supabase_has_credentials': SupabaseService.hasValidCredentials,
      'service_initialized': _connectivitySubscription != null,
    };
  }

  // Dispose resources with enhanced cleanup
  void dispose() {
    print('🔧 Disposing Connectivity Service...');
    _connectivitySubscription?.cancel();
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.close();
    }
    print('✅ Connectivity Service disposed');
  }
}
