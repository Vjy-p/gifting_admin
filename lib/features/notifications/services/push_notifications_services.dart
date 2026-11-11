import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gifting_admin/app/routes/app_routes.dart';
import 'package:gifting_admin/core/constants/constants.dart';
import 'package:gifting_admin/core/theme/app_colors.dart';
import 'package:glass/glass.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../firebase_options.dart';

// =============================================
// ANDROID NOTIFICATION CHANNELS
// =============================================

const AndroidNotificationChannel enquiriesChannel = AndroidNotificationChannel(
  'enquiries',
  'Customer Enquiries',
  description: 'Notifications for Tribe Green customer enquiries.',
  importance: Importance.high,
  playSound: true,
);

const AndroidNotificationChannel fallbackChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Notifications for general Tribe Green updates.',
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// =============================================
// BACKGROUND MESSAGE HANDLER
// =============================================

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  log(
    'Background FCM message received: ${message.messageId} - ${message.data}',
  );
}

// =============================================
// BACKGROUND LOCAL NOTIFICATION TAP
// =============================================

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  log('Background local notification tapped: ${response.payload}');
}

// =============================================
// PUSH NOTIFICATION SERVICE
// =============================================

class PushNotificationsServices extends GetxService {
  PushNotificationsServices._();

  static final PushNotificationsServices instance =
      PushNotificationsServices._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<String>? _registeredSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<AuthState>? _authStateSubscription;

  String? _registeredToken;
  String? _cachedToken;

  bool _isInitialized = false;
  bool _isLocalNotificationInitialized = false;

  int _notificationId = 0;

  static const String webVapidKey = Constants.webVapidKey;

  static Map<String, dynamic>? pendingNotificationData;

  // =============================================
  // PLATFORM
  // =============================================

  String get platform {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
  }

