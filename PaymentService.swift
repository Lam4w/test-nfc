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
        
        // Extract transaction amount from tag 54
        guard let amountString = TLVParser.getTagValue(from: tagMap, tag: PaymentService.AMOUNT_TAG),
              !amountString.isEmpty else {
            print("Transaction amount not found in tag \(PaymentService.AMOUNT_TAG)")
            return nil
        }
        
        // Create parsed transaction data
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
    
    /// Determine the next step based on transaction amount
    /// - Parameter amount: Transaction amount as string
    /// - Returns: PaymentFlowAction indicating next step
    func determinePaymentFlow(for amount: String) -> PaymentFlowAction {
        guard let amountValue = Double(amount) else {
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
        // Check if amount is valid
        guard !data.amount.isEmpty else {
            return .invalid("Transaction amount is missing")
        }
        
        guard Double(data.amount) != nil else {
            return .invalid("Transaction amount is not a valid number")
        }
        
        guard let amountValue = Double(data.amount), amountValue > 0 else {
            return .invalid("Transaction amount must be greater than zero")
        }
        
        return .valid
    }
}

// MARK: - Supporting Types

enum PaymentFlowAction {
    case proceedToSuccess
    case showConfirmation
    case showError(String)
}

enum ValidationResult {
    case valid
    case invalid(String)
}
