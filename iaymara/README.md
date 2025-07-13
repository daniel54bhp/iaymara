````markdown
# IA-Task Flutter App

> **Single-device chat application for running lightweight AI models  
> ( `.task` format powered by [flutter_gemma] ).**  
> All inference happens **locally on your Android phone** – no cloud, no API keys.

---

## ✨ Features

| Capability | Details |
|------------|---------|
| **Local inference** | Runs Gemma 3 Nano (or any compatible `.task`) entirely on-device via MediaPipe GenAI. |
| **Images & text** | Send messages, attach photos from camera/galería, or dictate via push-to-talk mic. |
| **GPU / CPU fallback** | Detects Vulkan-capable GPU; otherwise switches to CPU automatically. |
| **Live streaming** | Responses appear token-by-token for a more natural “typing” effect. |
| **Offline-first** | Once the model is copied, the app works without internet permission. |
| **Theming** | Uses Material 3 with color-seeded theme (easily customizable). |

---

## 📂 Model placement

1. Create the folder **`/storage/emulated/0/moday`** on your Android device.  
2. Copy exactly **one** `*.task` file inside (e.g.  
   `gemma-3n-E2B-it-int4.task`).  
3. Launch the app — it auto-discovers the first `.task` it finds in that folder.  

> The filename itself does not matter; the extension **must** be `.task`.

---

## 🚀 Getting started (developer)

### Prerequisites

| Tool | Version |
|------|---------|
| **Flutter** | 3.22 (or newer) |
| **NDK** | 27.0.12077973 (set in *android/app/build.gradle*) |
| **Android SDK** | minSdk 24, targetSdk 34 |

### Clone & run

```bash
git clone https://github.com/<your-org>/ia-task-flutter.git
cd ia-task-flutter
flutter pub get
flutter run
````

The first launch copies the model into internal storage (if you bundled it as an asset). Subsequent launches read directly from `/moday`.

### Build release APK

```bash
flutter build apk --release
```

---

## 📱 Runtime permissions

| Permission                                                      | Purpose                                        |
| --------------------------------------------------------------- | ---------------------------------------------- |
| **MANAGE\_EXTERNAL\_STORAGE** (Android 11+) / **READ\_MEDIA\_** | Locate the `.task` model in `/moday`.          |
| **RECORD\_AUDIO**                                               | Push-to-talk microphone input.                 |
| **CAMERA** & **READ\_EXTERNAL\_STORAGE**                        | Capture or select images to send to the model. |

All permissions are requested at runtime only when their feature is used.

---

## 🛠️ Project structure

```
lib/
 ├─ screens/
 │   ├─ home_screen.dart      // main menu
 │   └─ chat_screen.dart      // chat UI + Gemma integration
 ├─ utils/
 │   └─ shared_prefs.dart     // lightweight key-value helpers
 └─ main.dart                 // MaterialApp entry-point
assets/
 └─ images/icono.png          // app & bot avatar
android/
 └─ ...                       // Gradle, NDK, manifest tweaks
```

---

## 🤝 Contributing

1. Fork the repo & create a feature branch.
2. Commit your changes (`git commit -m 'feat: amazing improvement'`).
3. Push to your fork and open a pull request.
4. Make sure `flutter analyze` runs cleanly.

---

## 📄 License

MIT — see `LICENSE` file for details.

---

### References

* **flutter\_gemma** – [https://pub.dev/packages/flutter\_gemma](https://pub.dev/packages/flutter_gemma)
  Provides the Dart bindings to MediaPipe GenAI and Gemma 3 Nano models.

---

> *Happy local chatting!*

```
::contentReference[oaicite:0]{index=0}
```
