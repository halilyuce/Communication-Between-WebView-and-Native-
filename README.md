# Communication Between WebView and Native
Making Native iOS(Swift) interacting with Web App

You can learn how to trigger your javascript function from native iOS application thanks to this tutorial.

What will you learn from this tutorial ?

* How to pass any type of data to both side
* How to run any events or functions

### You can click to the image below for watch tutorial on Youtube

[![TUTORIAL ON YOUTUBE](http://img.youtube.com/vi/OqpDrKRQ4bY/0.jpg)](http://www.youtube.com/watch?v=OqpDrKRQ4bY)

### 1) Create a HTML File
```html
<!DOCTYPE html>
<html>
<head>
<title>Page Title</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<h1 id="name">Model</h1>
<p id="version">System Version</p>
<input type="button" onclick="trigger()" value="Trigger">
</body>
<script>
    function device(name, version) {
        document.getElementById("name").innerHTML = name;
        document.getElementById("version").innerHTML = version;
    }
    function trigger() {
        window.webkit.messageHandlers.observer.postMessage("trigger from JS");
    }
</script>
</html>
```

### 2) Define an UIViewRepresentable and Coordinator for WebView
```swift
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
```

### 3) Create Coordinator Class for Use Delegate Functions
```swift
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
```

Yeah, that's it ! :) I hope you understand clearly all. Feel free to ask anything :)
