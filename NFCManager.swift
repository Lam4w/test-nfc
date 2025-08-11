import Foundation
import CoreNFC

struct TransactionData {
    let amount: String
    let currency: String
    let fullURL: String
}

class NFCManager: NSObject, NFCNDEFReaderSessionDelegate {
    static let shared = NFCManager()
    private var completion: ((Result<TransactionData, Error>) -> Void)?

    func beginScanning(completion: @escaping (Result<TransactionData, Error>) -> Void) {
        // Check if NFC is available
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(NSError(domain: "NFC", code: -1, userInfo: [NSLocalizedDescriptionKey: "NFC is not available on this device"])))
            return
        }
        
        self.completion = completion
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = "Hold your iPhone near the NFC tag."
        session.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        completion?(.failure(error))
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first else {
            completion?(.failure(NSError(domain: "NFC", code: 0, userInfo: [NSLocalizedDescriptionKey: "No NFC records found"])))
            return
        }
        
        // Check if this is a URI record
        if record.typeNameFormat == .nfcWellKnown && record.type == Data([0x55]) { // 'U' for URI
            handleURIRecord(record)
        } else {
            // Fallback to text parsing for backwards compatibility
            handleTextRecord(record)
        }
    }
    
    private func handleURIRecord(_ record: NFCNDEFPayload) {
        guard let uriString = parseURIFromPayload(record.payload) else {
            completion?(.failure(NSError(domain: "NFC", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URI format"])))
            return
        }
        
        // Parse the deep link
        if let transactionData = parseDeepLink(uriString) {
            completion?(.success(transactionData))
        } else {
            completion?(.failure(NSError(domain: "NFC", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse transaction data from deep link"])))
        }
    }
    
    private func handleTextRecord(_ record: NFCNDEFPayload) {
        guard let payloadString = String(data: record.payload, encoding: .utf8) else {
            completion?(.failure(NSError(domain: "NFC", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid NFC data"])))
            return
        }
        
        // Check if it's a deep link URL
        if payloadString.hasPrefix("napasapp://") {
            if let transactionData = parseDeepLink(payloadString) {
                completion?(.success(transactionData))
            } else {
                completion?(.failure(NSError(domain: "NFC", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse transaction data from deep link"])))
            }
        } else {
            // Legacy format: "amount:123.45"
            if let amount = payloadString.components(separatedBy: "amount:").last?.trimmingCharacters(in: .whitespacesAndNewlines) {
                let transactionData = TransactionData(amount: amount, currency: "VND", fullURL: payloadString)
                completion?(.success(transactionData))
            } else {
                completion?(.failure(NSError(domain: "NFC", code: 1, userInfo: [NSLocalizedDescriptionKey: "Amount not found"])))
            }
        }
    }
    
    private func parseURIFromPayload(_ payload: Data) -> String? {
        guard payload.count > 1 else { return nil }
        
        // URI record format: first byte is URI identifier code, rest is URI
        let identifierCode = payload[0]
        let uriData = payload.dropFirst()
        
        // Common URI prefixes according to NFC spec
        let prefixes = [
            0x00: "",
            0x01: "http://www.",
            0x02: "https://www.",
            0x03: "http://",
            0x04: "https://",
            0x05: "tel:",
            0x06: "mailto:",
            0x07: "ftp://anonymous:anonymous@",
            0x08: "ftp://ftp.",
            0x09: "ftps://",
            0x0A: "sftp://",
            0x0B: "smb://",
            0x0C: "nfs://",
            0x0D: "ftp://",
            0x0E: "dav://",
            0x0F: "news:",
            0x10: "telnet://",
            0x11: "imap:",
            0x12: "rtsp://",
            0x13: "urn:",
            0x14: "pop:",
            0x15: "sip:",
            0x16: "sips:",
            0x17: "tftp:",
            0x18: "btspp://",
            0x19: "btl2cap://",
            0x1A: "btgoep://",
            0x1B: "tcpobex://",
            0x1C: "irdaobex://",
            0x1D: "file://",
            0x1E: "urn:epc:id:",
            0x1F: "urn:epc:tag:",
            0x20: "urn:epc:pat:",
            0x21: "urn:epc:raw:",
            0x22: "urn:epc:",
            0x23: "urn:nfc:"
        ]
        
        let prefix = prefixes[identifierCode] ?? ""
        guard let uriSuffix = String(data: uriData, encoding: .utf8) else { return nil }
        
        return prefix + uriSuffix
    }
    
    func parseDeepLink(_ urlString: String) -> TransactionData? {
        guard let url = URL(string: urlString),
              url.scheme == "napasapp",
              url.host == "transaction" else {
            return nil
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var amount: String?
        var currency: String = "VND" // Default currency
        
        for item in queryItems {
            switch item.name {
            case "amount":
                amount = item.value
            case "currency":
                currency = item.value ?? "VND"
            default:
                break
            }
        }
        
        guard let transactionAmount = amount else {
            return nil
        }
        
        return TransactionData(amount: transactionAmount, currency: currency, fullURL: urlString)
    }
}