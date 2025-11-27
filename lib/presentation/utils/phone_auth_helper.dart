import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthHelper {
  const PhoneAuthHelper._();

  static Future<PhoneOtpData> requestOtp(
    String phoneNumber, {
    int? resendToken,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final completer = Completer<PhoneOtpData>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      forceResendingToken: resendToken,
      verificationCompleted: (credential) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneOtpData(
              phoneNumber: phoneNumber,
              credential: credential,
              resendToken: resendToken,
            ),
          );
        }
      },
      verificationFailed: (exception) {
        if (!completer.isCompleted) {
          completer.completeError(exception);
        }
      },
      codeSent: (verificationId, newResendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneOtpData(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              resendToken: newResendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }
}

class PhoneOtpData {
  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final PhoneAuthCredential? credential;

  const PhoneOtpData({
    required this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.credential,
  });
}



