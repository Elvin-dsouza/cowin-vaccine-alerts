import 'dart:convert';
import 'package:http/http.dart' as http;

class GetAvailableSessions {
  static const String BASE_URL =
      'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=591101&date=05-06-2021';

  static Future<List<String>> getAvailableSessions() async {
    final response = await http.get(BASE_URL);
    if (response.statusCode == 200) {
      List<String> output = [];
      final List centers = json.decode(response.body)["centers"];
      centers.forEach((f) {
        output.add(f["name"]);
      });
      return output;
    } else
      return null;
  }
}
