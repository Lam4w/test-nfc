import SwiftUI
import CoreNFC

struct ContentView: View {
    @State private var showTransactionView = false
    @State private var transactionData: TransactionData?
    @State private var nfcError: String?

    var body: some View {
        NavigationView {
            VStack {
                Button("Scan NFC Tag") {
                    NFCManager.shared.beginScanning { result in
                        switch result {
                        case .success(let data):
                            transactionData = data
                            showTransactionView = true
                        case .failure(let error):
                            nfcError = error.localizedDescription
                        }
                    }
                }
                .padding()
                if let error = nfcError {
                    Text("Error: \(error)").foregroundColor(.red)
                }
                NavigationLink(
                    destination: TransactionView(transactionData: transactionData),
                    isActive: $showTransactionView
                ) { EmptyView() }
            }
            .navigationTitle("NFC Demo")
        }
    }
}

struct TransactionView: View {
    let transactionData: TransactionData?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Transaction Details")
                .font(.title)
                .fontWeight(.bold)
            
            if let data = transactionData {
                VStack(spacing: 10) {
                    HStack {
                        Text("Amount:")
                            .font(.headline)
                        Spacer()
                        Text(data.amount)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Currency:")
                            .font(.headline)
                        Spacer()
                        Text(data.currency)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Deep Link URL:")
                            .font(.headline)
                        Text(data.fullURL)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            } else {
                Text("No transaction data available")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
}