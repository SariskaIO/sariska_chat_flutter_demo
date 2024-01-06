import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'SariskaChatHome.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "SariskaChat",
      theme: new ThemeData(
        primaryColor: new Color(0xFF0096C7),
        hintColor: new Color(0xFF0096C7),
      ),
      home: new SariskaChatHome(
        channel: new IOWebSocketChannel.connect(
            "wss://api.sariska.io/api/v1/messaging/websocket/websocket"),
      ),
    );
  }
}
