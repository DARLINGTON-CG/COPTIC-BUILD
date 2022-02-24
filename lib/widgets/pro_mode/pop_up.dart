import 'dart:io';

import 'package:copticmeet/services/BLoCs/in_app_purchases/in_app_purchases_bloc.dart';
import 'package:copticmeet/services/database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseProPopup extends StatelessWidget {
  const PurchaseProPopup({Key key, @required this.bloc}) : super(key: key);
  final bloc;

  static Widget create(BuildContext context, {@required Database database}) {
    return Provider<InAppPurchasesBloc>(
      create: (_) => InAppPurchasesBloc(database: database),
      dispose: (context, bloc) => bloc.dispose(),
      child: Consumer<InAppPurchasesBloc>(
          builder: (BuildContext context, bloc, _) => PurchaseProPopup(
                bloc: bloc,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    bloc.getPastPurchases();
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0))),
      content: Builder(
        builder: (context) {
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;
          return StreamBuilder<Object>(
              stream: bloc.isPurchaseLoading,
              initialData: false,
              builder: (context, isLoading) {
                return SafeArea(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: height - 250,
                      width: width - 30,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Title(
                                    color: Colors.white,
                                    child: Text(
                                      'Pro Mode',
                                      style: Theme.of(context).textTheme.body1,
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'With Pro Mode you get access to advanced filters, unlimited undo’s, unlimited double likes, and the ability to change your location. Pro Mode also allows you to see users who liked your profile.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Papyrus', fontSize: 12),
                                ),
                              ),
                              Container(
                                height:
                                    MediaQuery.of(context).size.height / 2.4,
                                child: Center(
                                  child: GridView.count(
                                    primary: true,
                                    physics: new NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    scrollDirection: Axis.vertical,
                                    children: [
                                      FutureBuilder<List<ProductDetails>>(
                                          future: bloc
                                              .getWeeklySubscriptionDetails(),
                                          builder:
                                              (context, weeklySubscription) {
                                            if (weeklySubscription.hasData) {
                                              if (weeklySubscription
                                                  .data.isNotEmpty) {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  ProductDetails
                                                                      product =
                                                                      weeklySubscription
                                                                          .data[0];
                                                                  bloc.buyProduct(
                                                                      prod:
                                                                          product);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                14,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Image.asset('assets/images/pro_mode_icons/one_week.png'),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'One Week',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Papyrus',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.normal),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                              isLoading.data
                                                                  ? Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child: Card(
                                                                          color: Colors
                                                                              .grey,
                                                                          child:
                                                                              Center(child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,))),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          weeklySubscription
                                                              .data[0].price,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              } else {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                16,
                                                                        child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: Center(child: Icon(Icons.error_outline, color: Colors.redAccent))),
                                                                      ),
                                                                      Text(
                                                                        'Failed to connect',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .body2,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          '--.--',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              }
                                            } else {
                                              return Center(
                                                  child: Stack(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Stack(
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              child: Card(
                                                                  child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          14,
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(
                                                                            child:
                                                                                CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,),
                                                                          )),
                                                                    ),
                                                                    Text(
                                                                      'Loading Products',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .body2,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Chip(
                                                      label: Text(
                                                        '--.--',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Papyrus',
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ));
                                            }
                                          }),
                                      FutureBuilder<List<ProductDetails>>(
                                          future: bloc
                                              .getMonthlySubscriptionDetails(),
                                          builder:
                                              (context, weeklySubscription) {
                                            if (weeklySubscription.hasData) {
                                              if (weeklySubscription
                                                  .data.isNotEmpty) {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                onTap: () {
                                                                  bloc.buyProduct(
                                                                      prod: weeklySubscription
                                                                          .data[0]);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                14,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Image.asset('assets/images/pro_mode_icons/one_month.png'),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'One Month',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Papyrus',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.normal),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                              isLoading.data
                                                                  ? Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child: Card(
                                                                          color: Colors
                                                                              .grey,
                                                                          child:
                                                                              Center(child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,))),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          weeklySubscription
                                                              .data[0].price,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              } else {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                16,
                                                                        child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: Center(child: Icon(Icons.error_outline, color: Colors.redAccent))),
                                                                      ),
                                                                      Text(
                                                                        'Failed to connect',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .body2,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          '--.--',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              }
                                            } else {
                                              return Center(
                                                  child: Stack(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Stack(
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              child: Card(
                                                                  child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          14,
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(
                                                                            child:
                                                                                CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,),
                                                                          )),
                                                                    ),
                                                                    Text(
                                                                      'Loading Products',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .body2,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Chip(
                                                      label: Text(
                                                        '--.--',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Papyrus',
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ));
                                            }
                                          }),
                                      FutureBuilder<List<ProductDetails>>(
                                          future: bloc
                                              .getThreeMonthSubscriptionDetails(),
                                          builder:
                                              (context, weeklySubscription) {
                                            if (weeklySubscription.hasData) {
                                              if (weeklySubscription
                                                  .data.isNotEmpty) {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                onTap: () {
                                                                  ProductDetails
                                                                      product =
                                                                      weeklySubscription
                                                                          .data[0];
                                                                  bloc.buyProduct(
                                                                      prod:
                                                                          product);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                14,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Image.asset('assets/images/pro_mode_icons/three_months.png'),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'Three Months',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Papyrus',
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.normal),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                              isLoading.data
                                                                  ? Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child: Card(
                                                                          color: Colors
                                                                              .grey,
                                                                          child:
                                                                              Center(child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,))),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          weeklySubscription
                                                              .data[0].price,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              } else {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                16,
                                                                        child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: Center(child: Icon(Icons.error_outline, color: Colors.redAccent))),
                                                                      ),
                                                                      Text(
                                                                        'Failed to connect',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .body2,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          '--.--',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              }
                                            } else {
                                              return Center(
                                                  child: Stack(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Stack(
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              child: Card(
                                                                  child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          14,
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(
                                                                            child:
                                                                                CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,),
                                                                          )),
                                                                    ),
                                                                    Text(
                                                                      'Loading Products',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .body2,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Chip(
                                                      label: Text(
                                                        '--.--',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Papyrus',
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ));
                                            }
                                          }),
                                      FutureBuilder<List<ProductDetails>>(
                                          future: bloc
                                              .getYearlySubscriptionDetails(),
                                          builder:
                                              (context, weeklySubscription) {
                                            if (weeklySubscription.hasData) {
                                              if (weeklySubscription
                                                  .data.isNotEmpty) {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                onTap: () {
                                                                  ProductDetails
                                                                      product =
                                                                      weeklySubscription
                                                                          .data[0];
                                                                  bloc.buyProduct(
                                                                      prod:
                                                                          product);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                14,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Image.asset('assets/images/pro_mode_icons/lifetime.png'),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'One Year',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                'Papyrus',
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.normal),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                              isLoading.data
                                                                  ? Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child: Card(
                                                                          color: Colors
                                                                              .grey,
                                                                          child:
                                                                              Center(child: CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,))),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          weeklySubscription
                                                              .data[0].price,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              } else {
                                                return Center(
                                                    child: Stack(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Stack(
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                child: Card(
                                                                    child:
                                                                        Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        height:
                                                                            MediaQuery.of(context).size.height /
                                                                                16,
                                                                        child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: Center(child: Icon(Icons.error_outline, color: Colors.redAccent))),
                                                                      ),
                                                                      Text(
                                                                        'Failed to connect',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .body2,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Chip(
                                                        label: Text(
                                                          '--.--',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Papyrus',
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                              }
                                            } else {
                                              return Center(
                                                  child: Stack(
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Stack(
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              child: Card(
                                                                  child: Center(
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height /
                                                                          16,
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Center(
                                                                            child:
                                                                                CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,color: Colors.white,),
                                                                          )),
                                                                    ),
                                                                    Text(
                                                                      'Loading Products',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .body2,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Chip(
                                                      label: Text(
                                                        '--.--',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Papyrus',
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ));
                                            }
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                              Platform.isIOS
                                  ? Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Title(
                                          color: Colors.white,
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: <Widget>[
                                              Linkify(
                                                text:
                                                    'Billing is recurring. Cancel anytime through your iTunes & App Store Account Settings.\n\nYour subscription automatically renews unless you turn off auto-renewal at least 24 hours before the end of the current period.\n\nAll personal data is handled under the Privacy Policy & Terms and Conditions of Coptic Meet.  More details can be found here: https://www.copticmeet.com/terms-conditions  https://www.copticmeet.com/privacy-policy',
                                                style: TextStyle(
                                                    fontFamily: 'Papyrus',
                                                    fontSize: 11,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                textAlign: TextAlign.center,
                                                onOpen: (link) async {
                                                  if (await canLaunch(
                                                      link.url)) {
                                                    await launch(link.url);
                                                  } else {
                                                    throw 'Could not launch $link';
                                                  }
                                                },
                                              ),
                                            ],
                                          )),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Title(
                                          color: Colors.white,
                                          child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: <Widget>[
                                              Linkify(
                                                text:
                                                    'Billing is recurring. Cancel anytime through your Google Play Store & Play Store Account Settings.\n\nYour subscription automatically renews unless you turn off auto-renewal at least 24 hours before the end of the current period.\n\nAll personal data is handled under the Privacy Policy & Terms and Conditions of Coptic Meet.  More details can be found here: https://www.copticmeet.com/terms-conditions  https://www.copticmeet.com/privacy-policy',
                                                style: TextStyle(
                                                    fontFamily: 'Papyrus',
                                                    fontSize: 11,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                textAlign: TextAlign.center,
                                                onOpen: (link) async {
                                                  if (await canLaunch(
                                                      link.url)) {
                                                    await launch(link.url);
                                                  } else {
                                                    throw 'Could not launch $link';
                                                  }
                                                },
                                              ),
                                            ],
                                          )),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}