package com.apuwaqay.apu_waqay

import android.telephony.SmsManager
import android.os.Bundle
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.apuwaqay/sms"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendDirectSMS") {
                val phone = call.argument<String>("phone")
                val msg = call.argument<String>("msg")

                if (phone != null && msg != null) {
                    sendSMS(phone, msg)
                    result.success("Enviado")
                } else {
                    result.error("ERROR", "Datos incompletos", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSMS(phoneNumber: String, message: String) {
        try {
            val smsManager = SmsManager.getDefault()
            // Usamos null en los PendingIntent para evitar el crash de flags en Android moderno
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}