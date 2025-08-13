# Custom NFC Modal Messages

## 🎯 **Feature Overview**
You can now set custom text inside the NFC scan modal popup to provide better user guidance and context-specific instructions.

## ✅ **Implementation Details**

### **1. NFCManager Enhancement**
```swift
func beginScanning(
    customMessage: String? = nil,
    completion: @escaping (Result<TransactionData, Error>) -> Void
) {
    // ...
    session.alertMessage = customMessage ?? "Hold your iPhone near the NFC tag."
    // ...
}
```

### **2. PaymentViewModel Update**
```swift
func startNFCScanning(customMessage: String? = nil) {
    // ...
    nfcManager.beginScanning(customMessage: customMessage) { result in
        // ...
    }
}
```

### **3. Predefined Message Templates**
```swift
struct NFCMessages {
    static let payment = "💳 Tap to Pay\nBring your device close to the NFC tag"
    static let quickScan = "🔍 Quick Scan\nPlace your phone near any NFC tag"
    static let retry = "🔄 Retry Payment\nTry placing your phone closer to the tag"
    static let ready = "🏦 Ready for Payment\nHold your phone near the payment tag"
    static let `default` = "Hold your iPhone near the NFC tag."
}
```

## 📱 **Current Usage**

### **ContentView - Main Scan Button**
```swift
Button("Scan NFC Tag") {
    viewModel.startNFCScanning(customMessage: PaymentViewModel.NFCMessages.quickScan)
}
```
**Shows:** "🔍 Quick Scan\nPlace your phone near any NFC tag"

### **NFCTapView - Auto Scan**
```swift
.onAppear {
    if !viewModel.hasInitiatedNFC {
        viewModel.startNFCScanning(customMessage: PaymentViewModel.NFCMessages.payment)
    }
}
```
**Shows:** "💳 Tap to Pay\nBring your device close to the NFC tag"

### **NFCTapView - Manual Scan Button**
```swift
Button("Start NFC Scan") {
    viewModel.startNFCScanning(customMessage: PaymentViewModel.NFCMessages.ready)
}
```
**Shows:** "🏦 Ready for Payment\nHold your phone near the payment tag"

### **NFCTapView - Retry Button**
```swift
Button("Try Again") {
    viewModel.startNFCScanning(customMessage: PaymentViewModel.NFCMessages.retry)
}
```
**Shows:** "🔄 Retry Payment\nTry placing your phone closer to the tag"

## 🔧 **How to Use**

### **Option 1: Use Predefined Messages**
```swift
viewModel.startNFCScanning(customMessage: PaymentViewModel.NFCMessages.payment)
```

### **Option 2: Use Custom Text**
```swift
viewModel.startNFCScanning(customMessage: "🛒 Shopping Payment\nTouch your phone to the store's NFC reader")
```

### **Option 3: Use Default Message**
```swift
viewModel.startNFCScanning() // Uses default message
```

## 💡 **Message Guidelines**

### **Best Practices:**
- ✅ Keep messages clear and concise
- ✅ Use emojis for visual appeal
- ✅ Use `\n` for line breaks
- ✅ Provide context-specific instructions
- ✅ Use action-oriented language

### **Examples for Different Scenarios:**
```swift
// Payment scenarios
"💳 Tap to Pay\nBring your device close to the payment terminal"
"🏪 Store Payment\nHold your phone near the checkout scanner"

// Data transfer
"📱 Share Data\nBring devices close together"
"📄 Transfer File\nAlign phones back-to-back"

// Access control
"🔐 Security Access\nTap your phone to the door reader"
"🎫 Event Check-in\nHold near the entrance scanner"

// Transportation
"🚇 Transit Payment\nTap to pay for your ride"
"🚌 Bus Pass\nTouch the fare reader"
```

## 🎨 **Message Templates Available**

| Template | Message | Use Case |
|----------|---------|----------|
| `payment` | 💳 Tap to Pay<br>Bring your device close to the NFC tag | Payment flows |
| `quickScan` | 🔍 Quick Scan<br>Place your phone near any NFC tag | General scanning |
| `retry` | 🔄 Retry Payment<br>Try placing your phone closer to the tag | Error recovery |
| `ready` | 🏦 Ready for Payment<br>Hold your phone near the payment tag | Manual triggers |
| `default` | Hold your iPhone near the NFC tag. | Fallback |

## 🔄 **Adding New Templates**

To add new message templates, update the `NFCMessages` struct:

```swift
struct NFCMessages {
    // Existing messages...
    
    // Add new templates
    static let shopping = "🛒 Shopping Payment\nTouch the store's NFC reader"
    static let transit = "🚇 Transit Card\nTap to pay for your ride"
    static let loyalty = "🎁 Loyalty Card\nScan to earn points"
}
```

## ✨ **Benefits**

- 🎯 **Context-aware messaging** for different use cases
- 🎨 **Visual appeal** with emojis and formatting
- 🔧 **Easy customization** without code duplication
- 📱 **Better UX** with clear instructions
- 🌐 **Consistent messaging** across the app

Your NFC modal now provides much better user guidance! 🎉
