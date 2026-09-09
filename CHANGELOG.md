## 0.0.9

* Re-version of the modern line: `0.0.8` was published from the `3.27.x`
  support branch, so the modern stack (Flutter >=3.44.0, Built-in Kotlin,
  AGP 9) continues here. No code changes versus the `0.0.8` development line.

## 0.0.8

* Updates the minimum supported SDK version to Flutter 3.44/Dart 3.12.
* Migrates to built-in Kotlin (remove `kotlin-android` apply, `kotlin.compilerOptions`).
* Fix `Color.alpha/red/green/blue` deprecations (Flutter 3.27+ color API).
* Honor `format`/`quality` on all platforms: merges now go through the native
  merger (PNG + JPEG) with a Flutter canvas fallback for unsupported platforms.
* Guard `ScrollController` access with `hasClients` to avoid crashes when the
  controller is not attached.
* Fix canvas background blend (`BlendMode.srcOver`) and dispose native images.
* Android: AGP 9.1.0, Kotlin 2.4.0, Java 17, compileSdk 36; hardened `Merger`
  (size guards, null-safe decode, bitmap recycling) and error results instead
  of crashes.
* iOS: modern `UIGraphicsImageRenderer`, robust `NSNumber` param parsing, canvas
  size guards, deployment target iOS 13.0.
* Update minimums to Dart >=3.4.0 / Flutter >=3.38.0 and `flutter_lints` 6.0.0.
* Example: `share_plus` 13.x, dispose `ScrollController`, drop unused dep.
* **Breaking:** requires Flutter >=3.44.0 / Dart ^3.12.0 (Built-in Kotlin, AGP 9).
  Flutter 3.27.x apps must stay on 0.0.7. See README Compatibility section.

## 0.0.7

* Previous release.

## 0.0.1

* TODO: Describe initial release.
