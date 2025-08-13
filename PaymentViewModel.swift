import Foundation
import SwiftUI

// MARK: - Payment View Model

class PaymentViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var showTransactionView = false
    @Published var showEnterAmountView = false
    @Published var showPaymentSuccessView = false
    @Published var showNFCTapView = false
    @Published var transactionData: ParsedTransactionData?
    @Published var nfcError: String?
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    @Published var isProcessing = false
    
    // Track if NFC scan has been initiated to prevent duplicates
    @Published var hasInitiatedNFC = false
    
    // MARK: - Dependencies
    
    private let paymentService = PaymentService()
    private let nfcManager = NFCManager.shared
    
    // MARK: - Public Methods
    
    /// Start NFC scanning process
    func startNFCScanning() {
        // Prevent multiple simultaneous scans
        guard !isProcessing else {
            print("NFC scan already in progress, ignoring duplicate request")
            return
        }
        
        isProcessing = true
        hasInitiatedNFC = true
        clearErrors()
        
        nfcManager.beginScanning { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                switch result {
                case .success(let data):
                    self?.handleNfcData(data: data)
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    /// Handle manual amount entry from user
    /// - Parameter amount: User-entered amount
    func handleManualAmount(_ amount: String) {
        let manualTransactionData = ParsedTransactionData(
            amount: amount,
            currency: "VND",
            fullURL: "manual://transaction?amount=\(amount)",
            tlvData: ["54": amount], // Add amount to TLV data
            originalData: "manual_entry"
        )
        
        handleTransactionAmount(data: manualTransactionData)
        showEnterAmountView = false
    }
    
    /// Confirm transaction from details view
    func confirmTransaction() {
        showTransactionView = false
        showPaymentSuccessView = true
    }
    
    /// Clear all errors and reset state
    func clearErrors() {
        nfcError = nil
        errorMessage = ""
        showErrorAlert = false
    }
    
    /// Reset all navigation states
    func resetNavigationState() {
        showTransactionView = false
        showEnterAmountView = false
        showPaymentSuccessView = false
        showNFCTapView = false
        hasInitiatedNFC = false
        transactionData = nil
        isProcessing = false
        clearErrors()
    }
    
    // MARK: - Private Methods
    
    /// Handle NFC data processing
    /// - Parameter data: Raw NFC data from scanner
    private func handleNfcData(data: TransactionData) {
        // Parse NFC data using PaymentService
        guard let parsedData = paymentService.parseNfcData(data) else {
            showError(message: "Failed to parse NFC data. Please try again.")
            return
        }
        
        // Validate parsed data
        let validationResult = paymentService.validateTransactionData(parsedData)
        switch validationResult {
        case .valid:
            // Store transaction data and proceed
            transactionData = parsedData
            handleTransactionAmount(data: parsedData)
            
        case .invalid(let errorMessage):
            showError(message: "Invalid NFC data: \(errorMessage)")
        }
    }
    
    /// Handle transaction amount logic
    /// - Parameter data: Parsed transaction data
    private func handleTransactionAmount(data: ParsedTransactionData) {
        // Prevent multiple navigation triggers
        guard !showTransactionView && !showPaymentSuccessView else {
            print("Navigation already in progress, ignoring duplicate request")
            return
        }
        
        // Set the transaction data for use in views
        transactionData = data
        
        let flowAction = paymentService.determinePaymentFlow(for: data.amount)
        
        switch flowAction {
        case .proceedToSuccess:
            // Amount < 200,000 → Navigate directly to Payment Success
            showPaymentSuccessView = true
            
        case .showConfirmation:
            // Amount ≥ 200,000 → Show Transaction Details for confirmation
            showTransactionView = true
            
        case .enterAmountManually:
            // No amount in NFC data → Show Enter Amount screen
            showEnterAmountView = true
            
        case .showError(let message):
            showError(message: message)
        }
    }
    
    /// Show error message to user
    /// - Parameter message: Error message to display
    private func showError(message: String) {
        errorMessage = message
        nfcError = message
        showErrorAlert = true
    }
    
    /// Return to main view by resetting all navigation states
    func returnToMainView() {
        showTransactionView = false
        showEnterAmountView = false
        showPaymentSuccessView = false
        showNFCTapView = false
        hasInitiatedNFC = false
        clearErrors()
        // Reset transaction data if needed
        // transactionData = nil
    }
}
