import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubscriptionForm extends StatefulWidget {
  List<Map> plans ;
  int selectedPlanID;
  bool loading = false;

  SubscriptionForm({Key key, this.plans, this.selectedPlanID}) : super(key: key);

  @override
  _SubscriptionFormState createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<SubscriptionForm> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryDateController = TextEditingController();
  final TextEditingController cardCVCController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final delegate = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: widget.loading ?
      Text(delegate.loadingText) :
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              key: Key("email"),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                labelText: 'Email',
              ),
              validator: (value) {
                if (EmailValidator.validate(value) == false) {
                  return delegate.emailValidationMsg;
                }
                return null;
              },
            ),
            Row(
              children: widget.plans.map((plan) {
                return Expanded(
                    child: Card(
                        color: ((widget.selectedPlanID == plan['id']) ? Colors.purple[100] : Colors.white),
                        key: Key('plan-$plan.id'),
                        child: Column(
                            children: <Widget>[
                              Text(plan['title'],
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 10.0,),
                              Text(plan['description']),
                              SizedBox(height: 10.0,),
                              Text("€ ${plan['fees']}/${delegate.perMonthText}"),
                              TextButton(
                                  onPressed: (){
                                    setState(() {
                                      widget.selectedPlanID = plan['id'];
                                    });
                                  },
                                  child: Text(delegate.chosePlanButtonText,
                                      key: Key("choose-plan-${plan['id']}")
                                  )
                              )
                            ]
                        )
                    )
                );
              }).toList(),
            ),
            TextFormField(
                controller: cardHolderController,
                key: Key("card_holder"),
              decoration: const InputDecoration(
                hintText: 'E.g Joana Anka',
                labelText: 'Card holder',
              ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return delegate.cardHolderValidationMsg;
                  }
                  return null;
                }
            ),
            TextFormField(
              controller: cardNumberController,
              key: Key("card_number"),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'E.g 4714 7123 0061 0237',
                labelText: 'Card number',
              ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return delegate.cardNumberValidationMsg;
                  }
                  return null;
                }
            ),
            Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(child: TextFormField(
                    controller: cardExpiryDateController,
                    key: Key("card_expiry_date"),
                    decoration: const InputDecoration(
                        hintText: 'E.g 04/24',
                        labelText: 'Card Expiry date'
                    ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return delegate.cardExpiryDateValidationMsg;
                        }
                        return null;
                      }
                  ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: cardCVCController,
                      keyboardType: TextInputType.number,
                      key: Key("card_cvc"),
                      decoration: const InputDecoration(
                          hintText: 'E.g 262',
                          labelText: 'Code'
                      ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length != 3) {
                            return delegate.cardCVCValidationMsg;
                          }
                          return null;
                        }
                    ),
                  ),
                ]
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      Map data = {
                        'email': emailController.text,
                        'locale': 'fr',
                        'subscription_plan_id': widget.selectedPlanID,
                        'card_number': cardNumberController.text,
                        'card_holder_name': cardHolderController.text,
                        'card_expiry_date': cardExpiryDateController.text,
                        'card_cvc': cardCVCController.text,
                      };
                      setState(() {
                        widget.loading = true;
                      });
                      var apiUrl = Uri.parse("http://localhost:3000/users");
                      final response = await http.post(apiUrl, headers: {'Content-Type': 'application/json'}, body: jsonEncode(data));
                      var result = jsonDecode(response.body);
                      setState(() {
                        widget.loading = false;
                      });
                      bool redirect = result['payment']['table']['redirect'];

                      if (redirect) {
                        String url = result['payment']['table']['url'];
                        Navigator.pushNamed(context, '/3ds', arguments: url);
                      }else{
                        String userID = result['user']['id'].toString();
                        Navigator.pushNamed(context, '/profile', arguments: userID);
                      }
                    }
                  },
                  child: Text(delegate.submitButtonText),
                )
            )
          ]
      )
    );
  }
}
