import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sendbird_demo_app/pages/private_group_channel/private_group_channel_page.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';
import 'package:sendbird_sdk/core/models/user.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Sendbird + Dash Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Log in with",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            SendBirdService().user.profileUrl!.isEmpty
                ? CircleAvatar(
                    radius: 80,
                    child: Text(
                      (SendBirdService().user.nickname.isEmpty
                              ? SendBirdService().user.userId
                              : SendBirdService().user.nickname)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 80),
                    ))
                : CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(
                      SendBirdService().user.profileUrl.toString(),
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              SendBirdService().user.nickname,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const PrivateGroupChannelPage()),
                );
              },
              child: const Text("LET'S CHAT"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
