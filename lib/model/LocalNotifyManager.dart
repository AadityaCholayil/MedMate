import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotifyManager{
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initSetting;
  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<ReceiveNotification>();

  LocalNotifyManager.init(){
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if(Platform.isIOS) {
      requestIOSPermission();
    }
    initializePlatform();
  }


  requestIOSPermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>().requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  initializePlatform() {
    var initSettingAndroid = AndroidInitializationSettings('app_notification_icon');
    var initSettingIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          ReceiveNotification notification = ReceiveNotification(
              id: id, title: title, body: body, payload: payload
          );
          didReceiveLocalNotificationSubject.add(notification);
        }
    );
    initSetting = InitializationSettings(android: initSettingAndroid, iOS: initSettingIOS);
  }

  setOnNotificationReceive(Function onNotificationReceive){
    didReceiveLocalNotificationSubject.listen((notification){
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: (String payload) async {
          onNotificationClick(payload);
        });
  }

  Future<void> showNotification() async {
    String name = 'paracetamol';
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      enableLights: true,

    );
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel, iOS: iosChannel);
    await flutterLocalNotificationsPlugin.show(
      1,
      '${name[0]}${name.substring(1)}',
      "Heads up! Your ${name[0]}${name.substring(1)} is due. Don't miss it!",
      platformChannel,
      payload: 'New Payload',
    );
  }

  Future<void> scheduleNotification() async {
    tz.initializeTimeZones();
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      timeoutAfter: 5000,
      enableLights: true,

    );
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel, iOS: iosChannel);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Schedule Test Title',
      'Schedule Test Body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      platformChannel,
      payload: 'New Payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showDailyAtTimeNotification(String name, int id, int hour, int minute) async {
    String medName = "${name[0]}${name.substring(1)}";
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    var androidChannel = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      'CHANNEL_DESCRIPTION',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: 'icon_notification_replace',
      //largeIcon: DrawableResourceAndroidBitmap('icon_large_notification'),
      enableLights: true,
    );
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel, iOS: iosChannel);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '$medName',
      "Heads up! Your $medName is due. Don't miss it!",
      _nextInstanceOfMedicine(hour, minute, id),
      platformChannel,
      payload: 'New Payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfMedicine(int hour, int minute, int id) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now) ){
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    print('($id)notification set for $scheduledDate');
    return scheduledDate;
  }

  Future<void> cancelNotification(int id, String name) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('cancelled $name');
  }
}

LocalNotifyManager localNotifyManager = LocalNotifyManager.init();

class ReceiveNotification {
  final int id;
  final String title;
  final String body;
  final String payload;
  ReceiveNotification({@required this.id, @required this.title,
    @required this.body, @required this.payload});
}
