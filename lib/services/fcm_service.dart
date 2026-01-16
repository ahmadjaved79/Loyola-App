import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// Top-level function for background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final ApiService _apiService = ApiService();

  String? _fcmToken;
  StreamController<RemoteMessage>? _messageStreamController;

  Stream<RemoteMessage> get messageStream => _messageStreamController!.stream;

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Set up background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request permissions (iOS)
      await _requestPermissions();

      // Configure local notifications
      await _configureLocalNotifications();

      // Get FCM token
      await _getFCMToken();

      // Set up message handlers
      _setupMessageHandlers();

      print('✅ FCM Service initialized successfully');
    } catch (e) {
      print('❌ FCM initialization error: $e');
    }
  }

  // ==================== PERMISSIONS ====================

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('FCM Permission status: ${settings.authorizationStatus}');
  }

  // ==================== FCM TOKEN MANAGEMENT ====================

  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();

      if (_fcmToken != null) {
        print('✅ FCM Token: $_fcmToken');
        await _saveTokenLocally(_fcmToken!);

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _saveTokenLocally(newToken);
          _updateTokenOnServer(newToken);
          print('🔄 FCM Token refreshed: $newToken');
        });
      }

      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  String? get currentToken => _fcmToken;

  Future<void> _updateTokenOnServer(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('student_id');

    if (studentId != null) {
      await registerDeviceWithServer(
        studentId: studentId,
        fcmToken: newToken,
      );
    }
  }

  // ==================== DEVICE REGISTRATION ====================

  Future<bool> registerDeviceWithServer({
    required int studentId,
    required String fcmToken,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
  }) async {
    try {
      final deviceInfo = await _getDeviceInfo();

      final response = await _apiService.registerDevice(
        studentId: studentId,
        fcmToken: fcmToken,
        parentName: parentName,
        parentPhone: parentPhone,
        parentEmail: parentEmail,
        deviceInfo: deviceInfo,
      );

      if (response.success) {
        print('✅ Device registered successfully');
        return true;
      } else {
        print('❌ Device registration failed: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Registration error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      // You can use device_info_plus and package_info_plus here
      return {
        'platform': Platform.operatingSystem,
        'os_version': Platform.operatingSystemVersion,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {};
    }
  }

  // ==================== LOCAL NOTIFICATIONS ====================

  Future<void> _configureLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'attendance_alerts',
        'Attendance Alerts',
        description: 'Notifications for student attendance updates',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'attendance_alerts',
      'Attendance Alerts',
      channelDescription: 'Notifications for student attendance updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // ==================== MESSAGE HANDLERS ====================

  void _setupMessageHandlers() {
    _messageStreamController = StreamController<RemoteMessage>.broadcast();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.messageId}');

      _messageStreamController?.add(message);

      // Show local notification
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title ?? 'SmartShala',
          body: message.notification!.body ?? 'New notification',
          payload: message.data.toString(),
        );
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 App opened from notification: ${message.messageId}');
      _messageStreamController?.add(message);
      _handleNotificationTap(message);
    });

    // Check if app was opened from terminated state
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      print('🚀 App opened from terminated state with notification');
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;

    print('Notification data: $data');

    // Extract data and navigate accordingly
    // You can use navigation service here
  }

  // ==================== TESTING ====================

  Future<bool> testNotification({String? customMessage}) async {
    try {
      if (_fcmToken == null) {
        print('❌ No FCM token available');
        return false;
      }

      final response = await _apiService.testFcmToken(
        fcmToken: _fcmToken!,
        testMessage: customMessage,
      );

      if (response.success) {
        print('✅ Test notification sent');
        return true;
      } else {
        print('❌ Test failed: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Test error: $e');
      return false;
    }
  }

  // ==================== SUBSCRIPTIONS ====================

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Subscribe error: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Unsubscribe error: $e');
    }
  }

  // ==================== CLEANUP ====================

  void dispose() {
    _messageStreamController?.close();
  }
}
