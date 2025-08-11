# NFC Payment App

This iOS app implements a complete NFC payment flow that reads transaction data from NFC tags and processes payments based on amount thresholds.

## Payment Flow

### 1. NFC Scan
- User taps "Scan NFC Tag" button
- App scans for NFC tags containing payment data

### 2. Data Validation
- ✅ Valid data → Continue to amount handling
- ❌ Invalid data → Show error alert and stop

### 3. Amount-Based Navigation

#### If amount < 200,000 VND:
- Navigate directly to **Payment Success** screen

#### If amount ≥ 200,000 VND:
- Show **Transaction Details** screen for confirmation
- After confirmation → Navigate to **Payment Success** screen

#### If no amount in NFC data:
- Show **Enter Amount** screen for manual input
- After amount entry → Apply amount-based logic above

## Screens

### 1. Main Screen
- "Scan NFC Tag" button
- Error display area
- Navigation to other screens

### 2. Transaction Details Screen (amount ≥ 200,000)
- Shows transaction amount and currency
- Confirmation required for high-value transactions
- "Confirm Payment" and "Cancel" buttons

### 3. Enter Amount Screen (no amount in NFC)
- Manual amount entry with number pad
- Input validation
- "Continue" and "Cancel" buttons

### 4. Payment Success Screen
- Success confirmation with checkmark
- Transaction details summary
- Random transaction ID generation
- "Done" button to return to main screen

## Function Architecture

### Core Functions

#### `handleNfcData(data: TransactionData)`
- Validates NFC data integrity
- Checks for required fields
- Routes to appropriate next step
- Shows error alerts for invalid data

#### `handleTransactionAmount(data: TransactionData)`
- Compares amount with 200,000 VND threshold
- Navigates directly to success (< 200,000)
- Shows confirmation screen (≥ 200,000)

### Error Handling
- NFC availability check
- Data validation with user-friendly error messages
- Thread-safe UI updates
- Graceful handling of invalid amounts

```
napasapp://transaction?amount=99&currency=VND
```

### Parameters:
- `amount` (required): The transaction amount
- `currency` (optional): The currency code (defaults to "VND")

### Example URLs:
- `napasapp://transaction?amount=99`
- `napasapp://transaction?amount=100&currency=VND`
- `napasapp://transaction?amount=250.50&currency=USD`
- `napasapp://transaction?amount=1000` (uses default currency VND)

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
