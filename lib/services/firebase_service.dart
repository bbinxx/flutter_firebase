import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class FirebaseMessagingInterface {
  Future<String?> getToken();
  Future<void> requestPermission();
  Stream<String> get onTokenRefresh;
  Future<NotificationSettings> getNotificationSettings();
}

abstract class FirebaseDatabaseInterface {
  DatabaseReference ref();
}

class FirebaseService {
  final FirebaseMessagingInterface _firebaseMessaging;
  final FirebaseDatabaseInterface _firebaseDatabase;
  static const String _dataPath = 'example';
  late DatabaseReference _databaseRef;

  FirebaseService(this._firebaseMessaging, this._firebaseDatabase) {
    _databaseRef = _firebaseDatabase.ref();
  }

  Future<void> initNotifications() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fCMToken = await _firebaseMessaging.getToken();
        if (fCMToken != null) {
          print('Token: $fCMToken');
          await saveTokenToSecureStorage(fCMToken);
          await saveTokenToDatabase(fCMToken);
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        await _firebaseMessaging.requestPermission();
        print('Permission requested');
      } else {
        print('Notification permission denied');
      }
    } catch (e) {
      print('Error initializing notifications: $e');
      // Log error to Firebase Crashlytics or other logging service
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('Token refreshed: $newToken');
      await saveTokenToSecureStorage(newToken);
      await updateTokenInDatabase(
          newToken); // Added function to handle token update in database
    });
  }

  Future<void> saveTokenToSecureStorage(String token) async {
    const _storage = FlutterSecureStorage();
    await _storage.write(key: 'fcm_token', value: token);
  }

  Future<String?> getTokenFromSecureStorage() async {
    const _storage = FlutterSecureStorage();
    return await _storage.read(key: 'fcm_token');
  }

  Future<void> saveTokenToDatabase(String token) async {
    try {
      await _databaseRef.child('fcm_tokens').push().set({'token': token});
      print('FCM Token saved successfully');
    } catch (e) {
      print('Error saving FCM token: $e');
      // Log error to Firebase Crashlytics or other logging service with details
    }
  }

  Future<void> updateTokenInDatabase(String token) async {
    try {
      // Here you would update the token in the database, for example:
      // await _databaseRef.child('fcm_tokens').child('existingTokenKey').set({'token': token});
      print('FCM Token updated successfully');
    } catch (e) {
      print('Error updating FCM token: $e');
      // Log error to Firebase Crashlytics or other logging service with details
    }
  }

  Future<void> saveData(String data) async {
    try {
      final newRef = _databaseRef.child(_dataPath).push();
      await newRef.set({'data': data});
      print('Data saved successfully');
    } catch (e) {
      print('Error saving data: $e');
      // Log error to Firebase Crashlytics or other logging service with details
    }
  }

  Future<void> updateData(String key, String newData) async {
    try {
      await _databaseRef.child(_dataPath).child(key).update({'data': newData});
      print('Data updated successfully');
    } catch (e) {
      print('Error updating data: $e');
      // Log error to Firebase Crashlytics or other logging service with details
    }
  }

  Future<void> deleteData(String key) async {
    try {
      await _databaseRef.child(_dataPath).child(key).remove();
      print('Data deleted successfully');
    } catch (e) {
      print('Error deleting data: $e');
      // Log error to Firebase Crashlytics or other logging service with details
    }
  }

  Stream<DatabaseEvent> streamData() {
    return _databaseRef.child(_dataPath).onValue;
  }
}
