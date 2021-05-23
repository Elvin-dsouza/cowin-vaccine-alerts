import 'package:cowin_notification_app/get_available_sessions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const String COWIN_TAG = "COWIN_NOTIFICATIONS";
const String NOTIFY_COWIN_TASK = "NOTIFY_COWIN_CRITERIA";
void callbackDispatcher() {
  print("Hello world");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Cowin Notifications", home: InputFilters());
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
  SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    TextEditingController filterPinController = TextEditingController();
    TextEditingController filterAgeController = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Cowin Alert"),
        ),
        body: Container(
            child: Column(children: [
          TextFormField(
              controller: filterPinController,
              decoration: InputDecoration(hintText: "Enter Pin Code")),
          TextFormField(
              controller: filterAgeController,
              decoration: InputDecoration(hintText: "Enter Age Restriction")),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  filterPinCode = filterPinController.text;
                  filterAgeRestrictions = filterAgeController.text;
                });

                _setData(filterPinController.text, filterAgeController.text);
              },
              child: Text("Update Alert Criteria")),
          Text("Filtering By $filterPinCode $filterAgeRestrictions")
        ])));
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
    });
    Workmanager().registerPeriodicTask(
      "cowin:task:notify:when_criteria_met",
      NOTIFY_COWIN_TASK,
      initialDelay: Duration(seconds: 10),
      frequency: Duration(hours: 1),
      tag: COWIN_TAG,
    );
  }

  _setData(String pin, String ageRestrictions) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("filterPinCode", pin);
    prefs.setString("filterAgeRestrictions", ageRestrictions);
  }
}

class ShowAPIPage extends StatefulWidget {
  ShowAPIPage({Key key}) : super(key: key);

  @override
  _ShowAPIPageState createState() => new _ShowAPIPageState();
}

class _ShowAPIPageState extends State<ShowAPIPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Cowin Notifications")),
        body: FutureBuilder(
            future: GetAvailableSessions.getAvailableSessions(),
            initialData: "loading",
            builder: (context, snapshot) {
              final centers = snapshot.data;
              if (snapshot.connectionState == ConnectionState.done) {
                return ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(centers[index]),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: centers.length);
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
