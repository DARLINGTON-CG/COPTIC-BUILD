import 'dart:async';
import 'package:copticmeet/services/sign_in/auth.dart';
import 'package:flutter/foundation.dart';

class SignInBloc {
  SignInBloc({@required this.auth});
  final AuthBase auth;
  final StreamController<bool> _isLoadingController = StreamController<bool>();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  void dispose() {
    _isLoadingController.close();
  }

  void _setIsLoading(bool isLoading) => _isLoadingController.add(isLoading);

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      _setIsLoading(true);
      return await signInMethod();
    } catch (e) {
      _setIsLoading(false);
      rethrow;
    }
  }

  Future<User> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);

  Future<User> verifyPhoneNumber(phoneNumber, {VoidCallback onPressed}) async {
    try {
      _setIsLoading(true);
      return await auth.verifyPhoneNumber(phoneNumber, onPressed: onPressed);
    } catch (e) {
      _setIsLoading(false);
      rethrow;
    }
  }

  Future<User> signInWithPhoneNumber(phoneNumber) async {
    try {
      _setIsLoading(true);
      return await auth.signInWithPhoneNumber(phoneNumber);
    } catch (e) {
      _setIsLoading(false);
      rethrow;
    }
  }
}
