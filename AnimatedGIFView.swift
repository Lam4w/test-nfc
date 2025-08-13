import SwiftUI
import WebKit

// MARK: - Animated GIF View using WebKit

struct AnimatedGIFView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        
        if let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let gifData = NSData(contentsOfFile: gifPath) {
            
            webView.load(
                gifData as Data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: Bundle.main.bundleURL
            )
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed
    }
}

// MARK: - Alternative Simple GIF View (if WebKit doesn't work)

struct SimpleGIFView: View {
    let gifName: String
    @State private var isAnimating = false
    
    var body: some View {
        Image(gifName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .animation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
