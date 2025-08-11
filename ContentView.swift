import SwiftUI
import CoreNFC

struct ContentView: View {
    @StateObject private var viewModel = PaymentViewModel()
    @State private var showNFCTapView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Original NFC Scan button
                Button("Scan NFC Tag") {
                    viewModel.startNFCScanning()
                }
                .padding()
                .background(viewModel.isProcessing ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.isProcessing)
                
                // New NFC Tap button
                Button("NFC Tap") {
                    showNFCTapView = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                if viewModel.isProcessing {
                    ProgressView("Scanning...")
                        .padding()
                }
                
                if let error = viewModel.nfcError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                // Navigation Links
                NavigationLink(
                    destination: NFCTapView(viewModel: viewModel),
                    isActive: $showNFCTapView
                ) { EmptyView() }
                
                NavigationLink(
                    destination: TransactionDetailsView(
                        transactionData: viewModel.transactionData,
                        onConfirm: {
                            viewModel.confirmTransaction()
                        }
                    ),
                    isActive: $viewModel.showTransactionView
                ) { EmptyView() }
                
                NavigationLink(
                    destination: EnterAmountView(
                        onAmountEntered: { amount in
                            viewModel.handleManualAmount(amount)
                        }
                    ),
                    isActive: $viewModel.showEnterAmountView
                ) { EmptyView() }
                
                NavigationLink(
                    destination: PaymentSuccessView(transactionData: viewModel.transactionData),
                    isActive: $viewModel.showPaymentSuccessView
                ) { EmptyView() }
            }
            .navigationTitle("NFC Payment")
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") { 
                    viewModel.clearErrors()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Transaction Details View (for amounts > 200,000)

struct TransactionDetailsView: View {
    let transactionData: ParsedTransactionData?
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
                        
                        if !data.tlvData.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Transaction Tags:")
                                    .font(.headline)
                                
                                ForEach(Array(data.tlvData.prefix(3)), id: \.key) { key, value in
                                    HStack {
                                        Text("Tag \(key):")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(value)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                }
                                
                                if data.tlvData.count > 3 {
                                    Text("... and \(data.tlvData.count - 3) more tags")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
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
    let transactionData: ParsedTransactionData?
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
                        
                        if !data.tlvData.isEmpty {
                            HStack {
                                Text("Data Source:")
                                    .font(.headline)
                                Spacer()
                                Text(data.originalData.hasPrefix("manual") ? "Manual Entry" : "NFC Tag")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
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