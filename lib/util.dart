import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchToken() async {
  final body = jsonEncode({
    'apiKey': "{your-apik-key}",
  });
  var url = 'https://api.sariska.io/api/v1/misc/generate-token';
  final response = await http.post(Uri.parse(url),
      headers: {"Content-Type": "application/json"}, body: body);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var body = jsonDecode(response.body);
    print(body);
    return body['token'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}
