import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class SendBirdService {
  SendBirdService._internal();
  static final SendBirdService _instance = SendBirdService._internal();
  factory SendBirdService() => _instance;
  User user = User(userId: "", nickname: "");

  Future<User> sendbirdConnect() async {
    try {
      final sendbird =
          SendbirdSdk(appId: "3A40D3AC-5D48-4B40-BC2D-3C22D512B59C");
      user = await sendbird.connect("yong12345");
      return user;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<GroupChannel>> getGroupChannel() async {
    try {
      final query = GroupChannelListQuery()
        ..includeEmptyChannel = true
        ..order = GroupChannelListOrder.latestLastMessage
        ..limit = 15;
      final result = await query.loadNext();
      return result;
    } catch (e) {
      throw ('getGroupChannels: ERROR: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final query = ApplicationUserListQuery();
      List<User> users = await query.loadNext();
      return users;
    } catch (e) {
      print('create_channel_view: getUsers: ERROR: $e');
      return [];
    }
  }

  Future<GroupChannel> createChannel(List<String> userIds) async {
    try {
      final params = GroupChannelParams()..userIds = userIds;
      final channel = await GroupChannel.createChannel(params);
      return channel;
    } catch (e) {
      print('createChannel: ERROR: $e');
      throw e;
    }
  }
}
