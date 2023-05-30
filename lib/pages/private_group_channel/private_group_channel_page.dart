import 'package:flutter/material.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';
import 'package:sendbird_demo_app/widgets/private_group_channel/selected_users_bottom_sheet.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class PrivateGroupChannelPage extends StatefulWidget {
  const PrivateGroupChannelPage({super.key});

  @override
  State<PrivateGroupChannelPage> createState() =>
      _PrivateGroupChannelPageState();
}

class _PrivateGroupChannelPageState extends State<PrivateGroupChannelPage> {
  final List<User> _availableUsers = [];
  final Set<User> _selectedUsers = {};

  @override
  void initState() {
    SendBirdService().getUsers().then((value) {
      setState(() {
        _availableUsers.clear();
        _availableUsers.addAll(value);
      });
    }).catchError((e) {
      throw ('ERROR: $e');
    });
    ;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Channel rooms "),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: FutureBuilder(
          future: SendBirdService().getGroupChannel(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        NetworkImage(snapshot.data![index].coverUrl.toString()),
                  ),
                  title: Text(snapshot.data![index].name.toString()),
                  subtitle: Text(
                    [
                      for (final member in snapshot.data![index].members)
                        member.nickname
                    ].join(","),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.message_rounded),
                    onPressed: () {},
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        SelectedUsersBottomSheet(
                context: context, availableUsers: _availableUsers)
            .showSelectedUserBottomSheet();
      }),
    );
  }
}
