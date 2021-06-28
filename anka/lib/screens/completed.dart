import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class Completed extends StatefulWidget {
  final String url;
  final String userID;
  const Completed({Key key, this.url, this.userID}) : super(key: key);

  @override
  _CompletedState createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  bool loading = false;
  String email;
  String createdAt;
  String subscriptionType;
  String subscriptionStatus;

  void completeProcess(String url, String id) async {
    String apiURL = 'http://localhost:3000/payment/check?locale=${Intl.getCurrentLocale()}';

    var res;
    if (url == null) {
      apiURL = 'http://localhost:3000/users/$id?locale=${Intl.getCurrentLocale()}';
    }
      try {
        var apiUrl = Uri.parse(apiURL);
        if(url != null) {
          var uri = Uri.dataFromString(url);
          Map<String, String> params = uri.queryParameters;

          res = await http.post(
              apiUrl, headers: {'Content-Type': 'application/json'},
              body: jsonEncode(params)
          );
        }else{
           res = await http.get(apiUrl, headers: {'Content-Type': 'application/json'});
        }
        Map<String, dynamic> data = jsonDecode(res.body);

        setState(() {
          loading = false;
          subscriptionStatus = (data['subscription_status']) ? 'active': 'inactive';
          subscriptionType = data['subscription_type'];

          email = data['email'];
          createdAt = data['created_at'];
        });
      }
      catch (e) {
        setState(() {
          loading = false;
        });
      }

  }

  @override
  void initState() {
    super.initState();
    completeProcess(widget.url, widget.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            title: Text(AppLocalizations.of(context).congratulations),
          ),
          (loading ? Text(AppLocalizations.of(context).loadingText) : SizedBox(height: 10.0)),
          SizedBox(height: 10.0),
          Text(
            '${AppLocalizations.of(context).emailFieldLabel}: $email',
            style: TextStyle(
              color: Colors.black,
              backgroundColor: Colors.white,
              fontSize: 14.0,
              decoration: TextDecoration.none
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            '${AppLocalizations.of(context).subscriptionType}: $subscriptionType',
            style: TextStyle(
                color: Colors.black,
                backgroundColor: Colors.white,
                fontSize: 14.0,
                decoration: TextDecoration.none
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            '${AppLocalizations.of(context).subscriptionStatus}: $subscriptionStatus',
            style: TextStyle(
                color: Colors.black,
                backgroundColor: Colors.white,
                fontSize: 14.0,
                decoration: TextDecoration.none
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            '${AppLocalizations.of(context).subscriptionDate}: $createdAt',
            style: TextStyle(
                color: Colors.black,
                backgroundColor: Colors.white,
                fontSize: 14.0,
                decoration: TextDecoration.none
            ),
          ),
          SizedBox(height: 40.0),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: SvgPicture.asset('images/anka-logo.svg'),
          ),
          SizedBox(height: 10.0),
        ],
      )
    );
  }
}
