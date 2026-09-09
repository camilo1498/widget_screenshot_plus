## 0.0.8

* Supports Flutter >=3.27.0 / Dart >=3.6.0 with a single codebase (see README Compatibility).
* Dart uses version-stable APIs only (`Color.toARGB32` bit shifts, no version-specific getters).
* Android stays on the legacy stack (AGP 8.11.1, Kotlin 2.2.20, Java 11, `kotlin-android` apply) pinned at the newest versions old Flutter tooling still accepts; native `Merger` hardened (size guards, null-safe decode, bitmap recycling, error results).
* Honor `format`/`quality` on all platforms: merges now go through the native
  merger (PNG + JPEG) with a Flutter canvas fallback for unsupported platforms.
* Guard `ScrollController` access with `hasClients` to avoid crashes when the
  controller is not attached.
* Fix canvas background blend (`BlendMode.srcOver`) and dispose native images.
* iOS: modern `UIGraphicsImageRenderer`, robust `NSNumber` param parsing, canvas
  size guards, deployment target iOS 12.0.
* Example: version ranges resolving old and new SDKs, dispose `ScrollController`, drop unused dep.

## 0.0.7

* Previous release.

## 0.0.1

* TODO: Describe initial release.
