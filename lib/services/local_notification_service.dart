import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import 'package:todoapp/models/notification.dart';
import 'package:todoapp/models/todo.dart';

class LocalNotificationService {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late InitializationSettings _initSettings;

  LocalNotificationService.init() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) _requestIOSPermission();
    initialize();
  }

  void _requestIOSPermission() {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(alert: true, sound: true, badge: true);
  }

  void initialize() {
    const AndroidInitializationSettings initAndroidSettings = AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initIOSSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    _initSettings = InitializationSettings(android: initAndroidSettings, iOS: initIOSSettings);
    tz.initializeTimeZones();
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await _flutterLocalNotificationsPlugin.initialize(
      _initSettings,
      onSelectNotification: (payload) async {
        onNotificationClick(payload);
      },
    );
  }

  Future<void> scheduleNotification(Todo todo, DateTime scheduleTime) async {
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true      
    );
    IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      Uuid.parse(todo.id).reduce((a, b) => a + b),
      'Erinnerung',
      todo.title,
      tz.TZDateTime.from(scheduleTime, tz.local),  
      notificationDetails,   
      payload: todo.id, 
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );

    print('Notification scheduled for ${todo.id} at ${scheduleTime.toString()}');
  }

  Future<void> cancelNotification(Todo todo) async {
    int id = Uuid.parse(todo.id).reduce((a, b) => a + b);
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('Canceled notification for ${todo.id}');
  }

  BehaviorSubject<Notification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<Notification>();
}

LocalNotificationService localNotificationService = LocalNotificationService.init();