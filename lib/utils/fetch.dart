import 'package:http/http.dart' as http;
import 'dart:convert';

String url = 'https://intranet.cbn.net.id/api-mob/';

Future<dynamic> httpGet(String endpoint, {Map<String, String> header}) {
  return http.get(url + endpoint).then((response) {
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return json.decode(response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  });
}
