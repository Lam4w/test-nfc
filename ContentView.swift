import SwiftUI
import CoreNFC

struct ContentView: View {
    @State private var showAmountView = false
    @State private var transactionAmount: String = ""
    @State private var nfcError: String?

    var body: some View {
        NavigationView {
            VStack {
                Button("Scan NFC Tag") {
                    NFCManager.shared.beginScanning { result in
                        switch result {
                        case .success(let amount):
                            transactionAmount = amount
                            showAmountView = true
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
                    destination: AmountView(amount: transactionAmount),
                    isActive: $showAmountView
                ) { EmptyView() }
            }
            .navigationTitle("NFC Demo")
        }
    }
}

struct AmountView: View {
    let amount: String
    var body: some View {
        VStack {
            Text("Transaction Amount")
                .font(.headline)
            Text(amount)
                .font(.largeTitle)
                .padding()
        }
    }
}