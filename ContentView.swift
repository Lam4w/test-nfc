import SwiftUI
import CoreNFC

struct ContentView: View {
    @State private var showTransactionView = false
    @State private var showEnterAmountView = false
    @State private var showPaymentSuccessView = false
    @State private var transactionData: TransactionData?
    @State private var nfcError: String?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                Button("Scan NFC Tag") {
                    NFCManager.shared.beginScanning { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let data):
                                handleNfcData(data: data)
                            case .failure(let error):
                                showError(message: error.localizedDescription)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if let error = nfcError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                // Navigation Links
                NavigationLink(
                    destination: TransactionDetailsView(
                        transactionData: transactionData,
                        onConfirm: {
                            showTransactionView = false
                            showPaymentSuccessView = true
                        }
                    ),
                    isActive: $showTransactionView
                ) { EmptyView() }
                
                NavigationLink(
                    destination: EnterAmountView(
                        onAmountEntered: { amount in
                            showEnterAmountView = false
                            let manualTransactionData = TransactionData(
                                amount: amount,
                                currency: "VND",
                                fullURL: "manual://transaction?amount=\(amount)"
                            )
                            handleTransactionAmount(data: manualTransactionData)
                        }
                    ),
                    isActive: $showEnterAmountView
                ) { EmptyView() }
                
                NavigationLink(
                    destination: PaymentSuccessView(transactionData: transactionData),
                    isActive: $showPaymentSuccessView
                ) { EmptyView() }
            }
            .navigationTitle("NFC Payment")
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - NFC Data Handling
    
    private func handleNfcData(data: TransactionData) {
        // Data validation
        guard !data.amount.isEmpty else {
            showError(message: "Invalid NFC data: Missing transaction amount")
            return
        }
        
        // Validate amount is numeric
        guard Double(data.amount) != nil else {
            showError(message: "Invalid NFC data: Transaction amount is not a valid number")
            return
        }
        
        // Store transaction data
        transactionData = data
        
        // Check if amount exists and process
        if !data.amount.isEmpty {
            handleTransactionAmount(data: data)
        } else {
            // No amount in NFC data, show enter amount screen
            showEnterAmountView = true
        }
    }
    
    private func handleTransactionAmount(data: TransactionData) {
        guard let amount = Double(data.amount) else {
            showError(message: "Invalid amount format")
            return
        }
        
        if amount < 200000 {
            // Amount < 200,000 → Navigate directly to Payment Success
            showPaymentSuccessView = true
        } else {
            // Amount > 200,000 → Show Transaction Details for confirmation
            showTransactionView = true
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        nfcError = message
        showErrorAlert = true
    }
}

// MARK: - Transaction Details View (for amounts > 200,000)

struct TransactionDetailsView: View {
    let transactionData: TransactionData?
    let onConfirm: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Transaction Confirmation")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please confirm the transaction details")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let data = transactionData {
                VStack(spacing: 20) {
                    // Amount display
                    VStack(spacing: 10) {
                        Text("Transaction Amount")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(data.amount)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(data.currency)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Additional details
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Currency:")
                                .font(.headline)
                            Spacer()
                            Text(data.currency)
                                .font(.body)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Source:")
                                .font(.headline)
                            Text(data.fullURL)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button("Confirm Payment") {
                    onConfirm()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .font(.headline)
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Confirm Payment")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Enter Amount View (when NFC has no amount)

struct EnterAmountView: View {
    @State private var enteredAmount: String = ""
    let onAmountEntered: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Enter Amount")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please enter the transaction amount")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 20) {
                HStack {
                    TextField("0", text: $enteredAmount)
                        .keyboardType(.decimalPad)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                    
                    Text("VND")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                Text("Minimum amount: 1 VND")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button("Continue") {
                    if !enteredAmount.isEmpty, Double(enteredAmount) != nil {
                        onAmountEntered(enteredAmount)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(enteredAmount.isEmpty || Double(enteredAmount) == nil ? Color(.systemGray4) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .font(.headline)
                .disabled(enteredAmount.isEmpty || Double(enteredAmount) == nil)
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Enter Amount")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Payment Success View

struct PaymentSuccessView: View {
    let transactionData: TransactionData?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("Payment Successful!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            if let data = transactionData {
                VStack(spacing: 20) {
                    Text("Transaction Details")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Amount:")
                                .font(.headline)
                            Spacer()
                            HStack {
                                Text(data.amount)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text(data.currency)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Status:")
                                .font(.headline)
                            Spacer()
                            Text("Completed")
                                .font(.body)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Transaction ID:")
                                .font(.headline)
                            Spacer()
                            Text("TXN\(Int.random(in: 100000...999999))")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
            }
            
            Spacer()
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .font(.headline)
        }
        .padding()
        .navigationTitle("Payment Complete")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}