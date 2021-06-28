import 'dart:convert';

import 'package:anka/screens/form.dart';
import 'package:anka/router_generator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:http/http.dart' as http;

void main() async {
  runApp(AnkaApp());
}

class AnkaApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ANKA',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<dynamic, dynamic>> plans = [];
  int planID;
  bool loading = true;
  bool failed = false;

  void fetchPlans() async {
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      String apiUrl = "http://localhost:3000/plans";
      var url = Uri.parse(apiUrl);
      http.Response res = await http.get(url, headers: {'Accept': 'application/json', 'locale': 'fr'});

      setState(() {
        var data = List<Map>.from(jsonDecode(res.body) as List);
        plans = data;
        if (data.length > 0) {
          planID = data[0]['id'];
        }
        loading = false;
        failed = false;
      });
    }
    catch (e) {
      setState(() {
        loading = false;
        failed = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('ANKA'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.white,
            child: loading ? Text(AppLocalizations.of(context).loadingText)
                : failed ?
              Column(children: [
                Text(AppLocalizations.of(context).failureText),
                ElevatedButton(
                    onPressed: fetchPlans,
                    child: Text(AppLocalizations.of(context).tryAgainButtonText)
                ),
              ])
                : SubscriptionForm(plans: plans, selectedPlanID: planID)
          ),
        )
      )
    );
  }
}