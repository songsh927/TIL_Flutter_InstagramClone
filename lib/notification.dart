import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notifications = FlutterLocalNotificationsPlugin();

initNotifications(context) async{
  var androidSetting = AndroidInitializationSettings('app_icon');

  var iosSetting = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings = InitializationSettings(
    android: androidSetting,
    iOS: iosSetting
  );
  await notifications.initialize(
    initializationSettings,
    onSelectNotification: (payload){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Text('새로운페이지')
          )
      );
    }
  );
}

showNotification() async{

  var androidDetails = AndroidNotificationDetails(
    '유니크한 알림 채널 ID',
    '알림종류 설명',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 0, 150, 255),
  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  notifications.show(
      1,
      '제목',
      '내용',
      NotificationDetails(android: androidDetails, iOS: iosDetails)
  );

}

showNotifications2() async{
  tz.initializeTimeZones();


  var androidDetails = AndroidNotificationDetails(
    '유니크한 알림 채널 ID',
    '알림종류 설명',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 0, 150, 255),
  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  notifications.zonedSchedule(
      2,
      'title',
      'body',
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true
  );

}