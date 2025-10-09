import Foundation

struct VietQRGenerator {
    
    // MARK: - Field IDs
    private enum FieldID: String {
        case version = "00"
        case initMethod = "01"
        case vietQRInfo = "38"
        case category = "52"
        case currency = "53"
        case amount = "54"
        case tipAndFeeType = "55"
        case tipAndFeeAmount = "56"
        case tipAndFeePercent = "57"
        case nation = "58"
        case merchantName = "59"
        case city = "60"
        case additionalData = "62"
        case crc = "63"
    }
    
    private enum VietQRInfoID: String {
        case guid = "00"
        case beneficiary = "01"
        case service = "02"
    }
    
    private enum BeneficiaryInfoID: String {
        case bankBin = "00"
        case accountNumber = "01"
    }
    
    // MARK: - Main function
    static func generateQRString(
        bankBin: String,
        accountNumber: String,
        amount: String? = nil,
        message: String? = nil,
        isOneTimeQR: Bool = false
    ) -> String {
        var payload = ""
        
        // Version
        payload += buildField(id: FieldID.version.rawValue, value: "01")
        
        // Init method
        let initMethod = (isOneTimeQR || (amount != nil && (Int(amount!) ?? 0) > 0)) ? "11" : "12"
        payload += buildField(id: FieldID.initMethod.rawValue, value: initMethod)
        
        // VietQR Info
        let vietQRInfo = buildVietQRInfo(bankBin: bankBin, accountNumber: accountNumber)
        payload += buildField(id: FieldID.vietQRInfo.rawValue, value: vietQRInfo)
        
        // Category
        payload += buildField(id: FieldID.category.rawValue, value: "7070")
        
        // Currency (704 = VND)
        payload += buildField(id: FieldID.currency.rawValue, value: "704")
        
        // Amount
        if let amount = amount, !amount.isEmpty, Double(amount) ?? 0 > 0 {
            payload += buildField(id: FieldID.amount.rawValue, value: amount)
        }
        
        // Nation
        payload += buildField(id: FieldID.nation.rawValue, value: "VN")
        
        // Merchant Name (placeholder)
        payload += buildField(id: FieldID.merchantName.rawValue, value: "NA")
        
        // Additional data (message)
        if let message = message, !message.isEmpty {
            let normalizedMessage = "08" + formatLength(message.count) + removeAccent(message).uppercased()
            let additionalData = buildField(id: VietQRInfoID.service.rawValue, value: "QRIBFTTA") + normalizedMessage
            payload += buildField(id: FieldID.additionalData.rawValue, value: additionalData)
        }
        
        // CRC
        payload += FieldID.crc.rawValue + "04"
        let crc = calculateCRC16_CCITT(Array(payload.utf8))
        let crcHex = String(format: "%04X", crc)
        
        return payload + crcHex
    }
    
    // MARK: - Helpers
    
    private static func buildVietQRInfo(bankBin: String, accountNumber: String) -> String {
        let beneficiaryInfo = buildField(id: BeneficiaryInfoID.bankBin.rawValue, value: bankBin)
            + buildField(id: BeneficiaryInfoID.accountNumber.rawValue, value: accountNumber)
        
        return buildField(id: VietQRInfoID.guid.rawValue, value: "A000000727")
            + buildField(id: VietQRInfoID.beneficiary.rawValue, value: beneficiaryInfo)
            + buildField(id: VietQRInfoID.service.rawValue, value: "QRIBFTTA")
    }
    
    private static func buildField(id: String, value: String) -> String {
        guard !value.isEmpty else { return "" }
        let length = formatLength(value.count)
        return id + length + value
    }
    
    private static func formatLength(_ length: Int) -> String {
        return String(format: "%02d", length)
    }
    
    private static func removeAccent(_ input: String) -> String {
        let decomposed = input.folding(options: .diacriticInsensitive, locale: .current)
        return decomposed.replacingOccurrences(of: "đ", with: "d")
            .replacingOccurrences(of: "Đ", with: "D")
    }
    
    private static func calculateCRC16_CCITT(_ bytes: [UInt8]) -> Int {
        var crc = 0xFFFF
        let polynomial = 0x1021
        
        for b in bytes {
            for i in 0..<8 {
                let bit = ((Int(b) >> (7 - i)) & 1) == 1
                let c15 = ((crc >> 15) & 1) == 1
                crc <<= 1
                if c15 != bit {
                    crc ^= polynomial
                }
            }
        }
        return crc & 0xFFFF
    }
}

import SwiftUI

struct StatusView: View {
    @State private var isCheckingEnabled = true       // Biến flag
    @State private var checkingTask: Task<Void, Never>? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Toggle("Enable Checking", isOn: $isCheckingEnabled)
                .padding()
            
            Button("Stop Checking") {
                stopChecking()
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            startChecking()
        }
        .onDisappear {
            stopChecking()
        }
    }
    
    /// Bắt đầu interval loop
    private func startChecking() {
        // Không tạo trùng Task
        guard checkingTask == nil else { return }
        
        checkingTask = Task {
            while !Task.isCancelled {
                if isCheckingEnabled {
                    await getStatus()
                } else {
                    print("⚠️ Skipped because flag = false at \(Date())")
                }
                
                // Sleep 3 giây giữa các lần
                try? await Task.sleep(nanoseconds: 3_000_000_000)
            }
        }
    }
    
    /// Dừng interval
    private func stopChecking() {
        checkingTask?.cancel()
        checkingTask = nil
        print("🛑 Checking stopped.")
    }
    
    /// Hàm mô phỏng gọi API / xử lý
    private func getStatus() async {
        print("✅ getStatus() called at \(Date())")
        // Ví dụ async API:
        // let result = try await apiService.getStatus()
    }
}

import SwiftUI

struct TransferView: View {
    @State private var sourceAccount = "1016868016"
    @State private var balance = "60,279,197 VND"
    @State private var recipientBank = "Vietcombank - Ngân hàng TMCP Ngoại thương Việt Nam"
    @State private var recipientAccount = ""
    @State private var recipientName = ""
    @State private var amount = ""
    @State private var note = "NGUYEN TUNG LAM chuyen tien"
    @State private var saveRecipient = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                HStack {
                    Text("Chuyển tiền trong nước")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.top)
                
                // MARK: - Source Account
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tài khoản nguồn")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(sourceAccount)
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        Spacer()
                        Text(balance)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // MARK: - Recipient Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Thông tin người nhận")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ngân hàng nhận")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Chọn ngân hàng", text: $recipientBank)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tài khoản/thẻ nhận")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Nhập số tài khoản", text: $recipientAccount)
                            .padding()
                            .keyboardType(.numberPad)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tên người nhận")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Nhập tên người nhận", text: $recipientName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    Toggle("Lưu người nhận", isOn: $saveRecipient)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                
                Divider()
                
                // MARK: - Transaction Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Thông tin giao dịch")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Số tiền")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Nhập số tiền", text: $amount)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Nội dung")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Nhập nội dung chuyển khoản", text: $note)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                // MARK: - Continue Button
                Button(action: {
                    print("Chuyển tiền tiếp tục")
                }) {
                    Text("Tiếp tục")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .padding(.top)
                
            }
            .padding()
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    TransferView()
}
