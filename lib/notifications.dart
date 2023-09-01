import 'package:onesignal_flutter/onesignal_flutter.dart';

void initializeNotifications() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(
    "504a3375-4f50-436d-bf25-92cfea174507"
  );
  OneSignal.Notifications.requestPermission(true);
  OneSignal.login('Dev');
}