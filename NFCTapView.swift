import SwiftUI

// MARK: - NFC Tap View

struct NFCTapView: View {
    @ObservedObject var viewModel: PaymentViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            Text("NFC Ready")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // NFC Icon or animation
            Image(systemName: "wave.3.right.circle.fill")
                .font(.system(size: 120))
                .foregroundColor(.blue)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("Hold your device near an NFC tag")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Status information
            VStack(spacing: 15) {
                if viewModel.isProcessing {
                    ProgressView("Scanning for NFC tag...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.2)
                } else {
                    Text("Ready to scan")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                if let error = viewModel.nfcError {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button("Start NFC Scan") {
                    viewModel.startNFCScanning()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isProcessing ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.isProcessing)
                
                Button("Cancel") {
                    viewModel.resetNavigationState()
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
        .navigationTitle("NFC Tap")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Automatically trigger NFC scanning when view appears
            viewModel.startNFCScanning()
        }
        .onDisappear {
            // Clear any errors when leaving the view
            viewModel.clearErrors()
        }
        // Navigation links for the payment flow
        .background(
            Group {
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
        )
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK") { 
                viewModel.clearErrors()
            }
            Button("Try Again") {
                viewModel.clearErrors()
                viewModel.startNFCScanning()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
