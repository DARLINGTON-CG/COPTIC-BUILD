import 'dart:async';
import 'dart:io';

import 'package:copticmeet/services/database/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchasesBloc {
  final Database database;

  InAppPurchasesBloc({@required this.database});

  void dispose() {
    _isPurchaseLoading.close();
  }

  StreamController<bool> _isPurchaseLoading =
      StreamController<bool>.broadcast();
  Stream<bool> get isPurchaseLoading => _isPurchaseLoading.stream;

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  void _updateIsPurchaseLoading(bool isLoading) =>
      _isPurchaseLoading.add(isLoading);

  List<PurchaseDetails> _purchases = [];
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;

  Future<List<ProductDetails>> getWeeklySubscriptionDetails() async {
    const Set<String> _kIds = {'copticmeet.weekly_subscription'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    if (!response.notFoundIDs.isEmpty) {

    }
    List<ProductDetails> product = response.productDetails;
    return product;
  }

  Future<List<ProductDetails>> getMonthlySubscriptionDetails() async {
    const Set<String> _kIds = {'copticmeet.monthly_subscription'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    if (!response.notFoundIDs.isEmpty) {

    }
    List<ProductDetails> product = response.productDetails;
    return product;
  }

  Future<List<ProductDetails>> getThreeMonthSubscriptionDetails() async {
    const Set<String> _kIds = {'copticmeet.three_monthly_subscription'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    if (!response.notFoundIDs.isEmpty) {

    }
    List<ProductDetails> product = response.productDetails;

    return product;
  }

  Future<List<ProductDetails>> getYearlySubscriptionDetails() async {
    const Set<String> _kIds = {'copticmeet.yearly_subscription'};
    final ProductDetailsResponse response =
        await InAppPurchaseConnection.instance.queryProductDetails(_kIds);
    if (!response.notFoundIDs.isEmpty) {

    }
    List<ProductDetails> product = response.productDetails;
    return product;
  }

  /// Gets past purchases
  Future<bool> getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();

    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }
    _purchases = response.pastPurchases;
    if (_purchases.length > 0 &&
        (_purchases[0].productID == 'copticmeet.yearly_subscription' ||
            _purchases[0].productID ==
                'copticmeet.three_monthly_subscription' ||
            _purchases[0].productID == 'copticmeet.monthly_subscription' ||
            _purchases[0].productID == 'copticmeet.weekly_subscription')) {
      return true;
    } else {
      return false;
    }
  }

  /// Returns purchase of specific product ID
  PurchaseDetails _hasPurchased(String productID) {
    return _purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  Future buyProduct({@required ProductDetails prod}) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    database.updateUserDetails({
      'proFeatures': {
        'preferedStarSign': 'Aries',
        'starSignFilterEnabled': 'false',
        'preferedLoveLanguage': 'Words of affirmation',
        'loveLanguageFilterEnabled': 'false',
        'preferedKidStatus': "Don't want",
        'kidFilterEnabled': 'false',
        'preferedEducation': "High School",
        'educationFilterEnabled': 'false',
        'preferredHeight': 'null,null',
        'heightFilterEnabled': 'false',
        'preferedDrinkStatus': 'Never',
        'DrinkFilterEnabled': 'false',
        'preferedFeministStatus': 'Absolutely',
        'FeministFilterEnabled': 'false',
        'preferedSmokeStatus': 'Never',
        'SmokeFilterEnabled': 'false',
      },
    });
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    firebaseMessaging.subscribeToTopic('proMode');
    //return true;
    // _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }

  /// Your own business logic to setup a consumable
  void _verifyPurchase(productID) {
    PurchaseDetails purchase = _hasPurchased(productID);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
   }
  }
}
