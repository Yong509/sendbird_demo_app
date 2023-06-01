import 'package:flutter/material.dart';
import 'package:sendbird_demo_app/pages/chat_page/chat_page.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class SelectedUsersBottomSheet {
  final BuildContext context;
  final List<User> availableUsers;
  const SelectedUsersBottomSheet(
      {required this.context, required this.availableUsers});

  showSelectedUserBottomSheet() {
    final Set<User> _selectedUsers = {};
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Select who you want to chat with",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: availableUsers.length,
                            itemBuilder: (context, index) {
                              if (availableUsers[index].userId !=
                                  SendBirdService().user.userId) {
                                return CheckboxListTile(
                                  title: Text(availableUsers[index].nickname),
                                  activeColor: Theme.of(context).primaryColor,
                                  controlAffinity:
                                      ListTileControlAffinity.platform,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedUsers
                                            .add(availableUsers[index]);
                                      } else {
                                        _selectedUsers
                                            .remove(availableUsers[index]);
                                      }
                                    });
                                    print(
                                        _selectedUsers.map((e) => e.nickname));
                                  },
                                  value: _selectedUsers
                                      .contains(availableUsers[index]),
                                  secondary: availableUsers[index]
                                          .profileUrl!
                                          .isEmpty
                                      ? CircleAvatar(
                                          child: Text(
                                          (availableUsers[index]
                                                      .nickname
                                                      .isEmpty
                                                  ? availableUsers[index].userId
                                                  : availableUsers[index]
                                                      .nickname)
                                              .substring(0, 1)
                                              .toUpperCase(),
                                        ))
                                      : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            availableUsers[index]
                                                .profileUrl
                                                .toString(),
                                          ),
                                        ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                    onPressed: () {
                      SendBirdService().createChannel([
                        for (final user in _selectedUsers) user.userId
                      ]).then(
                        (value) {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(groupChannel: value),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Create"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
