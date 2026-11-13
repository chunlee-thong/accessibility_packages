package com.lynical.accessibility_packages

import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Build
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AccessibilityPackagesPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.lynical.accessibility_packages")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            val am = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
            when (call.method) {
                "getEnabledServices" -> {
                    val enabled = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
                    result.success(enabled.map { toMap(it, true) })
                }
                "getInstalledServices" -> {
                    val enabledIds = am
                        .getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
                        .map { it.id }
                        .toSet()
                    val installed = am.installedAccessibilityServiceList
                    result.success(installed.map { toMap(it, enabledIds.contains(it.id)) })
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("ACCESSIBILITY_ERROR", e.message, null)
        }
    }

    private fun toMap(info: AccessibilityServiceInfo, enabled: Boolean): Map<String, Any?> {
        val pm = context.packageManager
        val si = info.resolveInfo.serviceInfo
        val flags = si.applicationInfo.flags
        val isSystem = (flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
            (flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0

        return mapOf(
            "packageName" to si.packageName,
            "appName" to si.applicationInfo.loadLabel(pm).toString(),
            "serviceName" to si.name,
            "serviceId" to info.id,
            "isEnabled" to enabled,
            "isSystemApp" to isSystem,
            "capabilities" to capabilityNames(info.capabilities),
            "description" to try { info.loadDescription(pm) } catch (e: Exception) { null }
        )
    }

    private fun capabilityNames(caps: Int): List<String> {
        val out = mutableListOf<String>()
        if (caps and AccessibilityServiceInfo.CAPABILITY_CAN_RETRIEVE_WINDOW_CONTENT != 0) out += "retrieveWindowContent"
        if (caps and AccessibilityServiceInfo.CAPABILITY_CAN_REQUEST_TOUCH_EXPLORATION != 0) out += "touchExploration"
        if (caps and AccessibilityServiceInfo.CAPABILITY_CAN_REQUEST_FILTER_KEY_EVENTS != 0) out += "filterKeyEvents"
        if (Build.VERSION.SDK_INT >= 26 &&
            caps and AccessibilityServiceInfo.CAPABILITY_CAN_PERFORM_GESTURES != 0) out += "performGestures"
        if (Build.VERSION.SDK_INT >= 21 &&
            caps and AccessibilityServiceInfo.CAPABILITY_CAN_REQUEST_ENHANCED_WEB_ACCESSIBILITY != 0) out += "enhancedWebAccessibility"
        return out
    }
}
