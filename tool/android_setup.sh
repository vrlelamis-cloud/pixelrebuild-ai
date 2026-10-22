#!/usr/bin/env bash
# Génère le projet Android (non versionné) et applique la configuration de l'application :
# identifiant, nom affiché, minSdk 24 et script Gradle compileSdk.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ ! -d android ]; then
  tmp="$(mktemp -d)"
  flutter create --platforms=android --org com.pixelrebuild --project-name pixelrebuild_ai "$tmp"
  cp -r "$tmp/android" android
fi

mkdir -p "$HOME/.gradle/init.d"
cp tool/gradle/compilesdk.init.gradle "$HOME/.gradle/init.d/compilesdk.gradle"

gradle_file="$( (ls android/app/build.gradle.kts android/app/build.gradle 2>/dev/null || true) | head -n1 )"
if [[ "$gradle_file" == *.kts ]]; then
  sed -i -E 's/minSdk[[:space:]]*=.*/minSdk = 24/' "$gradle_file"
  sed -i -E 's/applicationId[[:space:]]*=[[:space:]]*"[^"]*"/applicationId = "com.pixelrebuild.app"/; s/namespace[[:space:]]*=[[:space:]]*"[^"]*"/namespace = "com.pixelrebuild.app"/' "$gradle_file"
else
  sed -i -E 's/minSdkVersion[[:space:]]*=?[[:space:]]*flutter\.minSdkVersion/minSdkVersion 24/; s/minSdk[[:space:]]*=?[[:space:]]*flutter\.minSdkVersion/minSdk 24/' "$gradle_file"
  sed -i -E 's/applicationId[[:space:]]+"[^"]*"/applicationId "com.pixelrebuild.app"/; s/namespace[[:space:]]+"[^"]*"/namespace "com.pixelrebuild.app"/' "$gradle_file"
fi

manifest=android/app/src/main/AndroidManifest.xml
sed -i -E 's/android:label="[^"]*"/android:label="PixelRebuild"/' "$manifest"

# Le package Kotlin généré doit correspondre au nouvel identifiant.
old_activity="$(find android/app/src/main -name 'MainActivity.*' | head -n1 || true)"
if [ -n "$old_activity" ] && ! grep -q 'package com.pixelrebuild.app' "$old_activity"; then
  new_dir=android/app/src/main/kotlin/com/pixelrebuild/app
  mkdir -p "$new_dir"
  sed -E 's/^package .*/package com.pixelrebuild.app/' "$old_activity" > "$new_dir/MainActivity.kt"
  [ "$old_activity" = "$new_dir/MainActivity.kt" ] || rm -f "$old_activity"
fi
echo "Projet Android prêt."
