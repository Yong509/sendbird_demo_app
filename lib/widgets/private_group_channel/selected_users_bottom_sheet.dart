import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
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
            height: MediaQuery.of(context).size.height / 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Select user to create room",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: availableUsers.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            title: Text(availableUsers[index].nickname),
                            activeColor: Theme.of(context).primaryColor,
                            controlAffinity: ListTileControlAffinity.platform,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedUsers.add(availableUsers[index]);
                                } else {
                                  _selectedUsers.remove(availableUsers[index]);
                                }
                              });
                              print(_selectedUsers.map((e) => e.nickname));
                            },
                            value:
                                _selectedUsers.contains(availableUsers[index]),
                            secondary: availableUsers[index].profileUrl!.isEmpty
                                ? CircleAvatar(
                                    child: Text(
                                    (availableUsers[index].nickname.isEmpty
                                            ? availableUsers[index].userId
                                            : availableUsers[index].nickname)
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
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                    onPressed: () {
                      SendBirdService().createChannel([
                        for (final user in _selectedUsers) user.userId
                      ]).then(
                        (value) => print(value.members),
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
