import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    var onUniversalLink: (([String: String]?) -> Void)?

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard let url = userActivity.webpageURL,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            onUniversalLink?(nil)
            return false
        }

        var extracted: [String: String] = [:]
        for item in queryItems {
            if ["data", "signature", "cert"].contains(item.name) {
                extracted[item.name] = item.value ?? ""
            }
        }

        onUniversalLink?(extracted.isEmpty ? nil : extracted)
        return true
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var universalLinkParams: [String: String]? = nil

    init() {
        appDelegate.onUniversalLink = { params in
            DispatchQueue.main.async {
                universalLinkParams = params
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(universalLinkParams: universalLinkParams)
        }
    }
}