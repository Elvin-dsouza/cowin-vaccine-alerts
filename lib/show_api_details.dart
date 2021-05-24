import 'package:cowin_notification_app/get_available_sessions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowAPIPage extends StatefulWidget {
  final String pinCode, ageLimit;
  ShowAPIPage({Key key, this.pinCode, this.ageLimit}) : super(key: key);

  @override
  _ShowAPIPageState createState() => new _ShowAPIPageState(pinCode, ageLimit);
}

class _ShowAPIPageState extends State<ShowAPIPage> {
  String pinCode, ageLimit = "";
  _ShowAPIPageState(String pinCode, String ageLimit) {
    this.pinCode = pinCode;
    this.ageLimit = ageLimit;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Container(
        child: FutureBuilder(
            future: GetAvailableSessions.getAvailableSessions(
                pinCode,
                ageLimit,
                DateFormat('dd-MM-yyyy')
                    .format(DateTime(now.year, now.month, now.day)),
                "1"),
            initialData: "loading",
            builder: (context, snapshot) {
              final centers = snapshot.data;
              if (snapshot.connectionState == ConnectionState.done) {
                return Text("Doses Available at ${centers.length} centers");
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
