package com.anashassaan.wifiscanner

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enforce Android 15 Edge-to-Edge windowing guidelines
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
