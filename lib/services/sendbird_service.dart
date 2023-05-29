import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class SendBirdService {
  SendBirdService._internal();
  static final SendBirdService _instance = SendBirdService._internal();
  factory SendBirdService() => _instance;
  User user = User(userId: "", nickname: "");
  Future<User> sendbirdConnect() async {
    try {
      final sendbird = SendbirdSdk(appId: dotenv.env['SENDBIRD_APPID']);
      user = await sendbird.connect("yong12345");
      return user;
    } catch (error) {
      rethrow;
    }
  }
}
