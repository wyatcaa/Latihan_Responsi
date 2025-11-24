import 'package:awesome_notifications/awesome_notifications.dart';

class NotifHelper {
  static Future<void> showNotif(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  static Future<void> requestPermissionIfNeeded() async {
    bool allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      // Ask user to allow notifications
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }
}
