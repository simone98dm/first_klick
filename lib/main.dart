import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/background/run_service.dart';
import 'core/permissions/permission_service.dart';
import 'shared/logging_service.dart';

Future<void> main() async {
  try {
    LoggingService.info('App starting...');

    WidgetsFlutterBinding.ensureInitialized();
    LoggingService.debug('WidgetsFlutterBinding initialized');

    // Load .env before anything that reads credentials
    await dotenv.load(fileName: '.env');
    LoggingService.debug('.env loaded');

    // Configure the background service (registers channels/notification channel)
    await initBackgroundService();
    LoggingService.debug('Background service initialized');

    // Initialise local notifications plugin so the UNUserNotificationCenter
    // delegate is set up before the background service posts any notifications.
    if (Platform.isIOS) {
      const initSettings = InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      await FlutterLocalNotificationsPlugin().initialize(initSettings);
      LoggingService.debug('flutter_local_notifications initialised');
    }

    // Request all runtime permissions (location, notifications, Bluetooth).
    // Called before runApp so dialogs appear as early as possible.
    await PermissionService.requestAll();
    LoggingService.debug('Permissions requested');

    runApp(const ProviderScope(child: App()));
    LoggingService.info('App started successfully');
  } catch (e, stackTrace) {
    LoggingService.fatal(
        'Critical error during app initialization', e, stackTrace);
    // Re-throw to let Flutter handle it (shows error screen in debug mode)
    rethrow;
  }
}
