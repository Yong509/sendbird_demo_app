import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sendbird_demo_app/pages/app.dart';
import 'package:sendbird_demo_app/services/sendbird_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await SendBirdService().sendbirdConnect();
  runApp(const App());
}
