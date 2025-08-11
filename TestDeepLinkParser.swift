import Foundation

// Test function to verify TLV parsing and deep link functionality
// You can call this in your app to test without NFC hardware
func testTlvParsing() {
    let testData = [
        // New TLV format
        "napasapp:///qr-nfc?data=00020101021138570010A000000727012700069704220113VQRQADKQM47680208QRIBFTTA53037045802VN62150107NPS686908006304FAFE",
        
        // Legacy format (should still work)
        "napasapp://transaction?amount=99",
        "napasapp://transaction?amount=250000&currency=VND"
    ]
    
    let paymentService = PaymentService()
    
    print("=== Testing TLV and Deep Link Parsing ===\n")
    
    for (index, urlString) in testData.enumerated() {
        print("Test \(index + 1): \(urlString)")
        
        // Simulate NFCManager parsing
        if let transactionData = NFCManager.shared.parseDeepLink(urlString) {
            print("✅ NFCManager parsing successful")
            print("   Amount: \(transactionData.amount)")
            print("   Currency: \(transactionData.currency)")
            
            // Test PaymentService parsing
            if let parsedData = paymentService.parseNfcData(transactionData) {
                print("✅ PaymentService parsing successful")
                print("   Parsed Amount: \(parsedData.amount)")
                print("   Currency: \(parsedData.currency)")
                print("   TLV Tags Count: \(parsedData.tlvData.count)")
                
                // Show some TLV tags if available
                if !parsedData.tlvData.isEmpty {
                    print("   Sample TLV Tags:")
                    for (tag, value) in parsedData.tlvData.prefix(5) {
                        print("     Tag \(tag): \(value)")
                    }
                }
                
                // Test flow determination
                let flowAction = paymentService.determinePaymentFlow(for: parsedData.amount)
                switch flowAction {
                case .proceedToSuccess:
                    print("   Flow: Direct to Success (< 200,000)")
                case .showConfirmation:
                    print("   Flow: Show Confirmation (≥ 200,000)")
                case .showError(let error):
                    print("   Flow: Error - \(error)")
                }
            } else {
                print("❌ PaymentService parsing failed")
            }
        } else {
            print("❌ NFCManager parsing failed")
        }
        
        print("---\n")
    }
}

// Test specific TLV parsing functionality
func testSpecificTlvParsing() {
    let tlvData = "00020101021138570010A000000727012700069704220113VQRQADKQM47680208QRIBFTTA5410542.000.0005802VN62150107NPS686908006304FAFE"
    
    print("=== Testing Specific TLV Parsing ===")
    print("Input: \(tlvData)")
    
    let tagMap = TLVParser.parseQrDataFlat(tlvData)
    
    print("\nParsed Tags:")
    for (tag, value) in tagMap.sorted(by: { $0.key < $1.key }) {
        print("Tag \(tag): \(value)")
    }
    
    // Test getting specific tag values
    if let amount = TLVParser.getTagValue(from: tagMap, tag: "54") {
        print("\n✅ Found transaction amount in tag 54: \(amount)")
        
        // Test amount conversion
        let paymentService = PaymentService()
        let testAmounts = [amount, "2.000.000", "150.000", "50000", "1.500.000"]
        
        print("\n=== Testing Amount Conversion ===")
        for testAmount in testAmounts {
            let flowAction = paymentService.determinePaymentFlow(for: testAmount)
            switch flowAction {
            case .proceedToSuccess:
                print("Amount \(testAmount) → Direct to Success (< 200,000)")
            case .showConfirmation:
                print("Amount \(testAmount) → Show Confirmation (≥ 200,000)")
            case .showError(let error):
                print("Amount \(testAmount) → Error: \(error)")
            }
        }
    } else {
        print("\n❌ Transaction amount (tag 54) not found")
    }
    
    if let currency = TLVParser.getTagValue(from: tagMap, tag: "53") {
        print("\n✅ Found currency in tag 53: \(currency)")
    } else {
        print("\n❌ Currency (tag 53) not found")
    }
}

// Test amount conversion functionality
func testAmountConversion() {
    let paymentService = PaymentService()
    
    print("=== Testing Amount Conversion Function ===")
    
    let testCases = [
        ("2.000.000", "Should show confirmation (≥ 200,000)"),
        ("1.500.000", "Should show confirmation (≥ 200,000)"),
        ("150.000", "Should proceed to success (< 200,000)"),
        ("50.000", "Should proceed to success (< 200,000)"),
        ("200.000", "Should show confirmation (= 200,000)"),
        ("199.999", "Should proceed to success (< 200,000)"),
        ("100000", "Should proceed to success (< 200,000)"),
        ("300000", "Should show confirmation (≥ 200,000)"),
        ("abc", "Should show error (invalid format)"),
        ("", "Should show error (empty)")
    ]
    
    for (amount, expectedBehavior) in testCases {
        let flowAction = paymentService.determinePaymentFlow(for: amount)
        
        print("\nAmount: '\(amount)' (\(expectedBehavior))")
        
        switch flowAction {
        case .proceedToSuccess:
            print("   Result: ✅ Direct to Success")
        case .showConfirmation:
            print("   Result: ✅ Show Confirmation")
        case .showError(let error):
            print("   Result: ⚠️ Error - \(error)")
        }
    }
    
    print("\n=== Amount Conversion Test Complete ===")
}
