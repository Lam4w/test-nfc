import SwiftUI

// MARK: - Models
struct ConfiguredApp: Identifiable {
    let id = UUID()
    let bundleId: String
    let name: String
    let universalLinkURL: URL
    let customScheme: String?
    let appStoreId: String? // Optional App Store ID for fallback
}

// MARK: - View Model
@MainActor
class UniversalLinkAppDetector: ObservableObject {
    @Published var installedApps: [ConfiguredApp] = []
    @Published var isLoading = false
    
    // Your configured apps from AASA file
    private let configuredApps: [ConfiguredApp] = [
        ConfiguredApp(
            bundleId: "com.example.app1",
            name: "App 1",
            universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app1")!,
            customScheme: "app1://",
            appStoreId: "123456789"
        ),
        ConfiguredApp(
            bundleId: "com.example.app2",
            name: "App 2",
            universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app2")!,
            customScheme: "app2://",
            appStoreId: "123456790"
        ),
        ConfiguredApp(
            bundleId: "com.example.app3",
            name: "App 3",
            universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app3")!,
            customScheme: nil,
            appStoreId: "123456791"
        ),
        ConfiguredApp(
            bundleId: "com.example.app4",
            name: "App 4",
            universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app4")!,
            customScheme: "app4://",
            appStoreId: "123456792"
        ),
        ConfiguredApp(
            bundleId: "com.example.app5",
            name: "App 5",
            universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app5")!,
            customScheme: nil,
            appStoreId: "123456793"
        )
    ]
    
    var totalConfiguredApps: Int {
        configuredApps.count
    }
    
    // Check for installed apps
    func checkInstalledApps() {
        isLoading = true
        
        Task {
            let installed = await getInstalledApps()
            
            await MainActor.run {
                self.installedApps = installed
                self.isLoading = false
            }
        }
    }
    
    // Get list of installed apps
    private func getInstalledApps() async -> [ConfiguredApp] {
        return configuredApps.filter { app in
            isAppInstalled(app: app)
        }
    }
    
    // Check if a specific app is installed
    private func isAppInstalled(app: ConfiguredApp) -> Bool {
        // Method 1: Try custom scheme first (most reliable)
        if let customScheme = app.customScheme,
           let schemeURL = URL(string: customScheme) {
            if UIApplication.shared.canOpenURL(schemeURL) {
                return true
            }
        }
        
        // Method 2: Try universal link (less reliable for detection)
        if UIApplication.shared.canOpenURL(app.universalLinkURL) {
            return true
        }
        
        return false
    }
    
    // Method to open an app if installed, fallback to App Store if not
    func openApp(_ app: ConfiguredApp) {
        if isAppInstalled(app: app) {
            // Try custom scheme first
            if let customScheme = app.customScheme,
               let schemeURL = URL(string: customScheme) {
                UIApplication.shared.open(schemeURL)
            } else {
                // Fallback to universal link
                UIApplication.shared.open(app.universalLinkURL)
            }
        } else {
            // Open App Store page
            if let appStoreId = app.appStoreId {
                let appStoreURL = URL(string: "https://apps.apple.com/app/id\(appStoreId)")!
                UIApplication.shared.open(appStoreURL)
            }
        }
    }
}

// MARK: - Main View
struct UniversalLinkDetectorView: View {
    @StateObject private var detector = UniversalLinkAppDetector()
    @State private var showingInstalledApps = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HeaderView(
                    installedCount: detector.installedApps.count,
                    totalCount: detector.totalConfiguredApps
                )
                
                if detector.isLoading {
                    LoadingView()
                } else if detector.installedApps.isEmpty {
                    EmptyStateView()
                } else {
                    InstalledAppsListView(
                        apps: detector.installedApps,
                        onAppTap: detector.openApp
                    )
                }
                
                Spacer()
                
                ActionButtonsView(
                    onRefresh: detector.checkInstalledApps,
                    onShowAll: { showingInstalledApps = true },
                    isLoading: detector.isLoading
                )
            }
            .padding()
            .navigationTitle("My Apps")
            .onAppear {
                detector.checkInstalledApps()
            }
            .sheet(isPresented: $showingInstalledApps) {
                AllAppsSheet(detector: detector)
            }
        }
    }
}

// MARK: - Supporting Views
struct HeaderView: View {
    let installedCount: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Installed Apps")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("\(installedCount) of \(totalCount) apps installed")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Checking installed apps...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "app.badge")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No Compatible Apps Found")
                .font(.headline)
            
            Text("None of the configured apps are currently installed on this device.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct InstalledAppsListView: View {
    let apps: [ConfiguredApp]
    let onAppTap: (ConfiguredApp) -> Void
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(apps) { app in
                AppRowView(app: app) {
                    onAppTap(app)
                }
            }
        }
    }
}

struct AppRowView: View {
    let app: ConfiguredApp
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // App icon placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.gradient)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "app.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(app.bundleId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if app.customScheme != nil {
                        Label("Custom Scheme", systemImage: "link")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionButtonsView: View {
    let onRefresh: () -> Void
    let onShowAll: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onRefresh) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Refresh")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading)
            
            Button(action: onShowAll) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Show All Configured Apps")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Sheet View
struct AllAppsSheet: View {
    @ObservedObject var detector: UniversalLinkAppDetector
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(getAllConfiguredApps()) { app in
                    AppRowInSheet(
                        app: app,
                        isInstalled: detector.installedApps.contains { $0.id == app.id },
                        onTap: { detector.openApp(app) }
                    )
                }
            }
            .navigationTitle("All Configured Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getAllConfiguredApps() -> [ConfiguredApp] {
        return [
            ConfiguredApp(bundleId: "com.example.app1", name: "App 1", universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app1")!, customScheme: "app1://", appStoreId: "123456789"),
            ConfiguredApp(bundleId: "com.example.app2", name: "App 2", universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app2")!, customScheme: "app2://", appStoreId: "123456790"),
            ConfiguredApp(bundleId: "com.example.app3", name: "App 3", universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app3")!, customScheme: nil, appStoreId: "123456791"),
            ConfiguredApp(bundleId: "com.example.app4", name: "App 4", universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app4")!, customScheme: "app4://", appStoreId: "123456792"),
            ConfiguredApp(bundleId: "com.example.app5", name: "App 5", universalLinkURL: URL(string: "https://yourdomain.com/redirect?app=app5")!, customScheme: nil, appStoreId: "123456793")
        ]
    }
}

struct AppRowInSheet: View {
    let app: ConfiguredApp
    let isInstalled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(app.bundleId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if isInstalled {
                        Label("Installed", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Label("Not Installed", systemImage: "xmark.circle")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(isInstalled ? "Tap to Open" : "Tap for App Store")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - App Entry Point
@main
struct UniversalLinkApp: App {
    var body: some Scene {
        WindowGroup {
            UniversalLinkDetectorView()
        }
    }
}