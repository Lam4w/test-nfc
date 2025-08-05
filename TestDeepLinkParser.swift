import Foundation

// Test function to verify deep link parsing functionality
// You can call this in your app to test without NFC hardware
func testDeepLinkParsing() {
    let testURLs = [
        "napasapp://transaction?amount=99",
        "napasapp://transaction?amount=100&currency=VND",
        "napasapp://transaction?amount=250.50&currency=USD",
        "napasapp://transaction?amount=1000",
        "napasapp://transaction?currency=EUR&amount=75.25"
    ]
    
    let nfcManager = NFCManager.shared
    
    for urlString in testURLs {
        if let transactionData = nfcManager.parseDeepLink(urlString) {
            print("✅ Successfully parsed: \(urlString)")
            print("   Amount: \(transactionData.amount)")
            print("   Currency: \(transactionData.currency)")
            print("   Full URL: \(transactionData.fullURL)")
        } else {
            print("❌ Failed to parse: \(urlString)")
        }
        print("---")
    }
}