  // =============================================
  // INITIALIZE
  // =============================================

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Request notification permissions
      final settings = await requestPermissions();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        log('Push notification permission denied by user');
      }

      // Setup platform notifications
      if (!kIsWeb) {
        await _setupLocalNotifications();
        // On iOS, allow native foreground alert, badge and sound
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Listen to Supabase auth state to associate token when logged in
      _listenAuthState();

      // Configure FCM listeners first (registers onRegistered and onTokenRefresh observers)
      _configureFirebaseMessaging();

      // Obtain and register FCM token
      await _registerFCMToken();

      _isInitialized = true;
      log('Push notification service initialized for $platform');
    } catch (e, stackTrace) {
      log(
        'Push notification initialization failed: $e',
        stackTrace: stackTrace,
      );
    }
  }

  // =============================================
  // REQUEST PERMISSIONS
  // =============================================

  Future<NotificationSettings> requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('FCM Notification permission status: ${settings.authorizationStatus}');
    return settings;
  }

  // =============================================
  // GET FCM TOKEN
  // =============================================

  Future<String?> _getFCMToken() async {
    try {
      if (kIsWeb) {
        // ignore: deprecated_member_use
        return await _messaging.getToken(
          vapidKey: webVapidKey,
          serviceWorkerScriptPath: 'firebase-messaging-sw.js',
        );
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging.getAPNSToken();
        log('iOS APNs token: $apnsToken');
      }

      // ignore: deprecated_member_use
      return await _messaging.getToken();
    } catch (e, stackTrace) {
      log('Error getting FCM token: $e', stackTrace: stackTrace);
      return null;
    }
  }

  // =============================================
  // REGISTER TOKEN
  // =============================================

  Future<void> _registerFCMToken() async {
    if (kIsWeb) {
      try {
        await _messaging.register(
          vapidKey: webVapidKey,
          serviceWorkerScriptPath: 'firebase-messaging-sw.js',
        );
      } catch (e) {
        log('Web messaging register: $e');
      }
    }

    final token = await _getFCMToken();

    if (token != null && token.isNotEmpty) {
      log('FCM Token retrieved ($platform): $token');
      await saveToken(token);
    } else {
      log('FCM token currently unavailable, awaiting stream event');
    }
  }

  // =============================================
  // SAVE TOKEN IN SUPABASE
  // =============================================

  Future<void> saveToken(String token) async {
    if (token.isEmpty) return;
    _cachedToken = token;

    final user = _supabase.auth.currentUser;

    if (user == null) {
      log('FCM token cached; awaiting admin login to persist in Supabase');
      return;
    }

    try {
      final oldToken = _registeredToken;

      await _supabase.from('admin_fcm_tokens').upsert({
        'admin_user_id': user.id,
        'fcm_token': token,
        'platform': platform,
        'is_active': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'admin_user_id,fcm_token');

      _registeredToken = token;

      // Remove previous token if rotated
      if (oldToken != null && oldToken != token) {
        await _supabase
            .from('admin_fcm_tokens')
            .delete()
            .eq('admin_user_id', user.id)
            .eq('fcm_token', oldToken);
      }

      log('FCM token successfully registered in Supabase: $platform ($token)');
    } catch (e, stackTrace) {
      log(
        'FCM token registration in Supabase failed: $e',
        stackTrace: stackTrace,
      );
    }
  }

  // =============================================
  // AUTH STATE LISTENER
  // =============================================

  void _listenAuthState() {
    _authStateSubscription ??= _supabase.auth.onAuthStateChange.listen((
      data,
    ) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        final token = _cachedToken ?? await _getFCMToken();
        if (token != null && token.isNotEmpty) {
          await saveToken(token);
        }
      }
    });
  }

  // =============================================
  // TOKEN REFRESH & REGISTERED LISTENERS
  // =============================================

  void _listenTokenRefresh() {
    // ignore: deprecated_member_use
    _tokenSubscription ??= _messaging.onTokenRefresh.listen(
      (token) async {
        log('FCM token refreshed: $token');
        await saveToken(token);
      },
      onError: (error) {
        log('FCM token refresh error: $error');
      },
    );

    _registeredSubscription ??= _messaging.onRegistered.listen(
      (token) async {
        log('FCM onRegistered stream emitted: $token');
        await saveToken(token);
      },
      onError: (error) {
        log('FCM onRegistered error: $error');
      },
    );
  }

  // =============================================
  // FIREBASE MESSAGE LISTENERS
  // =============================================

  void _configureFirebaseMessaging() {
    try {
      _listenTokenRefresh();

      // Foreground messages
      _messageSubscription ??= FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        log(
          'Foreground FCM message: '
          '${message.messageId} ${message.notification?.title} | ${message.data}',
        );

        if (kIsWeb) {
          _showWebForegroundNotification(message);
        } else {
          _showLocalNotification(message);
        }
      });

      // App opened by tapping notification from background
      _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) {
        log('Notification opened from background: ${message.data}');
        _handleNotificationData(message.data);
      });

      // Notification opened from terminated state
      _checkInitialMessage();
    } catch (e, stackTree) {
      log('Error Foreground FCM : $e -- $stackTree');
    }
  }

  // =============================================
  // INITIAL MESSAGE (TERMINATED LAUNCH)
  // =============================================

  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();

    if (message != null) {
      pendingNotificationData = message.data;
      log('Initial FCM notification from launch: ${message.data}');
    }

    // Native local notification launch
    if (!kIsWeb) {
      final launchDetails = await flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();

      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;

        if (payload != null && payload.isNotEmpty) {
          try {
            pendingNotificationData = Map<String, dynamic>.from(
              jsonDecode(payload),
            );
          } catch (e) {
            log('Invalid notification launch payload: $e');
          }
        }
      }
    }
  }

  // =============================================
  // CHECK PENDING NOTIFICATION
  // =============================================

  void checkPendingNotification() {
    final data = pendingNotificationData;

    if (data == null) return;

    pendingNotificationData = null;
    _handleNotificationData(data);
  }

  // =============================================
  // INITIALIZE LOCAL NOTIFICATIONS (NATIVE)
  // =============================================

  Future<void> _setupLocalNotifications() async {
    if (_isLocalNotificationInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response);
      },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(enquiriesChannel);
      await androidPlugin.createNotificationChannel(fallbackChannel);
    }

    _isLocalNotificationInitialized = true;
  }

  // Future webSetup() async {
  //   if (WebFlutterLocalNotificationsPlugin.isSupported) {
  //     await plugin.requestNotificationsPermission();
  //     log('initialised $initialized');

  //     log('web notifications ${plugin.permissionStatus.toString()}');
  //     if (plugin.permissionStatus == WebNotificationPermission.granted) {
  //       _isLocalNotificationInitialized =
  //           await plugin.initialize(
  //             onDidReceiveNotificationResponse:
  //                 (NotificationResponse response) {
  //                   _handleNotificationResponse(response);
  //                 },
  //           ) ??
  //           false;
  //     }
  //   } else {
  //     log('Notifications are not supported in this browser');
  //   }
  // }

  // =============================================
  // SHOW ANDROID FOREGROUND NOTIFICATION
  // =============================================

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) return;

    final payload = <String, dynamic>{
      'title': ?title,
      'body': ?body,
      ...message.data,
    };

    if (message.notification == null) return;

    final String imageUrl =
        message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl ??
        message.data['image_url'] ??
        '';
    log('imaeg url : $imageUrl , notify data : $payload');

    final imageBytes = imageUrl.isEmpty
        ? null
        : await downloadNotificationImage(imageUrl);

    final androidDetails = AndroidNotificationDetails(
      enquiriesChannel.id,
      enquiriesChannel.name,
      channelDescription: enquiriesChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      // largeIcon: const DrawableResourceAndroidBitmap('logo'),
      styleInformation: imageBytes != null
          ? BigPictureStyleInformation(
              ByteArrayAndroidBitmap(imageBytes),
              contentTitle: title,
              summaryText: body,
              hideExpandedLargeIcon: true,
            )
          : BigTextStyleInformation(body ?? ''),
    );

    await flutterLocalNotificationsPlugin.show(
      id: _notificationId++,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  // =============================================
  // SHOW WEB FOREGROUND NOTIFICATION
  // =============================================

  Future<void> _showWebForegroundNotification(RemoteMessage message) async {
    try {
      log('web -- ${message.toMap()} ====== $_registeredToken');
      int id = 0;
      final notification = message.notification;

      final title =
          notification?.title ??
          message.data['title']?.toString() ??
          'Tribe Green Admin';

      final body =
          notification?.body ??
          message.data['body']?.toString() ??
          'You have a new enquiry.';

      final payload = <String, dynamic>{
        'title': title,
        'body': body,
        ...message.data,
      };

      if (message.notification == null) return;

      final String imageUrl =
          message.notification?.web?.image ?? message.data['image_url'] ?? '';
      log('imaeg url : $imageUrl , notify data : $payload');

      // final imageBytes = imageUrl.isEmpty
      //     ? null
      //     : await downloadNotificationImage(imageUrl);

      Get.snackbar(
        title,
        body,
        maxWidth: 900,
        padding: EdgeInsets.zero,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
        backgroundColor: AppColors.surface,
        colorText: AppColors.text,
        // icon: const Icon(
        //   Icons.notifications_active_outlined,
        //   color: Colors.amber,
        // ),
        // icon: const SizedBox.shrink(),
        titleText: const SizedBox.shrink(),
        borderRadius: 16,
        messageText: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            image: imageUrl.isEmpty
                ? null
                : DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                    opacity: 0.8,
                  ),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                color: Colors.amber,
              ),
              Expanded(
                child: Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.darkBackground),
                    ).asGlass(blurX: 4, blurY: 4, frosted: true),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.darkBackground),
                    ).asGlass(blurX: 4, blurY: 4, frosted: true),
                  ],
                ),
              ),
            ],
          ),
        ),

        onTap: (_) => _handleNotificationData(message.data),
      );

      // Check if the browser supports notifications before initializing

      // await plugin.show(
      //   id: id++,
      //   title: title,
      //   body: body,
      //   // payload: jsonEncode(payload),
      // );

      // log('Notifications Blocked');
      // // User blocked notifications - guide them to browser settings
      // Get.dialog(
      //   const AlertDialog(
      //     title: Text('Notifications Blocked'),
      //     content: Text(
      //       'You have blocked notifications. To enable them, '
      //       'please update your browser settings.',
      //     ),
      //   ),
      // );
      // webSetup();
      // }
    } catch (e, stackTree) {
      log('Error web notify $e $stackTree');
    }
  }

  // =============================================
  // TEST NOTIFICATION
  // =============================================

  Future<void> sendLocalTestNotification() async {
    const title = 'Tribe Green Admin';
    const body = 'Web notifications are configured and active!';

    if (kIsWeb) {
      _showWebForegroundNotification(
        const RemoteMessage(
          notification: RemoteNotification(
            title: 'Tribe Green Admin',
            body: 'You have a new customer enquiry.',
          ),
          data: {'type': 'new_enquiry', 'count': 10},
        ),
      );
      // Get.snackbar(
      //   title,
      //   body,
      //   snackPosition: SnackPosition.TOP,
      //   duration: const Duration(seconds: 4),
      //   margin: const EdgeInsets.all(16),
      //   backgroundColor: AppColors.surface,
      //   colorText: AppColors.text,
      //   icon: Icon(Icons.notifications_active, color: AppColors.primary),
      // );
    } else {
      await _showLocalNotification(
        const RemoteMessage(
          notification: RemoteNotification(title: title, body: body),
          data: {'type': 'test'},
        ),
      );
    }
  }

  // =============================================
  // LOCAL NOTIFICATION TAP
  // =============================================

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) return;

    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload));
      _handleNotificationData(data);
    } catch (e, stackTrace) {
      log('Notification tap error: $e', stackTrace: stackTrace);
    }
  }

  // =============================================
  // HANDLE NOTIFICATION DATA
  // =============================================

  Future<void> _handleNotificationData(Map<String, dynamic> data) async {
    try {
      log('Handling notification tap: $data');

      final type = data['type']?.toString();

      if (type == 'new_enquiry' || type == 'enquiry') {
        if (Get.currentRoute != AppRoutes.adminDashboard) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        }

        // if (Get.isRegistered<EnquiryController>()) {
        //   final enquiryController = Get.find<EnquiryController>();
        //   await enquiryController.loadDashboard();

        //   final enquiryId = data['enquiry_id']?.toString();
        //   if (enquiryId != null && enquiryId.isNotEmpty) {
        //     final found = enquiryController.enquiries.firstWhereOrNull(
        //       (item) => item.id == enquiryId,
        //     );
        //     if (found != null) {
        //       Get.toNamed(AppRoutes.enquiryDetails, arguments: found);
        //     }
        //   }
        // }
      } else {
        if (Get.currentRoute != AppRoutes.adminDashboard) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        }
      }
    } catch (e, stackTree) {
      log('Error notify $e -- $stackTree');
    }
  }

  // =============================================
  // UNREGISTER DEVICE TOKEN (BEFORE SIGN OUT)
  // =============================================

  Future<void> unregister() async {
    final user = _supabase.auth.currentUser;
    final token = _registeredToken ?? await _getFCMToken();

    if (user != null && token != null && token.isNotEmpty) {
      try {
        await _supabase
            .from('admin_fcm_tokens')
            .delete()
            .eq('admin_user_id', user.id)
            .eq('fcm_token', token);
        log('FCM token removed from Supabase for admin ${user.id}');
      } catch (e, stackTrace) {
        log('FCM token unregister failed: $e', stackTrace: stackTrace);
      }
    }

    await _tokenSubscription?.cancel();
    await _registeredSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _authStateSubscription?.cancel();

    _tokenSubscription = null;
    _registeredSubscription = null;
    _messageSubscription = null;
    _openedSubscription = null;
    _authStateSubscription = null;

    _registeredToken = null;
    _cachedToken = null;
    _isInitialized = false;
  }

  Future<Uint8List?> downloadNotificationImage(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }

    try {
      final response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 &&
          response.bodyBytes.length <= 1024 * 1024) {
        return response.bodyBytes;
      }
    } catch (e) {
      log('Notification image download failed: $e');
    }

    return null;
  }

  // =============================================
  // DISPOSE
  // =============================================

  @override
  void onClose() {
    _tokenSubscription?.cancel();
    _registeredSubscription?.cancel();
    _messageSubscription?.cancel();
    _openedSubscription?.cancel();
    _authStateSubscription?.cancel();

    super.onClose();
  }
}
