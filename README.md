# NFC Payment App

This iOS app implements a complete NFC payment flow that reads TLV (Tag-Length-Value) data from NFC tags and processes payments based on amount thresholds.

## New Features - TLV Data Support

### **Supported NFC Data Formats:**

#### 1. **TLV Format (New)**
```
napasapp:///qr-nfc?data=00020101021138570010A000000727012700069704220113VQRQADKQM47680208QRIBFTTA53037045802VN62150107NPS686908006304FAFE
```
- The `data` parameter contains TLV encoded transaction information
- Tag `54` contains the transaction amount
- Supports nested TLV structures with tags 38, 62, and 64

#### 2. **Legacy Format (Still Supported)**
```
napasapp://transaction?amount=99&currency=VND
```

## Architecture - MVVM Pattern

### **File Structure:**
```
📁 NFC Payment App/
├── 📄 ContentView.swift          # Main UI (View)
├── 📄 PaymentViewModel.swift     # UI State Management (ViewModel)
├── 📄 PaymentService.swift       # Business Logic (Model)
├── 📄 TLVParser.swift           # TLV Data Parsing Utility
├── 📄 NFCManager.swift          # NFC Hardware Interface
└── 📄 TestDeepLinkParser.swift  # Testing Utilities
```

### **Key Components:**

#### **TLVParser.swift**
- `parseQrDataFlat()` - Main TLV parsing function
- `parseSubFieldsFlat()` - Handles nested TLV structures
- `getTagValue()` - Utility to extract specific tag values
- Supports complex nested structures (tags 38, 62, 64)

#### **PaymentService.swift**
- `parseNfcData()` - Processes raw NFC data into structured format
- `determinePaymentFlow()` - Implements amount threshold logic
- `validateTransactionData()` - Data validation and error handling
- Extracts transaction amount from TLV tag `54`

#### **PaymentViewModel.swift**
- `@Published` properties for UI state
- `startNFCScanning()` - Initiates NFC scan process
- `handleManualAmount()` - Processes manual amount entry
- Thread-safe UI updates with proper error handling

## Payment Flow

### 1. NFC Data Processing
```
NFC Scan → Extract TLV Data → Parse Tag-Value Pairs → Extract Amount (Tag 54) → Validate Data
```

### 2. Amount-Based Navigation

#### **Amount < 200,000 VND:**
- Navigate directly to **Payment Success** screen

#### **Amount ≥ 200,000 VND:**
- Show **Transaction Details** screen for confirmation
- After confirmation → Navigate to **Payment Success** screen

#### **No amount in NFC data:**
- Show **Enter Amount** screen for manual input
- After amount entry → Apply amount-based logic above

## TLV Data Structure

### **Standard Tags:**
- `00` - Payload Format Indicator
- `01` - Point of Initiation Method  
- `38` - Merchant Account Information (nested)
- `53` - Transaction Currency
- `54` - Transaction Amount ⭐ **Key tag for amount extraction**
- `58` - Country Code
- `62` - Additional Data Field Template (nested)
- `63` - CRC

### **Nested Structure Support:**
- Tags `38`, `62`, `64` can contain sub-TLV data
- Parser automatically flattens nested structures
- Sub-tags are prefixed with parent tag (e.g., `38_01`, `62_07`)

## Testing

### **Unit Testing Functions:**
```swift
// Test TLV parsing with real data
testSpecificTlvParsing()

// Test complete flow with various URL formats  
testTlvParsing()
```

### **Test Data:**
- Real TLV data from napasapp URLs
- Legacy transaction URLs
- Edge cases and error scenarios

## Error Handling

### **Robust Validation:**
- NFC availability check
- TLV data format validation  
- Amount extraction and validation
- Thread-safe UI updates
- User-friendly error messages

### **Graceful Degradation:**
- Falls back to legacy URL parsing if TLV parsing fails
- Manual amount entry when NFC data is incomplete
- Clear error alerts with actionable messages

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
