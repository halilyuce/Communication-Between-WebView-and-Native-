//
//  ContentView.swift
//  Web2Swift
//
//  Created by Halil İbrahim YÜCE on 11.03.2020.
//  Copyright © 2020 Halil İbrahim YÜCE. All rights reserved.
//

import SwiftUI
import WebKit
  
struct WebView: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        let userContentController = WKUserContentController()

        userContentController.add(context.coordinator, name:"observer")

        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        DispatchQueue.main.async {
            if let filePath = Bundle.main.url(forResource: "index", withExtension: "html") {
              let request = NSURLRequest(url: filePath)
              webView.load(request as URLRequest)
            }
        }
        return webView
    }
  
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
  
    typealias UIViewType = WKWebView
}

struct ContentView : View {
    var body: some View {
        WebView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    
    var control: WebView
    
    init(_ control: WebView) {
        self.control = control
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        showAlert(body: message.body)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let name = UIDevice.current.name
        let systemVersion = UIDevice.current.systemVersion

        let javaScriptString = "device('\(name)', '\(systemVersion)');"
        webView.evaluateJavaScript(javaScriptString, completionHandler: nil)
    }
    
    func showAlert(body: Any) {
        let content = "\(body)"
        let alertController = UIAlertController(title: "Trigger", message: content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        let window = UIApplication.shared.windows.first
        window?.rootViewController?.present(alertController, animated: true)
    }
    
}
