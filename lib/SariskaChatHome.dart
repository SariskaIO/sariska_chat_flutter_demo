import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'util.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class SariskaChatHome extends StatefulWidget {
  final WebSocketChannel channel;

  SariskaChatHome({required this.channel});
  @override
  _SariskaChatHomeState createState() => _SariskaChatHomeState();
}

class _SariskaChatHomeState extends State<SariskaChatHome>
    with SingleTickerProviderStateMixin {
  List<ChatMessage> messages = [];
  late PhoenixChannel _channel;
  TextEditingController editingController = new TextEditingController();
  bool showFab = true;
  @override
  void initState() {
    connectSocket();
    super.initState();
  }

  connectSocket() async {
    var token = await fetchToken();
    final options = PhoenixSocketOptions(params: {"token": token});
    final socket = PhoenixSocket(
        "wss://api.sariska.io/api/v1/messaging/websocket",
        socketOptions: options);
    await socket.connect();
    _channel = socket.channel("chat:{your-room-name}");
    _channel.on("new_message", _say);
    _channel.join();
  }

  _say(payload, _ref, _joinRef) {
    setState(() {
      messages.insert(0, ChatMessage(text: payload["content"]));
    });
  }

  _printThis(message) {
    setState(() {
      messages.insert(0, ChatMessage(text: message));
    });
  }

  _sendMyMessage(message) async {
    _printThis(
        message); //inserts the sent message in the messages queue in order to be shown on the local machine
    _channel.push(event: "new_message", payload: {"content": message});
    editingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                final message = messages[index];
                return Card(
                    child: Column(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.message_outlined),
                        title: Text(message.text),
                        subtitle: Text(message.time)),
                  ],
                ));
              },
              itemCount: messages.length,
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: MessageComposer(
                textController: editingController,
                sendMyMessage: _sendMyMessage,
              ))
        ],
      ),
    );
  }
}

AppBar appBarMain(BuildContext context) {
  return AppBar(
    title: Text("Sariska Chat"),
    // Other app bar configurations like actions, etc.
  );
}
class ChatMessage {
  final String text;
  final DateTime received = DateTime.now();
  ChatMessage({required this.text});
  get time => DateFormat.Hms().format(received);
}

class MessageComposer extends StatelessWidget {
  final textController;
  final sendMyMessage;

  MessageComposer({this.textController, this.sendMyMessage});
  build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                  controller: textController,
                  onSubmitted: sendMyMessage,
                  decoration:
                      InputDecoration.collapsed(hintText: "Start Typing...")),
            ),
            Container(
              child: IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () {
                    sendMyMessage(textController.text);
                  }),
            )
          ],
        ));
  }
}
