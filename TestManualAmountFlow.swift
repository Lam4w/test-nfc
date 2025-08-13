import Foundation

/// Test function to verify manual amount entry flow
class TestManualAmountFlow {
    
    static func testManualAmountFlow() {
        print("🧪 Testing Manual Amount Entry Flow:")
        
        let viewModel = PaymentViewModel()
        
        print("✅ Step 1: Simulate manual amount entry")
        let testAmount = "150000" // Below threshold
        viewModel.handleManualAmount(testAmount)
        
        print("✅ Step 2: Check if transactionData is set")
        if let transactionData = viewModel.transactionData {
            print("✅ Transaction data found:")
            print("   Amount: \(transactionData.amount)")
            print("   Currency: \(transactionData.currency)")
            print("   Source: \(transactionData.originalData)")
            print("   Full URL: \(transactionData.fullURL)")
        } else {
            print("❌ Transaction data is nil!")
        }
        
        print("✅ Step 3: Check navigation state")
        if viewModel.showPaymentSuccessView {
            print("✅ Correctly navigating to Payment Success (amount < 200,000)")
        } else if viewModel.showTransactionView {
            print("✅ Correctly navigating to Transaction Details (amount ≥ 200,000)")
        } else {
            print("❌ No navigation state set!")
        }
        
        print("")
        print("🧪 Testing high amount:")
        viewModel.returnToMainView() // Reset
        let highAmount = "500000" // Above threshold
        viewModel.handleManualAmount(highAmount)
        
        if let transactionData = viewModel.transactionData {
            print("✅ High amount transaction data:")
            print("   Amount: \(transactionData.amount)")
        }
        
        if viewModel.showTransactionView {
            print("✅ Correctly navigating to Transaction Details for high amount")
        } else {
            print("❌ Should navigate to Transaction Details for high amount!")
        }
    }
}

// Usage:
// TestManualAmountFlow.testManualAmountFlow()
