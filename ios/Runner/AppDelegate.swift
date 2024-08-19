import UIKit
import Flutter
import CryptoSwift
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Handel FlutterMethodChannel
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceChannel = FlutterMethodChannel(name: "encryption_channel",
                                              binaryMessenger: controller.binaryMessenger)
    prepareMethodHandler(deviceChannel: deviceChannel)
    //////////

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handel Call Methods
  private func prepareMethodHandler(deviceChannel: FlutterMethodChannel) {
      deviceChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          guard let args = call.arguments as? [String: Any] else {
              result(FlutterMethodNotImplemented)
              return
          }
          if call.method == "encryptFile" {
              guard let inputFile = args["inputFile"] as? String,
                    let outputFile = args["outputFile"] as? String,
                    let key = args["key"] as? String else {
                  result(FlutterMethodNotImplemented)
                  return
              }
              do {
                  try self.encryptFile(inputPath: inputFile, outputPath: outputFile, key: key)
                  result(nil)
              } catch {
                  result(error.localizedDescription)
              }
          } else if call.method == "decryptFile" {
              guard let inputFile = args["inputFile"] as? String,
                    let outputFile = args["outputFile"] as? String,
                    let key = args["key"] as? String else {
                  result(FlutterMethodNotImplemented)
                  return
              }
              do {
                  try self.decryptFile(inputPath: inputFile, outputPath: outputFile, key: key)
                  result(nil)
              } catch {
                  result(error.localizedDescription)
              }
          } else {
              result(FlutterMethodNotImplemented)
          }
      }
    )
  }

  // Encrypt File
  func encryptFile(inputPath: String,outputPath: String, key: String) throws {

    let inputFileURL = URL(fileURLWithPath: inputPath)
    let outputFileURL = URL(fileURLWithPath: outputPath)
    let key: [UInt8] = Array(key.utf8)
    let iv: [UInt8] = AES.randomIV(AES.blockSize)
    let chunkSize = 1024 * 1024 // 1 MB


    let inputStream = InputStream(url: inputFileURL )!
    let outputStream = OutputStream(url: outputFileURL, append: false)!
    inputStream.open()
    outputStream.open()

    var buffer = [UInt8](repeating: 0, count: chunkSize)
    var bytesRead = inputStream.read(&buffer, maxLength: buffer.count)

    while bytesRead > 0 {
        let chunk = Array(buffer[0..<bytesRead])
        let encryptedChunk = try AES(key: key, blockMode: CBC(iv: iv)).encrypt(chunk)
        outputStream.write(encryptedChunk, maxLength: encryptedChunk.count)
        bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
    }

    inputStream.close()
    outputStream.close()
  }

  // Decrypt File
  func decryptFile(inputPath: String,outputPath: String, key: String) throws {

    let encryptedFileURL = URL(fileURLWithPath: inputPath)
    let decryptedFileURL = URL(fileURLWithPath: outputPath)
    let key: [UInt8] = Array(key.utf8)
    let iv: [UInt8] = AES.randomIV(AES.blockSize)
    let chunkSize = 1024 * 1024 // 1 MB


    let encryptedInputStream = InputStream(url: encryptedFileURL)!
    let decryptedOutputStream = OutputStream(url: decryptedFileURL, append: false)!
    encryptedInputStream.open()
    decryptedOutputStream.open()

    var encryptedBuffer = [UInt8](repeating: 0, count: chunkSize)
    var encryptedBytesRead = encryptedInputStream.read(&encryptedBuffer, maxLength: encryptedBuffer.count)

    while encryptedBytesRead > 0 {
        let encryptedChunk = Array(encryptedBuffer[0..<encryptedBytesRead])
        let decryptedChunk = try AES(key: key, blockMode: CBC(iv: iv)).decrypt(encryptedChunk)
        decryptedOutputStream.write(decryptedChunk, maxLength: decryptedChunk.count)
        encryptedBytesRead = encryptedInputStream.read(&encryptedBuffer, maxLength: encryptedBuffer.count)
    }

    encryptedInputStream.close()
    decryptedOutputStream.close()

  }

}

