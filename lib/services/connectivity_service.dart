import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/supabase_service.dart';

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

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      await _checkConnection();

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) {
        _handleConnectivityChange(results);
      });
    } catch (e) {
      print('ConnectivityService initialization error: $e');
      _updateStatus(ConnectionStatus.error);
    }
  }

  // Check network connectivity with improved reliability
  Future<bool> hasNetworkConnection() async {
    try {
      final List<ConnectivityResult> connectivityResult =
          await _connectivity.checkConnectivity();

      // If no network connectivity, return false immediately
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check: try to ping a reliable server
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 3));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        // If ping fails, still consider connected if we have network interface
        return !connectivityResult.contains(ConnectivityResult.none);
      }
    } catch (e) {
      return false;
    }
  }

  // Check Supabase connectivity with improved error handling
  Future<bool> checkSupabaseConnection({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      _updateStatus(ConnectionStatus.checking);

      // First check if Supabase is properly initialized
      if (!SupabaseService.isInitialized) {
        print('Supabase not initialized, attempting to initialize...');
        final initialized = await SupabaseService.initialize();
        if (!initialized) {
          _updateStatus(ConnectionStatus.disconnected);
          return false;
        }
      }

      // Check network connectivity first
      final hasNetwork = await hasNetworkConnection();
      if (!hasNetwork) {
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
      print('Supabase connection check failed: $e');
      _updateStatus(ConnectionStatus.error);
      return false;
    }
  }

  // Comprehensive connection check with graceful fallbacks
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
    };

    try {
      // Step 1: Check network connectivity
      _updateStatus(ConnectionStatus.checking);
      status['hasNetwork'] = await hasNetworkConnection();

      if (!status['hasNetwork']) {
        status['errorMessage'] = 'No network connection available';
        _updateStatus(ConnectionStatus.disconnected);
        return status;
      }

      // Step 2: Check Supabase credentials
      if (!SupabaseService.hasValidCredentials) {
        status['hasSupabase'] = false;
        status['errorMessage'] = 'Supabase credentials not configured';
        _updateStatus(ConnectionStatus.error);
        return status;
      }

      // Step 3: Check Supabase initialization
      if (!SupabaseService.isInitialized) {
        final initialized = await SupabaseService.initialize();
        if (!initialized) {
          status['hasSupabase'] = false;
          status['errorMessage'] = 'Failed to initialize Supabase';
          _updateStatus(ConnectionStatus.error);
          return status;
        }
      }

      // Step 4: Test Supabase connectivity
      try {
        final client = SupabaseService.instance.safeClient;
        if (client == null) {
          throw Exception('Supabase client not available');
        }

        // Test basic Supabase connection
        final session = client.auth.currentSession;
        status['authStatus'] =
            session != null ? 'authenticated' : 'unauthenticated';

        // Test database connectivity with shorter timeout
        await client
            .from('categories')
            .select('id')
            .limit(1)
            .timeout(const Duration(seconds: 6));

        status['databaseAccess'] = true;
        status['hasSupabase'] = true;
        _updateStatus(ConnectionStatus.connected);
      } catch (e) {
        status['hasSupabase'] = false;
        status['errorMessage'] = 'Database connection failed: ${e.toString()}';
        // Don't mark as complete error if we have basic connectivity
        _updateStatus(
          status['hasNetwork']
              ? ConnectionStatus.timeout
              : ConnectionStatus.error,
        );
      }
    } catch (e) {
      status['errorMessage'] = 'Connectivity check failed: ${e.toString()}';
      _updateStatus(ConnectionStatus.error);
    }

    return status;
  }

  // Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _updateStatus(ConnectionStatus.disconnected);
    } else {
      // When connectivity returns, recheck connection after a brief delay
      Timer(const Duration(seconds: 1), () {
        _checkConnection();
      });
    }
  }

  // Internal connection check with timeout
  Future<void> _checkConnection() async {
    try {
      await checkSupabaseConnection(timeout: const Duration(seconds: 6));
    } catch (e) {
      _updateStatus(ConnectionStatus.error);
    }
  }

  // Update connection status
  void _updateStatus(ConnectionStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _connectionStatusController.add(status);
    }
  }

  // Get current connectivity type
  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  // Test authentication safely
  Future<bool> testAuthentication() async {
    try {
      final client = SupabaseService.instance.safeClient;
      if (client == null) return false;

      final session = client.auth.currentSession;
      return session != null;
    } catch (e) {
      return false;
    }
  }

  // Retry connection with exponential backoff and better error handling
  Future<bool> retryConnection({int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        print('Connection retry attempt ${attempt + 1}/$maxRetries');

        // Gradually increase timeout with each attempt
        final timeout = Duration(seconds: 4 + (attempt * 2));
        final isConnected = await checkSupabaseConnection(timeout: timeout);

        if (isConnected) {
          return true;
        }

        // Exponential backoff: 1s, 2s, 4s
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(seconds: 1 << attempt));
        }
      } catch (e) {
        print('Retry attempt ${attempt + 1} failed: $e');
      }
    }

    return false;
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}
