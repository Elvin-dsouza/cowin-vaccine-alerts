import 'package:cowin_notification_app/get_available_sessions.dart';
import 'package:cowin_notification_app/notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String COWIN_TAG = "COWIN_NOTIFICATIONS";
const String NOTIFY_COWIN_TASK = "NOTIFY_COWIN_CRITERIA";

/// called by the Workmanager background tasks based on the interval set.
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    //retrieve last set filter values from user shared preferences.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String pinCode = prefs.getString("filterPinCode");
    final String age = prefs.getString("filterAgeRestrictions");
    final String dose = prefs.getString("filterDose");

    // edge case where either of the preferences are set to zero
    if (pinCode != "" && age != "") {
      List<String> availableCenters =
          await GetAvailableSessions.getAvailableSessionsForOneMonth(
              pinCode, age, DateTime.now(), dose);
      if (availableCenters.length > 0) {
        prefs.setString("lastUpdatedOn",
            "Vaccination sessions are available, last updated on ${DateTime.now().toLocal().toString()}");
        NotificationManager.createAvailableNotification(availableCenters);
      } else {
        prefs.setString("lastUpdatedOn",
            "No Vaccination sessions are available, last updated on ${DateTime.now().toLocal().toString()}");
      }
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cowin Notifications",
      home: InputFilters(),
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        accentColor: Colors.blueAccent,

        // Define the default font family.
        fontFamily: 'Roboto',
      ),
    );
  }
}

class InputFilters extends StatefulWidget {
  InputFilters({Key key}) : super(key: key);

  @override
  _InputFiltersState createState() => new _InputFiltersState();
}

class _InputFiltersState extends State<InputFilters> {
  String filterPinCode = "";
  String filterAgeRestrictions = "";
  String filterDose = "1";
  bool enableNotifications = false;
  String lastUpdatedOn = "";
  SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    TextEditingController filterPinController =
        TextEditingController(text: filterPinCode);
    TextEditingController filterAgeController =
        TextEditingController(text: filterAgeRestrictions);
    return Scaffold(
        appBar: AppBar(
          title: Text("Cowin Vaccination Alerts"),
        ),
        body: Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  TextFormField(
                      controller: filterPinController,
                      decoration: InputDecoration(
                          hintText: "Enter Pin Code", labelText: "Pin Code")),
                  TextFormField(
                      controller: filterAgeController,
                      decoration: InputDecoration(
                          hintText: "Enter Age Restriction", labelText: "Age")),
                  DropdownButtonFormField(
                      value: filterDose,
                      decoration: InputDecoration(labelText: "Dose#"),
                      items: <String>['1', '2']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        prefs.setString("filterDose", value);
                        setState(() {
                          filterDose = value;
                        });
                      }),
                  Container(
                    child: Row(
                      children: [
                        Text("Enable nofitications"),
                        Switch(
                            value: enableNotifications ?? false,
                            onChanged: (value) {
                              if (filterPinController.text.isEmpty ||
                                  filterAgeController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        "Enter all filter parameters before enabling notifications")));
                              } else {
                                setState(() {
                                  filterPinCode = filterPinController.text;
                                  filterAgeRestrictions =
                                      filterAgeController.text;
                                  enableNotifications = value;
                                });

                                _setData(
                                    filterPinController.text,
                                    filterAgeController.text,
                                    value,
                                    filterDose);

                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        backgroundColor: Colors.indigoAccent,
                                        content: Text(
                                            "Notification settings updated")));

                                if (!value) {
                                  Workmanager().cancelByTag(COWIN_TAG);
                                } else {
                                  Workmanager().registerPeriodicTask(
                                    "2",
                                    NOTIFY_COWIN_TASK,
                                    initialDelay: Duration(seconds: 10),
                                    tag: COWIN_TAG,
                                  );
                                }
                              }
                            })
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.info_outlined, color: Colors.blue),
                      Flexible(
                          child: Text(enableNotifications ?? false
                              ? "You will be notified when dose #$filterDose vaccinations are available at $filterPinCode for age $filterAgeRestrictions and higher"
                              : "Notifications are disabled"))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timeline_outlined, color: Colors.blue),
                      Flexible(
                          child:
                              lastUpdatedOn != null && lastUpdatedOn.length > 0
                                  ? Text("$lastUpdatedOn")
                                  : Text("No Information Available"))
                    ],
                  ),
                  // ElevatedButton(
                  //     onPressed: () async {
                  //       List<String> availableCenters =
                  //           await GetAvailableSessions
                  //               .getAvailableSessionsForOneMonth(
                  //                   filterPinCode,
                  //                   filterAgeRestrictions,
                  //                   DateTime.now(),
                  //                   filterDose);
                  //       if (availableCenters.length > 0) {
                  //         NotificationManager.createAvailableNotification(
                  //             availableCenters);
                  //       }
                  //     },
                  //     child: Text("Check for Updates")),
                ]))));
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _getData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      filterPinCode = prefs.getString("filterPinCode");
      filterAgeRestrictions = prefs.getString("filterAgeRestrictions");
      enableNotifications = prefs.getBool("enableNotifications") ?? false;
      filterDose = prefs.getString("filterDose");
      lastUpdatedOn = prefs.getString("lastUpdatedOn");
    });
    if (enableNotifications == true) {
      Workmanager().registerPeriodicTask(
        "2",
        NOTIFY_COWIN_TASK,
        initialDelay: Duration(seconds: 10),
        tag: COWIN_TAG,
      );
    }
  }

  _setData(String pin, String ageRestrictions, bool enableNotifications,
      String filterDose) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("filterPinCode", pin);
    prefs.setString("filterAgeRestrictions", ageRestrictions);
    prefs.setBool("enableNotifications", enableNotifications);
    prefs.setString("filterDose", filterDose ?? 1);
  }
}
