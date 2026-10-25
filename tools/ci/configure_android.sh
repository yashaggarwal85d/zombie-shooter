#!/usr/bin/env bash
# Points Godot's editor settings at the Android SDK and JDK, and makes a
# throwaway debug keystore. Run once after Godot has created its settings file.
# Usage: tools/ci/configure_android.sh <android_sdk_dir> <java_home>
set -euo pipefail

sdk="${1:?android sdk dir required}"
jdk="${2:?java home required}"
settings="$(ls "$HOME"/.config/godot/editor_settings-4.*.tres | head -n1)"

sed -i '/^export\/android\/android_sdk_path/d; /^export\/android\/java_sdk_path/d' "$settings"
sed -i "0,/^\[resource\]/s||[resource]\nexport/android/android_sdk_path = \"${sdk}\"\nexport/android/java_sdk_path = \"${jdk}\"|" "$settings"

keystore="$RUNNER_TEMP/debug.keystore"
"$jdk/bin/keytool" -keyalg RSA -genkeypair -alias androiddebugkey -keypass android \
  -keystore "$keystore" -storepass android -dname "CN=Android Debug,O=Android,C=US" \
  -validity 9999 -deststoretype pkcs12 >/dev/null
{
  echo "GODOT_ANDROID_KEYSTORE_DEBUG_PATH=$keystore"
  echo "GODOT_ANDROID_KEYSTORE_DEBUG_USER=androiddebugkey"
  echo "GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD=android"
} >> "$GITHUB_ENV"
