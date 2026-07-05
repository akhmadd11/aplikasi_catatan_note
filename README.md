# Note Taking App

A simple and elegant note-taking application built with Flutter. This app allows users to easily create, edit, search, and manage notes, including support for categories and Markdown formatting.

## Key Features

- **Note Management**: Create, read, update, and delete notes (CRUD).
- **Markdown Formatting**: Write and preview text using Markdown formatting (bold, italic, lists, etc).
- **Categories**: Group notes into categories for better organization.
- **Search**: Quickly find specific notes using the integrated search feature.
- **Share**: Easily share note content to other applications.
- **Local Storage**: All data is securely stored locally on the device using SQLite.

## Technologies and Libraries

This app is built using several third-party packages:
- [sqflite](https://pub.dev/packages/sqflite): For local database storage.
- [go_router](https://pub.dev/packages/go_router): Declarative routing and navigation.
- [flutter_markdown](https://pub.dev/packages/flutter_markdown): Renders Markdown text into Flutter widgets.
- [google_fonts](https://pub.dev/packages/google_fonts): Typography and custom fonts.
- [share_plus](https://pub.dev/packages/share_plus): Share note text to other apps.
- [intl](https://pub.dev/packages/intl) & [timezone](https://pub.dev/packages/timezone): Date and time formatting.

## Requirements

Before starting, ensure you have the following installed on your machine:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Requires Dart SDK ^3.12.2 or compatible)
- Code editor such as [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

## Installation and Setup

Follow the steps below to set up and run the application in your local environment:

1. **Clone the Repository**
   Open a terminal and navigate to the folder where you want to store the project, then run:
   ```bash
   git clone <your-repository-url>
   cd aplikasi_catatan_note
   ```
   *(Note: If you are not using git, simply open the source code folder in your terminal.)*

2. **Install Dependencies**
   Ensure you are in the project's root directory, then run the following command to download all packages:
   ```bash
   flutter pub get
   ```

3. **Run the Application**
   Connect a physical device (Android/iOS) or start an emulator. Then type:
   ```bash
   flutter run
   ```

## Building APK (Release Build)

If you want to create an installation file (APK) to test on an Android device without connecting to a computer:

```bash
flutter build apk --release
```
Once the process is complete, the APK file can be found in the directory `build/app/outputs/flutter-apk/app-release.apk`.

## Directory Structure

```text
lib/
 ├── screens/      # Main UI screens (e.g., HomeScreen, NoteEditorScreen, CategoryManagerScreen)
 ├── widgets/      # Reusable UI components (e.g., SearchBarWidget)
 └── main.dart     # Application entry point
```

## Additional Notes

If you encounter a Gradle cache error when building the app for Android, you can perform a temporary reset by running `cd android && gradlew clean` or manually clearing the `.gradle` cache folder if necessary.
