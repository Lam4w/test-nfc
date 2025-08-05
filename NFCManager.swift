import Foundation
import CoreNFC

class NFCManager: NSObject, NFCNDEFReaderSessionDelegate {
    static let shared = NFCManager()
    private var completion: ((Result<String, Error>) -> Void)?

    func beginScanning(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session.alertMessage = "Hold your iPhone near the NFC tag."
        session.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        completion?(.failure(error))
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first,
              let payloadString = String(data: record.payload, encoding: .utf8) else {
            completion?(.failure(NSError(domain: "NFC", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid NFC data"])))
            return
        }
        // Example: "amount:123.45"
        if let amount = payloadString.components(separatedBy: "amount:").last?.trimmingCharacters(in: .whitespacesAndNewlines) {
            completion?(.success(amount))
        } else {
            completion?(.failure(NSError(domain: "NFC", code: 1, userInfo: [NSLocalizedDescriptionKey: "Amount not found"])))
        }
    }
}