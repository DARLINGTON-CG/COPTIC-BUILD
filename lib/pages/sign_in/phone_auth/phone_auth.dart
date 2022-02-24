import 'dart:async';
import 'dart:convert';

import 'package:copticmeet/data_models/country_model.dart';
import 'package:copticmeet/pages/sign_in/phone_auth/phone_verification.dart';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/platform_exception_alert_dialog.dart';
import 'package:copticmeet/widgets/phone_auth_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PhoneAuthPage extends StatefulWidget {
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  double _height, _fixedPadding;

  List<Country> countries = [];
  StreamController<List<Country>> _countriesStreamController;
  Stream<List<Country>> _countriesStream;
  Sink<List<Country>> _countriesSink;

  TextEditingController _searchCountryController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  int _selectedCountryIndex = 234;

  bool _isCountriesDataFormed = false;

  bool _isLoading = false;

  FocusNode focusNode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchCountryController.dispose();
    super.dispose();
  }

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
            title: 'Phone authentication failed', exception: exception)
        .show(context);
  }

  Future<List<Country>> loadCountriesJson() async {
    countries.clear();
    var value = await DefaultAssetBundle.of(context)
        .loadString("assets/data/country_codes/country_phone_codes.json");
    var countriesJson = json.decode(value);
    for (var country in countriesJson) {
      countries.add(Country.fromJson(country));
    }
    return countries;
  }

  Future<void> _verifyPhoneNumber(BuildContext context, phoneNumber) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.verifyPhoneNumber(phoneNumber, onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhoneVerification(
                    phoneNumber: countries[_selectedCountryIndex].dialCode +
                        _phoneNumberController.text,
                  )),
        );
      });
    } catch (e) {
      _showSignInError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _fixedPadding = _height * 0.025;

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      if (countries.length < 240) {
        loadCountriesJson().whenComplete(() {
          setState(() => _isCountriesDataFormed = true);
        });
      }
    });
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                  begin: const FractionalOffset(1.0, 0.0),
                  end: const FractionalOffset(0.0, 0.7),
                  stops: [0.3, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Container(
              child: Card(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: MediaQuery.of(context).size.height / 1.2,
                      color: Colors.white,
                      child: (Column(children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )),
                        Align(
                          alignment: Alignment(0.0, -0.65),
                          child: Container(
                              width: MediaQuery.of(context).size.width / 1.7,
                              child: Image(
                                  image: AssetImage(
                                      'assets/images/logos/large/logo.png'))),
                        ),
                        Align(
                            alignment: Alignment(0.0, 0.5),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _isCountriesDataFormed
                                      ? _getColumnBody()
                                      : Center(
                                          child: CircularProgressIndicator(backgroundColor:Theme.of(context).primaryColor,color: Colors.white,)),
                                ])),
                      ]))),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _getColumnBody() => SingleChildScrollView(
      child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: _fixedPadding, left: _fixedPadding),
              child: PhoneAuthWidgets.subTitle('Select your country'),
            ),
            Padding(
              padding: EdgeInsets.only(left: _fixedPadding, right: _fixedPadding),
              child: PhoneAuthWidgets.selectCountryDropDown(
                  countries[_selectedCountryIndex], showCountries),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: _fixedPadding),
              child: PhoneAuthWidgets.subTitle('Enter your phone'),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: _fixedPadding,
                  right: _fixedPadding,
                  bottom: _fixedPadding),
              child: Card(
                child: TextFormField(
                  controller: _phoneNumberController,
                  autofocus: true,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  key: Key('EnterPhone-TextFormField'),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    errorMaxLines: 1,
                    prefix: Text(
                        "  " + countries[_selectedCountryIndex].dialCode + "  "),
                  ),
                ),
              ),
            ),
            _isLoading != true
                ? Text(
                    'We will send the One Time Passcode to this mobile number to verify your account',
                    style: Theme.of(context).textTheme.body2,
                    textAlign: TextAlign.center)
                : Padding(
                    padding: EdgeInsets.all(10),
                    child: Wrap(
                      children: <Widget>[
                        CircularProgressIndicator(
                            backgroundColor: Theme.of(context).primaryColor,color: Colors.white,)
                      ],
                    ),
                  ),
            SizedBox(height: _fixedPadding * 1.1),
            RaisedButton(
              elevation: 16.0,
              onPressed: () async {
                setState(() => _isLoading = true);
                await _verifyPhoneNumber(
                        context,
                        countries[_selectedCountryIndex].dialCode +
                            _phoneNumberController.text)
                    .then((value) {});
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Send Verification Code',
                  style: Theme.of(context).textTheme.body2,
                ),
              ),
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ],
        ),
  );

  showCountries() {
    _countriesStreamController = StreamController();
    _countriesStream = _countriesStreamController.stream;
    _countriesSink = _countriesStreamController.sink;
    _countriesSink.add(countries);

    _searchCountryController.addListener(searchCountries);

    showDialog(
        context: context,
        builder: (BuildContext context) => searchAndPickYourCountryHere(),
        barrierDismissible: false);
  }

  searchCountries() {
    String query = _searchCountryController.text;
    if (query.length == 0 || query.length == 1) {
      if (!_countriesStreamController.isClosed) _countriesSink.add(countries);
    } else if (query.length >= 2 && query.length <= 5) {
      List<Country> searchResults = [];
      searchResults.clear();
      countries.forEach((Country c) {
        if (c.toString().toLowerCase().contains(query.toLowerCase()))
          searchResults.add(c);
      });
      _countriesSink.add(searchResults);
    } else {
      List<Country> searchResults = [];
      _countriesSink.add(searchResults);
    }
  }

  Widget searchAndPickYourCountryHere() => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Dialog(
          key: Key('SearchCountryDialog'),
          elevation: 8.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Container(
            margin: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PhoneAuthWidgets.searchCountry(_searchCountryController),
                SizedBox(
                  height: 260.0,
                  child: StreamBuilder<List<Country>>(
                      stream: _countriesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data.length == 0
                              ? Center(
                                  child: Text('Your search found no results',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: "Papyrus")),
                                )
                              : ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int i) =>
                                      PhoneAuthWidgets.selectableWidget(
                                          snapshot.data[i],
                                          (Country c) => selectThisCountry(c)),
                                );
                        } else if (snapshot.hasError)
                          return Center(
                            child: Text('Seems, there is an error',
                                style: TextStyle(
                                    fontSize: 16.0, fontFamily: "Papyrus")),
                          );
                        return Center(child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,));
                      }),
                )
              ],
            ),
          ),
        ),
      );

  void selectThisCountry(Country country) {
    _searchCountryController.clear();
    Navigator.of(context).pop();
    Future.delayed(Duration(milliseconds: 10)).whenComplete(() {
      _countriesStreamController.close();
      _countriesSink.close();

      setState(() {
        _selectedCountryIndex = countries.indexOf(country);
      });
    });
  }
}
