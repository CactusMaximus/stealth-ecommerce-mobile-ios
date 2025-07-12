# Stealth Ecommerce Mobile iOS App

## Regional Localization

This app supports regional localization for different English variants and Spanish. The app allows users to select their preferred region/language from within the app interface.

### Supported Regions

- English (Default) - General English
- English (US) - American English
- English (UK) - British English
- English (Canada) - Canadian English
- Spanish - Spanish language

### How Regional Localization Works

1. **Automatic Detection**: The app automatically detects the user's preferred language from device settings.
2. **Manual Selection**: Users can manually change their region/language preference from within the app.
3. **Persistent Settings**: The selected region preference is saved and persists between app sessions.

### Implementation Details

- Regional preferences are managed by the `RegionManager` class
- The UI for selecting regions is provided by the `RegionSelectorView`
- Localized strings are stored in `.lproj` directories for each supported region
- String extensions make it easy to use localized strings in code

### Adding New Regions

To add support for a new region:

1. Create a new `.lproj` directory with the region code (e.g., `fr.lproj` for French)
2. Add a `Localizable.strings` file with translated strings
3. Update the `USRegion` enum in `RegionHelper.swift` to include the new region
4. Add the new region code to the `CFBundleLocalizations` array in `Info.plist`

### Testing Regional Localization

You can test the regional localization feature in two ways:

1. **In-App Selection**: Use the region selector in the app's registration or login screens
2. **Device Settings**: Change the language settings on your device

## Development

### Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

### Setup

1. Clone the repository
2. Open `StealthEcommerce.xcodeproj` in Xcode
3. Build and run the app on a simulator or device

## License

This project is proprietary and confidential.
