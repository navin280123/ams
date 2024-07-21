# 📚 Attendance Management App

Welcome to the Attendance Management App! This Flutter project provides a comprehensive solution for managing student attendance, featuring Firebase integration and QR code scanning functionalities. The app is designed to streamline attendance processes and provide insightful statistics to administrators.

## 🛠 Features

- 📱 **User Authentication**: Secure login and registration with Firebase Authentication.
- 📊 **Attendance Management**: Mark attendance using QR codes and view attendance records.
- 📅 **QR Code Scanning**: Scan QR codes to mark attendance and ensure accurate tracking.
- 📈 **Attendance Statistics**: View and analyze attendance statistics with visual charts.
- 🔔 **Notifications Management**: Manage and send notifications to users.
- 🔄 **Data Import/Export**: Import and export data using Excel files.
- 🔐 **Admin Dashboard**: Access a comprehensive dashboard for managing groups, students, and more.

## 🚀 Getting Started

Follow these steps to get started with the Attendance Management App:

### Prerequisites

Ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Project](https://firebase.google.com/)
- [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)

### Installation

1. **Clone the Repository**

   Open your terminal or command prompt and clone the repository:

   ```bash
   git clone https://github.com/navin280123/ams
   cd ams


2. **Install Dependencies**

   Install the required Flutter packages:

   ```bash
   flutter pub get
   ```

3. **Set Up Firebase**

   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Create a new Firebase project or use an existing one.
   - Follow the [Flutter Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup) to integrate Firebase with your app:
     - Add Firebase to your Android app by downloading `google-services.json` and placing it in the `android/app` directory.
     - Add Firebase to your iOS app by downloading `GoogleService-Info.plist` and placing it in the `ios/Runner` directory.
     - Update your `android/build.gradle` and `ios/Podfile` as per the Firebase setup instructions.

4. **Run the App**

   After setting up Firebase, run the app on an emulator or physical device:

   ```bash
   flutter run
   ```

## 🛠 Development

To contribute to this project or make changes, follow these steps:

1. **Create a Branch**

   ```bash
   git checkout -b your-feature-branch
   ```

2. **Make Changes**

   Implement your changes to the codebase.

3. **Commit Your Changes**

   ```bash
   git add .
   git commit -m "Add a clear and concise commit message"
   ```

4. **Push Changes**

   ```bash
   git push origin your-feature-branch
   ```

5. **Create a Pull Request**

   Open a pull request on GitHub to merge your changes into the main branch.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙌 Acknowledgements

- [Flutter](https://flutter.dev/) - For the cross-platform development framework.
- [Firebase](https://firebase.google.com/) - For authentication and real-time database services.
- [QR Code Scanner](https://pub.dev/packages/qr_code_scanner) - For QR code scanning functionality.
- [Intl Package](https://pub.dev/packages/intl) - For internationalization and date formatting.
- [Lottie for Flutter](https://pub.dev/packages/lottie) - For animations.
- [Excel Export/Import Libraries](https://pub.dev/packages/excel) - For data import and export.

## 📞 Contact

For any questions or feedback, please contact [📩Mail to Admin](mailto:kumarnavinverma7@gmail.com) or open an issue on GitHub.

Thank you for using the Attendance Management App!
