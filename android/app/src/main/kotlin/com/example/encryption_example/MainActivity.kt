package com.example.encryption_example

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings
import android.os.Build
import java.io.File
import javax.crypto.Cipher
import javax.crypto.CipherOutputStream
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "encryption_channel").setMethodCallHandler { call, result ->
            when (call.method) {
                "encryptFile" -> {
                    val inputFile = call.argument<String>("inputFile")!!
                    val outputFile = call.argument<String>("outputFile")!!
                    val key = call.argument<ByteArray>("key")!!
                    val iv = call.argument<ByteArray>("iv")!!
                    encryptFile(inputFile, outputFile, key, iv)
                    result.success(null)
                }
                "decryptFile" -> {
                    val inputFile = call.argument<String>("inputFile")!!
                    val outputFile = call.argument<String>("outputFile")!!
                    val key = call.argument<ByteArray>("key")!!
                    val iv = call.argument<ByteArray>("iv")!!
                    decryptFile(inputFile, outputFile, key, iv)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }


    private fun encryptFile(inputFilePath: String, outputFilePath: String, key: ByteArray, iv: ByteArray) {
        val inputFile = File(inputFilePath)
        val outputFile = File(outputFilePath)
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(key, "AES"), IvParameterSpec(iv))

        inputFile.inputStream().use { input ->
            CipherOutputStream(outputFile.outputStream(), cipher).use { output ->
                val buffer = ByteArray(1024 * 1024) // 1MB buffer
                var read: Int
                while (input.read(buffer).also { read = it } != -1) {
                    output.write(buffer, 0, read)
                }
                output.flush()
            }
        }
    }

    private fun decryptFile(inputFilePath: String, outputFilePath: String, key: ByteArray, iv: ByteArray) {
        val inputFile = File(inputFilePath)
        val outputFile = File(outputFilePath)
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.DECRYPT_MODE, SecretKeySpec(key, "AES"), IvParameterSpec(iv))

        inputFile.inputStream().use { input ->
            CipherOutputStream(outputFile.outputStream(), cipher).use { output ->
                val buffer = ByteArray(1024 * 1024) // 1MB buffer
                var read: Int
                while (input.read(buffer).also { read = it } != -1) {
                    output.write(buffer, 0, read)
                }
                output.flush()
            }
        }
    }


}
