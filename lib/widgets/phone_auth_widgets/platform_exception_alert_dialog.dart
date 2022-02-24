import 'package:copticmeet/widgets/phone_auth_widgets/platform_aler_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog({
    @required String title, 
    @required PlatformException exception
  }) : super (
    title: title,
    content: _message(exception),
    defaultActionText: 'Ok'
  );

  static String _message(PlatformException exception) {
    return _errors[exception.message] ?? exception.message;
  }

  static Map<String, String> _errors = {
    'ERROR_INVALID_CREDENTIAL':'The credentials are invalid or have expired',
    'ERROR_USER_DISABLED':'Your account has been disabled'
    /// 
    ///  * `ERROR_INVALID_CUSTOM_TOKEN` - The custom token format is incorrect.
    ///     Please check the documentation.
    ///  * `ERROR_CUSTOM_TOKEN_MISMATCH` - Invalid configuration.
    ///     Ensure your app's SHA1 is correct in the Firebase console.
  };
}