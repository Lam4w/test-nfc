import Foundation

// MARK: - Payment Models

/// Enhanced TransactionData to include parsed TLV data
struct ParsedTransactionData {
    let amount: String
    let currency: String
    let fullURL: String
    let tlvData: QRTagMap
    let originalData: String
}

// MARK: - Payment Service

class PaymentService: ObservableObject {
    
    // MARK: - Constants
    
    private static let AMOUNT_THRESHOLD: Double = 200000
    private static let AMOUNT_TAG = "54"
    
    // MARK: - NFC Data Processing
    
    /// Parse NFC data and extract transaction information
    /// - Parameter nfcData: The raw NFC data
    /// - Returns: ParsedTransactionData if successful, nil if parsing fails
    func parseNfcData(_ nfcData: TransactionData) -> ParsedTransactionData? {
        // Extract TLV data from the URL
        guard let tlvString = extractTlvData(from: nfcData.fullURL) else {
            print("Failed to extract TLV data from URL: \(nfcData.fullURL)")
            return nil
        }
        
        // Parse TLV data
        let tagMap = parseTlvData(tlvString)
        
        // Check if transaction amount exists in tag 54
        guard let amountString = TLVParser.getTagValue(from: tagMap, tag: PaymentService.AMOUNT_TAG),
              !amountString.isEmpty else {
            print("Transaction amount not found in tag \(PaymentService.AMOUNT_TAG) - will prompt for manual entry")
            
            // Return parsed data with empty amount to indicate manual entry needed
            return ParsedTransactionData(
                amount: "", // Empty amount indicates manual entry needed
                currency: nfcData.currency,
                fullURL: nfcData.fullURL,
                tlvData: tagMap,
                originalData: tlvString
            )
        }
        
        // Create parsed transaction data with amount from tag 54
        return ParsedTransactionData(
            amount: amountString,
            currency: nfcData.currency,
            fullURL: nfcData.fullURL,
            tlvData: tagMap,
            originalData: tlvString
        )
    }
    
    /// Extract TLV data string from napasapp URL
    /// - Parameter urlString: The napasapp URL
    /// - Returns: The TLV data string if found
    private func extractTlvData(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        // Look for the 'data' parameter
        for item in queryItems {
            if item.name == "data" {
                return item.value
            }
        }
        
        return nil
    }
    
    /// Parse TLV data string into tag-value pairs
    /// - Parameter tlvString: The TLV data string
    /// - Returns: Dictionary of tag-value pairs
    private func parseTlvData(_ tlvString: String) -> QRTagMap {
        return TLVParser.parseQrDataFlat(tlvString)
    }
    
    // MARK: - Payment Flow Logic
    
    /// Convert formatted amount string to numeric value
    /// Handles formats like "2.000.000", "1.500", "100000", etc.
    /// - Parameter amountString: The formatted amount string
    /// - Returns: Double value if conversion successful, nil otherwise
    private func convertAmountToDouble(_ amountString: String) -> Double? {
        // Remove all dots (.) from the string as they are thousand separators
        let cleanedAmount = amountString.replacingOccurrences(of: ".", with: "")
        
        // Try to convert to Double
        return Double(cleanedAmount)
    }
    
    /// Determine the next step based on transaction amount
    /// - Parameter amount: Transaction amount as string (formatted like "2.000.000")
    /// - Returns: PaymentFlowAction indicating next step
    func determinePaymentFlow(for amount: String) -> PaymentFlowAction {
        // Check if amount is empty (no tag 54 found)
        if amount.isEmpty {
            return .enterAmountManually
        }
        
        guard let amountValue = convertAmountToDouble(amount) else {
            return .showError("Invalid amount format")
        }
        
        if amountValue < PaymentService.AMOUNT_THRESHOLD {
            return .proceedToSuccess
        } else {
            return .showConfirmation
        }
    }
    
    /// Validate parsed transaction data
    /// - Parameter data: The parsed transaction data
    /// - Returns: Validation result
    func validateTransactionData(_ data: ParsedTransactionData) -> ValidationResult {
        // If amount is empty, it means manual entry is needed - this is valid
        if data.amount.isEmpty {
            return .valid
        }
        
        // Check if amount is valid when present
        guard let amountValue = convertAmountToDouble(data.amount) else {
            return .invalid("Transaction amount is not a valid number")
        }
        
        guard amountValue > 0 else {
            return .invalid("Transaction amount must be greater than zero")
        }
        
        return .valid
    }
}

// MARK: - Supporting Types

enum PaymentFlowAction {
    case proceedToSuccess
    case showConfirmation
    case enterAmountManually
    case showError(String)
}

enum ValidationResult {
    case valid
    case invalid(String)
}
