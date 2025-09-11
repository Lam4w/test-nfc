import SwiftUI

struct ContentView: View {
    @State private var parameters: [String: String] = [:]

    var body: some View {
        VStack(spacing: 20) {
            Text("BlueTap Universal Link Handler")
                .font(.headline)

            if parameters.isEmpty {
                Text("No parameters received yet")
                    .foregroundColor(.gray)
            } else {
                List(parameters.keys.sorted(), id: \.self) { key in
                    HStack {
                        Text(key)
                            .fontWeight(.bold)
                        Spacer()
                        Text(parameters[key] ?? "")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUniversalLink)
    }

    private func handleUniversalLink(_ userActivity: NSUserActivity) {
        guard let inputURL = userActivity.webpageURL else {
            print("No URL found in userActivity")
            return
        }

        print("Incoming Universal Link: \(inputURL)")

        // Break the URL into components
        guard let components = URLComponents(url: inputURL, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            print("No query items in URL")
            return
        }

        // Convert query items to dictionary
        var extractedParams: [String: String] = [:]
        for item in queryItems {
            extractedParams[item.name] = item.value ?? ""
        }

        // Store in state for UI
        self.parameters = extractedParams
    }
}
