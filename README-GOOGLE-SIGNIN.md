# Google Sign-In Integration

This document provides instructions for setting up Google Sign-In in the StealthEcommerce iOS app.

## Prerequisites

1. A Firebase project with Google Sign-In enabled
2. The GoogleSignIn SDK installed in your project

## Setup Instructions

### 1. Install Dependencies

Add the following packages to your project using Swift Package Manager:

1. Firebase iOS SDK: https://github.com/firebase/firebase-ios-sdk.git
   - Select FirebaseAuth and FirebaseCore products

2. Google Sign-In for iOS: https://github.com/google/GoogleSignIn-iOS
   - Select GoogleSignIn and GoogleSignInSwift products

### 2. Update GoogleService-Info.plist

Make sure your GoogleService-Info.plist contains all required fields:

```
CLIENT_ID
REVERSED_CLIENT_ID
API_KEY
GCM_SENDER_ID
PLIST_VERSION
BUNDLE_ID
PROJECT_ID
STORAGE_BUCKET
IS_ADS_ENABLED
IS_ANALYTICS_ENABLED
IS_APPINVITE_ENABLED
IS_GCM_ENABLED
IS_SIGNIN_ENABLED
GOOGLE_APP_ID
```

The most important fields are:
- CLIENT_ID
- REVERSED_CLIENT_ID
- API_KEY
- GOOGLE_APP_ID

You can get a complete GoogleService-Info.plist from the Firebase console:
1. Go to your Firebase project
2. Click on the iOS app
3. Click on the gear icon
4. Click "Download GoogleService-Info.plist"

### 3. Configure Info.plist

Make sure your Info.plist contains:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

The URL scheme should match the REVERSED_CLIENT_ID from your GoogleService-Info.plist.

### 4. Initialize Firebase in AppDelegate

```swift
import FirebaseCore

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}
```

### 5. Handle URL Callbacks

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
}
```

## Troubleshooting

If you encounter the error "Configuration fails. It may be caused by an invalid GOOGLE_APP_ID in GoogleService-Info.plist or set in the customized options":

1. Make sure you've downloaded the correct GoogleService-Info.plist from Firebase
2. Check that the GOOGLE_APP_ID field exists and is valid
3. Verify that the CLIENT_ID matches your Google Cloud Console project
4. Make sure Firebase is properly initialized before any other Firebase calls

## Testing

To test Google Sign-In:

1. Run the app on a physical device or simulator
2. Tap the "Sign in with Google" button
3. Choose a Google account to sign in with
4. If successful, you should be logged in to the app 