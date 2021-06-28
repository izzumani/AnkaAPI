import 'package:anka/screens/completed.dart';
import 'package:flutter/material.dart';
import 'package:anka/screens/three_ds.dart';

import 'package:anka/main.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
      case '/3ds':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ThreeDS(
              url: args,
            ),
          );
        }
        break;
      case '/completed':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => Completed(
              url: args,
              userID: null,
            ),
          );
        }
        break;
      case '/profile':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => Completed(
              url: null,
              userID: args,
            ),
          );
        }

        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}