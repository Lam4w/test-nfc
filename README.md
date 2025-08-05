# NFC Deep Link Demo App

This iOS app demonstrates how to read NFC tags containing deep links and parse transaction data without triggering external app redirects.

## Features

- Scans NFC tags for URI records containing deep links
- Parses deep link URLs in the format: `myapp://transaction?amount=100&currency=VND`
- Extracts transaction amount and currency from the URL
- Displays transaction details in a dedicated view
- Handles the deep link internally without system popup

## NFC Tag Setup

To test this app, you need to write a URI record to an NFC tag with the following format:

```
myapp://transaction?amount=100&currency=VND
```

### Parameters:
- `amount` (required): The transaction amount
- `currency` (optional): The currency code (defaults to "VND")

### Example URLs:
- `myapp://transaction?amount=100&currency=VND`
- `myapp://transaction?amount=250.50&currency=USD`
- `myapp://transaction?amount=1000` (uses default currency VND)

## How It Works

1. **NFC Detection**: The app uses `NFCNDEFReaderSession` to detect NFC tags
2. **URI Record Parsing**: It specifically looks for URI records (type 'U') in NDEF messages
3. **Deep Link Parsing**: Extracts the URL and parses query parameters
4. **Internal Navigation**: Navigates to a transaction view without external app switching

## Testing Without NFC Hardware

You can test the deep link parsing functionality using the test function:

```swift
// Call this function to test URL parsing
testDeepLinkParsing()
```

## Project Structure

- `NFCManager.swift`: Handles NFC scanning and deep link parsing
- `ContentView.swift`: Main UI with NFC scan button
- `TransactionView`: Displays parsed transaction data
- `TestDeepLinkParser.swift`: Testing utilities

## Requirements

- iOS 13.0+
- NFC capability enabled in project settings
- Physical device with NFC support (NFC doesn't work in simulator)

## Setup Instructions

1. Add "Near Field Communication Tag Reading" capability in Xcode project settings
2. Add the following to your Info.plist:
   ```xml
   <key>NFCReaderUsageDescription</key>
   <string>This app uses NFC to read transaction data from tags</string>
   ```
3. Build and run on a physical iOS device

## Usage

1. Tap "Scan NFC Tag" button
2. Hold your iPhone near an NFC tag containing the deep link
3. The app will automatically parse the data and navigate to the transaction view
4. View the extracted amount, currency, and full URL

The deep link is processed entirely within the app - no external app switching occurs.
