import SwiftUI

struct ContentView: View {
    @State private var receivedURL: URL?
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Universal Link Handler")
                .font(.title)
            
            if let url = receivedURL {
                Text("Received URL:")
                    .font(.headline)
                Text(url.absoluteString)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Button("Open External Universal Link") {
                // Ví dụ mở một universal link
                openUniversalLink()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .onAppear {
            // Có thể trigger một universal link khi view xuất hiện
            // openUniversalLink()
        }
        .onOpenURL { url in
            // Xử lý khi app nhận universal link
            handleIncomingURL(url)
        }
        .alert("URL Received", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text("App đã nhận được Universal Link")
        }
    }
    
    private func openUniversalLink() {
        // Ví dụ universal link - thay thế bằng domain của bạn
        guard let url = URL(string: "https://yourapp.com/deeplink/action") else {
            return
        }
        
        // iOS sẽ thực hiện logic sau khi UIApplication.shared.open được gọi:
        // 1. Check tất cả installed apps có declare domain "yourapp.com"
        // 2. Build list of matching handlers
        // 3. Choose UX:
        //    - Nếu chỉ có 1 app match -> mở app đó trực tiếp
        //    - Nếu multiple apps match -> hiện chooser/action sheet
        
        UIApplication.shared.open(url) { success in
            if success {
                print("Universal link opened successfully")
            } else {
                print("Failed to open universal link")
                // Fallback: có thể mở Safari hoặc App Store
                handleUniversalLinkFallback(url)
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        print("Received universal link: \(url.absoluteString)")
        receivedURL = url
        showAlert = true
        
        // Parse URL để xử lý logic cụ thể
        parseAndHandleURL(url)
    }
    
    private func parseAndHandleURL(_ url: URL) {
        guard let host = url.host else { return }
        
        // Xử lý theo path/query parameters
        let pathComponents = url.pathComponents
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        
        switch host {
        case "yourapp.com":
            if pathComponents.contains("deeplink") {
                handleDeeplinkAction(url: url, queryItems: queryItems)
            }
        default:
            print("Unknown host: \(host)")
        }
    }
    
    private func handleDeeplinkAction(url: URL, queryItems: [URLQueryItem]?) {
        // Xử lý deeplink cụ thể
        print("Handling deeplink action")
        
        // Ví dụ: extract parameters
        if let actionParam = queryItems?.first(where: { $0.name == "action" })?.value {
            print("Action: \(actionParam)")
        }
        
        if let userIdParam = queryItems?.first(where: { $0.name == "userId" })?.value {
            print("User ID: \(userIdParam)")
        }
        
        // Navigate to specific screen based on URL
        // NavigationLink hoặc programmatic navigation
    }
    
    private func handleUniversalLinkFallback(_ url: URL) {
        // Fallback khi không có app nào handle được universal link
        // Có thể redirect đến App Store hoặc web version
        
        if let fallbackURL = URL(string: "https://apps.apple.com/app/your-app-id") {
            UIApplication.shared.open(fallbackURL)
        }
    }
}

// MARK: - App Delegate Setup (for UIKit integration)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                    continue userActivity: NSUserActivity,
                    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // Xử lý Universal Link thông qua NSUserActivity
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            
            print("Received universal link via NSUserActivity: \(url.absoluteString)")
            
            // Post notification để SwiftUI view có thể handle
            NotificationCenter.default.post(
                name: NSNotification.Name("UniversalLinkReceived"),
                object: url
            )
            
            return true
        }
        
        return false
    }
}

// MARK: - App Structure
@main
struct UniversalLinkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Associated Domains Configuration
/*
 Để Universal Links hoạt động, bạn cần:

 1. Thêm vào Info.plist:
 <key>com.apple.developer.associated-domains</key>
 <array>
     <string>applinks:yourapp.com</string>
     <string>applinks:www.yourapp.com</string>
 </array>

 2. Tạo file apple-app-site-association trên server:
 {
     "applinks": {
         "details": [
             {
                 "appIDs": ["TEAMID.com.yourcompany.yourapp"],
                 "components": [
                     {
                         "/": "/deeplink/*",
                         "comment": "Matches any URL with path starting with /deeplink/"
                     }
                 ]
             }
         ]
     }
 }

 3. Host file tại: https://yourapp.com/.well-known/apple-app-site-association
    (không có file extension, content-type: application/json)

 iOS Logic khi mở Universal Link:
 - iOS scan tất cả installed apps có associated domains matching
 - Build list of eligible handlers
 - Nếu chỉ có 1 app: mở trực tiếp
 - Nếu nhiều apps: hiện action sheet cho user chọn
 - User có thể set default app choice
*/