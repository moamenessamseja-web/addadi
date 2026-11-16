#!/usr/bin/env bash
# Runs in CI after `flutter create` generated android/ (android/ is not committed).
# 1. Arabic launcher label.
# 2. What flutter_local_notifications needs natively: permissions, the two receivers, core-library desugaring,
#    and R8 keep rules (release builds are shrunk). Same injections that built and ran on the owner's phone in
#    manager-assistant-ready (commit d2a17ef), minus SCHEDULE_EXACT_ALARM: reminders here are inexact on purpose.
# Fails loudly if the generated files do not look as expected.
set -euo pipefail

manifest="android/app/src/main/AndroidManifest.xml"
test -f "$manifest" || { echo "missing $manifest"; exit 1; }

# --- 1. label
sed -i 's/android:label="[^"]*"/android:label="عَدّادي"/' "$manifest"
grep -q 'android:label="عَدّادي"' "$manifest" || { echo "could not set the app label"; exit 1; }

# --- 2a. permissions (placed before <application>)
perms='    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>\n    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>'
grep -q 'POST_NOTIFICATIONS' "$manifest" || sed -i "0,/<application/s|<application|${perms}\n    <application|" "$manifest"

# --- 2b. receivers (scheduled reminders must survive a reboot)
if ! grep -q 'ScheduledNotificationReceiver' "$manifest"; then
  receivers='        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />\n        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">\n            <intent-filter>\n                <action android:name="android.intent.action.BOOT_COMPLETED"/>\n                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>\n                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>\n                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>\n            </intent-filter>\n        </receiver>'
  sed -i "0,/android:icon=\"@mipmap\/ic_launcher\">/s||android:icon=\"@mipmap/ic_launcher\">\n${receivers}|" "$manifest"
fi
for needle in POST_NOTIFICATIONS RECEIVE_BOOT_COMPLETED ScheduledNotificationReceiver ScheduledNotificationBootReceiver; do
  grep -q "$needle" "$manifest" || { echo "manifest injection failed: $needle"; exit 1; }
done

# --- 2c. desugaring + R8 rules (Gradle Kotlin DSL; plain Groovy is handled as a fallback)
gradle="android/app/build.gradle.kts"
[ -f "$gradle" ] || gradle="android/app/build.gradle"
test -f "$gradle" || { echo "missing android/app/build.gradle(.kts)"; exit 1; }

cat > android/app/proguard-rules.pro <<'PRO'
# flutter_local_notifications keeps scheduled-notification data through Gson reflection
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
PRO

if ! grep -q 'desugar_jdk_libs' "$gradle"; then
  if [[ "$gradle" == *.kts ]]; then
    cat >> "$gradle" <<'KTS'

android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
KTS
  else
    cat >> "$gradle" <<'GROOVY'

android {
    compileOptions {
        coreLibraryDesugaringEnabled true
    }
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
GROOVY
  fi
fi
grep -q 'desugar_jdk_libs' "$gradle" || { echo "desugaring injection failed"; exit 1; }
echo "android customisation done: label, notifications manifest entries, desugaring, R8 rules"
