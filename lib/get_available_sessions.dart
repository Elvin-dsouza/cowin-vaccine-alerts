import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Utility Class to retrieve available vaccination sessions for the Cowin API
///
class GetAvailableSessions {
  /// Get all availabe sessions for 7 days from a given date
  /// returns null on failure, empty list when there are no respones/sessions available
  static Future<List<String>> getAvailableSessions(
      String pinCode, String minAgeLimit, String date, String dose) async {
    final String BASE_URL =
        'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$pinCode&date=$date';
    final response = await http.get(BASE_URL);
    if (response.statusCode == 200) {
      List<String> output = [];
      final List centers = json.decode(response.body)["centers"];
      centers.forEach((f) {
        f["sessions"].forEach((session) {
          if (session["min_age_limit"] >= int.parse(minAgeLimit, radix: 10) &&
              session["available_capacity_dose$dose"] > 0) {
            if (!output.contains(f["name"])) {
              output.add(f["name"]);
            }
          }
        });
      });
      return output;
    } else
      return null;
  }

  /// returns a list of vaccination centers with available doses for a period of
  /// 4 weeks from a given date.
  /// makes 4 calls to the cowin API, returns an empty list when no sessions are available.
  static Future<List<String>> getAvailableSessionsForOneMonth(
      String pinCode, String minAgeLimit, DateTime now, String dose) async {
    List<String> output = [];
    output.addAll(await GetAvailableSessions.getAvailableSessions(
        pinCode,
        minAgeLimit,
        DateFormat('dd-MM-yyyy').format(DateTime(now.year, now.month, now.day)),
        dose));

    output.addAll(await GetAvailableSessions.getAvailableSessions(
        pinCode,
        minAgeLimit,
        DateFormat('dd-MM-yyyy')
            .format(DateTime(now.year, now.month, now.day + 7)),
        dose));

    output.addAll(await GetAvailableSessions.getAvailableSessions(
        pinCode,
        minAgeLimit,
        DateFormat('dd-MM-yyyy')
            .format(DateTime(now.year, now.month, now.day + 14)),
        dose));

    output.addAll(await GetAvailableSessions.getAvailableSessions(
        pinCode,
        minAgeLimit,
        DateFormat('dd-MM-yyyy')
            .format(DateTime(now.year, now.month, now.day + 21)),
        dose));
    //TODO: find a better way to dedup this.

    return output.toSet().toList();
  }
}
