import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';

abstract class CustomEncryptor {
  static const MethodChannel _encryptionChannel =
      MethodChannel('encryption_channel');

  static Future<void> encryptFile({
    required String inputFile,
    required String outputFile,
  }) async {
    Key key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16).bytes;
    try {
      _encryptionChannel.invokeMethod('encryptFile', {
        'inputFile': inputFile,
        'outputFile': outputFile,
        'key': key,
        'iv': iv,
      }).then((value) {
        File(inputFile).deleteSync();
        print("Done");
      });
    } on PlatformException catch (e) {
      print('Failed to encrypt file: ${e.message}');
    }
  }

  static Future<void> decryptFile({
    required String inputFile,
    required String outputFile,
  }) async {
    Key key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16).bytes;

    try {
      await _encryptionChannel.invokeMethod('decryptFile', {
        'inputFile': inputFile,
        'outputFile': outputFile,
        'key': key,
        'iv': iv,
      }).then((value) {
        print("done");
      });
    } on PlatformException catch (e) {
      print('Failed to decrypt file: ${e.message}');
    }
  }
}
